import 'package:equatable/equatable.dart';

abstract class AccountHeadEvent extends Equatable {
  const AccountHeadEvent();

  @override
  List<Object?> get props => [];
}

class FetchAccountHeads extends AccountHeadEvent {
  const FetchAccountHeads();

  @override
  List<Object?> get props => [];
}

class SearchAccountHeads extends AccountHeadEvent {
  final String query;
  const SearchAccountHeads(this.query);

  @override
  List<Object?> get props => [query];
}

class UpdateMainFilter extends AccountHeadEvent {
  final String? parent;
  const UpdateMainFilter(this.parent);

  @override
  List<Object?> get props => [parent];
}

class UpdateSubFilter extends AccountHeadEvent {
  final String? mainGroup;
  const UpdateSubFilter(this.mainGroup);

  @override
  List<Object?> get props => [mainGroup];
}

class ClearFilters extends AccountHeadEvent {
  const ClearFilters();

  @override
  List<Object?> get props => [];
}

class GoToPage extends AccountHeadEvent {
  final int page;
  const GoToPage(this.page);

  @override
  List<Object?> get props => [page];
}

class UpdateFiltersApplied extends AccountHeadEvent {
  const UpdateFiltersApplied();

  @override
  List<Object?> get props => [];
}
