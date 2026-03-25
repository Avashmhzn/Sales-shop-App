// product_event.dart
import 'package:equatable/equatable.dart';

abstract class ProductEvent extends Equatable {
  const ProductEvent();

  @override
  List<Object?> get props => [];
}

class FetchProducts extends ProductEvent {
  const FetchProducts();
}

class FetchUnits extends ProductEvent {
  const FetchUnits();
}

class SearchProducts extends ProductEvent {
  final String query;
  const SearchProducts(this.query);

  @override
  List<Object?> get props => [query];
}

class UpdateCategoryFilter extends ProductEvent {
  final String? category;
  const UpdateCategoryFilter(this.category);

  @override
  List<Object?> get props => [category];
}

class UpdateUnitFilter extends ProductEvent {
  final String? unit;
  const UpdateUnitFilter(this.unit);

  @override
  List<Object?> get props => [unit];
}

class ClearFilters extends ProductEvent {
  const ClearFilters();
}

class GoToPage extends ProductEvent {
  final int page;
  const GoToPage(this.page);

  @override
  List<Object?> get props => [page];
}

class UpdateFiltersApplied extends ProductEvent {
  const UpdateFiltersApplied();
}

class SortProducts extends ProductEvent {
  final String sortBy;
  const SortProducts(this.sortBy);

  @override
  List<Object?> get props => [sortBy];
}
