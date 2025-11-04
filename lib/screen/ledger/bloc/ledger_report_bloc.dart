// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:saleup_app/model/ledger_report_response.dart';
// import 'package:saleup_app/core/network/dio_client.dart';
// import 'ledger_report_event.dart';
// import 'ledger_report_state.dart';
// import 'dart:developer';
// import 'package:path_provider/path_provider.dart';
// import 'dart:io';

// class LedgerReportBloc extends Bloc<LedgerReportEvent, LedgerReportState> {
//   final DioClient dioClient;
//   final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

//   LedgerReportBloc({required this.dioClient}) : super(LedgerReportInitial()) {
//     on<FetchFilterOptions>(_onFetchFilterOptions);
//     on<FetchAndDownloadLedgerReport>(_onFetchAndDownloadLedgerReport);
//     on<ClearFilterEvent>(_onClearFilterEvent);
//   }

//   Future<void> _onFetchFilterOptions(
//     FetchFilterOptions event,
//     Emitter<LedgerReportState> emit,
//   ) async {
//     emit(LedgerReportLoading());
//     try {
//       final response = await dioClient.dio.get(
//         '/ledger/get_ledger_report/',
//         queryParameters: {'start_date': '2025-01-01', 'end_date': '2025-12-31'},
//       );
//       if (response.statusCode == 200) {
//         final ledgerReport = LedgerReport.fromJson(response.data);
//         log('API Response Data: ${response.data}');
//         final accHeads = ledgerReport.data
//                 ?.where((account) => account.accountId != null && account.accountName != null)
//                 .map((account) => account.accountName!)
//                 .toList() ??
//             [];
//         if (accHeads.isNotEmpty) {
//           emit(FilterOptionsLoaded(accHeads: accHeads));
//         } else {
//           emit(const LedgerReportFailure('No account heads available'));
//         }
//       } else {
//         emit(LedgerReportFailure('Error fetching account heads: ${response.statusCode}'));
//       }
//     } catch (e) {
//       emit(LedgerReportFailure('An error occurred: $e'));
//     }
//   }

//   Future<void> _onFetchAndDownloadLedgerReport(
//     FetchAndDownloadLedgerReport event,
//     Emitter<LedgerReportState> emit,
//   ) async {
//     emit(LedgerReportLoading());
//     try {
//       final response = await dioClient.dio.get(
//         '/ledger/get_ledger_report/',
//         queryParameters: {
//           'start_date': event.startDate,
//           'end_date': event.endDate,
//           'acc_head': event.accHead,
//         },
//       );

//       if (response.statusCode == 200) {
//         final ledgerReport = LedgerReport.fromJson(response.data);
//         log('API Response Data: ${response.data}');
//         if (ledgerReport.success &&
//             ledgerReport.data != null &&
//             ledgerReport.data!.isNotEmpty &&
//             ledgerReport.data!.first.ledger != null &&
//             hasData(ledgerReport.data!.first.ledger!)) {
//           await _showDownloadDialog(event, ledgerReport, emit);
//           emit(LedgerReportSuccess(ledgerReport));
//         } else {
//           emit(const LedgerReportFailure('No data available for the selected filters'));
//         }
//       } else {
//         emit(LedgerReportFailure('Error fetching ledger report: ${response.statusCode}'));
//       }
//     } catch (e) {
//       emit(LedgerReportFailure('An error occurred: $e'));
//     }
//   }

//   void _onClearFilterEvent(
//     ClearFilterEvent event,
//     Emitter<LedgerReportState> emit,
//   ) {
//     emit(LedgerReportInitial());
//   }

//   Future<void> _showDownloadDialog(
//     FetchAndDownloadLedgerReport event,
//     LedgerReport ledgerReport,
//     Emitter<LedgerReportState> emit,
//   ) async {
//     final context = navigatorKey.currentContext!;
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: const Text('Download Options'),
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               ElevatedButton(
//                 onPressed: () async {
//                   try {
//                     await dioClient.downloadAsPdf(ledgerReport, event.startDate, event.endDate);
//                     log('PDF download initiated successfully');
//                     final output = Platform.isAndroid ? await getDownloadsDirectory() ?? await getApplicationDocumentsDirectory() : await getApplicationDocumentsDirectory();
//                     final filePath = '${output.path}/ledger_report_${DateTime.now().toIso8601String().replaceAll(':', '-')}.pdf';
//                     Navigator.pop(context);
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       SnackBar(
//                         content: Text(Platform.isAndroid
//                             ? 'PDF downloaded to Downloads folder: $filePath'
//                             : 'PDF downloaded to Files app: $filePath'),
//                       ),
//                     );
//                   } catch (e) {
//                     log('Failed to initiate PDF download: $e');
//                     Navigator.pop(context);
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       const SnackBar(content: Text('Failed to download PDF')),
//                     );
//                   }
//                 },
//                 child: const Text('Download as PDF'),
//               ),
//               const SizedBox(height: 10),
//               ElevatedButton(
//                 onPressed: () async {
//                   try {
//                     await dioClient.downloadAsExcel(ledgerReport, event.startDate, event.endDate);
//                     log('Excel download initiated successfully');
//                     final output = Platform.isAndroid ? await getDownloadsDirectory() ?? await getApplicationDocumentsDirectory() : await getApplicationDocumentsDirectory();
//                     final filePath = '${output.path}/ledger_report_${DateTime.now().toIso8601String().replaceAll(':', '-')}.csv';
//                     Navigator.pop(context);
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       SnackBar(
//                         content: Text(Platform.isAndroid
//                             ? 'Excel downloaded to Downloads folder: $filePath'
//                             : 'Excel downloaded to Files app: $filePath'),
//                       ),
//                     );
//                   } catch (e) {
//                     log('Failed to initiate Excel download: $e');
//                     Navigator.pop(context);
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       const SnackBar(content: Text('Failed to download Excel')),
//                     );
//                   }
//                 },
//                 child: const Text('Download as Excel'),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   bool hasData(List<dynamic>? data) => data != null && data.isNotEmpty;
// }
// // lib/screen/ledger/bloc/ledger_report_bloc.dart
// import 'dart:developer';
// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:saleup_app/core/network/dio_client.dart';
// import 'package:saleup_app/model/ledger_report_response.dart';
// import 'package:saleup_app/model/account_heads_response.dart'; // ✅ NEW IMPORT
// import 'ledger_report_event.dart';
// import 'ledger_report_state.dart';

// class LedgerReportBloc extends Bloc<LedgerReportEvent, LedgerReportState> {
//   final DioClient dioClient;
//   final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

//   LedgerReportBloc({required this.dioClient}) : super(LedgerReportInitial()) {
//     on<FetchFilterOptions>(_onFetchFilterOptions);
//     on<FetchAndDownloadLedgerReport>(_onFetchAndDownloadLedgerReport);
//     on<ClearFilterEvent>(_onClearFilterEvent);
//   }

//   // ✅ CHANGED: Now calls account-heads endpoint
//   Future<void> _onFetchFilterOptions(
//     FetchFilterOptions event,
//     Emitter<LedgerReportState> emit,
//   ) async {
//     emit(LedgerReportLoading());
//     try {
//       final response =
//           await dioClient.dio.get('/account-heads/get_account_heads/');

//       if (response.statusCode == 200 && response.data['success'] == true) {
//         final accountResponse = AccountHeadsResponse.fromJson(response.data);
//         final List<AccountHeadData> heads = accountResponse.data;
//         final Map<int, String> idToName = {};

//         for (final head in heads) {
//           idToName[head.id] = head.name;
//         }

//         log('Loaded ${heads.length} account heads');
//         emit(FilterOptionsLoaded(
//           accountHeads: heads,
//           idToName: idToName,
//         ));
//       } else {
//         emit(LedgerReportFailure(
//             'Failed to load accounts: ${response.statusMessage}'));
//       }
//     } catch (e) {
//       emit(LedgerReportFailure('Error loading accounts: $e'));
//     }
//   }

//   // ✅ CHANGED: Now uses int accHeadId
//   Future<void> _onFetchAndDownloadLedgerReport(
//     FetchAndDownloadLedgerReport event,
//     Emitter<LedgerReportState> emit,
//   ) async {
//     emit(LedgerReportLoading());
//     try {
//       final response = await dioClient.dio.get(
//         '/ledger/get_ledger_report/',
//         queryParameters: {
//           'start_date': event.startDate,
//           'end_date': event.endDate,
//           'acc_head': event.accHeadId, // ✅ CHANGED: int instead of string
//         },
//       );

//       if (response.statusCode == 200) {
//         final ledgerReport = LedgerReport.fromJson(response.data);
//         if (ledgerReport.success &&
//             ledgerReport.data != null &&
//             ledgerReport.data!.isNotEmpty &&
//             _hasData(ledgerReport.data!.first.ledger!)) {
//           await _showDownloadDialog(event, ledgerReport);
//           emit(LedgerReportSuccess(ledgerReport));
//         } else {
//           emit(const LedgerReportFailure('No ledger data found'));
//         }
//       } else {
//         emit(LedgerReportFailure('HTTP ${response.statusCode}'));
//       }
//     } catch (e) {
//       emit(LedgerReportFailure('Error: $e'));
//     }
//   }

//   void _onClearFilterEvent(
//       ClearFilterEvent event, Emitter<LedgerReportState> emit) {
//     emit(LedgerReportInitial());
//   }

//   bool _hasData(List<dynamic>? data) => data != null && data.isNotEmpty;

//   Future<void> _showDownloadDialog(
//     FetchAndDownloadLedgerReport event,
//     LedgerReport report,
//   ) async {
//     final context = navigatorKey.currentContext!;
//     showDialog(
//       context: context,
//       builder: (_) => AlertDialog(
//         title: const Text('Download Options'),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             ElevatedButton(
//               onPressed: () => _download(
//                   'PDF',
//                   () => dioClient.downloadAsPdf(
//                       report, event.startDate, event.endDate),
//                   context),
//               child: const Text('Download PDF'),
//             ),
//             const SizedBox(height: 8),
//             ElevatedButton(
//               onPressed: () => _download(
//                   'Excel',
//                   () => dioClient.downloadAsExcel(
//                       report, event.startDate, event.endDate),
//                   context),
//               child: const Text('Download Excel'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Future<void> _download(
//       String type, Future<void> Function() fn, BuildContext ctx) async {
//     try {
//       await fn();
//       final dir = Platform.isAndroid
//           ? (await getDownloadsDirectory()) ??
//               await getApplicationDocumentsDirectory()
//           : await getApplicationDocumentsDirectory();
//       final ext = type == 'PDF' ? 'pdf' : 'csv';
//       final path =
//           '${dir.path}/ledger_report_${DateTime.now().toIso8601String().replaceAll(':', '-')}.$ext';

//       Navigator.pop(ctx);
//       ScaffoldMessenger.of(ctx).showSnackBar(
//         SnackBar(content: Text('$type saved: $path')),
//       );
//     } catch (e) {
//       Navigator.pop(ctx);
//       ScaffoldMessenger.of(ctx).showSnackBar(
//         SnackBar(content: Text('Failed to download $type')),
//       );
//     }
//   }
// }
// lib/screen/ledger/bloc/ledger_report_bloc.dart
import 'dart:developer';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:saleup_app/core/network/dio_client.dart';
import 'package:saleup_app/model/ledger_report_response.dart';
import 'package:saleup_app/model/account_heads_response.dart';
import 'ledger_report_event.dart';
import 'ledger_report_state.dart';

class LedgerReportBloc extends Bloc<LedgerReportEvent, LedgerReportState> {
  final DioClient dioClient;

  LedgerReportBloc({required this.dioClient}) : super(LedgerReportInitial()) {
    on<FetchFilterOptions>(_onFetchFilterOptions);
    on<FetchAndDownloadLedgerReport>(_onFetchAndDownloadLedgerReport);
    on<ClearFilterEvent>(_onClearFilterEvent);
  }

  Future<void> _onFetchFilterOptions(
    FetchFilterOptions event,
    Emitter<LedgerReportState> emit,
  ) async {
    emit(LedgerReportLoading());
    try {
      final response =
          await dioClient.dio.get('/account-heads/get_account_heads/');

      if (response.statusCode == 200 && response.data['success'] == true) {
        final accountResponse = AccountHeadsResponse.fromJson(response.data);
        final List<AccountHeadData> heads = accountResponse.data;
        final Map<int, String> idToName = {for (var h in heads) h.id: h.name};

        log('Loaded ${heads.length} account heads');
        emit(FilterOptionsLoaded(accountHeads: heads, idToName: idToName));
      } else {
        emit(LedgerReportFailure('Failed: ${response.statusMessage}'));
      }
    } catch (e) {
      emit(LedgerReportFailure('Error: $e'));
    }
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
          'acc_head': event.accHeadId,
        },
      );

      if (response.statusCode == 200) {
        final ledgerReport = LedgerReport.fromJson(response.data);
        if (ledgerReport.success &&
            ledgerReport.data != null &&
            ledgerReport.data!.isNotEmpty &&
            _hasData(ledgerReport.data!.first.ledger!)) {
          // REMOVED showDialog → Just emit success
          emit(LedgerReportSuccess(ledgerReport));
        } else {
          emit(const LedgerReportFailure('No ledger data found'));
        }
      } else {
        emit(LedgerReportFailure('HTTP ${response.statusCode}'));
      }
    } catch (e) {
      emit(LedgerReportFailure('Error: $e'));
    }
  }

  void _onClearFilterEvent(
      ClearFilterEvent event, Emitter<LedgerReportState> emit) {
    emit(LedgerReportInitial());
  }

  bool _hasData(List<dynamic>? data) => data != null && data.isNotEmpty;
}
