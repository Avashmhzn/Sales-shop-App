import 'package:equatable/equatable.dart';

abstract class LedgerReportEvent extends Equatable {
  const LedgerReportEvent();

  @override
  List<Object?> get props => [];
}

class FetchAndDownloadLedgerReport extends LedgerReportEvent {
  final String startDate;
  final String endDate;
  final String accHead;

  const FetchAndDownloadLedgerReport({
    required this.startDate,
    required this.endDate,
    required this.accHead,
  });

  @override
  List<Object?> get props => [startDate, endDate, accHead];
}