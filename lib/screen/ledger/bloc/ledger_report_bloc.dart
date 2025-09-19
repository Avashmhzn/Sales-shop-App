import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:saleup_app/core/network/dio_client.dart';
import 'package:saleup_app/model/ledger_report_response.dart';
import 'ledger_report_event.dart';
import 'ledger_report_state.dart';

class LedgerReportBloc extends Bloc<LedgerReportEvent, LedgerReportState> {
  final DioClient dioClient;
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  LedgerReportBloc({required this.dioClient}) : super(LedgerReportInitial()) {
    on<FetchAndDownloadLedgerReport>(_onFetchAndDownloadLedgerReport);
  }

  Future<void> _onFetchAndDownloadLedgerReport(
    FetchAndDownloadLedgerReport event,
    Emitter<LedgerReportState> emit,
  ) async {
    emit(LedgerReportLoading());
    try {
      final response = await dioClient.dio.get(
        '/ledger/get_ledger_report/',
        queryParameters: {
          'start_date': event.startDate,
          'end_date': event.endDate,
          'acc_head': event.accHead,
        },
      );

      if (response.statusCode == 200) {
        final ledgerReport = LedgerReport.fromJson(response.data);
        if (ledgerReport.success && ledgerReport.data.isNotEmpty) {
          await _showDownloadDialog(event, ledgerReport, emit);
          emit(LedgerReportSuccess(ledgerReport));
        } else {
          emit(const LedgerReportFailure('No data available for the selected filters'));
        }
      } else {
        emit(const LedgerReportFailure('Error fetching ledger report'));
      }
    } catch (e) {
      emit(LedgerReportFailure('An error occurred: $e at ${DateTime.now().toIso8601String()}'));
    }
  }

  Future<void> _showDownloadDialog(
    FetchAndDownloadLedgerReport event,
    LedgerReport ledgerReport,
    Emitter<LedgerReportState> emit,
  ) async {
    final context = navigatorKey.currentContext!;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Download Options'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                onPressed: () async {
                  await dioClient.downloadAsPdf(ledgerReport, event.startDate, event.endDate);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('PDF downloaded successfully')),
                  );
                },
                child: const Text('Download as PDF'),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () async {
                  await dioClient.downloadAsExcel(ledgerReport, event.startDate, event.endDate);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Excel downloaded successfully')),
                  );
                },
                child: const Text('Download as Excel'),
              ),
            ],
          ),
        );
      },
    );
  }
}