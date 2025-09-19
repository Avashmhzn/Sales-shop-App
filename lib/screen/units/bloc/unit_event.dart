import 'package:equatable/equatable.dart';

abstract class UnitEvent extends Equatable {
  const UnitEvent();

  @override
  List<Object?> get props => [];
}

class FetchUnits extends UnitEvent {
  const FetchUnits();
}

class SearchUnits extends UnitEvent {
  final String query;
  const SearchUnits(this.query);

  @override
  List<Object?> get props => [query];
}

class GoToPage extends UnitEvent {
  final int page;
  const GoToPage(this.page);

  @override
  List<Object?> get props => [page];
}
