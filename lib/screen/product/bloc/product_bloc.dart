// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:saleup_app/core/network/dio_client.dart';
// import 'package:saleup_app/model/product_response.dart';
// import 'package:dio/dio.dart' as dio;
// import 'package:saleup_app/model/unit_response.dart';
// import 'package:saleup_app/screen/product/bloc/product_event.dart';
// import 'package:saleup_app/screen/product/bloc/product_state.dart';

// class ProductBloc extends Bloc<ProductEvent, ProductState> {
//   ProductBloc() : super(const ProductState()) {
//     on<FetchProducts>(_onFetchProducts);
//     on<FetchUnits>(_onFetchUnits);
//     on<SearchProducts>(_onSearchProducts);
//     on<UpdateCategoryFilter>(_onUpdateCategoryFilter);
//     on<UpdateUnitFilter>(_onUpdateUnitFilter);
//     on<ClearFilters>(_onClearFilters);
//     on<GoToPage>(_onGoToPage);
//     on<UpdateFiltersApplied>(_onUpdateFiltersApplied);
//     on<SortProducts>(_onSortProducts); // New event handler
//   }

//   Future<void> _onFetchProducts(
//       FetchProducts event, Emitter<ProductState> emit) async {
//     emit(state.copyWith(isLoading: true, errorMessage: null));
//     try {
//       final response = await DioClient().dio.get('/product/get_products/');
//       if (response.data is! Map<String, dynamic>) {
//         emit(state.copyWith(
//           isLoading: false,
//           errorMessage: 'Invalid API response format',
//         ));
//         return;
//       }
//       final productResponse = ProductResponse.fromJson(response.data);

//       if (productResponse.success == true) {
//         final categories = {
//           'All',
//           ...productResponse.data
//               .map((p) => p.category)
//               .where((c) => c.isNotEmpty)
//         };
//         emit(state.copyWith(
//           isLoading: false,
//           products: productResponse.data,
//           totalItems: productResponse.data.length,
//           errorMessage: null,
//           isFiltersCleared: state.isFiltersCleared,
//           allCategories: categories,
//         ));
//       } else {
//         emit(state.copyWith(
//           isLoading: false,
//           errorMessage: productResponse.message ?? 'Failed to fetch products',
//         ));
//       }
//     } on dio.DioException catch (e) {
//       String errorMessage = 'Network error: ${e.message}';
//       if (e.response != null) {
//         errorMessage =
//             'Server error: ${e.response!.statusCode} - ${e.response!.data}';
//       } else if (e.type == dio.DioExceptionType.connectionTimeout) {
//         errorMessage = 'Connection timed out. Please check your internet.';
//       }
//       emit(state.copyWith(
//         isLoading: false,
//         errorMessage: errorMessage,
//       ));
//     } catch (e) {
//       emit(state.copyWith(
//         isLoading: false,
//         errorMessage: 'Failed to parse products: $e',
//       ));
//     }
//   }

//   Future<void> _onFetchUnits(
//       FetchUnits event, Emitter<ProductState> emit) async {
//     emit(state.copyWith(isLoading: true, errorMessage: null));
//     try {
//       final response = await DioClient().dio.get('/unit/get_units/');
//       if (response.data is! Map<String, dynamic>) {
//         emit(state.copyWith(
//           isLoading: false,
//           errorMessage: 'Invalid API response format',
//         ));
//         return;
//       }
//       final unitResponse = UnitResponse.fromJson(response.data);
//       print('Fetched units: ${unitResponse.data.map((u) => u.name).toList()}');

//       if (unitResponse.success == true) {
//         emit(state.copyWith(
//           isLoading: false,
//           errorMessage: null,
//           units: unitResponse.data,
//         ));
//       } else {
//         emit(state.copyWith(
//           isLoading: false,
//           errorMessage: unitResponse.message ?? 'Failed to fetch units',
//         ));
//       }
//     } on dio.DioException catch (e) {
//       String errorMessage = 'Network error: ${e.message}';
//       if (e.response != null) {
//         errorMessage =
//             'Server error: ${e.response!.statusCode} - ${e.response!.data}';
//       }
//       emit(state.copyWith(
//         isLoading: false,
//         errorMessage: errorMessage,
//       ));
//     } catch (e) {
//       emit(state.copyWith(
//         isLoading: false,
//         errorMessage: 'Failed to parse units: $e',
//       ));
//     }
//   }

//   void _onSearchProducts(SearchProducts event, Emitter<ProductState> emit) {
//     emit(state.copyWith(
//       searchQuery: event.query,
//       currentPage: 1,
//       isFiltersCleared: false,
//     ));
//   }

//   void _onUpdateCategoryFilter(
//       UpdateCategoryFilter event, Emitter<ProductState> emit) {
//     emit(state.copyWith(
//       selectedCategoryFilter: event.category ?? 'All',
//       currentPage: 1,
//       isFiltersCleared: false,
//     ));
//   }

//   void _onUpdateUnitFilter(UpdateUnitFilter event, Emitter<ProductState> emit) {
//     emit(state.copyWith(
//       selectedUnitFilter: event.unit ?? 'All',
//       currentPage: 1,
//       isFiltersCleared: false,
//     ));
//   }

//   Future<void> _onClearFilters(
//       ClearFilters event, Emitter<ProductState> emit) async {
//     emit(state.copyWith(
//       isLoading: true,
//       selectedCategoryFilter: 'All',
//       selectedUnitFilter: 'All',
//       currentPage: 1,
//       searchQuery: '',
//       isFiltersCleared: true,
//       errorMessage: null,
//     ));
//     try {
//       final response = await DioClient().dio.get('/product/get_products/');
//       if (response.data is! Map<String, dynamic>) {
//         emit(state.copyWith(
//           isLoading: false,
//           errorMessage: 'Invalid API response format',
//           isFiltersCleared: true,
//         ));
//         return;
//       }
//       final productResponse = ProductResponse.fromJson(response.data);

//       if (productResponse.success == true) {
//         final categories = {
//           'All',
//           ...productResponse.data
//               .map((p) => p.category)
//               .where((c) => c.isNotEmpty)
//         };
//         emit(state.copyWith(
//           isLoading: false,
//           products: productResponse.data,
//           totalItems: productResponse.data.length,
//           errorMessage: null,
//           isFiltersCleared: true,
//           selectedCategoryFilter: 'All',
//           selectedUnitFilter: 'All',
//           currentPage: 1,
//           searchQuery: '',
//           allCategories: categories,
//         ));
//       } else {
//         emit(state.copyWith(
//           isLoading: false,
//           errorMessage: productResponse.message ?? 'Failed to fetch products',
//           isFiltersCleared: true,
//         ));
//       }
//     } on dio.DioException catch (e) {
//       String errorMessage = 'Network error: ${e.message}';
//       if (e.response != null) {
//         errorMessage =
//             'Server error: ${e.response!.statusCode} - ${e.response!.data}';
//       } else if (e.type == dio.DioExceptionType.connectionTimeout) {
//         errorMessage = 'Connection timed out. Please check your internet.';
//       }
//       emit(state.copyWith(
//         isLoading: false,
//         errorMessage: errorMessage,
//         isFiltersCleared: true,
//       ));
//     } catch (e) {
//       emit(state.copyWith(
//         isLoading: false,
//         errorMessage: 'Failed to parse products: $e',
//         isFiltersCleared: true,
//       ));
//     }
//   }

//   void _onUpdateFiltersApplied(
//       UpdateFiltersApplied event, Emitter<ProductState> emit) {
//     emit(state.copyWith(
//       isFiltersCleared: state.selectedCategoryFilter != 'All' ||
//               state.selectedUnitFilter != 'All'
//           ? false
//           : true,
//       currentPage: 1,
//     ));
//   }

//   void _onGoToPage(GoToPage event, Emitter<ProductState> emit) {
//     final totalPages =
//         (state.getFilteredData().length / state.itemsPerPage).ceil();
//     final newPage = event.page.clamp(1, totalPages);
//     emit(state.copyWith(currentPage: newPage));
//   }

//   void _onSortProducts(SortProducts event, Emitter<ProductState> emit) {
//     emit(state.copyWith(
//       sortBy: event.sortBy,
//       currentPage: 1,
//     ));
//   }
// }
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:saleup_app/core/network/dio_client.dart';
import 'package:saleup_app/model/product_response.dart';
import 'package:dio/dio.dart' as dio;
import 'package:saleup_app/model/unit_response.dart';
import 'package:saleup_app/screen/product/bloc/product_event.dart';
import 'package:saleup_app/screen/product/bloc/product_state.dart';
import 'dart:developer' as developer;

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  ProductBloc() : super(const ProductState()) {
    on<FetchProducts>(_onFetchProducts);
    on<FetchUnits>(_onFetchUnits);
    on<SearchProducts>(_onSearchProducts);
    on<UpdateCategoryFilter>(_onUpdateCategoryFilter);
    on<UpdateUnitFilter>(_onUpdateUnitFilter);
    on<ClearFilters>(_onClearFilters);
    on<GoToPage>(_onGoToPage);
    on<UpdateFiltersApplied>(_onUpdateFiltersApplied);
    on<SortProducts>(_onSortProducts);
  }

  Future<void> _onFetchProducts(
      FetchProducts event, Emitter<ProductState> emit) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      final response = await DioClient().dio.get('/product/get_products/');

      // Validate top-level response structure
      if (response.data is! Map<String, dynamic>) {
        emit(state.copyWith(
          isLoading: false,
          errorMessage: 'Invalid API response format',
        ));
        return;
      }

      final Map<String, dynamic> responseData = response.data;

      if (responseData['success'] != true) {
        final message =
            responseData['message']?.toString() ?? 'Failed to fetch products';
        emit(state.copyWith(
          isLoading: false,
          errorMessage: message,
        ));
        return;
      }

      // Extract the wrapper object: data.results
      final dynamic dataWrapper = responseData['data'];
      if (dataWrapper is! Map<String, dynamic>) {
        emit(state.copyWith(
          isLoading: false,
          errorMessage: 'Expected data to be an object with results',
        ));
        return;
      }

      final dynamic results = dataWrapper['results'];
      if (results is! List) {
        emit(state.copyWith(
          isLoading: false,
          errorMessage: 'Expected results to be a list of products',
        ));
        return;
      }

      // Safely parse each product in 'results'
      final List<ProductData> productList = [];
      for (var item in results) {
        if (item is Map<String, dynamic>) {
          try {
            // Map API field 'stock_quantity' to model's 'stockQuantity'
            final Map<String, dynamic> adaptedItem = {
              ...item,
              'stockQuantity': item['stock_quantity'],
            };
            productList.add(ProductData.fromJson(adaptedItem));
          } on Exception catch (e) {
            developer.log('Error parsing product item', error: e);
          }
        }
      }

      // Extract unique categories
      final categories = {
        'All',
        ...productList.map((p) => p.category).where((c) => c.isNotEmpty),
      };

      emit(state.copyWith(
        isLoading: false,
        products: productList,
        totalItems: productList.length,
        errorMessage: null,
        isFiltersCleared: state.isFiltersCleared,
        allCategories: categories,
      ));
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
        errorMessage: 'Failed to parse products: $e',
      ));
    }
  }

  Future<void> _onFetchUnits(
      FetchUnits event, Emitter<ProductState> emit) async {
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
      print('Fetched units: ${unitResponse.data.map((u) => u.name).toList()}');

      if (unitResponse.success == true) {
        emit(state.copyWith(
          isLoading: false,
          errorMessage: null,
          units: unitResponse.data,
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

  void _onSearchProducts(SearchProducts event, Emitter<ProductState> emit) {
    emit(state.copyWith(
      searchQuery: event.query,
      currentPage: 1,
      isFiltersCleared: false,
    ));
  }

  void _onUpdateCategoryFilter(
      UpdateCategoryFilter event, Emitter<ProductState> emit) {
    emit(state.copyWith(
      selectedCategoryFilter: event.category ?? 'All',
      currentPage: 1,
      isFiltersCleared: false,
    ));
  }

  void _onUpdateUnitFilter(UpdateUnitFilter event, Emitter<ProductState> emit) {
    emit(state.copyWith(
      selectedUnitFilter: event.unit ?? 'All',
      currentPage: 1,
      isFiltersCleared: false,
    ));
  }

  Future<void> _onClearFilters(
      ClearFilters event, Emitter<ProductState> emit) async {
    emit(state.copyWith(
      isLoading: true,
      selectedCategoryFilter: 'All',
      selectedUnitFilter: 'All',
      currentPage: 1,
      searchQuery: '',
      isFiltersCleared: true,
      errorMessage: null,
    ));
    try {
      final response = await DioClient().dio.get('/product/get_products/');
      if (response.data is! Map<String, dynamic>) {
        emit(state.copyWith(
          isLoading: false,
          errorMessage: 'Invalid API response format',
          isFiltersCleared: true,
        ));
        return;
      }

      final Map<String, dynamic> responseData = response.data;

      if (responseData['success'] != true) {
        final message =
            responseData['message']?.toString() ?? 'Failed to fetch products';
        emit(state.copyWith(
          isLoading: false,
          errorMessage: message,
          isFiltersCleared: true,
        ));
        return;
      }

      final dynamic dataWrapper = responseData['data'];
      if (dataWrapper is! Map<String, dynamic>) return;

      final dynamic results = dataWrapper['results'];
      if (results is! List) return;

      final List<ProductData> productList = [];
      for (var item in results) {
        if (item is Map<String, dynamic>) {
          try {
            final Map<String, dynamic> adaptedItem = {
              ...item,
              'stockQuantity': item['stock_quantity'],
            };
            productList.add(ProductData.fromJson(adaptedItem));
          } on Exception catch (e) {
            developer.log('Error parsing product on clear filter', error: e);
          }
        }
      }

      final categories = {
        'All',
        ...productList.map((p) => p.category).where((c) => c.isNotEmpty),
      };

      emit(state.copyWith(
        isLoading: false,
        products: productList,
        totalItems: productList.length,
        errorMessage: null,
        isFiltersCleared: true,
        selectedCategoryFilter: 'All',
        selectedUnitFilter: 'All',
        currentPage: 1,
        searchQuery: '',
        allCategories: categories,
      ));
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
        isFiltersCleared: true,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to parse products: $e',
        isFiltersCleared: true,
      ));
    }
  }

  void _onUpdateFiltersApplied(
      UpdateFiltersApplied event, Emitter<ProductState> emit) {
    emit(state.copyWith(
      isFiltersCleared: state.selectedCategoryFilter != 'All' ||
              state.selectedUnitFilter != 'All'
          ? false
          : true,
      currentPage: 1,
    ));
  }

  void _onGoToPage(GoToPage event, Emitter<ProductState> emit) {
    final totalPages =
        (state.getFilteredData().length / state.itemsPerPage).ceil();
    final newPage = event.page.clamp(1, totalPages);
    emit(state.copyWith(currentPage: newPage));
  }

  void _onSortProducts(SortProducts event, Emitter<ProductState> emit) {
    emit(state.copyWith(
      sortBy: event.sortBy,
      currentPage: 1,
    ));
  }
}
