// import 'package:equatable/equatable.dart';

// abstract class LedgerReportEvent extends Equatable {
//   const LedgerReportEvent();

//   @override
//   List<Object?> get props => [];
// }

// class FetchFilterOptions extends LedgerReportEvent {}

// class FetchAndDownloadLedgerReport extends LedgerReportEvent {
//   final String startDate;
//   final String endDate;
//   final String accHead;

//   const FetchAndDownloadLedgerReport({
//     required this.startDate,
//     required this.endDate,
//     required this.accHead,
//   });

//   @override
//   List<Object?> get props => [startDate, endDate, accHead];
// }

// class ClearFilterEvent extends LedgerReportEvent {}
// lib/screen/ledger/bloc/ledger_report_event.dart
import 'package:equatable/equatable.dart';

abstract class LedgerReportEvent extends Equatable {
  const LedgerReportEvent();
  @override
  List<Object?> get props => [];
}

class FetchFilterOptions extends LedgerReportEvent {}

class FetchAndDownloadLedgerReport extends LedgerReportEvent {
  final String startDate;
  final String endDate;
  final int accHeadId; // ✅ CHANGED: int instead of String

  const FetchAndDownloadLedgerReport({
    required this.startDate,
    required this.endDate,
    required this.accHeadId,
  });

  @override
  List<Object?> get props => [startDate, endDate, accHeadId];
}

class ClearFilterEvent extends LedgerReportEvent {}
