import 'package:equatable/equatable.dart';
import 'package:saleup_app/model/trial_balance_report_response.dart';
import 'package:saleup_app/utility/trial_balance_grouping.dart';

abstract class TrialBalanceState extends Equatable {
  const TrialBalanceState();
  @override
  List<Object?> get props => [];
}

class TrialBalanceInitial extends TrialBalanceState {}

class TrialBalanceLoading extends TrialBalanceState {}

class TrialBalanceDatesLoaded extends TrialBalanceState {
  final DateTime startDate;
  final DateTime endDate;

  const TrialBalanceDatesLoaded({
    required this.startDate,
    required this.endDate,
  });

  @override
  List<Object?> get props => [startDate, endDate];
}

class TrialBalanceSuccess extends TrialBalanceState {
  final List<TrialBalanceAccount> accounts;
  final TrialBalanceGroupingResult grouping;
  final DateTime startDate;
  final DateTime endDate;
  final String balanceType;

  const TrialBalanceSuccess({
    required this.accounts,
    required this.grouping,
    required this.startDate,
    required this.endDate,
    this.balanceType = 'with_closing',
  });

  @override
  List<Object?> get props => [accounts, grouping, startDate, endDate, balanceType];
}

class TrialBalanceFailure extends TrialBalanceState {
  final String message;
  const TrialBalanceFailure(this.message);
  @override
  List<Object?> get props => [message];
}
