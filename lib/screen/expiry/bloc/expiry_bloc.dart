// lib/screen/expiry/bloc/expiry_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:saleup_app/core/network/dio_client.dart';
import 'package:saleup_app/model/expiry_response.dart';
import 'package:dio/dio.dart' as dio;
import 'expiry_event.dart';
import 'expiry_state.dart';

class ExpiryBloc extends Bloc<ExpiryEvent, ExpiryState> {
  ExpiryBloc() : super(const ExpiryState()) {
    on<FetchExpiry>(_onFetch);
    on<SearchExpiry>(_onSearch);
    on<ToggleProductFilter>(_onProductFilter);
    on<SetPriceSort>(_onPriceSort);
    on<SetQuantitySort>(_onQuantitySort);
    on<ClearFilters>(_onClearFilters);
    on<GoToPage>(_onGoToPage);
    on<DeleteExpiry>(_onDelete);
  }

  Future<void> _onFetch(FetchExpiry event, Emitter<ExpiryState> emit) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      final response = await DioClient().dio.get('/expiry/get_expiries/');
      final expiryResponse = ExpiryResponse.fromJson(response.data);
      if (expiryResponse.success) {
        emit(state.copyWith(
          isLoading: false,
          expiryData: expiryResponse.data ?? [],
          errorMessage: null,
        ));
      } else {
        emit(state.copyWith(
          isLoading: false,
          errorMessage: expiryResponse.message ?? 'Failed to fetch',
        ));
      }
    } on dio.DioException catch (e) {
      String errorMessage = 'Network error: ${e.message}';
      if (e.response != null && e.response!.statusCode == 400) {
        errorMessage = e.response!.data['message'] ?? 'Authentication failed';
      } else if (e.response != null) {
        errorMessage = 'Server error: ${e.response!.statusCode}';
      }
      emit(state.copyWith(isLoading: false, errorMessage: errorMessage));
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: 'Error: $e'));
    }
  }

  void _onSearch(SearchExpiry event, Emitter<ExpiryState> emit) {
    emit(state.copyWith(searchQuery: event.query, currentPage: 1));
  }

  void _onProductFilter(ToggleProductFilter event, Emitter<ExpiryState> emit) {
    emit(state.copyWith(selectedProduct: event.product, currentPage: 1));
  }

  void _onPriceSort(SetPriceSort event, Emitter<ExpiryState> emit) {
    emit(state.copyWith(
      priceSort: event.direction,
      quantitySort: null, // Only one sort active
      currentPage: 1,
    ));
  }

  void _onQuantitySort(SetQuantitySort event, Emitter<ExpiryState> emit) {
    emit(state.copyWith(
      quantitySort: event.direction,
      priceSort: null, // Only one sort active
      currentPage: 1,
    ));
  }

  void _onClearFilters(ClearFilters event, Emitter<ExpiryState> emit) {
    emit(state.copyWith(
      selectedProduct: null,
      priceSort: null,
      quantitySort: null,
      currentPage: 1,
    ));
  }

  void _onGoToPage(GoToPage event, Emitter<ExpiryState> emit) {
    final filtered = state.getFilteredData();
    final totalPages =
        (filtered.length / state.itemsPerPage).ceil().clamp(1, 999);
    emit(state.copyWith(currentPage: event.page.clamp(1, totalPages)));
  }

  Future<void> _onDelete(DeleteExpiry event, Emitter<ExpiryState> emit) async {
    try {
      await DioClient().dio.delete('/expiry/delete_expiry/${event.id}/');
      final updated = state.expiryData.where((e) => e.id != event.id).toList();
      emit(state.copyWith(expiryData: updated));
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Delete failed: $e'));
    }
  }
}
