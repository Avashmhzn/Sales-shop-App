import 'package:equatable/equatable.dart';

abstract class DayClosingEvent extends Equatable {
  const DayClosingEvent();

  @override
  List<Object?> get props => [];
}

/// Fetch the day summary data from the API
class FetchDayData extends DayClosingEvent {
  const FetchDayData();
}

/// Close the current day
class CloseDay extends DayClosingEvent {
  const CloseDay();
}

/// Open a new day
class OpenDay extends DayClosingEvent {
  const OpenDay();
}
