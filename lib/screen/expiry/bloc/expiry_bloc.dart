import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:saleup_app/core/network/dio_client.dart';
import 'package:saleup_app/model/expiry_response.dart';
import 'package:saleup_app/screen/expiry/bloc/expiry_event.dart';
import 'package:saleup_app/screen/expiry/bloc/expiry_state.dart';
import 'package:dio/dio.dart' as dio;

class ExpiryBloc extends Bloc<ExpiryEvent, ExpiryState> {
  ExpiryBloc() : super(const ExpiryState()) {
    on<FetchExpiry>(_onFetchExpiry);
    on<SortExpiry>(_onSortExpiry);
    on<ApplyFilters>(_onApplyFilters);
    on<GoToPage>(_onGoToPage);
    on<SearchExpiry>(_onSearchExpiry);
  }

  Future<void> _onFetchExpiry(
      FetchExpiry event, Emitter<ExpiryState> emit) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      final response = await DioClient().dio.get('/expiry/get_expiries/');
      print('Parsed Response: ${response.data}');
      if (response.data is! Map<String, dynamic>) {
        emit(state.copyWith(
          isLoading: false,
          errorMessage: 'Invalid API response format',
        ));
        return;
      }
      final expiryResponse = ExpiryResponse.fromJson(response.data);
      print('Parsed ExpiryData: ${expiryResponse.data}');

      if (expiryResponse.success) {
        emit(state.copyWith(
          isLoading: false,
          expiryData: expiryResponse.data,
          totalItems: expiryResponse.data.length,
          errorMessage: null,
        ));
      } else {
        emit(state.copyWith(
          isLoading: false,
          errorMessage: expiryResponse.message ?? 'Failed to fetch expiry data',
        ));
      }
    } on dio.DioException catch (e) {
      String errorMessage = 'Network error: ${e.message}';
      if (e.response != null && e.response!.statusCode == 400) {
        errorMessage = e.response!.data['message'] ?? 'Authentication failed';
      } else if (e.response != null) {
        errorMessage =
            'Server error: ${e.response!.statusCode} - ${e.response!.data}';
      }
      emit(state.copyWith(isLoading: false, errorMessage: errorMessage));
    } catch (e) {
      emit(state.copyWith(
          isLoading: false, errorMessage: 'Failed to parse expiry data: $e'));
      print('Parsing Error: $e');
    }
  }

  void _onSortExpiry(SortExpiry event, Emitter<ExpiryState> emit) {
    var updatedTempCriteria = Map<String, String>.from(state.tempSortCriteria);
    if (event.remove) {
      updatedTempCriteria.remove(event.category);
    } else {
      updatedTempCriteria[event.category] = event.value;
    }
    emit(state.copyWith(tempSortCriteria: updatedTempCriteria));
  }

  void _onApplyFilters(ApplyFilters event, Emitter<ExpiryState> emit) {
    emit(state.copyWith(
      sortCriteria: Map<String, String>.from(state.tempSortCriteria),
      currentPage: 1,
    ));
  }

  void _onGoToPage(GoToPage event, Emitter<ExpiryState> emit) {
    final totalPages =
        (state.getFilteredData().length / state.itemsPerPage).ceil();
    final newPage = event.page.clamp(1, totalPages);
    emit(state.copyWith(currentPage: newPage));
  }

  void _onSearchExpiry(SearchExpiry event, Emitter<ExpiryState> emit) {
    emit(state.copyWith(
      searchQuery: event.query,
      currentPage: 1,
    ));
  }
}
