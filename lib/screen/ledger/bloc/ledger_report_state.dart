// import 'package:equatable/equatable.dart';
// import 'package:saleup_app/model/ledger_report_response.dart';

// abstract class LedgerReportState extends Equatable {
//   const LedgerReportState();

//   @override
//   List<Object?> get props => [];
// }

// class LedgerReportInitial extends LedgerReportState {}

// class LedgerReportLoading extends LedgerReportState {}

// class LedgerReportSuccess extends LedgerReportState {
//   final LedgerReport ledgerReport;

//   const LedgerReportSuccess(this.ledgerReport);

//   @override
//   List<Object?> get props => [ledgerReport];
// }

// class LedgerReportFailure extends LedgerReportState {
//   final String errorMessage;

//   const LedgerReportFailure(this.errorMessage);

//   @override
//   List<Object?> get props => [errorMessage];
// }

// class FilterOptionsLoaded extends LedgerReportState {
//   final List<String> accHeads;

//   const FilterOptionsLoaded({
//     required this.accHeads,
//   });

//   @override
//   List<Object?> get props => [accHeads];
// }
// lib/screen/ledger/bloc/ledger_report_state.dart
import 'package:equatable/equatable.dart';
import 'package:saleup_app/model/ledger_report_response.dart';
import 'package:saleup_app/model/account_heads_response.dart'; // ✅ NEW IMPORT

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

// ✅ CHANGED: Now uses AccountHeadData instead of List<String>
class FilterOptionsLoaded extends LedgerReportState {
  final List<AccountHeadData> accountHeads;
  final Map<int, String> idToName;

  const FilterOptionsLoaded({
    required this.accountHeads,
    required this.idToName,
  });

  @override
  List<Object?> get props => [accountHeads, idToName];
}
