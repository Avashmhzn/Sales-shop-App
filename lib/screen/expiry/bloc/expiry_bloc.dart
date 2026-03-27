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
    on<DeleteAllExpiry>(_onDeleteAll);
    on<UpdateExpiry>(_onUpdate);
  }

  // ── Fetch ──────────────────────────────────────────────────────────────
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
      emit(state.copyWith(
        isLoading: false,
        errorMessage: _dioError(e),
      ));
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: 'Error: $e'));
    }
  }

  // ── Search ─────────────────────────────────────────────────────────────
  void _onSearch(SearchExpiry event, Emitter<ExpiryState> emit) {
    emit(state.copyWith(searchQuery: event.query, currentPage: 1));
  }

  // ── Filters ────────────────────────────────────────────────────────────
  void _onProductFilter(ToggleProductFilter event, Emitter<ExpiryState> emit) {
    emit(state.copyWith(selectedProduct: event.product, currentPage: 1));
  }

  void _onPriceSort(SetPriceSort event, Emitter<ExpiryState> emit) {
    emit(state.copyWith(
      priceSort: event.direction,
      quantitySort: null,
      currentPage: 1,
    ));
  }

  void _onQuantitySort(SetQuantitySort event, Emitter<ExpiryState> emit) {
    emit(state.copyWith(
      quantitySort: event.direction,
      priceSort: null,
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

  // ── Delete single ──────────────────────────────────────────────────────
  Future<void> _onDelete(DeleteExpiry event, Emitter<ExpiryState> emit) async {
    try {
      await DioClient().dio.delete('/expiry/delete_expiry/${event.id}/');
      final updated = state.expiryData.where((e) => e.id != event.id).toList();
      emit(state.copyWith(expiryData: updated));
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Delete failed: $e'));
    }
  }

  // ── Delete all (selected ids) ──────────────────────────────────────────
  Future<void> _onDeleteAll(
      DeleteAllExpiry event, Emitter<ExpiryState> emit) async {
    try {
      await DioClient().dio.delete(
        '/expiry/delete_expiries/',
        data: {'ids': event.ids},
      );
      final updated =
          state.expiryData.where((e) => !event.ids.contains(e.id)).toList();
      emit(state.copyWith(expiryData: updated, currentPage: 1));
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Delete all failed: $e'));
    }
  }

  // ── Update ─────────────────────────────────────────────────────────────
  Future<void> _onUpdate(UpdateExpiry event, Emitter<ExpiryState> emit) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      final response = await DioClient().dio.put(
            '/expiry/update_expiry/',
            queryParameters: {'expiry_id': event.id},
            data: event.payload,
            options: dio.Options(
              contentType: 'application/json', // force JSON — not form-data
            ),
          );

      final json = response.data as Map<String, dynamic>;
      if (json['success'] == true) {
        final updatedItem =
            ExpiryData.fromJson(json['data'] as Map<String, dynamic>);
        final updatedList = state.expiryData.map((e) {
          return e.id == event.id ? updatedItem : e;
        }).toList();
        emit(state.copyWith(isLoading: false, expiryData: updatedList));
      } else {
        emit(state.copyWith(
          isLoading: false,
          errorMessage: json['message'] as String? ?? 'Update failed',
        ));
      }
    } on dio.DioException catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: _dioError(e)));
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: 'Error: $e'));
    }
  }

  // ── Helpers ────────────────────────────────────────────────────────────
  String _dioError(dio.DioException e) {
    if (e.response != null) {
      if (e.response!.statusCode == 400) {
        return e.response!.data['message'] ?? 'Bad request';
      }
      return 'Server error: ${e.response!.statusCode}';
    }
    return 'Network error: ${e.message}';
  }
}
