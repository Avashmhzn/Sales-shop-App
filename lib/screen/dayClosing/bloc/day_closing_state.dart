import 'package:equatable/equatable.dart';
import 'package:saleup_app/screen/dayClosing/model/day_closing_model.dart';

abstract class DayClosingState extends Equatable {
  const DayClosingState();

  @override
  List<Object?> get props => [];
}

class DayClosingInitial extends DayClosingState {}

class DayClosingLoading extends DayClosingState {}

class DayClosingLoaded extends DayClosingState {
  final DayClosingData dayData;
  final bool isClosed;

  const DayClosingLoaded({
    required this.dayData,
    this.isClosed = false,
  });

  @override
  List<Object?> get props => [dayData, isClosed];
}

class DayClosingNoDayOpen extends DayClosingState {
  final String message;

  const DayClosingNoDayOpen({this.message = 'No day data'});

  @override
  List<Object?> get props => [message];
}

class DayClosingError extends DayClosingState {
  final String message;

  const DayClosingError(this.message);

  @override
  List<Object?> get props => [message];
}

class DayCloseSuccess extends DayClosingState {
  final String message;

  const DayCloseSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class DayOpenSuccess extends DayClosingState {
  final String message;

  const DayOpenSuccess(this.message);

  @override
  List<Object?> get props => [message];
}
