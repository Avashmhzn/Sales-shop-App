import 'package:equatable/equatable.dart';
import 'package:saleup_app/model/party_response.dart';

class PartyState extends Equatable {
  final bool isLoading;
  final List<PartyData> parties;
  final int currentPage;
  final int itemsPerPage;
  final int totalItems;
  final String searchQuery;
  final String selectedTypeFilter;
  final Set<String> allTypes;
  final String? errorMessage;
  final bool isFiltersCleared;

  const PartyState({
    this.isLoading = false,
    this.parties = const [],
    this.currentPage = 1,
    this.itemsPerPage = 10,
    this.totalItems = 0,
    this.searchQuery = '',
    this.selectedTypeFilter = 'All',
    this.allTypes = const {'All', 'Sundry Creditor', 'Sundry Debtor'},
    this.errorMessage,
    this.isFiltersCleared = false,
  });

  PartyState copyWith({
    bool? isLoading,
    List<PartyData>? parties,
    int? currentPage,
    int? itemsPerPage,
    int? totalItems,
    String? searchQuery,
    String? selectedTypeFilter,
    Set<String>? allTypes,
    String? errorMessage,
    bool? isFiltersCleared,
  }) {
    return PartyState(
      isLoading: isLoading ?? this.isLoading,
      parties: parties ?? this.parties,
      currentPage: currentPage ?? this.currentPage,
      itemsPerPage: itemsPerPage ?? this.itemsPerPage,
      totalItems: totalItems ?? this.totalItems,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedTypeFilter: selectedTypeFilter ?? this.selectedTypeFilter,
      allTypes: allTypes ?? this.allTypes,
      errorMessage: errorMessage,
      isFiltersCleared: isFiltersCleared ?? this.isFiltersCleared,
    );
  }

  List<PartyData> getFilteredData() {
    print('getFilteredData called with: '
        'searchQuery=$searchQuery, '
        'selectedTypeFilter=$selectedTypeFilter, '
        'isFiltersCleared=$isFiltersCleared');
    var filteredList = parties
        .where((party) =>
            party.name.toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();

    if (!isFiltersCleared && selectedTypeFilter != 'All') {
      if (selectedTypeFilter == 'Sundry Creditor') {
        filteredList = filteredList
            .where((party) => party.type == 'Customer' || party.type == 'Both')
            .toList();
        print(
            'Sundry Creditor filter: ${filteredList.map((p) => p.type).toList()}');
      } else if (selectedTypeFilter == 'Sundry Debtor') {
        filteredList = filteredList
            .where((party) => party.type == 'Supplier' || party.type == 'Both')
            .toList();
        print(
            'Sundry Debtor filter: ${filteredList.map((p) => p.type).toList()}');
      }
    }

    filteredList.sort((a, b) => a.id.compareTo(b.id));
    print(
        'Filtered list length: ${filteredList.length}, types: ${filteredList.map((p) => p.type).toList()}');
    return filteredList;
  }

  @override
  List<Object?> get props => [
        isLoading,
        parties,
        currentPage,
        itemsPerPage,
        totalItems,
        searchQuery,
        selectedTypeFilter,
        allTypes,
        errorMessage,
        isFiltersCleared,
      ];
}
