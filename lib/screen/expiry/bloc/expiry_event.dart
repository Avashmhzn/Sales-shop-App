import 'package:equatable/equatable.dart';

abstract class ExpiryEvent extends Equatable {
  const ExpiryEvent();
}

class FetchExpiry extends ExpiryEvent {
  const FetchExpiry();
  @override
  List<Object?> get props => [];
}

class SearchExpiry extends ExpiryEvent {
  final String query;
  const SearchExpiry(this.query);
  @override
  List<Object?> get props => [query];
}

class ToggleProductFilter extends ExpiryEvent {
  final String? product;
  const ToggleProductFilter(this.product);
  @override
  List<Object?> get props => [product];
}

class SetPriceSort extends ExpiryEvent {
  final String? direction;
  const SetPriceSort(this.direction);
  @override
  List<Object?> get props => [direction];
}

class SetQuantitySort extends ExpiryEvent {
  final String? direction;
  const SetQuantitySort(this.direction);
  @override
  List<Object?> get props => [direction];
}

class ClearFilters extends ExpiryEvent {
  const ClearFilters();
  @override
  List<Object?> get props => [];
}

class GoToPage extends ExpiryEvent {
  final int page;
  const GoToPage(this.page);
  @override
  List<Object?> get props => [page];
}

class DeleteExpiry extends ExpiryEvent {
  final int id;
  const DeleteExpiry(this.id);
  @override
  List<Object?> get props => [id];
}
