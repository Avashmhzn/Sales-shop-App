import 'package:equatable/equatable.dart';
import 'package:saleup_app/model/account_heads_response.dart';

class AccountHeadState extends Equatable {
  final bool isLoading;
  final List<AccountHeadData> accountHeads;
  final int currentPage;
  final int itemsPerPage;
  final int totalItems;
  final String searchQuery;
  final String selectedMainFilter;
  final String? selectedSubFilter;
  final Map<String, Set<String>> subFilters;
  final Set<String> allParents;
  final Set<String> availableSubFilters;
  final String? errorMessage;
  final bool isFiltersCleared;

  const AccountHeadState({
    this.isLoading = false,
    this.accountHeads = const [],
    this.currentPage = 1,
    this.itemsPerPage = 10,
    this.totalItems = 0,
    this.searchQuery = '',
    this.selectedMainFilter = 'All',
    this.selectedSubFilter,
    this.subFilters = const {},
    this.allParents = const {'All'},
    this.availableSubFilters = const {},
    this.errorMessage,
    this.isFiltersCleared = false,
  });

  AccountHeadState copyWith({
    bool? isLoading,
    List<AccountHeadData>? accountHeads,
    int? currentPage,
    int? itemsPerPage,
    int? totalItems,
    String? searchQuery,
    String? selectedMainFilter,
    String? selectedSubFilter,
    Map<String, Set<String>>? subFilters,
    Set<String>? allParents,
    Set<String>? availableSubFilters,
    String? errorMessage,
    bool? isFiltersCleared,
  }) {
    return AccountHeadState(
      isLoading: isLoading ?? this.isLoading,
      accountHeads: accountHeads ?? this.accountHeads,
      currentPage: currentPage ?? this.currentPage,
      itemsPerPage: itemsPerPage ?? this.itemsPerPage,
      totalItems: totalItems ?? this.totalItems,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedMainFilter: selectedMainFilter ?? this.selectedMainFilter,
      selectedSubFilter: selectedSubFilter ?? this.selectedSubFilter,
      subFilters: subFilters ?? this.subFilters,
      allParents: allParents ?? this.allParents,
      availableSubFilters: availableSubFilters ?? this.availableSubFilters,
      errorMessage: errorMessage,
      isFiltersCleared: isFiltersCleared ?? this.isFiltersCleared,
    );
  }

  List<AccountHeadData> getFilteredData() {
    print('getFilteredData called with: '
        'searchQuery=$searchQuery, '
        'selectedMainFilter=$selectedMainFilter, '
        'selectedSubFilter=$selectedSubFilter, '
        'isFiltersCleared=$isFiltersCleared');
    var filteredList = accountHeads
        .where((head) =>
            head.name.toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();

    if (!isFiltersCleared && selectedMainFilter != 'All') {
      filteredList = filteredList
          .where((head) => head.parent == selectedMainFilter)
          .toList();
    }

    if (!isFiltersCleared &&
        selectedSubFilter != null &&
        selectedSubFilter!.isNotEmpty) {
      filteredList = filteredList
          .where((head) => head.mainGroup == selectedSubFilter)
          .toList();
    }

    filteredList.sort((a, b) => a.id.compareTo(b.id));
    print('Filtered list length: ${filteredList.length}');
    return filteredList;
  }

  @override
  List<Object?> get props => [
        isLoading,
        accountHeads,
        currentPage,
        itemsPerPage,
        totalItems,
        searchQuery,
        selectedMainFilter,
        selectedSubFilter,
        subFilters,
        allParents,
        availableSubFilters,
        errorMessage,
        isFiltersCleared,
      ];
}
