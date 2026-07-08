import 'package:equatable/equatable.dart';

abstract class TrialBalanceEvent extends Equatable {
  const TrialBalanceEvent();
  @override
  List<Object?> get props => [];
}

class InitializeTrialBalance extends TrialBalanceEvent {}

class FetchTrialBalance extends TrialBalanceEvent {
  final String startDate;
  final String endDate;
  final String balanceType;

  const FetchTrialBalance({
    required this.startDate,
    required this.endDate,
    this.balanceType = 'with_closing',
  });

  @override
  List<Object?> get props => [startDate, endDate, balanceType];
}

class ResetTrialBalance extends TrialBalanceEvent {}
