import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:saleup_app/core/network/dio_client.dart';
import 'package:saleup_app/model/unit_response.dart';
import 'package:saleup_app/screen/units/bloc/unit_event.dart';
import 'package:saleup_app/screen/units/bloc/unit_state.dart';
import 'package:dio/dio.dart' as dio;

class UnitBloc extends Bloc<UnitEvent, UnitState> {
  UnitBloc() : super(const UnitState()) {
    on<FetchUnits>(_onFetchUnits);
    on<SearchUnits>(_onSearchUnits);
    on<GoToPage>(_onGoToPage);
  }

  Future<void> _onFetchUnits(FetchUnits event, Emitter<UnitState> emit) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      final response = await DioClient().dio.get('/unit/get_units/');
      if (response.data is! Map<String, dynamic>) {
        emit(state.copyWith(
          isLoading: false,
          errorMessage: 'Invalid API response format',
        ));
        return;
      }
      final unitResponse = UnitResponse.fromJson(response.data);

      if (unitResponse.success == true) {
        emit(state.copyWith(
          isLoading: false,
          units: unitResponse.data,
          totalItems: unitResponse.data.length,
          errorMessage: null,
        ));
      } else {
        emit(state.copyWith(
          isLoading: false,
          errorMessage: unitResponse.message ?? 'Failed to fetch units',
        ));
      }
    } on dio.DioException catch (e) {
      String errorMessage = 'Network error: ${e.message}';
      if (e.response != null) {
        errorMessage =
            'Server error: ${e.response!.statusCode} - ${e.response!.data}';
      } else if (e.type == dio.DioExceptionType.connectionTimeout) {
        errorMessage = 'Connection timed out. Please check your internet.';
      }
      emit(state.copyWith(
        isLoading: false,
        errorMessage: errorMessage,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to parse units: $e',
      ));
    }
  }

  void _onSearchUnits(SearchUnits event, Emitter<UnitState> emit) {
    emit(state.copyWith(
      searchQuery: event.query,
      currentPage: 1,
    ));
  }

  void _onGoToPage(GoToPage event, Emitter<UnitState> emit) {
    final totalPages =
        (state.getFilteredData().length / state.itemsPerPage).ceil();
    final newPage = event.page.clamp(1, totalPages);
    emit(state.copyWith(currentPage: newPage));
  }
}
