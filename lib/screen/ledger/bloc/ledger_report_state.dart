import 'package:equatable/equatable.dart';
import 'package:saleup_app/model/ledger_report_response.dart';

abstract class LedgerReportState extends Equatable {
  const LedgerReportState();

  @override
  List<Object?> get props => [];
}

class LedgerReportInitial extends LedgerReportState {}

class LedgerReportLoading extends LedgerReportState {}

class LedgerReportSuccess extends LedgerReportState {
  final LedgerReport ledgerReport;

  const LedgerReportSuccess(this.ledgerReport);

  @override
  List<Object?> get props => [ledgerReport];
}

class LedgerReportFailure extends LedgerReportState {
  final String errorMessage;

  const LedgerReportFailure(this.errorMessage);

  @override
  List<Object?> get props => [errorMessage];
}