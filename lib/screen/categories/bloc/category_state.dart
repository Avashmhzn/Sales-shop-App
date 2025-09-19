import 'package:equatable/equatable.dart';
import 'package:saleup_app/model/category_response.dart';

class CategoryState extends Equatable {
  final bool isLoading;
  final List<CategoryData> categories;
  final int currentPage;
  final int itemsPerPage;
  final int totalItems;
  final String searchQuery;
  final String selectedShortCodeFilter;
  final Set<String> allShortCodes;
  final String? errorMessage;
  final bool isFiltersCleared;

  const CategoryState({
    this.isLoading = false,
    this.categories = const [],
    this.currentPage = 1,
    this.itemsPerPage = 10,
    this.totalItems = 0,
    this.searchQuery = '',
    this.selectedShortCodeFilter = 'All',
    this.allShortCodes = const {'All', '1', '2'},
    this.errorMessage,
    this.isFiltersCleared = true,
  });

  CategoryState copyWith({
    bool? isLoading,
    List<CategoryData>? categories,
    int? currentPage,
    int? itemsPerPage,
    int? totalItems,
    String? searchQuery,
    String? selectedShortCodeFilter,
    Set<String>? allShortCodes,
    String? errorMessage,
    bool? isFiltersCleared,
  }) {
    return CategoryState(
      isLoading: isLoading ?? this.isLoading,
      categories: categories ?? this.categories,
      currentPage: currentPage ?? this.currentPage,
      itemsPerPage: itemsPerPage ?? this.itemsPerPage,
      totalItems: totalItems ?? this.totalItems,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedShortCodeFilter:
          selectedShortCodeFilter ?? this.selectedShortCodeFilter,
      allShortCodes: allShortCodes ?? this.allShortCodes,
      errorMessage: errorMessage,
      isFiltersCleared: isFiltersCleared ?? this.isFiltersCleared,
    );
  }

  List<CategoryData> getFilteredData() {
    var filteredList = categories
        .where((category) => (category.name?.toLowerCase() ?? '')
            .contains(searchQuery.toLowerCase()))
        .toList();

    if (!isFiltersCleared && selectedShortCodeFilter != 'All') {
      filteredList = filteredList.where((category) {
        final categoryShortCode = category.shortCode ?? '';
        return categoryShortCode.startsWith(selectedShortCodeFilter) ||
            (category.parent != null &&
                categories
                    .firstWhere((c) => c.id == category.parent,
                        orElse: () => CategoryData(
                            id: 0,
                            name: '',
                            shortCode: '',
                            status: false,
                            createdOn: DateTime.now(),
                            updatedOn: DateTime.now(),
                            subcategories: const []))
                    .shortCode!
                    .startsWith(selectedShortCodeFilter));
      }).toList();
    }

    filteredList.sort((a, b) => (a.id).compareTo(b.id));
    return filteredList;
  }

  @override
  List<Object?> get props => [
        isLoading,
        categories,
        currentPage,
        itemsPerPage,
        totalItems,
        searchQuery,
        selectedShortCodeFilter,
        allShortCodes,
        errorMessage,
        isFiltersCleared,
      ];
}
