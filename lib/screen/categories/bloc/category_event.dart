import 'package:equatable/equatable.dart';

abstract class CategoryEvent extends Equatable {
  const CategoryEvent();

  @override
  List<Object?> get props => [];
}

class FetchCategories extends CategoryEvent {
  const FetchCategories();
}

class SearchCategories extends CategoryEvent {
  final String query;
  const SearchCategories(this.query);

  @override
  List<Object?> get props => [query];
}

class UpdateCategoryFilter extends CategoryEvent {
  final String? category;
  const UpdateCategoryFilter(this.category);

  @override
  List<Object?> get props => [category];
}

class ClearCategoryFilters extends CategoryEvent {
  const ClearCategoryFilters();
}

class GoToCategoryPage extends CategoryEvent {
  final int page;
  const GoToCategoryPage(this.page);

  @override
  List<Object?> get props => [page];
}

class UpdateFiltersApplied extends CategoryEvent {
  const UpdateFiltersApplied();
}
