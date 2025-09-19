import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:saleup_app/core/network/dio_client.dart';
import 'package:saleup_app/model/category_response.dart';
import 'package:saleup_app/screen/categories/bloc/category_event.dart';
import 'package:saleup_app/screen/categories/bloc/category_state.dart';
import 'package:dio/dio.dart' as dio;

class CategoryBloc extends Bloc<CategoryEvent, CategoryState> {
  CategoryBloc() : super(const CategoryState()) {
    on<FetchCategories>(_onFetchCategories);
    on<SearchCategories>(_onSearchCategories);
    on<UpdateCategoryFilter>(_onUpdateCategoryFilter);
    on<ClearCategoryFilters>(_onClearCategoryFilters);
    on<GoToCategoryPage>(_onGoToCategoryPage);
    on<UpdateFiltersApplied>(_onUpdateFiltersApplied);
  }

  Future<void> _onFetchCategories(
      FetchCategories event, Emitter<CategoryState> emit) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      final response = await DioClient().dio.get('/category/get_categories/');
      if (response.data is! Map<String, dynamic>) {
        emit(state.copyWith(
          isLoading: false,
          errorMessage: 'Invalid API response format',
        ));
        return;
      }
      final categoryResponse = CategoryResponse.fromJson(response.data);
      print(
          'Fetched categories: ${categoryResponse.data.map((c) => c.name).toList()}');

      if (categoryResponse.success == true) {
        emit(state.copyWith(
          isLoading: false,
          categories: categoryResponse.data,
          totalItems: categoryResponse.data.length,
          errorMessage: null,
          isFiltersCleared: true,
        ));
      } else {
        emit(state.copyWith(
          isLoading: false,
          errorMessage:
              categoryResponse.message ?? 'Failed to fetch categories',
        ));
      }
    } on dio.DioException catch (e) {
      String errorMessage = 'Network error: ${e.message}';
      if (e.response != null) {
        errorMessage =
            'Server error: ${e.response!.statusCode} - ${e.response!.data}';
      }
      emit(state.copyWith(
        isLoading: false,
        errorMessage: errorMessage,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to parse categories: $e',
      ));
    }
  }

  void _onSearchCategories(
      SearchCategories event, Emitter<CategoryState> emit) {
    emit(state.copyWith(
      searchQuery: event.query,
      currentPage: 1,
      isFiltersCleared: false,
    ));
  }

  void _onUpdateCategoryFilter(
      UpdateCategoryFilter event, Emitter<CategoryState> emit) {
    emit(state.copyWith(
      selectedShortCodeFilter: event.category ?? 'All', // Use short_code
      currentPage: 1,
      isFiltersCleared: false,
    ));
  }

  Future<void> _onClearCategoryFilters(
      ClearCategoryFilters event, Emitter<CategoryState> emit) async {
    emit(state.copyWith(
      isLoading: true,
      selectedShortCodeFilter: 'All',
      currentPage: 1,
      searchQuery: '',
      isFiltersCleared: true,
      errorMessage: null,
    ));
    try {
      final response = await DioClient().dio.get('/category/get_categories/');
      if (response.data is! Map<String, dynamic>) {
        emit(state.copyWith(
          isLoading: false,
          errorMessage: 'Invalid API response format',
          isFiltersCleared: true,
        ));
        return;
      }
      final categoryResponse = CategoryResponse.fromJson(response.data);

      if (categoryResponse.success == true) {
        emit(state.copyWith(
          isLoading: false,
          categories: categoryResponse.data,
          totalItems: categoryResponse.data.length,
          errorMessage: null,
          isFiltersCleared: true,
          selectedShortCodeFilter: 'All',
          currentPage: 1,
          searchQuery: '',
        ));
      } else {
        emit(state.copyWith(
          isLoading: false,
          errorMessage:
              categoryResponse.message ?? 'Failed to fetch categories',
          isFiltersCleared: true,
        ));
      }
    } on dio.DioException catch (e) {
      String errorMessage = 'Network error: ${e.message}';
      if (e.response != null) {
        errorMessage =
            'Server error: ${e.response!.statusCode} - ${e.response!.data}';
      }
      emit(state.copyWith(
        isLoading: false,
        errorMessage: errorMessage,
        isFiltersCleared: true,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to parse categories: $e',
        isFiltersCleared: true,
      ));
    }
  }

  void _onUpdateFiltersApplied(
      UpdateFiltersApplied event, Emitter<CategoryState> emit) {
    emit(state.copyWith(
      isFiltersCleared: state.selectedShortCodeFilter != 'All' ? false : true,
      currentPage: 1,
    ));
  }

  void _onGoToCategoryPage(
      GoToCategoryPage event, Emitter<CategoryState> emit) {
    final totalPages =
        (state.getFilteredData().length / state.itemsPerPage).ceil();
    final newPage = event.page.clamp(1, totalPages);
    emit(state.copyWith(currentPage: newPage));
  }
}
