// lib/screen/trial_balance/bloc/trial_balance_state.dart
import 'package:equatable/equatable.dart';
import 'package:saleup_app/model/trial_balance_report_response.dart';

abstract class TrialBalanceState extends Equatable {
  const TrialBalanceState();
  @override
  List<Object?> get props => [];
}

class TrialBalanceInitial extends TrialBalanceState {}

class TrialBalanceLoading extends TrialBalanceState {}

class TrialBalanceLoaded extends TrialBalanceState {
  final TrialBalanceReport report;
  const TrialBalanceLoaded(this.report);
  @override
  List<Object?> get props => [report];
}

class TrialBalanceError extends TrialBalanceState {
  final String message;
  const TrialBalanceError(this.message);
  @override
  List<Object?> get props => [message];
}
