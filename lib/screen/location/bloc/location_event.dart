import 'package:equatable/equatable.dart';

abstract class LocationEvent extends Equatable {
  const LocationEvent();

  @override
  List<Object?> get props => [];
}

class FetchLocations extends LocationEvent {
  const FetchLocations();
}

class SearchLocations extends LocationEvent {
  final String query;
  const SearchLocations(this.query);

  @override
  List<Object?> get props => [query];
}

class GoToPage extends LocationEvent {
  final int page;
  const GoToPage(this.page);

  @override
  List<Object?> get props => [page];
}
