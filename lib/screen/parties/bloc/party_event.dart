import 'package:equatable/equatable.dart';

abstract class PartyEvent extends Equatable {
  const PartyEvent();

  @override
  List<Object?> get props => [];
}

class FetchParties extends PartyEvent {
  const FetchParties();
}

class SearchParties extends PartyEvent {
  final String query;
  const SearchParties(this.query);

  @override
  List<Object?> get props => [query];
}

class UpdateTypeFilter extends PartyEvent {
  final String? type;
  const UpdateTypeFilter(this.type);

  @override
  List<Object?> get props => [type];
}

class ClearFilters extends PartyEvent {
  const ClearFilters();
}

class GoToPage extends PartyEvent {
  final int page;
  const GoToPage(this.page);

  @override
  List<Object?> get props => [page];
}

class UpdateFiltersApplied extends PartyEvent {
  const UpdateFiltersApplied();
}
