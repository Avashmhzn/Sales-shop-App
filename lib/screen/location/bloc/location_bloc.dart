import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:saleup_app/core/network/dio_client.dart';
import 'package:saleup_app/model/location_response.dart';
import 'package:dio/dio.dart' as dio;
import 'package:saleup_app/screen/location/bloc/location_event.dart';
import 'package:saleup_app/screen/location/bloc/location_state.dart';

class LocationBloc extends Bloc<LocationEvent, LocationState> {
  LocationBloc() : super(const LocationState()) {
    on<FetchLocations>(_onFetchLocations);
    on<SearchLocations>(_onSearchLocations);
    on<GoToPage>(_onGoToPage);
  }

  Future<void> _onFetchLocations(
      FetchLocations event, Emitter<LocationState> emit) async {
    print('Fetching locations');
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      final response = await DioClient().dio.get('/location/get_locations/');
      print('API response (raw): ${response.data}');
      if (response.data is! Map<String, dynamic>) {
        print(
            'Error: API response is not a Map<String, dynamic>: ${response.data.runtimeType}');
        emit(state.copyWith(
          isLoading: false,
          errorMessage: 'Invalid API response format',
        ));
        return;
      }
      final locationResponse = LocationResponse.fromJson(response.data);
      print('Parsed LocationResponse: success=${locationResponse.success}, '
          'message=${locationResponse.message}, '
          'dataLength=${locationResponse.data.length}, '
          'data=${locationResponse.data.map((l) => 'id=${l.id}, name=${l.name}').toList()}');

      if (locationResponse.success == true) {
        emit(state.copyWith(
          isLoading: false,
          locations: locationResponse.data,
          totalItems: locationResponse.total ?? locationResponse.data.length,
          errorMessage: null,
        ));
      } else {
        print('API failed: message=${locationResponse.message}');
        emit(state.copyWith(
          isLoading: false,
          errorMessage: locationResponse.message ?? 'Failed to fetch locations',
        ));
      }
    } on dio.DioException catch (e) {
      String errorMessage = 'Network error: ${e.message}';
      if (e.response != null) {
        errorMessage =
            'Server error: ${e.response!.statusCode} - ${e.response!.data}';
        if (e.response!.statusCode == 401) {
          print('401 Unauthorized: Attempting token refresh');
          final dioClient = DioClient();
          final refreshed = await dioClient.refreshToken();
          if (refreshed) {
            print('Token refreshed, retrying fetch');
            return await _onFetchLocations(event, emit); // Retry the fetch
          } else {
            errorMessage = 'Authentication failed. Please log in again.';
          }
        }
      } else if (e.type == dio.DioExceptionType.connectionTimeout) {
        errorMessage = 'Connection timed out. Please check your internet.';
      }
      print('Dio error: $errorMessage');
      emit(state.copyWith(
        isLoading: false,
        errorMessage: errorMessage,
      ));
    } catch (e, stackTrace) {
      print('Unexpected error in fetchLocations: $e, stackTrace: $stackTrace');
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to parse locations: $e',
      ));
    }
  }

  void _onSearchLocations(SearchLocations event, Emitter<LocationState> emit) {
    print('Search query updated: ${event.query}');
    emit(state.copyWith(
      searchQuery: event.query,
      currentPage: 1,
    ));
  }

  void _onGoToPage(GoToPage event, Emitter<LocationState> emit) {
    print('Navigating to page: ${event.page}');
    final totalPages =
        (state.getFilteredData().length / state.itemsPerPage).ceil();
    final newPage = event.page.clamp(1, totalPages);
    emit(state.copyWith(currentPage: newPage));
  }
}
