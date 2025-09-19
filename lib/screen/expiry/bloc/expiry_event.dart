import 'package:equatable/equatable.dart';

abstract class ExpiryEvent extends Equatable {
  const ExpiryEvent();
}

class FetchExpiry extends ExpiryEvent {
  const FetchExpiry();

  @override
  List<Object?> get props => [];
}

class SortExpiry extends ExpiryEvent {
  final String category;
  final String value;
  final bool remove;

  const SortExpiry(this.category, this.value, {this.remove = false});

  @override
  List<Object?> get props => [category, value, remove];
}

class ApplyFilters extends ExpiryEvent {
  const ApplyFilters();

  @override
  List<Object?> get props => [];
}

class GoToPage extends ExpiryEvent {
  final int page;

  const GoToPage(this.page);

  @override
  List<Object?> get props => [page];
}

class SearchExpiry extends ExpiryEvent {
  final String query;

  const SearchExpiry(this.query);

  @override
  List<Object?> get props => [query];
}
