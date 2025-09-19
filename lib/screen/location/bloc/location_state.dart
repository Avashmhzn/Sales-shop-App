import 'package:equatable/equatable.dart';
import 'package:saleup_app/model/location_response.dart';

class LocationState extends Equatable {
  final bool isLoading;
  final List<LocationData> locations;
  final int currentPage;
  final int itemsPerPage;
  final int totalItems;
  final String searchQuery;
  final String? errorMessage;

  const LocationState({
    this.isLoading = false,
    this.locations = const [],
    this.currentPage = 1,
    this.itemsPerPage = 10,
    this.totalItems = 0,
    this.searchQuery = '',
    this.errorMessage,
  });

  LocationState copyWith({
    bool? isLoading,
    List<LocationData>? locations,
    int? currentPage,
    int? itemsPerPage,
    int? totalItems,
    String? searchQuery,
    String? errorMessage,
  }) {
    return LocationState(
      isLoading: isLoading ?? this.isLoading,
      locations: locations ?? this.locations,
      currentPage: currentPage ?? this.currentPage,
      itemsPerPage: itemsPerPage ?? this.itemsPerPage,
      totalItems: totalItems ?? this.totalItems,
      searchQuery: searchQuery ?? this.searchQuery,
      errorMessage: errorMessage,
    );
  }

  List<LocationData> getFilteredData() {
    print('getFilteredData called with: searchQuery=$searchQuery');
    var filteredList = locations
        .where((location) =>
            location.name.toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();

    filteredList.sort((a, b) => a.id.compareTo(b.id));
    print(
        'Filtered list length: ${filteredList.length}, names: ${filteredList.map((l) => l.name).toList()}');
    return filteredList;
  }

  @override
  List<Object?> get props => [
        isLoading,
        locations,
        currentPage,
        itemsPerPage,
        totalItems,
        searchQuery,
        errorMessage,
      ];
}
