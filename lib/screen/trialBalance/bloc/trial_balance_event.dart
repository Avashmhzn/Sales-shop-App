// lib/screen/trial_balance/bloc/trial_balance_event.dart
import 'package:equatable/equatable.dart';

abstract class TrialBalanceEvent extends Equatable {
  const TrialBalanceEvent();
  @override
  List<Object?> get props => [];
}

class FetchTrialBalance extends TrialBalanceEvent {
  final String startDate;
  final String endDate;

  const FetchTrialBalance(this.startDate, this.endDate);
  @override
  List<Object?> get props => [startDate, endDate];
}

class ClearTrialBalanceFilter extends TrialBalanceEvent {}
