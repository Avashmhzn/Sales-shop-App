import 'package:equatable/equatable.dart';
import 'package:saleup_app/model/expiry_response.dart';

class ExpiryState extends Equatable {
  final bool isLoading;
  final List<ExpiryData> expiryData;
  final int currentPage;
  final int itemsPerPage;
  final int totalItems;
  final String? errorMessage;
  final Map<String, String> sortCriteria;
  final Map<String, String> tempSortCriteria;
  final String searchQuery;

  const ExpiryState({
    this.isLoading = false,
    this.expiryData = const [],
    this.currentPage = 1,
    this.itemsPerPage = 10,
    this.totalItems = 0,
    this.errorMessage,
    this.sortCriteria = const {},
    this.tempSortCriteria = const {},
    this.searchQuery = '',
  });

  ExpiryState copyWith({
    bool? isLoading,
    List<ExpiryData>? expiryData,
    int? currentPage,
    int? itemsPerPage,
    int? totalItems,
    String? errorMessage,
    Map<String, String>? sortCriteria,
    Map<String, String>? tempSortCriteria,
    String? searchQuery,
  }) {
    return ExpiryState(
      isLoading: isLoading ?? this.isLoading,
      expiryData: expiryData ?? this.expiryData,
      currentPage: currentPage ?? this.currentPage,
      itemsPerPage: itemsPerPage ?? this.itemsPerPage,
      totalItems: totalItems ?? this.totalItems,
      errorMessage: errorMessage,
      sortCriteria: sortCriteria ?? this.sortCriteria,
      tempSortCriteria: tempSortCriteria ?? this.tempSortCriteria,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  List<ExpiryData> getFilteredData() {
    var filteredList = List<ExpiryData>.from(expiryData);

    // Apply search filter
    if (searchQuery.isNotEmpty) {
      final query = searchQuery.toLowerCase();
      filteredList = filteredList.where((item) {
        final product = item.product?.toLowerCase() ?? '';
        final batchNumber = item.batchNumber?.toLowerCase() ?? '';
        return product.contains(query) || batchNumber.contains(query);
      }).toList();
    }

    // Apply sort filters
    for (var entry in sortCriteria.entries) {
      final category = entry.key;
      final value = entry.value;
      switch (category) {
        case 'Expiry Date':
          if (value == 'High to Low') {
            filteredList.sort((a, b) => (b.expiryDate ?? DateTime(1970))
                .compareTo(a.expiryDate ?? DateTime(1970)));
          } else if (value == 'Low to High') {
            filteredList.sort((a, b) => (a.expiryDate ?? DateTime(1970))
                .compareTo(b.expiryDate ?? DateTime(1970)));
          }
          break;
        case 'Quantity':
          if (value == 'High to Low') {
            filteredList
                .sort((a, b) => (b.quantity ?? 0).compareTo(a.quantity ?? 0));
          } else if (value == 'Low to High') {
            filteredList
                .sort((a, b) => (a.quantity ?? 0).compareTo(b.quantity ?? 0));
          }
          break;
        case 'Selling Price':
          if (value == 'High to Low') {
            filteredList.sort((a, b) =>
                (b.sellingPrice ?? 0.0).compareTo(a.sellingPrice ?? 0.0));
          } else if (value == 'Low to High') {
            filteredList.sort((a, b) =>
                (a.sellingPrice ?? 0.0).compareTo(b.sellingPrice ?? 0.0));
          }
          break;
        case 'Product':
          if (value.isNotEmpty) {
            filteredList =
                filteredList.where((e) => e.product == value).toList();
          }
          break;
      }
    }

    return filteredList.isEmpty && searchQuery.isEmpty
        ? expiryData
        : filteredList;
  }

  @override
  List<Object?> get props => [
        isLoading,
        expiryData,
        currentPage,
        itemsPerPage,
        totalItems,
        errorMessage,
        sortCriteria,
        tempSortCriteria,
        searchQuery,
      ];
}
