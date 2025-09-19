import 'package:equatable/equatable.dart';
import 'package:saleup_app/model/unit_response.dart';

class UnitState extends Equatable {
  final bool isLoading;
  final List<UnitData> units;
  final int currentPage;
  final int itemsPerPage;
  final int totalItems;
  final String searchQuery;
  final String? errorMessage;

  const UnitState({
    this.isLoading = false,
    this.units = const [],
    this.currentPage = 1,
    this.itemsPerPage = 10,
    this.totalItems = 0,
    this.searchQuery = '',
    this.errorMessage,
  });

  UnitState copyWith({
    bool? isLoading,
    List<UnitData>? units,
    int? currentPage,
    int? itemsPerPage,
    int? totalItems,
    String? searchQuery,
    String? errorMessage,
  }) {
    return UnitState(
      isLoading: isLoading ?? this.isLoading,
      units: units ?? this.units,
      currentPage: currentPage ?? this.currentPage,
      itemsPerPage: itemsPerPage ?? this.itemsPerPage,
      totalItems: totalItems ?? this.totalItems,
      searchQuery: searchQuery ?? this.searchQuery,
      errorMessage: errorMessage,
    );
  }

  List<UnitData> getFilteredData() {
    var filteredList = units
        .where((unit) =>
            unit.name.toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();

    filteredList.sort((a, b) => a.id.compareTo(b.id));
    return filteredList;
  }

  @override
  List<Object?> get props => [
        isLoading,
        units,
        currentPage,
        itemsPerPage,
        totalItems,
        searchQuery,
        errorMessage,
      ];
}
