import 'package:equatable/equatable.dart';
import 'package:saleup_app/model/product_response.dart';
import 'package:saleup_app/model/unit_response.dart';

class ProductState extends Equatable {
  final bool isLoading;
  final List<ProductData> products;
  final int currentPage;
  final int itemsPerPage;
  final int totalItems;
  final String searchQuery;
  final String selectedCategoryFilter;
  final Set<String> allCategories;
  final String? errorMessage;
  final bool isFiltersCleared;
  final List<UnitData> units;
  final String selectedUnitFilter;
  final String sortBy; // New field for sorting

  const ProductState({
    this.isLoading = false,
    this.products = const [],
    this.currentPage = 1,
    this.itemsPerPage = 10,
    this.totalItems = 0,
    this.searchQuery = '',
    this.selectedCategoryFilter = 'All',
    this.allCategories = const {'All'},
    this.errorMessage,
    this.isFiltersCleared = false,
    this.units = const [],
    this.selectedUnitFilter = 'All',
    this.sortBy = 'No Sorting', // Default sorting
  });

  ProductState copyWith({
    bool? isLoading,
    List<ProductData>? products,
    int? currentPage,
    int? itemsPerPage,
    int? totalItems,
    String? searchQuery,
    String? selectedCategoryFilter,
    Set<String>? allCategories,
    String? errorMessage,
    bool? isFiltersCleared,
    List<UnitData>? units,
    String? selectedUnitFilter,
    String? sortBy, // New parameter for sorting
  }) {
    return ProductState(
      isLoading: isLoading ?? this.isLoading,
      products: products ?? this.products,
      currentPage: currentPage ?? this.currentPage,
      itemsPerPage: itemsPerPage ?? this.itemsPerPage,
      totalItems: totalItems ?? this.totalItems,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedCategoryFilter:
          selectedCategoryFilter ?? this.selectedCategoryFilter,
      allCategories: allCategories ?? this.allCategories,
      errorMessage: errorMessage,
      isFiltersCleared: isFiltersCleared ?? this.isFiltersCleared,
      units: units ?? this.units,
      selectedUnitFilter: selectedUnitFilter ?? this.selectedUnitFilter,
      sortBy: sortBy ?? this.sortBy,
    );
  }

  List<ProductData> getFilteredData() {
    var filteredList = products
        .where((product) =>
            product.name.toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();

    if (!isFiltersCleared) {
      if (selectedCategoryFilter != 'All') {
        filteredList = filteredList
            .where((product) => product.category == selectedCategoryFilter)
            .toList();
      }
      if (selectedUnitFilter != 'All') {
        filteredList = filteredList
            .where((product) => product.unit == selectedUnitFilter)
            .toList();
      }
    }

    // Apply sorting
    switch (sortBy) {
      case 'Stock Quantity: High to Low':
        filteredList.sort(
            (a, b) => (b.stockQuantity ?? 0).compareTo(a.stockQuantity ?? 0));
        break;
      case 'Stock Quantity: Low to High':
        filteredList.sort(
            (a, b) => (a.stockQuantity ?? 0).compareTo(b.stockQuantity ?? 0));
        break;
      case 'Name: A to Z':
        filteredList.sort((a, b) => (a.name).compareTo(b.name));
        break;
      case 'Name: Z to A':
        filteredList.sort((a, b) => (b.name).compareTo(a.name));
        break;
      case 'No Sorting':
      case 'Clear Sorting':
      default:
        filteredList.sort((a, b) => (a.id ?? 0).compareTo(b.id ?? 0));
        break;
    }

    return filteredList;
  }

  @override
  List<Object?> get props => [
        isLoading,
        products,
        currentPage,
        itemsPerPage,
        totalItems,
        searchQuery,
        selectedCategoryFilter,
        allCategories,
        errorMessage,
        isFiltersCleared,
        units,
        selectedUnitFilter,
        sortBy,
      ];
}
