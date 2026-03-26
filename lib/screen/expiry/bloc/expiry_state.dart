// lib/screen/expiry/bloc/expiry_state.dart
import 'package:equatable/equatable.dart';
import 'package:saleup_app/model/expiry_response.dart';

class ExpiryState extends Equatable {
  final bool isLoading;
  final List<ExpiryData> expiryData;
  final String searchQuery;
  final String? selectedProduct;
  final String? priceSort;
  final String? quantitySort;
  final int currentPage;
  final int itemsPerPage;
  final String? errorMessage;

  const ExpiryState({
    this.isLoading = false,
    this.expiryData = const [],
    this.searchQuery = '',
    this.selectedProduct,
    this.priceSort,
    this.quantitySort,
    this.currentPage = 1,
    this.itemsPerPage = 10,
    this.errorMessage,
  });

  List<String> get uniqueProducts => expiryData
      .map((e) => e.product ?? '')
      .where((p) => p.isNotEmpty)
      .toSet()
      .toList()
    ..sort();

  List<ExpiryData> getFilteredData() {
    var list = List<ExpiryData>.from(expiryData);

    // Search
    if (searchQuery.isNotEmpty) {
      final q = searchQuery.toLowerCase();
      list = list.where((e) {
        return (e.product?.toLowerCase().contains(q) ?? false) ||
            (e.batchNumber?.toLowerCase().contains(q) ?? false);
      }).toList();
    }

    // Product Filter
    if (selectedProduct != null) {
      list = list.where((e) => e.product == selectedProduct).toList();
    }

    // Sorting - Only one sort active at a time (price OR quantity)
    if (priceSort == 'High to Low') {
      list.sort((a, b) => (b.sellingPrice ?? 0).compareTo(a.sellingPrice ?? 0));
    } else if (priceSort == 'Low to High') {
      list.sort((a, b) => (a.sellingPrice ?? 0).compareTo(b.sellingPrice ?? 0));
    } else if (quantitySort == 'High to Low') {
      list.sort((a, b) => (b.quantity ?? 0).compareTo(a.quantity ?? 0));
    } else if (quantitySort == 'Low to High') {
      list.sort((a, b) => (a.quantity ?? 0).compareTo(b.quantity ?? 0));
    }

    return list;
  }

  ExpiryState copyWith({
    bool? isLoading,
    List<ExpiryData>? expiryData,
    String? searchQuery,
    Object? selectedProduct = _sentinel,
    Object? priceSort = _sentinel,
    Object? quantitySort = _sentinel,
    int? currentPage,
    int? itemsPerPage,
    Object? errorMessage = _sentinel,
  }) {
    return ExpiryState(
      isLoading: isLoading ?? this.isLoading,
      expiryData: expiryData ?? this.expiryData,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedProduct: selectedProduct == _sentinel
          ? this.selectedProduct
          : selectedProduct as String?,
      priceSort: priceSort == _sentinel ? this.priceSort : priceSort as String?,
      quantitySort: quantitySort == _sentinel
          ? this.quantitySort
          : quantitySort as String?,
      currentPage: currentPage ?? this.currentPage,
      itemsPerPage: itemsPerPage ?? this.itemsPerPage,
      errorMessage: errorMessage == _sentinel
          ? this.errorMessage
          : errorMessage as String?,
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        expiryData,
        searchQuery,
        selectedProduct,
        priceSort,
        quantitySort,
        currentPage,
        itemsPerPage,
        errorMessage,
      ];
}

const _sentinel = Object();
