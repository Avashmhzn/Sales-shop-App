// import 'dart:developer';
// import 'dart:io';
// import 'package:csv/csv.dart';
// import 'package:dio/dio.dart';
// import 'package:dio/io.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:pdf/pdf.dart';
// import 'package:pdf/widgets.dart' as pw;
// import 'package:printing/printing.dart';
// import 'package:saleup_app/core/network/api_endpoints.dart';
// import 'package:saleup_app/model/ledger_report_response.dart';
// import 'package:saleup_app/model/stock_ledger_response.dart';
// import 'package:saleup_app/model/trial_balance_report_response.dart';
// import 'package:saleup_app/services/auth_service.dart';
// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';
// import 'package:permission_handler/permission_handler.dart';

// class DioClient {
//   static final DioClient _instance = DioClient._internal();
//   final Dio dio = Dio();

//   factory DioClient() {
//     return _instance;
//   }

//   DioClient._internal() {
//     dio.options.baseUrl = Api.backendUrl;
//     dio.options.connectTimeout = const Duration(seconds: 30);
//     dio.options.receiveTimeout = const Duration(seconds: 30);
//     dio.options.sendTimeout = const Duration(seconds: 30);

//     dio.options.headers = {
//       'Content-Type': 'application/json',
//       'Accept': 'application/json',
//     };

//     (dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
//       final client = HttpClient();
//       client.badCertificateCallback = (cert, host, port) => true;
//       return client;
//     };

//     dio.options.validateStatus = (status) {
//       return status != null && status < 500;
//     };

//     dio.interceptors.add(InterceptorsWrapper(
//       onRequest: (options, handler) async {
//         final unauthenticatedEndpoints = [
//           '/auth/login/',
//           '/auth/forgot_password/',
//           '/auth/verify_forgot_password_otp/',
//           '/auth/reset_password/',
//           '/chat/',
//         ];
//         if (!unauthenticatedEndpoints.contains(options.path)) {
//           final token = await AuthService().getAccessToken();
//           if (token != null) {
//             options.headers['Authorization'] = 'Bearer $token';
//             log('Authorization header set for ${options.path} with token: $token');
//           } else {
//             log('No access token available for ${options.path}');
//           }
//         } else {
//           log('Skipping Authorization header for ${options.path}');
//         }
//         log('Request: ${options.method} ${options.path}, Headers: ${options.headers}, Data: ${options.data}');
//         return handler.next(options);
//       },
//       onResponse: (response, handler) {
//         log('Response: ${response.statusCode} ${response.requestOptions.path}, Data: ${response.data}');
//         return handler.next(response);
//       },
//       onError: (DioException error, ErrorInterceptorHandler handler) async {
//         log('Error: ${error.response?.statusCode} ${error.requestOptions.path}, Data: ${error.response?.data}, Message: ${error.message}');
//         if (error.response?.statusCode == 401) {
//           log('401 error: Token invalid or expired');
//           if (!error.requestOptions.path.contains('/auth/login/')) {
//             log('Clearing tokens and navigating to login');
//             await AuthService().clearTokens();
//           }
//         }
//         return handler.next(error);
//       },
//     ));
//   }

//   Future<bool> isTokenValid() async {
//     try {
//       final token = await AuthService().getAccessToken();
//       return token != null;
//     } catch (e) {
//       log('Error checking token validity: $e');
//       return false;
//     }
//   }

//   Future<void> logout(BuildContext context) async {
//     try {
//       await AuthService().clearTokens();
//       context.go('/login');
//     } catch (e) {
//       log('Error during logout: $e');
//     }
//   }

//   Future<bool> refreshToken() async {
//     try {
//       final refreshToken = await AuthService().getRefreshToken();
//       if (refreshToken == null) {
//         log('No refresh token available');
//         return false;
//       }

//       log('Attempting to refresh token');
//       final response = await dio
//           .post('/auth/refresh/', data: {'refresh_token': refreshToken});

//       if (response.statusCode == 200 &&
//           response.data['success'] == true &&
//           response.data['data'] != null) {
//         final data = response.data['data'];
//         if (data.containsKey('access_token')) {
//           await AuthService().saveTokens(
//             accessToken: data['access_token'],
//             refreshToken: data['refresh_token'] ?? refreshToken,
//             userId: await AuthService().getUserId() ?? 0,
//           );
//           log('Token refresh successful');
//           return true;
//         }
//       }
//       log('Token refresh failed: ${response.data}');
//       return false;
//     } catch (e) {
//       log('Refresh token error: $e');
//       return false;
//     }
//   }

//   Future<bool> _requestPermission() async {
//     if (Platform.isAndroid) {
//       final status = await Permission.storage.request();
//       if (!status.isGranted) {
//         log('Storage permission denied on Android');
//         return false;
//       }
//       return true;
//     }
//     return true;
//   }

//   Future<Directory> _getDownloadDirectory() async {
//     if (Platform.isAndroid) {
//       try {
//         final directory = await getDownloadsDirectory();
//         if (directory != null) {
//           return directory;
//         }
//         log('Downloads directory not available, falling back to Documents directory');
//       } catch (e) {
//         log('Error accessing Downloads directory: $e');
//       }
//     }
//     return await getApplicationDocumentsDirectory();
//   }

//   // ────────────────────────────
//   // YOUR ORIGINAL METHODS (UNTOUCHED)
//   // ────────────────────────────
//   Future<void> downloadAsPdf(
//       LedgerReport ledgerReport, String startDate, String endDate) async {
//     try {
//       final granted = await _requestPermission();
//       if (!granted) {
//         log('Permission denied for PDF download');
//         throw Exception('Permission denied to save file');
//       }

//       final pdf = pw.Document();

//       if (ledgerReport.data!.isNotEmpty) {
//         final account = ledgerReport.data!.first;
//         pdf.addPage(
//           pw.Page(
//             build: (pw.Context context) {
//               return pw.Column(
//                 crossAxisAlignment: pw.CrossAxisAlignment.start,
//                 children: [
//                   pw.Text('Ledger Report',
//                       style: pw.TextStyle(
//                           fontSize: 24, fontWeight: pw.FontWeight.bold)),
//                   pw.Text('Account: ${account.accountName}',
//                       style: const pw.TextStyle(fontSize: 16)),
//                   pw.Text('Period: $startDate to $endDate',
//                       style: const pw.TextStyle(fontSize: 16)),
//                   pw.SizedBox(height: 20),
//                   pw.Table.fromTextArray(
//                     headers: [
//                       'Date',
//                       'Voucher #',
//                       'Debit',
//                       'Credit',
//                       'Balance'
//                     ],
//                     data: account.ledger!.map((entry) {
//                       return [
//                         entry.voucherDate!.split('T')[0],
//                         entry.voucherNumber,
//                         entry.debit!.toStringAsFixed(2),
//                         entry.credit!.toStringAsFixed(2),
//                         entry.runningBalance!.toStringAsFixed(2),
//                       ];
//                     }).toList(),
//                   ),
//                 ],
//               );
//             },
//           ),
//         );
//       } else {
//         pdf.addPage(
//           pw.Page(
//             build: (pw.Context context) {
//               return pw.Text('No ledger data available',
//                   style: const pw.TextStyle(fontSize: 16));
//             },
//           ),
//         );
//       }

//       final output = await _getDownloadDirectory();
//       final file = File(
//           '${output.path}/ledger_report_${DateTime.now().toIso8601String().replaceAll(':', '-')}.pdf');
//       await file.writeAsBytes(await pdf.save());
//       log('PDF download completed successfully: ${file.path}');
//     } catch (e) {
//       log('PDF download failed: $e');
//       rethrow;
//     }
//   }

//   Future<void> downloadAsExcel(
//       LedgerReport ledgerReport, String startDate, String endDate) async {
//     try {
//       final granted = await _requestPermission();
//       if (!granted) {
//         log('Permission denied for Excel download');
//         throw Exception('Permission denied to save file');
//       }

//       final csvData = <List<dynamic>>[];
//       csvData.add(['Date', 'Voucher #', 'Debit', 'Credit', 'Balance']);

//       if (ledgerReport.data!.isNotEmpty) {
//         final account = ledgerReport.data!.first;
//         csvData.addAll(account.ledger!.map((entry) => [
//               entry.voucherDate!.split('T')[0],
//               entry.voucherNumber,
//               entry.debit!.toStringAsFixed(2),
//               entry.credit!.toStringAsFixed(2),
//               entry.runningBalance!.toStringAsFixed(2),
//             ]));
//       }

//       final csv = const ListToCsvConverter().convert(csvData);
//       final output = await _getDownloadDirectory();
//       final file = File(
//           '${output.path}/ledger_report_${DateTime.now().toIso8601String().replaceAll(':', '-')}.csv');
//       await file.writeAsString(csv);
//       log('Excel (CSV) download completed successfully: ${file.path}');
//     } catch (e) {
//       log('Excel (CSV) download failed: $e');
//       rethrow;
//     }
//   }
//   // ─────────────────────────────────────────────────────────────
// // STOCK LEDGER PDF – FIXED: correct totals
// // ─────────────────────────────────────────────────────────────
//   Future<void> downloadStockLedgerAsPdf(
//     StockLedgerReport report,
//     String startDate,
//     String endDate,
//   ) async {
//     try {
//       final granted = await _requestPermission();
//       if (!granted) throw Exception('Permission denied');

//       final pdf = pw.Document();

//       if (report.data?.isNotEmpty != true) {
//         pdf.addPage(
//             pw.Page(build: (_) => pw.Center(child: pw.Text('No data'))));
//         return;
//       }

//       final account = report.data!.first;
//       final productName = account.productName ?? 'N/A';
//       final entries = account.ledger ?? [];

//       // ── Compute totals (CORRECTED) ───────────────────────
//       double openingQty = 0, openingRate = 0, openingAmt = 0;
//       double purQty = 0, purRate = 0, purAmt = 0;
//       double purRetQty = 0, purRetRate = 0, purRetAmt = 0;
//       double saleQty = 0, saleRate = 0, saleAmt = 0;
//       double saleRetQty = 0, saleRetRate = 0, saleRetAmt = 0;
//       double closingQty = 0, closingRate = 0, closingAmt = 0;

//       for (final e in entries) {
//         // ----- Opening -------------------------------------------------
//         if (e.opening != null && e.opening! > 0) {
//           openingQty += e.opening!;
//           openingRate = e.costPrice ?? 0; // last known cost
//           openingAmt += e.opening! * openingRate;
//         }

//         // ----- Purchase ------------------------------------------------
//         if (e.purchase != null && e.purchase! > 0) {
//           purQty += e.purchase!;
//           purRate = e.costPrice ?? 0;
//           purAmt += e.purchase! * purRate;
//         }

//         // ----- Purchase Return -----------------------------------------
//         if (e.purchase != null && e.purchase! < 0) {
//           purRetQty += e.purchase!.abs();
//           purRetRate = e.costPrice ?? 0;
//           purRetAmt += e.purchase!.abs() * purRetRate;
//         }

//         // ----- Sales ---------------------------------------------------
//         if (e.sales != null && e.sales! > 0) {
//           saleQty += e.sales!;
//           saleRate = e.sellingPrice ?? 0;
//           saleAmt += e.sales! * saleRate;
//         }

//         // ----- Sale Return ---------------------------------------------
//         if (e.sales != null && e.sales! < 0) {
//           saleRetQty += e.sales!.abs();
//           saleRetRate = e.sellingPrice ?? 0;
//           saleRetAmt += e.sales!.abs() * saleRetRate;
//         }

//         // ----- Closing -------------------------------------------------
//         if (e.closing != null) {
//           closingQty = e.closing!;
//           closingRate = e.costPrice ?? e.sellingPrice ?? 0;
//           closingAmt = closingQty * closingRate;
//         }
//       }

//       // ── the rest of the PDF building code stays unchanged ──
//       pdf.addPage(
//         pw.Page(
//           pageFormat: PdfPageFormat.a4.landscape,
//           margin: const pw.EdgeInsets.all(20),
//           build: (_) => pw.Column(
//             crossAxisAlignment: pw.CrossAxisAlignment.start,
//             children: [
//               pw.Text('Stock Ledger Summary',
//                   style: pw.TextStyle(
//                       fontSize: 20, fontWeight: pw.FontWeight.bold)),
//               pw.SizedBox(height: 4),
//               pw.Text('Product: $productName'),
//               pw.Text('Period: $startDate to $endDate'),
//               pw.SizedBox(height: 16),
//               pw.Table(
//                 border: pw.TableBorder.all(width: 1, color: PdfColors.black),
//                 columnWidths: {
//                   0: const pw.FixedColumnWidth(90),
//                   for (int i = 1; i < 19; i++) i: const pw.FixedColumnWidth(78),
//                 },
//                 children: [
//                   // SECTION HEADER ROW (unchanged)
//                   pw.TableRow(
//                     decoration: const pw.BoxDecoration(
//                       border: pw.TableBorder(
//                         top: pw.BorderSide(width: 1, color: PdfColors.black),
//                         bottom: pw.BorderSide(width: 1, color: PdfColors.black),
//                         left: pw.BorderSide.none,
//                         right: pw.BorderSide.none,
//                         horizontalInside: pw.BorderSide.none,
//                         verticalInside: pw.BorderSide.none,
//                       ),
//                     ),
//                     children: [
//                       pw.Container(),
//                       _sectionLabelOneLine('Opening'),
//                       pw.Container(),
//                       pw.Container(),
//                       _sectionLabelOneLine('Purchase'),
//                       pw.Container(),
//                       pw.Container(),
//                       _sectionLabelOneLine('Purchase Return'),
//                       pw.Container(),
//                       pw.Container(),
//                       _sectionLabelOneLine('Sales'),
//                       pw.Container(),
//                       pw.Container(),
//                       _sectionLabelOneLine('Sale Return'),
//                       pw.Container(),
//                       pw.Container(),
//                       _sectionLabelOneLine('Closing'),
//                       pw.Container(),
//                       pw.Container(),
//                     ],
//                   ),

//                   // SUB‑HEADER ROW
//                   pw.TableRow(
//                     children: [
//                       _headerCell('Product'),
//                       ...List.generate(
//                           18,
//                           (i) =>
//                               _subHeaderCell(['Qty', 'Rate', 'Amount'][i % 3])),
//                     ],
//                   ),

//                   // DATA ROW
//                   pw.TableRow(
//                     children: [
//                       _dataCell(productName, bold: true),
//                       _dataCell(openingQty.toStringAsFixed(0)),
//                       _dataCell(openingRate.toStringAsFixed(2)),
//                       _dataCell(openingAmt.toStringAsFixed(2)),
//                       _dataCell(purQty.toStringAsFixed(0)),
//                       _dataCell(purRate.toStringAsFixed(2)),
//                       _dataCell(purAmt.toStringAsFixed(2)),
//                       _dataCell(purRetQty.toStringAsFixed(0)),
//                       _dataCell(purRetRate.toStringAsFixed(2)),
//                       _dataCell(purRetAmt.toStringAsFixed(2)),
//                       _dataCell(saleQty.toStringAsFixed(0)),
//                       _dataCell(saleRate.toStringAsFixed(2)),
//                       _dataCell(saleAmt.toStringAsFixed(2)),
//                       _dataCell(saleRetQty.toStringAsFixed(0)),
//                       _dataCell(saleRetRate.toStringAsFixed(2)),
//                       _dataCell(saleRetAmt.toStringAsFixed(2)),
//                       _dataCell(closingQty.toStringAsFixed(0)),
//                       _dataCell(closingRate.toStringAsFixed(2)),
//                       _dataCell(closingAmt.toStringAsFixed(2)),
//                     ],
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       );

//       final dir = await _getDownloadDirectory();
//       final file = File(
//           '${dir.path}/stock_ledger_summary_${DateTime.now().millisecondsSinceEpoch}.pdf');
//       await file.writeAsBytes(await pdf.save());
//       log('Stock Ledger PDF saved: ${file.path}');
//     } catch (e) {
//       log('Stock Ledger PDF failed: $e');
//       rethrow;
//     }
//   }

// // ─────────────────────────────────────────────────────────────
// // STOCK LEDGER EXCEL (CSV) – FIXED: correct totals
// // ─────────────────────────────────────────────────────────────
//   Future<void> downloadStockLedgerAsExcel(
//     StockLedgerReport report,
//     String startDate,
//     String endDate,
//   ) async {
//     try {
//       final granted = await _requestPermission();
//       if (!granted) throw Exception('Permission denied');

//       double openingQty = 0, openingRate = 0, openingAmt = 0;
//       double purQty = 0, purRate = 0, purAmt = 0;
//       double purRetQty = 0, purRetRate = 0, purRetAmt = 0;
//       double saleQty = 0, saleRate = 0, saleAmt = 0;
//       double saleRetQty = 0, saleRetRate = 0, saleRetAmt = 0;
//       double closingQty = 0, closingRate = 0, closingAmt = 0;

//       if (report.data?.isNotEmpty == true) {
//         final entries = report.data!.first.ledger ?? [];

//         for (final e in entries) {
//           // ----- Opening -------------------------------------------------
//           if (e.opening != null && e.opening! > 0) {
//             openingQty += e.opening!;
//             openingRate = e.costPrice ?? 0;
//             openingAmt += e.opening! * openingRate;
//           }

//           // ----- Purchase ------------------------------------------------
//           if (e.purchase != null && e.purchase! > 0) {
//             purQty += e.purchase!;
//             purRate = e.costPrice ?? 0;
//             purAmt += e.purchase! * purRate;
//           }

//           // ----- Purchase Return -----------------------------------------
//           if (e.purchase != null && e.purchase! < 0) {
//             purRetQty += e.purchase!.abs();
//             purRetRate = e.costPrice ?? 0;
//             purRetAmt += e.purchase!.abs() * purRetRate;
//           }

//           // ----- Sales ---------------------------------------------------
//           if (e.sales != null && e.sales! > 0) {
//             saleQty += e.sales!;
//             saleRate = e.sellingPrice ?? 0;
//             saleAmt += e.sales! * saleRate;
//           }

//           // ----- Sale Return ---------------------------------------------
//           if (e.sales != null && e.sales! < 0) {
//             saleRetQty += e.sales!.abs();
//             saleRetRate = e.sellingPrice ?? 0;
//             saleRetAmt += e.sales!.abs() * saleRetRate;
//           }

//           // ----- Closing -------------------------------------------------
//           if (e.closing != null) {
//             closingQty = e.closing!;
//             closingRate = e.costPrice ?? e.sellingPrice ?? 0;
//             closingAmt = closingQty * closingRate;
//           }
//         }
//       }

//       final rows = <List<dynamic>>[
//         ['Stock Ledger Summary'],
//         ['Product', report.data?.first.productName ?? 'N/A'],
//         ['Period', '$startDate - $endDate'],
//         [],
//         [
//           'Product',
//           'Opening',
//           '',
//           '',
//           'Purchase',
//           '',
//           '',
//           'Purchase Return',
//           '',
//           '',
//           'Sales',
//           '',
//           '',
//           'Sale Return',
//           '',
//           '',
//           'Closing',
//           '',
//           '',
//         ],
//         [
//           '',
//           'Qty',
//           'Rate',
//           'Amount',
//           'Qty',
//           'Rate',
//           'Amount',
//           'Qty',
//           'Rate',
//           'Amount',
//           'Qty',
//           'Rate',
//           'Amount',
//           'Qty',
//           'Rate',
//           'Amount',
//           'Qty',
//           'Rate',
//           'Amount',
//         ],
//         [
//           report.data?.first.productName ?? 'N/A',
//           openingQty.toStringAsFixed(0),
//           openingRate.toStringAsFixed(2),
//           openingAmt.toStringAsFixed(2),
//           purQty.toStringAsFixed(0),
//           purRate.toStringAsFixed(2),
//           purAmt.toStringAsFixed(2),
//           purRetQty.toStringAsFixed(0),
//           purRetRate.toStringAsFixed(2),
//           purRetAmt.toStringAsFixed(2),
//           saleQty.toStringAsFixed(0),
//           saleRate.toStringAsFixed(2),
//           saleAmt.toStringAsFixed(2),
//           saleRetQty.toStringAsFixed(0),
//           saleRetRate.toStringAsFixed(2),
//           saleRetAmt.toStringAsFixed(2),
//           closingQty.toStringAsFixed(0),
//           closingRate.toStringAsFixed(2),
//           closingAmt.toStringAsFixed(2),
//         ],
//       ];

//       final csv = const ListToCsvConverter().convert(rows);
//       final dir = await _getDownloadDirectory();
//       final file = File(
//           '${dir.path}/stock_ledger_summary_${DateTime.now().millisecondsSinceEpoch}.csv');
//       await file.writeAsString(csv);
//       log('Stock Ledger CSV saved: ${file.path}');
//     } catch (e) {
//       log('Stock Ledger CSV failed: $e');
//       rethrow;
//     }
//   }

//   // ─────────────────────────────────────────────────────────────
//   // HELPER WIDGETS (PDF ONLY)
//   // ─────────────────────────────────────────────────────────────
//   pw.Widget _headerCell(String text) => pw.Container(
//         padding: const pw.EdgeInsets.all(6),
//         alignment: pw.Alignment.center,
//         child: pw.Text(text,
//             style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11)),
//       );

//   pw.Widget _subHeaderCell(String text) => pw.Container(
//         padding: const pw.EdgeInsets.all(4),
//         alignment: pw.Alignment.center,
//         child: pw.Text(text,
//             style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9)),
//       );

//   pw.Widget _dataCell(String text, {bool bold = false}) => pw.Container(
//         padding: const pw.EdgeInsets.all(4),
//         alignment: pw.Alignment.center,
//         child: pw.Text(
//           text,
//           style: pw.TextStyle(
//               fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
//               fontSize: 10),
//         ),
//       );

//   pw.Widget _sectionLabelOneLine(String text) => pw.Container(
//         padding: const pw.EdgeInsets.all(6),
//         alignment: pw.Alignment.center,
//         decoration: const pw.BoxDecoration(color: PdfColors.grey300),
//         child: pw.Text(
//           text,
//           style: pw.TextStyle(
//             fontWeight: pw.FontWeight.bold,
//             fontSize: 11,
//           ),
//           textAlign: pw.TextAlign.center,
//         ),
//       );

//   // ─────────────────────────────────────────────────────────────
//   // TRIAL BALANCE (UNTOUCHED)
//   // ─────────────────────────────────────────────────────────────
//   Future<TrialBalanceReport> fetchTrialBalance(String start, String end) async {
//     final response = await dio.get(
//       '/ledger/get_trial_balance/',
//       queryParameters: {'start_date': start, 'end_date': end},
//     );
//     return TrialBalanceReport.fromJson(response.data);
//   }

//   Future<void> downloadTrialBalanceAsPdf(
//     TrialBalanceReport report,
//     String startDate,
//     String endDate,
//   ) async {
//     try {
//       final granted = await _requestPermission();
//       if (!granted) throw Exception('Permission denied');

//       final pdf = pw.Document();

//       final List<TrialBalanceAccount> accounts = report.data ?? [];

//       pdf.addPage(
//         pw.Page(
//           pageFormat: PdfPageFormat.a4,
//           margin: const pw.EdgeInsets.all(40),
//           build: (pw.Context ctx) => pw.Column(
//             crossAxisAlignment: pw.CrossAxisAlignment.start,
//             children: [
//               pw.Text('Trial Balance Report',
//                   style: pw.TextStyle(
//                       fontSize: 22, fontWeight: pw.FontWeight.bold)),
//               pw.SizedBox(height: 8),
//               pw.Text('Period: $startDate to $endDate'),
//               pw.SizedBox(height: 4),
//               pw.Text(
//                 report.isDayOpen == true ? 'Day is OPEN' : 'Day is CLOSED',
//                 style: pw.TextStyle(
//                   color: report.isDayOpen == true
//                       ? PdfColors.green
//                       : PdfColors.red,
//                   fontWeight: pw.FontWeight.bold,
//                 ),
//               ),
//               pw.SizedBox(height: 20),
//               pw.Table(
//                 border: pw.TableBorder.all(),
//                 columnWidths: {
//                   0: const pw.FlexColumnWidth(4),
//                   1: const pw.FlexColumnWidth(2),
//                   2: const pw.FlexColumnWidth(2),
//                 },
//                 children: [
//                   pw.TableRow(
//                     decoration:
//                         const pw.BoxDecoration(color: PdfColors.grey300),
//                     children: [
//                       pw.Padding(
//                           padding: const pw.EdgeInsets.all(8),
//                           child: pw.Text('Account',
//                               style: pw.TextStyle(
//                                   fontWeight: pw.FontWeight.bold))),
//                       pw.Padding(
//                           padding: const pw.EdgeInsets.all(8),
//                           child: pw.Text('Debit',
//                               style: pw.TextStyle(
//                                   fontWeight: pw.FontWeight.bold))),
//                       pw.Padding(
//                           padding: const pw.EdgeInsets.all(8),
//                           child: pw.Text('Credit',
//                               style: pw.TextStyle(
//                                   fontWeight: pw.FontWeight.bold))),
//                     ],
//                   ),
//                   ...accounts.map((a) => pw.TableRow(children: [
//                         pw.Padding(
//                             padding: const pw.EdgeInsets.all(8),
//                             child: pw.Text(a.accountName ?? '')),
//                         pw.Padding(
//                             padding: const pw.EdgeInsets.all(8),
//                             child: pw.Text((a.debit ?? 0).toStringAsFixed(2))),
//                         pw.Padding(
//                             padding: const pw.EdgeInsets.all(8),
//                             child: pw.Text((a.credit ?? 0).toStringAsFixed(2))),
//                       ])),
//                   pw.TableRow(
//                     decoration:
//                         const pw.BoxDecoration(color: PdfColors.grey200),
//                     children: [
//                       pw.Padding(
//                           padding: const pw.EdgeInsets.all(8),
//                           child: pw.Text('TOTAL',
//                               style: pw.TextStyle(
//                                   fontWeight: pw.FontWeight.bold))),
//                       pw.Padding(
//                           padding: const pw.EdgeInsets.all(8),
//                           child: pw.Text(
//                               accounts
//                                   .fold<double>(0, (p, e) => p + (e.debit ?? 0))
//                                   .toStringAsFixed(2),
//                               style: pw.TextStyle(
//                                   fontWeight: pw.FontWeight.bold))),
//                       pw.Padding(
//                           padding: const pw.EdgeInsets.all(8),
//                           child: pw.Text(
//                               accounts
//                                   .fold<double>(
//                                       0, (p, e) => p + (e.credit ?? 0))
//                                   .toStringAsFixed(2),
//                               style: pw.TextStyle(
//                                   fontWeight: pw.FontWeight.bold))),
//                     ],
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       );

//       final pdfBytes = await pdf.save();
//       final dir = await _getDownloadDirectory();
//       final pdfFile = File(
//           '${dir.path}/trial_balance_${DateTime.now().millisecondsSinceEpoch}.pdf');
//       await pdfFile.writeAsBytes(pdfBytes);
//       log('Trial Balance PDF saved: ${pdfFile.path}');

//       // PNG PREVIEW
//       try {
//         final rasterImages =
//             await Printing.raster(pdfBytes, pages: [0], dpi: 150).toList();
//         if (rasterImages.isNotEmpty) {
//           final raster = rasterImages.first;
//           final pngFile = File(
//               '${dir.path}/trial_balance_preview_${DateTime.now().millisecondsSinceEpoch}.png');
//           await pngFile.writeAsBytes(raster.pixels);
//           log('Preview PNG saved: ${pngFile.path}');
//         }
//       } catch (e) {
//         log('PNG preview failed: $e');
//       }
//     } catch (e) {
//       log('Trial Balance PDF failed: $e');
//       rethrow;
//     }
//   }

//   Future<void> downloadTrialBalanceAsExcel(
//     TrialBalanceReport report,
//     String startDate,
//     String endDate,
//   ) async {
//     try {
//       final granted = await _requestPermission();
//       if (!granted) throw Exception('Permission denied');

//       final rows = <List<dynamic>>[
//         ['Trial Balance Report'],
//         ['Period', '$startDate - $endDate'],
//         ['Day Status', report.isDayOpen == true ? 'OPEN' : 'CLOSED'],
//         [],
//         ['Account', 'Debit', 'Credit'],
//       ];

//       final accounts = report.data ?? [];
//       for (final a in accounts) {
//         rows.add([
//           a.accountName ?? '',
//           (a.debit ?? 0).toStringAsFixed(2),
//           (a.credit ?? 0).toStringAsFixed(2),
//         ]);
//       }

//       final totalDebit = accounts.fold<double>(0, (p, e) => p + (e.debit ?? 0));
//       final totalCredit =
//           accounts.fold<double>(0, (p, e) => p + (e.credit ?? 0));
//       rows.add([
//         'TOTAL',
//         totalDebit.toStringAsFixed(2),
//         totalCredit.toStringAsFixed(2)
//       ]);

//       final csv = const ListToCsvConverter().convert(rows);
//       final dir = await _getDownloadDirectory();
//       final file = File(
//           '${dir.path}/trial_balance_${DateTime.now().millisecondsSinceEpoch}.csv');
//       await file.writeAsString(csv);
//       log('Trial Balance CSV saved: ${file.path}');
//     } catch (e) {
//       log('Trial Balance CSV failed: $e');
//       rethrow;
//     }
//   }
// }
//yesterday code
// import 'dart:developer';
// import 'dart:io';
// import 'package:csv/csv.dart';
// import 'package:dio/dio.dart';
// import 'package:dio/io.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:pdf/pdf.dart';
// import 'package:pdf/widgets.dart' as pw;
// import 'package:printing/printing.dart';
// import 'package:saleup_app/core/network/api_endpoints.dart';
// import 'package:saleup_app/model/ledger_report_response.dart';
// import 'package:saleup_app/model/stock_ledger_response.dart';
// import 'package:saleup_app/model/trial_balance_report_response.dart';
// import 'package:saleup_app/services/auth_service.dart';
// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';
// import 'package:permission_handler/permission_handler.dart';

// class DioClient {
//   static final DioClient _instance = DioClient._internal();
//   final Dio dio = Dio();

//   factory DioClient() => _instance;

//   DioClient._internal() {
//     dio.options.baseUrl = Api.backendUrl;
//     dio.options.connectTimeout = const Duration(seconds: 30);
//     dio.options.receiveTimeout = const Duration(seconds: 30);
//     dio.options.sendTimeout = const Duration(seconds: 30);

//     dio.options.headers = {
//       'Content-Type': 'application/json',
//       'Accept': 'application/json',
//     };

//     (dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
//       final client = HttpClient();
//       client.badCertificateCallback = (cert, host, port) => true;
//       return client;
//     };

//     dio.options.validateStatus = (status) => status != null && status < 500;

//     dio.interceptors.add(InterceptorsWrapper(
//       onRequest: (options, handler) async {
//         final unauthenticatedEndpoints = [
//           '/auth/login/',
//           '/auth/forgot_password/',
//           '/auth/verify_forgot_password_otp/',
//           '/auth/reset_password/',
//           '/chat/',
//         ];
//         if (!unauthenticatedEndpoints.contains(options.path)) {
//           final token = await AuthService().getAccessToken();
//           if (token != null) {
//             options.headers['Authorization'] = 'Bearer $token';
//             log('Authorization header set for ${options.path}');
//           }
//         }
//         log('Request: ${options.method} ${options.path}');
//         return handler.next(options);
//       },
//       onResponse: (response, handler) {
//         log('Response: ${response.statusCode} ${response.requestOptions.path}');
//         return handler.next(response);
//       },
//       onError: (DioException error, handler) async {
//         log('Error: ${error.response?.statusCode} ${error.requestOptions.path}');
//         if (error.response?.statusCode == 401 &&
//             !error.requestOptions.path.contains('/auth/login/')) {
//           await AuthService().clearTokens();
//         }
//         return handler.next(error);
//       },
//     ));
//   }

//   Future<bool> isTokenValid() async {
//     try {
//       return await AuthService().getAccessToken() != null;
//     } catch (e) {
//       log('Token check error: $e');
//       return false;
//     }
//   }

//   Future<void> logout(BuildContext context) async {
//     await AuthService().clearTokens();
//     context.go('/login');
//   }

//   Future<bool> refreshToken() async {
//     final refreshToken = await AuthService().getRefreshToken();
//     if (refreshToken == null) return false;

//     try {
//       final response = await dio
//           .post('/auth/refresh/', data: {'refresh_token': refreshToken});
//       if (response.statusCode == 200 && response.data['success'] == true) {
//         final data = response.data['data'];
//         await AuthService().saveTokens(
//           accessToken: data['access_token'],
//           refreshToken: data['refresh_token'] ?? refreshToken,
//           userId: await AuthService().getUserId() ?? 0,
//         );
//         return true;
//       }
//     } catch (e) {
//       log('Refresh failed: $e');
//     }
//     return false;
//   }

//   Future<bool> _requestPermission() async {
//     if (Platform.isAndroid) {
//       final status = await Permission.storage.request();
//       return status.isGranted;
//     }
//     return true;
//   }

//   Future<Directory> _getDownloadDirectory() async {
//     if (Platform.isAndroid) {
//       final dir = await getDownloadsDirectory();
//       if (dir != null) return dir;
//     }
//     return await getApplicationDocumentsDirectory();
//   }

//   // ─────────────────────────────────────────────────────────────
//   // PDF HELPER WIDGETS – DECLARED AT TOP (BEFORE USE)
//   // ─────────────────────────────────────────────────────────────
//   pw.Widget _headerCell(String text) => pw.Container(
//         padding: const pw.EdgeInsets.all(6),
//         alignment: pw.Alignment.center,
//         child: pw.Text(text,
//             style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11)),
//       );

//   pw.Widget _subHeaderCell(String text) => pw.Container(
//         padding: const pw.EdgeInsets.all(4),
//         alignment: pw.Alignment.center,
//         child: pw.Text(text,
//             style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9)),
//       );

//   pw.Widget _dataCell(String text, {bool bold = false}) => pw.Container(
//         padding: const pw.EdgeInsets.all(4),
//         alignment: pw.Alignment.center,
//         child: pw.Text(
//           text,
//           style: pw.TextStyle(
//               fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
//               fontSize: 10),
//         ),
//       );

//   pw.Widget _sectionLabelOneLine(String text) => pw.Container(
//         padding: const pw.EdgeInsets.all(6),
//         alignment: pw.Alignment.center,
//         decoration: const pw.BoxDecoration(color: PdfColors.grey300),
//         child: pw.Text(
//           text,
//           style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11),
//           textAlign: pw.TextAlign.center,
//         ),
//       );

//   // ─────────────────────────────────────────────────────────────
//   // STOCK LEDGER PDF – CORRECT DATA + NO ERRORS
//   // ─────────────────────────────────────────────────────────────
//   // Future<void> downloadStockLedgerAsPdf(
//   //   StockLedgerReport report,
//   //   String startDate,
//   //   String endDate,
//   // ) async {
//   //   try {
//   //     final granted = await _requestPermission();
//   //     if (!granted) throw Exception('Permission denied');

//   //     final pdf = pw.Document();
//   //     if (report.data?.isNotEmpty != true) {
//   //       pdf.addPage(
//   //           pw.Page(build: (_) => pw.Center(child: pw.Text('No data'))));
//   //       return;
//   //     }

//   //     final productName = report.data!.first.productName ?? 'N/A';
//   //     final raw = report.toJson();
//   //     final data = raw['data'] as Map<String, dynamic>?;
//   //     if (data == null) {
//   //       pdf.addPage(
//   //           pw.Page(build: (_) => pw.Center(child: pw.Text('No data'))));
//   //       return;
//   //     }

//   //     double openingQty = 0, openingRate = 0, openingAmt = 0;
//   //     double purQty = 0, purRate = 0, purAmt = 0;
//   //     double purRetQty = 0, purRetRate = 0, purRetAmt = 0;
//   //     double saleQty = 0, saleRate = 0, saleAmt = 0;
//   //     double saleRetQty = 0, saleRetRate = 0, saleRetAmt = 0;
//   //     double closingQty = 0, closingRate = 0, closingAmt = 0;

//   //     // Opening
//   //     final openingStock = data['opening_stock'] as Map<String, dynamic>?;
//   //     if (openingStock != null) {
//   //       final s = (openingStock['summary'] as List<dynamic>?)?.first;
//   //       if (s != null) {
//   //         openingQty = (s['quantity'] as num?)?.toDouble() ?? 0;
//   //         openingRate = (s['cost_price'] as num?)?.toDouble() ?? 0;
//   //         openingAmt = openingQty * openingRate;
//   //       }
//   //     }

//   //     // Purchases
//   //     final purchases = data['purchases'] as List<dynamic>?;
//   //     if (purchases != null) {
//   //       for (final p in purchases) {
//   //         final qty = (p['quantity'] as num?)?.toDouble() ?? 0;
//   //         final rate = (p['cost_price'] as num?)?.toDouble() ?? 0;
//   //         if (qty > 0) {
//   //           purQty += qty;
//   //           purRate = rate;
//   //           purAmt += qty * rate;
//   //         }
//   //       }
//   //     }

//   //     // Purchase Returns
//   //     final purchaseReturns = data['purchase_returns'] as List<dynamic>?;
//   //     if (purchaseReturns != null) {
//   //       for (final p in purchaseReturns) {
//   //         final qty = (p['quantity'] as num?)?.toDouble() ?? 0;
//   //         final rate = (p['cost_price'] as num?)?.toDouble() ?? 0;
//   //         if (qty < 0) {
//   //           purRetQty += qty.abs();
//   //           purRetRate = rate;
//   //           purRetAmt += qty.abs() * rate;
//   //         }
//   //       }
//   //     }

//   //     // Sales
//   //     final sales = data['sales'] as List<dynamic>?;
//   //     if (sales != null) {
//   //       for (final s in sales) {
//   //         final qty = (s['quantity'] as num?)?.toDouble() ?? 0;
//   //         final rate = (s['selling_price'] as num?)?.toDouble() ?? 0;
//   //         if (qty < 0) {
//   //           saleQty += qty.abs();
//   //           saleRate = rate;
//   //           saleAmt += qty.abs() * rate;
//   //         }
//   //       }
//   //     }

//   //     // Sale Returns
//   //     final saleReturns = data['sale_returns'] as List<dynamic>?;
//   //     if (saleReturns != null) {
//   //       for (final s in saleReturns) {
//   //         final qty = (s['quantity'] as num?)?.toDouble() ?? 0;
//   //         final rate = (s['selling_price'] as num?)?.toDouble() ?? 0;
//   //         if (qty > 0) {
//   //           saleRetQty += qty;
//   //           saleRetRate = rate;
//   //           saleRetAmt += qty * rate;
//   //         }
//   //       }
//   //     }

//   //     // Closing
//   //     final closingStock = data['closing_stock'] as Map<String, dynamic>?;
//   //     if (closingStock != null) {
//   //       final s = (closingStock['summary'] as List<dynamic>?)?.first;
//   //       if (s != null) {
//   //         closingQty = (s['quantity'] as num?)?.toDouble() ?? 0;
//   //         closingRate = (s['cost_price'] as num?)?.toDouble() ?? 0;
//   //         closingAmt = (s['total'] as num?)?.toDouble() ?? 0;
//   //       }
//   //     }

//   //     pdf.addPage(
//   //       pw.Page(
//   //         pageFormat: PdfPageFormat.a4.landscape,
//   //         margin: const pw.EdgeInsets.all(20),
//   //         build: (_) => pw.Column(
//   //           crossAxisAlignment: pw.CrossAxisAlignment.start,
//   //           children: [
//   //             pw.Text('Stock Ledger Summary',
//   //                 style: pw.TextStyle(
//   //                     fontSize: 20, fontWeight: pw.FontWeight.bold)),
//   //             pw.SizedBox(height: 4),
//   //             pw.Text('Product: $productName'),
//   //             pw.Text('Period: $startDate to $endDate'),
//   //             pw.SizedBox(height: 16),
//   //             pw.Table(
//   //               border: pw.TableBorder.all(width: 1, color: PdfColors.black),
//   //               columnWidths: {
//   //                 0: const pw.FixedColumnWidth(90),
//   //                 for (int i = 1; i < 19; i++) i: const pw.FixedColumnWidth(78),
//   //               },
//   //               children: [
//   //                 pw.TableRow(
//   //                   decoration: const pw.BoxDecoration(
//   //                     border: pw.TableBorder(
//   //                       top: pw.BorderSide(width: 1, color: PdfColors.black),
//   //                       bottom: pw.BorderSide(width: 1, color: PdfColors.black),
//   //                       left: pw.BorderSide.none,
//   //                       right: pw.BorderSide.none,
//   //                       horizontalInside: pw.BorderSide.none,
//   //                       verticalInside: pw.BorderSide.none,
//   //                     ),
//   //                   ),
//   //                   children: [
//   //                     pw.Container(),
//   //                     _sectionLabelOneLine('Opening'),
//   //                     pw.Container(),
//   //                     pw.Container(),
//   //                     _sectionLabelOneLine('Purchase'),
//   //                     pw.Container(),
//   //                     pw.Container(),
//   //                     _sectionLabelOneLine('Purchase Return'),
//   //                     pw.Container(),
//   //                     pw.Container(),
//   //                     _sectionLabelOneLine('Sales'),
//   //                     pw.Container(),
//   //                     pw.Container(),
//   //                     _sectionLabelOneLine('Sale Return'),
//   //                     pw.Container(),
//   //                     pw.Container(),
//   //                     _sectionLabelOneLine('Closing'),
//   //                     pw.Container(),
//   //                     pw.Container(),
//   //                   ],
//   //                 ),
//   //                 pw.TableRow(
//   //                   children: [
//   //                     _headerCell('Product'),
//   //                     ...List.generate(
//   //                         18,
//   //                         (i) =>
//   //                             _subHeaderCell(['Qty', 'Rate', 'Amount'][i % 3])),
//   //                   ],
//   //                 ),
//   //                 pw.TableRow(
//   //                   children: [
//   //                     _dataCell(productName, bold: true),
//   //                     _dataCell(openingQty.toStringAsFixed(0)),
//   //                     _dataCell(openingRate.toStringAsFixed(2)),
//   //                     _dataCell(openingAmt.toStringAsFixed(2)),
//   //                     _dataCell(purQty.toStringAsFixed(0)),
//   //                     _dataCell(purRate.toStringAsFixed(2)),
//   //                     _dataCell(purAmt.toStringAsFixed(2)),
//   //                     _dataCell(purRetQty.toStringAsFixed(0)),
//   //                     _dataCell(purRetRate.toStringAsFixed(2)),
//   //                     _dataCell(purRetAmt.toStringAsFixed(2)),
//   //                     _dataCell(saleQty.toStringAsFixed(0)),
//   //                     _dataCell(saleRate.toStringAsFixed(2)),
//   //                     _dataCell(saleAmt.toStringAsFixed(2)),
//   //                     _dataCell(saleRetQty.toStringAsFixed(0)),
//   //                     _dataCell(saleRetRate.toStringAsFixed(2)),
//   //                     _dataCell(saleRetAmt.toStringAsFixed(2)),
//   //                     _dataCell(closingQty.toStringAsFixed(0)),
//   //                     _dataCell(closingRate.toStringAsFixed(2)),
//   //                     _dataCell(closingAmt.toStringAsFixed(2)),
//   //                   ],
//   //                 ),
//   //               ],
//   //             ),
//   //           ],
//   //         ),
//   //       ),
//   //     );

//   //     final dir = await _getDownloadDirectory();
//   //     final file = File(
//   //         '${dir.path}/stock_ledger_summary_${DateTime.now().millisecondsSinceEpoch}.pdf');
//   //     await file.writeAsBytes(await pdf.save());
//   //     log('Stock Ledger PDF saved: ${file.path}');
//   //   } catch (e) {
//   //     log('Stock Ledger PDF failed: $e');
//   //     rethrow;
//   //   }
//   // }
//   // DioClient.dart → downloadStockLedgerAsPdf
//   // ========================================
//   // PDF DOWNLOAD
//   // ========================================
//   Future<void> downloadStockLedgerAsPdf(
//     Map<String, dynamic> json,
//     String startDate,
//     String endDate,
//   ) async {
//     try {
//       final granted = await _requestPermission();
//       if (!granted) throw Exception('Permission denied');
//       final pdf = pw.Document();

//       final data = json['data'] as Map<String, dynamic>?;
//       if (data == null) throw Exception('No data in response');

//       final productName = _safeString(data, 'purchases', 0, 'product_name') ?? 'N/A';

//       final purchaseQty = _safeDouble(data, 'purchases', 0, 'quantity') ?? 0.0;
//       final purchaseReturnQty = _safeDouble(data, 'purchase_returns', 0, 'quantity') ?? 0.0;
//       final salesQty = _safeDouble(data, 'sales', 0, 'quantity') ?? 0.0;
//       final salesReturnQty = _safeDouble(data, 'sale_returns', 0, 'quantity') ?? 0.0;
//       final closingQty = _safeDouble(data, 'closing_stock', 'summary', 0, 'quantity') ?? 0.0;
//       final closingRate = _safeDouble(data, 'closing_stock', 'summary', 0, 'cost_price') ?? 0.0;
//       final closingAmt = _safeDouble(data, 'closing_stock', 'summary', 0, 'total') ?? 0.0;

//       final sellingPriceStr = _safeString(data, 'sales', 0, 'selling_price');
//       final sellingPrice = sellingPriceStr != null ? double.tryParse(sellingPriceStr) ?? 0.0 : 0.0;

//       final salesAmt = salesQty * sellingPrice;
//       final salesReturnAmt = salesReturnQty * sellingPrice;

//       final openingQty = purchaseQty;
//       final purQty = purchaseReturnQty;
//       final purRetQty = salesQty;
//       final saleQty = salesReturnQty;

//       pdf.addPage(
//         pw.Page(
//           pageFormat: pw.PdfPageFormat.a4.landscape,
//           margin: const pw.EdgeInsets.all(20),
//           build: (_) => pw.Column(
//             crossAxisAlignment: pw.CrossAxisAlignment.start,
//             children: [
//               pw.Text('Stock Ledger Summary', style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
//               pw.Text('Product: $productName'),
//               pw.Text('Period: $startDate to $endDate'),
//               pw.SizedBox(height: 16),
//               pw.Table(
//                 border: pw.TableBorder.all(),
//                 columnWidths: {0: const pw.FixedColumnWidth(90), for (int i = 1; i < 19; i++) i: const pw.FixedColumnWidth(78)},
//                 children: [
//                   pw.TableRow(
//                     decoration: pw.BoxDecoration(color: pw.PdfColors.grey300),
//                     children: [
//                       pw.Container(),
//                       ...['Opening', 'Purchase', 'Purchase Return', 'Sales', 'Sales Return', 'Closing']
//                           .expand((label) => [_sectionLabelOneLine(label), pw.Container(), pw.Container()])
//                           .toList(),
//                     ],
//                   ),
//                   pw.TableRow(
//                     children: [
//                       _headerCell('Product'),
//                       ...List.generate(18, (i) => _subHeaderCell(['Qty', 'Rate', 'Amount'][i % 3])),
//                     ],
//                   ),
//                   pw.TableRow(
//                     children: [
//                       _dataCell(productName, bold: true),
//                       _dataCell(openingQty.toStringAsFixed(0)), _dataCell('0'), _dataCell('0'),
//                       _dataCell(purQty.toStringAsFixed(0)), _dataCell('0'), _dataCell('0'),
//                       _dataCell(purRetQty.toStringAsFixed(0)), _dataCell(sellingPrice.toStringAsFixed(0)), _dataCell(salesAmt.toStringAsFixed(0)),
//                       _dataCell(saleQty.toStringAsFixed(0)), _dataCell(sellingPrice.toStringAsFixed(0)), _dataCell(salesReturnAmt.toStringAsFixed(0)),
//                       _dataCell(''), _dataCell(''), _dataCell(''),
//                       _dataCell(closingQty.toStringAsFixed(0)), _dataCell(closingRate.toStringAsFixed(0)), _dataCell(closingAmt.toStringAsFixed(0)),
//                     ],
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       );

//       final dir = await _getDownloadDirectory();
//       final file = File('${dir.path}/stock_ledger_${DateTime.now().millisecondsSinceEpoch}.pdf');
//       await file.writeAsBytes(await pdf.save());
//       log('PDF SAVED → ${file.path}');
//     } catch (e, s) {
//       log('PDF FAILED → $e\n$s');
//       rethrow;
//     }
//   }
//   // ─────────────────────────────────────────────────────────────
//   // STOCK LEDGER EXCEL – CORRECT DATA
//   // ─────────────────────────────────────────────────────────────
//   // Future<void> downloadStockLedgerAsExcel(
//   //   StockLedgerReport report,
//   //   String startDate,
//   //   String endDate,
//   // ) async {
//   //   try {
//   //     final granted = await _requestPermission();
//   //     if (!granted) throw Exception('Permission denied');

//   //     final raw = report.toJson();
//   //     final data = raw['data'] as Map<String, dynamic>?;
//   //     if (data == null || report.data?.isEmpty == true) {
//   //       throw Exception('No data');
//   //     }

//   //     final productName = report.data!.first.productName ?? 'N/A';

//   //     double openingQty = 0, openingRate = 0, openingAmt = 0;
//   //     double purQty = 0, purRate = 0, purAmt = 0;
//   //     double purRetQty = 0, purRetRate = 0, purRetAmt = 0;
//   //     double saleQty = 0, saleRate = 0, saleAmt = 0;
//   //     double saleRetQty = 0, saleRetRate = 0, saleRetAmt = 0;
//   //     double closingQty = 0, closingRate = 0, closingAmt = 0;

//   //     final openingStock = data['opening_stock'] as Map<String, dynamic>?;
//   //     if (openingStock != null) {
//   //       final s = (openingStock['summary'] as List<dynamic>?)?.first;
//   //       if (s != null) {
//   //         openingQty = (s['quantity'] as num?)?.toDouble() ?? 0;
//   //         openingRate = (s['cost_price'] as num?)?.toDouble() ?? 0;
//   //         openingAmt = openingQty * openingRate;
//   //       }
//   //     }

//   //     void sumList(List<dynamic>? list, bool isPurchase, bool isReturn) {
//   //       if (list == null) return;
//   //       for (final item in list) {
//   //         final qty = (item['quantity'] as num?)?.toDouble() ?? 0;
//   //         final cost = (item['cost_price'] as num?)?.toDouble() ?? 0;
//   //         final sell = (item['selling_price'] as num?)?.toDouble() ?? 0;
//   //         final rate = isPurchase ? cost : sell;
//   //         final absQty = qty.abs();

//   //         if (isPurchase && !isReturn && qty > 0) {
//   //           purQty += qty;
//   //           purRate = rate;
//   //           purAmt += qty * rate;
//   //         } else if (isPurchase && isReturn && qty < 0) {
//   //           purRetQty += absQty;
//   //           purRetRate = rate;
//   //           purRetAmt += absQty * rate;
//   //         } else if (!isPurchase && !isReturn && qty < 0) {
//   //           saleQty += absQty;
//   //           saleRate = rate;
//   //           saleAmt += absQty * rate;
//   //         } else if (!isPurchase && isReturn && qty > 0) {
//   //           saleRetQty += qty;
//   //           saleRetRate = rate;
//   //           saleRetAmt += qty * rate;
//   //         }
//   //       }
//   //     }

//   //     sumList(data['purchases'], true, false);
//   //     sumList(data['purchase_returns'], true, true);
//   //     sumList(data['sales'], false, false);
//   //     sumList(data['sale_returns'], false, true);

//   //     final closingStock = data['closing_stock'] as Map<String, dynamic>?;
//   //     if (closingStock != null) {
//   //       final s = (closingStock['summary'] as List<dynamic>?)?.first;
//   //       if (s != null) {
//   //         closingQty = (s['quantity'] as num?)?.toDouble() ?? 0;
//   //         closingRate = (s['cost_price'] as num?)?.toDouble() ?? 0;
//   //         closingAmt = (s['total'] as num?)?.toDouble() ?? 0;
//   //       }
//   //     }

//   //     final rows = <List<dynamic>>[
//   //       ['Stock Ledger Summary'],
//   //       ['Product', productName],
//   //       ['Period', '$startDate - $endDate'],
//   //       [],
//   //       [
//   //         'Product',
//   //         'Opening',
//   //         '',
//   //         '',
//   //         'Purchase',
//   //         '',
//   //         '',
//   //         'Purchase Return',
//   //         '',
//   //         '',
//   //         'Sales',
//   //         '',
//   //         '',
//   //         'Sale Return',
//   //         '',
//   //         '',
//   //         'Closing',
//   //         '',
//   //         ''
//   //       ],
//   //       [
//   //         '',
//   //         'Qty',
//   //         'Rate',
//   //         'Amount',
//   //         'Qty',
//   //         'Rate',
//   //         'Amount',
//   //         'Qty',
//   //         'Rate',
//   //         'Amount',
//   //         'Qty',
//   //         'Rate',
//   //         'Amount',
//   //         'Qty',
//   //         'Rate',
//   //         'Amount',
//   //         'Qty',
//   //         'Rate',
//   //         'Amount'
//   //       ],
//   //       [
//   //         productName,
//   //         openingQty.toStringAsFixed(0),
//   //         openingRate.toStringAsFixed(2),
//   //         openingAmt.toStringAsFixed(2),
//   //         purQty.toStringAsFixed(0),
//   //         purRate.toStringAsFixed(2),
//   //         purAmt.toStringAsFixed(2),
//   //         purRetQty.toStringAsFixed(0),
//   //         purRetRate.toStringAsFixed(2),
//   //         purRetAmt.toStringAsFixed(2),
//   //         saleQty.toStringAsFixed(0),
//   //         saleRate.toStringAsFixed(2),
//   //         saleAmt.toStringAsFixed(2),
//   //         saleRetQty.toStringAsFixed(0),
//   //         saleRetRate.toStringAsFixed(2),
//   //         saleRetAmt.toStringAsFixed(2),
//   //         closingQty.toStringAsFixed(0),
//   //         closingRate.toStringAsFixed(2),
//   //         closingAmt.toStringAsFixed(2),
//   //       ],
//   //     ];

//   //     final csv = const ListToCsvConverter().convert(rows);
//   //     final dir = await _getDownloadDirectory();
//   //     final file = File(
//   //         '${dir.path}/stock_ledger_summary_${DateTime.now().millisecondsSinceEpoch}.csv');
//   //     await file.writeAsString(csv);
//   //     log('Stock Ledger CSV saved: ${file.path}');
//   //   } catch (e) {
//   //     log('Stock Ledger CSV failed: $e');
//   //     rethrow;
//   //   }
//   // }
//   Future<void> downloadStockLedgerAsExcel(
//     Map<String, dynamic> json,
//     String startDate,
//     String endDate,
//   ) async {
//     try {
//       final granted = await _requestPermission();
//       if (!granted) throw Exception('Permission denied');

//       final data = json['data'];
//       final productName = data['purchases'].isNotEmpty
//           ? data['purchases'][0]['product_name']
//           : 'N/A';

//       final purchaseQty =
//           data['purchases'].isNotEmpty ? data['purchases'][0]['quantity'] : 0.0;
//       final purchaseReturnQty = data['purchase_returns'].isNotEmpty
//           ? data['purchase_returns'][0]['quantity']
//           : 0.0;
//       final salesQty =
//           data['sales'].isNotEmpty ? data['sales'][0]['quantity'] : 0.0;
//       final salesReturnQty = data['sale_returns'].isNotEmpty
//           ? data['sale_returns'][0]['quantity']
//           : 0.0;
//       final closingQty = data['closing_stock']['summary'].isNotEmpty
//           ? data['closing_stock']['summary'][0]['quantity']
//           : 0.0;
//       final closingRate = data['closing_stock']['summary'].isNotEmpty
//           ? data['closing_stock']['summary'][0]['cost_price']
//           : 0.0;
//       final closingAmt = data['closing_stock']['summary'].isNotEmpty
//           ? data['closing_stock']['summary'][0]['total']
//           : 0.0;

//       final sellingPrice = data['sales'].isNotEmpty
//           ? double.tryParse(data['sales'][0]['selling_price']) ?? 0.0
//           : 0.0;
//       final salesAmt = salesQty * sellingPrice;
//       final salesReturnAmt = salesReturnQty * sellingPrice;

//       final rows = <List<dynamic>>[
//         ['Stock Ledger Summary'],
//         ['Product', productName],
//         ['Period', '$startDate - $endDate'],
//         [],
//         [
//           'Product',
//           'Opening',
//           '',
//           '',
//           'Purchase',
//           '',
//           '',
//           'Purchase Return',
//           '',
//           '',
//           'Sales',
//           '',
//           '',
//           'Sales Return',
//           '',
//           '',
//           'Closing',
//           '',
//           ''
//         ],
//         [
//           '',
//           'Qty',
//           'Rate',
//           'Amount',
//           'Qty',
//           'Rate',
//           'Amount',
//           'Qty',
//           'Rate',
//           'Amount',
//           'Qty',
//           'Rate',
//           'Amount',
//           'Qty',
//           'Rate',
//           'Amount',
//           'Qty',
//           'Rate',
//           'Amount'
//         ],
//         [
//           productName,
//           purchaseQty.toStringAsFixed(0),
//           '0',
//           '0',
//           purchaseReturnQty.toStringAsFixed(0),
//           '0',
//           '0',
//           salesQty.toStringAsFixed(0),
//           sellingPrice.toStringAsFixed(0),
//           salesAmt.toStringAsFixed(0),
//           salesReturnQty.toStringAsFixed(0),
//           sellingPrice.toStringAsFixed(0),
//           salesReturnAmt.toStringAsFixed(0),
//           '',
//           '',
//           '',
//           closingQty.toStringAsFixed(0),
//           closingRate.toStringAsFixed(0),
//           closingAmt.toStringAsFixed(0),
//         ],
//       ];

//       final csv = const ListToCsvConverter().convert(rows);
//       final dir = await _getDownloadDirectory();
//       final file = File(
//           '${dir.path}/stock_ledger_${DateTime.now().millisecondsSinceEpoch}.csv');
//       await file.writeAsString(csv);
//       log('EXCEL SAVED → ${file.path}');
//     } catch (e) {
//       log('EXCEL FAILED → $e');
//       rethrow;
//     }
//   }
//   // ========================================
//   // HELPER METHODS (MUST BE INSIDE CLASS)
//   // ========================================
//   double? _safeDouble(Map<String, dynamic> map, Object key1, [Object? key2, Object? key3, Object? key4]) {
//     try {
//       dynamic value = map[key1];
//       if (value == null) return null;
//       if (key2 != null) value = (value is List && key2 is int) ? value[key2] : value[key2];
//       if (key3 != null) value = (value is List && key3 is int) ? value[key3] : value[key3];
//       if (key4 != null) value = (value is List && key4 is int) ? value[key4] : value[key4];
//       if (value is num) return value.toDouble();
//       if (value is String) return double.tryParse(value);
//       return null;
//     } catch (_) {
//       return null;
//     }
//   }

//   String? _safeString(Map<String, dynamic> map, Object key1, [Object? key2, Object? key3, Object? key4]) {
//     try {
//       dynamic value = map[key1];
//       if (value == null) return null;
//       if (key2 != null) value = (value is List && key2 is int) ? value[key2] : value[key2];
//       if (key3 != null) value = (value is List && key3 is int) ? value[key3] : value[key3];
//       if (key4 != null) value = (value is List && key4 is int) ? value[key4] : value[key4];
//       return value?.toString();
//     } catch (_) {
//       return null;
//     }
//   }
//   // ─────────────────────────────────────────────────────────────
//   // ORIGINAL LEDGER PDF/EXCEL (UNTOUCHED)
//   // ─────────────────────────────────────────────────────────────
//   Future<void> downloadAsPdf(
//       LedgerReport ledgerReport, String startDate, String endDate) async {
//     try {
//       final granted = await _requestPermission();
//       if (!granted) throw Exception('Permission denied');

//       final pdf = pw.Document();
//       if (ledgerReport.data!.isNotEmpty) {
//         final account = ledgerReport.data!.first;
//         pdf.addPage(pw.Page(
//             build: (_) => pw.Column(
//                   crossAxisAlignment: pw.CrossAxisAlignment.start,
//                   children: [
//                     pw.Text('Ledger Report',
//                         style: pw.TextStyle(
//                             fontSize: 24, fontWeight: pw.FontWeight.bold)),
//                     pw.Text('Account: ${account.accountName}',
//                         style: const pw.TextStyle(fontSize: 16)),
//                     pw.Text('Period: $startDate to $endDate',
//                         style: const pw.TextStyle(fontSize: 16)),
//                     pw.SizedBox(height: 20),
//                     pw.Table.fromTextArray(
//                       headers: [
//                         'Date',
//                         'Voucher #',
//                         'Debit',
//                         'Credit',
//                         'Balance'
//                       ],
//                       data: account.ledger!
//                           .map((e) => [
//                                 e.voucherDate!.split('T')[0],
//                                 e.voucherNumber,
//                                 e.debit!.toStringAsFixed(2),
//                                 e.credit!.toStringAsFixed(2),
//                                 e.runningBalance!.toStringAsFixed(2),
//                               ])
//                           .toList(),
//                     ),
//                   ],
//                 )));
//       } else {
//         pdf.addPage(pw.Page(build: (_) => pw.Text('No data')));
//       }

//       final dir = await _getDownloadDirectory();
//       final file = File(
//           '${dir.path}/ledger_${DateTime.now().millisecondsSinceEpoch}.pdf');
//       await file.writeAsBytes(await pdf.save());
//       log('Ledger PDF saved: ${file.path}');
//     } catch (e) {
//       log('Ledger PDF failed: $e');
//       rethrow;
//     }
//   }

//   Future<void> downloadAsExcel(
//       LedgerReport ledgerReport, String startDate, String endDate) async {
//     try {
//       final granted = await _requestPermission();
//       if (!granted) throw Exception('Permission denied');

//       final rows = <List<dynamic>>[
//         ['Date', 'Voucher #', 'Debit', 'Credit', 'Balance'],
//         ...?ledgerReport.data?.first.ledger?.map((e) => [
//               e.voucherDate!.split('T')[0],
//               e.voucherNumber,
//               e.debit!.toStringAsFixed(2),
//               e.credit!.toStringAsFixed(2),
//               e.runningBalance!.toStringAsFixed(2),
//             ]),
//       ];

//       final csv = const ListToCsvConverter().convert(rows);
//       final dir = await _getDownloadDirectory();
//       final file = File(
//           '${dir.path}/ledger_${DateTime.now().millisecondsSinceEpoch}.csv');
//       await file.writeAsString(csv);
//       log('Ledger CSV saved: ${file.path}');
//     } catch (e) {
//       log('Ledger CSV failed: $e');
//       rethrow;
//     }
//   }

//   // ─────────────────────────────────────────────────────────────
//   // TRIAL BALANCE
//   // ─────────────────────────────────────────────────────────────
//   Future<TrialBalanceReport> fetchTrialBalance(String start, String end) async {
//     final response = await dio.get('/ledger/get_trial_balance/',
//         queryParameters: {'start_date': start, 'end_date': end});
//     return TrialBalanceReport.fromJson(response.data);
//   }

//   Future<void> downloadTrialBalanceAsPdf(
//       TrialBalanceReport report, String startDate, String endDate) async {
//     try {
//       final granted = await _requestPermission();
//       if (!granted) throw Exception('Permission denied');

//       final pdf = pw.Document();
//       final accounts = report.data ?? [];

//       pdf.addPage(pw.Page(
//         pageFormat: PdfPageFormat.a4,
//         margin: const pw.EdgeInsets.all(40),
//         build: (_) => pw.Column(
//           crossAxisAlignment: pw.CrossAxisAlignment.start,
//           children: [
//             pw.Text('Trial Balance Report',
//                 style:
//                     pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold)),
//             pw.SizedBox(height: 8),
//             pw.Text('Period: $startDate to $endDate'),
//             pw.Text(report.isDayOpen == true ? 'Day is OPEN' : 'Day is CLOSED',
//                 style: pw.TextStyle(
//                     color: report.isDayOpen == true
//                         ? PdfColors.green
//                         : PdfColors.red,
//                     fontWeight: pw.FontWeight.bold)),
//             pw.SizedBox(height: 20),
//             pw.Table(
//               border: pw.TableBorder.all(),
//               columnWidths: {
//                 0: const pw.FlexColumnWidth(4),
//                 1: const pw.FlexColumnWidth(2),
//                 2: const pw.FlexColumnWidth(2)
//               },
//               children: [
//                 pw.TableRow(
//                     decoration:
//                         const pw.BoxDecoration(color: PdfColors.grey300),
//                     children: [
//                       pw.Padding(
//                           padding: const pw.EdgeInsets.all(8),
//                           child: pw.Text('Account',
//                               style: pw.TextStyle(
//                                   fontWeight: pw.FontWeight.bold))),
//                       pw.Padding(
//                           padding: const pw.EdgeInsets.all(8),
//                           child: pw.Text('Debit',
//                               style: pw.TextStyle(
//                                   fontWeight: pw.FontWeight.bold))),
//                       pw.Padding(
//                           padding: const pw.EdgeInsets.all(8),
//                           child: pw.Text('Credit',
//                               style: pw.TextStyle(
//                                   fontWeight: pw.FontWeight.bold))),
//                     ]),
//                 ...accounts.map((a) => pw.TableRow(children: [
//                       pw.Padding(
//                           padding: const pw.EdgeInsets.all(8),
//                           child: pw.Text(a.accountName ?? '')),
//                       pw.Padding(
//                           padding: const pw.EdgeInsets.all(8),
//                           child: pw.Text((a.debit ?? 0).toStringAsFixed(2))),
//                       pw.Padding(
//                           padding: const pw.EdgeInsets.all(8),
//                           child: pw.Text((a.credit ?? 0).toStringAsFixed(2))),
//                     ])),
//                 pw.TableRow(
//                     decoration:
//                         const pw.BoxDecoration(color: PdfColors.grey200),
//                     children: [
//                       pw.Padding(
//                           padding: const pw.EdgeInsets.all(8),
//                           child: pw.Text('TOTAL',
//                               style: pw.TextStyle(
//                                   fontWeight: pw.FontWeight.bold))),
//                       pw.Padding(
//                           padding: const pw.EdgeInsets.all(8),
//                           child: pw.Text(
//                               accounts
//                                   .fold(0.0, (p, e) => p + (e.debit ?? 0))
//                                   .toStringAsFixed(2),
//                               style: pw.TextStyle(
//                                   fontWeight: pw.FontWeight.bold))),
//                       pw.Padding(
//                           padding: const pw.EdgeInsets.all(8),
//                           child: pw.Text(
//                               accounts
//                                   .fold(0.0, (p, e) => p + (e.credit ?? 0))
//                                   .toStringAsFixed(2),
//                               style: pw.TextStyle(
//                                   fontWeight: pw.FontWeight.bold))),
//                     ]),
//               ],
//             ),
//           ],
//         ),
//       ));

//       final dir = await _getDownloadDirectory();
//       final file = File(
//           '${dir.path}/trial_balance_${DateTime.now().millisecondsSinceEpoch}.pdf');
//       await file.writeAsBytes(await pdf.save());
//       log('Trial Balance PDF saved: ${file.path}');
//     } catch (e) {
//       log('Trial Balance PDF failed: $e');
//       rethrow;
//     }
//   }

//   Future<void> downloadTrialBalanceAsExcel(
//       TrialBalanceReport report, String startDate, String endDate) async {
//     try {
//       final granted = await _requestPermission();
//       if (!granted) throw Exception('Permission denied');

//       final rows = <List<dynamic>>[
//         ['Trial Balance Report'],
//         ['Period', '$startDate - $endDate'],
//         ['Day Status', report.isDayOpen == true ? 'OPEN' : 'CLOSED'],
//         [],
//         ['Account', 'Debit', 'Credit'],
//         ...?report.data?.map((a) => [
//               a.accountName ?? '',
//               (a.debit ?? 0).toStringAsFixed(2),
//               (a.credit ?? 0).toStringAsFixed(2)
//             ]),
//         [
//           'TOTAL',
//           report.data
//               ?.fold(0.0, (p, e) => p + (e.debit ?? 0))
//               .toStringAsFixed(2),
//           report.data
//               ?.fold(0.0, (p, e) => p + (e.credit ?? 0))
//               .toStringAsFixed(2),
//         ],
//       ];

//       final csv = const ListToCsvConverter().convert(rows);
//       final dir = await _getDownloadDirectory();
//       final file = File(
//           '${dir.path}/trial_balance_${DateTime.now().millisecondsSinceEpoch}.csv');
//       await file.writeAsString(csv);
//       log('Trial Balance CSV saved: ${file.path}');
//     } catch (e) {
//       log('Trial Balance CSV failed: $e');
//       rethrow;
//     }
//   }
// }

// import 'dart:convert';
// import 'dart:developer';
// import 'dart:io';
// import 'package:csv/csv.dart';
// import 'package:dio/dio.dart';
// import 'package:dio/io.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:pdf/pdf.dart'; // ← ADDED
// import 'package:pdf/widgets.dart' as pw; // ← KEPT
// import 'package:printing/printing.dart';
// import 'package:saleup_app/core/network/api_endpoints.dart';
// import 'package:saleup_app/model/ledger_report_response.dart';
// import 'package:saleup_app/model/stock_ledger_response.dart';
// import 'package:saleup_app/model/trial_balance_report_response.dart';
// import 'package:saleup_app/services/auth_service.dart';
// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:syncfusion_flutter_xlsio/xlsio.dart' as xlsio;

// class DioClient {
//   static final DioClient _instance = DioClient._internal();
//   final Dio dio = Dio();

//   factory DioClient() => _instance;

//   DioClient._internal() {
//     dio.options.baseUrl = Api.backendUrl;
//     dio.options.connectTimeout = const Duration(seconds: 30);
//     dio.options.receiveTimeout = const Duration(seconds: 30);
//     dio.options.sendTimeout = const Duration(seconds: 30);

//     dio.options.headers = {
//       'Content-Type': 'application/json',
//       'Accept': 'application/json',
//     };

//     (dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
//       final client = HttpClient();
//       client.badCertificateCallback = (cert, host, port) => true;
//       return client;
//     };

//     dio.options.validateStatus = (status) => status != null && status < 500;

//     dio.interceptors.add(
//       InterceptorsWrapper(
//         onRequest: (options, handler) async {
//           final unauthenticatedEndpoints = [
//             '/auth/login/',
//             '/auth/forgot_password/',
//             '/auth/verify_forgot_password_otp/',
//             '/auth/reset_password/',
//             '/chat/',
//           ];
//           if (!unauthenticatedEndpoints.contains(options.path)) {
//             final token = await AuthService().getAccessToken();
//             if (token != null) {
//               options.headers['Authorization'] = 'Bearer $token';
//               log('Authorization header set for ${options.path}');
//             }
//           }
//           log('Request: ${options.method} ${options.path}');
//           return handler.next(options);
//         },
//         onResponse: (response, handler) {
//           log(
//             'Response: ${response.statusCode} ${response.requestOptions.path}',
//           );
//           return handler.next(response);
//         },
//         onError: (DioException error, handler) async {
//           log(
//             'Error: ${error.response?.statusCode} ${error.requestOptions.path}',
//           );
//           if (error.response?.statusCode == 401 &&
//               !error.requestOptions.path.contains('/auth/login/')) {
//             await AuthService().clearTokens();
//           }
//           return handler.next(error);
//         },
//       ),
//     );
//   }

//   Future<bool> isTokenValid() async {
//     try {
//       return await AuthService().getAccessToken() != null;
//     } catch (e) {
//       log('Token check error: $e');
//       return false;
//     }
//   }

//   Future<void> logout(BuildContext context) async {
//     await AuthService().clearTokens();
//     context.go('/login');
//   }

//   Future<bool> refreshToken() async {
//     final refreshToken = await AuthService().getRefreshToken();
//     if (refreshToken == null) return false;

//     try {
//       final response = await dio.post(
//         '/auth/refresh/',
//         data: {'refresh_token': refreshToken},
//       );
//       if (response.statusCode == 200 && response.data['success'] == true) {
//         final data = response.data['data'];
//         await AuthService().saveTokens(
//           accessToken: data['access_token'],
//           refreshToken: data['refresh_token'] ?? refreshToken,
//           userId: await AuthService().getUserId() ?? 0,
//         );
//         return true;
//       }
//     } catch (e) {
//       log('Refresh failed: $e');
//     }
//     return false;
//   }

//   Future<bool> _requestPermission() async {
//     if (Platform.isAndroid) {
//       final status = await Permission.storage.request();
//       return status.isGranted;
//     }
//     return true;
//   }

//   Future<Directory> _getDownloadDirectory() async {
//     if (Platform.isAndroid) {
//       final dir = await getDownloadsDirectory();
//       if (dir != null) return dir;
//     }
//     return await getApplicationDocumentsDirectory();
//   }

//   // ─────────────────────────────────────────────────────────────
//   // PDF HELPER WIDGETS – DECLARED AT TOP (BEFORE USE)
//   // ─────────────────────────────────────────────────────────────
//   pw.Widget _headerCell(String text) => pw.Container(
//         padding: const pw.EdgeInsets.all(6),
//         alignment: pw.Alignment.center,
//         child: pw.Text(
//           text,
//           style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11),
//         ),
//       );

//   pw.Widget _subHeaderCell(String text) => pw.Container(
//         padding: const pw.EdgeInsets.all(4),
//         alignment: pw.Alignment.center,
//         child: pw.Text(
//           text,
//           style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9),
//         ),
//       );

//   pw.Widget _dataCell(String text, {bool bold = false}) => pw.Container(
//         padding: const pw.EdgeInsets.all(4),
//         alignment: pw.Alignment.center,
//         child: pw.Text(
//           text,
//           style: pw.TextStyle(
//             fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
//             fontSize: 10,
//           ),
//         ),
//       );

//   pw.Widget _sectionLabelOneLine(String text) => pw.Container(
//         padding: const pw.EdgeInsets.all(6),
//         alignment: pw.Alignment.center,
//         decoration: const pw.BoxDecoration(color: PdfColors.grey300),
//         child: pw.Text(
//           text,
//           style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11),
//           textAlign: pw.TextAlign.center,
//         ),
//       );

//   // ─────────────────────────────────────────────────────────────
//   // STOCK LEDGER PDF – CORRECT DATA + NO ERRORS
//   // ─────────────────────────────────────────────────────────────

//   Future<void> downloadStockLedgerAsPdf(
//     Map<String, dynamic> json,
//     String startDate,
//     String endDate,
//   ) async {
//     try {
//       final granted = await _requestPermission();
//       if (!granted) throw Exception('Permission denied');
//       final pdf = pw.Document();

//       final rawData = json['data'];
//       if (rawData == null ||
//           rawData is! Map<String, dynamic> ||
//           rawData.isEmpty) {
//         log('RAW JSON → $json');
//         throw Exception('No data in response');
//       }
//       final data = rawData as Map<String, dynamic>;

//       // === EXTRACT VALUES ===
//       final productName =
//           _safeString(data, 'purchases', 0, 'product_name') ?? 'N/A';

//       final openingQty =
//           _safeDouble(data, 'opening_stock', 'summary', 0, 'quantity') ?? 0.0;
//       final purchaseQty = _safeDouble(data, 'purchases', 0, 'quantity') ?? 0.0;
//       final purRetQty =
//           _safeDouble(data, 'purchase_returns', 0, 'quantity') ?? 0.0;
//       final salesQty = _safeDouble(data, 'sales', 0, 'quantity') ?? 0.0;
//       final saleRetQty =
//           _safeDouble(data, 'sale_returns', 0, 'quantity') ?? 0.0;
//       final closingQty =
//           _safeDouble(data, 'closing_stock', 'summary', 0, 'quantity') ?? 0.0;
//       final closingRate =
//           _safeDouble(data, 'closing_stock', 'summary', 0, 'cost_price') ?? 0.0;
//       final closingAmt =
//           _safeDouble(data, 'closing_stock', 'summary', 0, 'total') ?? 0.0;

//       final sellingPriceStr = _safeString(data, 'sales', 0, 'selling_price');
//       final sellingPrice = sellingPriceStr != null
//           ? double.tryParse(sellingPriceStr) ?? 0.0
//           : 0.0;

//       final salesAmt = salesQty * sellingPrice;
//       final saleRetAmt = saleRetQty * sellingPrice;

//       // === ONE ROW PER SECTION ===
//       pdf.addPage(
//         pw.Page(
//           pageFormat: PdfPageFormat.a4.landscape,
//           margin: const pw.EdgeInsets.all(20),
//           build: (_) => pw.Column(
//             crossAxisAlignment: pw.CrossAxisAlignment.start,
//             children: [
//               pw.Text(
//                 'Stock Ledger Summary',
//                 style: pw.TextStyle(
//                   fontSize: 20,
//                   fontWeight: pw.FontWeight.bold,
//                 ),
//               ),
//               pw.Text('Product: $productName'),
//               pw.Text('Period: $startDate to $endDate'),
//               pw.SizedBox(height: 16),
//               pw.Table(
//                 border: pw.TableBorder.all(),
//                 columnWidths: {
//                   0: const pw.FixedColumnWidth(90),
//                   for (int i = 1; i < 19; i++) i: const pw.FixedColumnWidth(78),
//                 },
//                 children: [
//                   // HEADER ROW
//                   pw.TableRow(
//                     decoration: pw.BoxDecoration(color: PdfColors.grey300),
//                     children: [
//                       pw.Container(),
//                       ...[
//                         'Opening',
//                         'Purchase',
//                         'Pur Return',
//                         'Sales',
//                         'Sale Return',
//                         'Closing',
//                       ]
//                           .expand(
//                             (label) => [
//                               _sectionLabelOneLine(label),
//                               pw.Container(),
//                               pw.Container(),
//                             ],
//                           )
//                           .toList(),
//                     ],
//                   ),
//                   pw.TableRow(
//                     children: [
//                       _headerCell('Product'),
//                       ...List.generate(
//                         18,
//                         (i) => _subHeaderCell(['Qty', 'Rate', 'Amount'][i % 3]),
//                       ),
//                     ],
//                   ),
//                   // DATA ROW
//                   pw.TableRow(
//                     children: [
//                       _dataCell(productName, bold: true),
//                       // Opening
//                       _dataCell(openingQty.toStringAsFixed(0)), _dataCell('0'),
//                       _dataCell('0'),
//                       // Purchase
//                       _dataCell(purchaseQty.toStringAsFixed(0)), _dataCell('0'),
//                       _dataCell('0'),
//                       // Pur Return
//                       _dataCell((purRetQty).toStringAsFixed(0)),
//                       _dataCell('0'), _dataCell('0'),
//                       // Sales
//                       _dataCell((salesQty).toStringAsFixed(0)),
//                       _dataCell(sellingPrice.toStringAsFixed(0)),
//                       _dataCell((salesAmt).toStringAsFixed(0)),
//                       // Sale Return
//                       _dataCell(saleRetQty.toStringAsFixed(0)),
//                       _dataCell(sellingPrice.toStringAsFixed(0)),
//                       _dataCell(saleRetAmt.toStringAsFixed(0)),
//                       // Closing
//                       _dataCell(closingQty.toStringAsFixed(0)),
//                       _dataCell(closingRate.toStringAsFixed(0)),
//                       _dataCell(closingAmt.toStringAsFixed(0)),
//                     ],
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       );

//       final dir = await _getDownloadDirectory();
//       final file = File(
//         '${dir.path}/stock_ledger_${DateTime.now().millisecondsSinceEpoch}.pdf',
//       );
//       await file.writeAsBytes(await pdf.save());
//       log('PDF SAVED → ${file.path}');
//     } catch (e, s) {
//       log('PDF FAILED → $e\n$s');
//       log('FULL JSON → $json');
//       rethrow;
//     }
//   }
//   Future<void> downloadStockLedgerAsExcel(
//     Map<String, dynamic> json,
//     String startDate,
//     String endDate,
//   ) async {
//     try {
//       final granted = await _requestPermission();
//       if (!granted) throw Exception('Permission denied');

//       print('API RESPONSE (RAW JSON):');
//       print(const JsonEncoder.withIndent('  ').convert(json));

//       final data = json['data'] as Map<String, dynamic>;

//       final productName =
//           _safeString(data, 'purchases', 0, 'product_name') ?? 'N/A';

//       final openingQty =
//           _safeDouble(data, 'opening_stock', 'summary', 0, 'quantity') ?? 0.0;
//       final openingRate =
//           _safeDouble(data, 'opening_stock', 'summary', 0, 'cost_price') ?? 0.0;

//       final purchaseQty = _safeDouble(data, 'purchases', 0, 'quantity') ?? 0.0;
//       final purchaseRate =
//           _safeDouble(data, 'purchases', 0, 'cost_price') ?? 0.0;

//       final purRetQty =
//           _safeDouble(data, 'purchase_returns', 0, 'quantity') ?? 0.0;
//       final purRetRate =
//           _safeDouble(data, 'purchase_returns', 0, 'cost_price') ?? 0.0;

//       final salesQty = _safeDouble(data, 'sales', 0, 'quantity') ?? 0.0;
//       final sellingPrice =
//           _safeDouble(data, 'sales', 0, 'selling_price') ?? 0.0;

//       final saleRetQty =
//           _safeDouble(data, 'sale_returns', 0, 'quantity') ?? 0.0;
//       final saleRetPrice =
//           _safeDouble(data, 'sale_returns', 0, 'selling_price') ?? 0.0;

//       final closingQty =
//           _safeDouble(data, 'closing_stock', 'summary', 0, 'quantity') ?? 0.0;
//       final closingRate =
//           _safeDouble(data, 'closing_stock', 'summary', 0, 'cost_price') ?? 0.0;
//       final closingAmt =
//           _safeDouble(data, 'closing_stock', 'summary', 0, 'total') ?? 0.0;

//       final purchaseAmt = purchaseQty * purchaseRate;
//       final purRetAmt = purRetQty * purRetRate;
//       final salesAmt = salesQty * sellingPrice;
//       final saleRetAmt = saleRetQty * saleRetPrice;

//       print('\nEXTRACTED VALUES:');
//       print('  Product: $productName');
//       print('  Opening: Qty=$openingQty, Rate=$openingRate');
//       print(
//           '  Purchase: Qty=$purchaseQty, Rate=$purchaseRate, Amt=$purchaseAmt');
//       print('  Pur Return: Qty=$purRetQty, Rate=$purRetRate, Amt=$purRetAmt');
//       print('  Sales: Qty=$salesQty, SP=$sellingPrice, Amt=$salesAmt');
//       print(
//           '  Sale Return: Qty=$saleRetQty, SP=$saleRetPrice, Amt=$saleRetAmt');
//       print('  Closing: Qty=$closingQty, Rate=$closingRate, Amt=$closingAmt');

//       final rows = <List<dynamic>>[
//         ['Stock Ledger Summary'],
//         ['Product', productName],
//         ['Period', '$startDate - $endDate'],
//         [],
//         [
//           'Product',
//           'Opening',
//           '',
//           '',
//           'Purchase',
//           '',
//           '',
//           'Pur Return',
//           '',
//           '',
//           'Sales',
//           '',
//           '',
//           'Sale Return',
//           '',
//           '',
//           'Closing',
//           '',
//           ''
//         ],
//         [
//           '',
//           'Qty',
//           'Rate',
//           'Amount',
//           'Qty',
//           'Rate',
//           'Amount',
//           'Qty',
//           'Rate',
//           'Amount',
//           'Qty',
//           'Rate',
//           'Amount',
//           'Qty',
//           'Rate',
//           'Amount',
//           'Qty',
//           'Rate',
//           'Amount'
//         ],
//         [
//           productName,
//           openingQty.toStringAsFixed(0),
//           openingRate.toStringAsFixed(2),
//           '0',
//           purchaseQty.toStringAsFixed(0),
//           purchaseRate.toStringAsFixed(2),
//           purchaseAmt.toStringAsFixed(2),
//           (purRetQty).toStringAsFixed(0),
//           purRetRate.toStringAsFixed(2),
//           (purRetAmt).toStringAsFixed(2),
//           (salesQty).toStringAsFixed(0),
//           sellingPrice.toStringAsFixed(2),
//           (salesAmt).toStringAsFixed(2),
//           saleRetQty.toStringAsFixed(0),
//           saleRetPrice.toStringAsFixed(2),
//           saleRetAmt.toStringAsFixed(2),
//           closingQty.toStringAsFixed(0),
//           closingRate.toStringAsFixed(2),
//           closingAmt.toStringAsFixed(2),
//         ],
//       ];

//       final csv = const ListToCsvConverter().convert(rows);
//       final dir = await _getDownloadDirectory();
//       final csvFile = File(
//           '${dir.path}/stock_ledger_${DateTime.now().millisecondsSinceEpoch}.csv');
//       await csvFile.writeAsString(csv);
//       print('\nCSV SAVED → ${csvFile.path}');

//       try {
//         final xlsio.Workbook workbook = xlsio.Workbook();
//         final xlsio.Worksheet sheet = workbook.worksheets[0];
//         sheet.name = 'Stock Ledger';

//         final xlsio.Range titleCell = sheet.getRangeByName('A1');
//         titleCell.text = 'Stock Ledger Summary';
//         titleCell.cellStyle.fontSize = 16;
//         titleCell.cellStyle.bold = true;
//         titleCell.cellStyle.hAlign = xlsio.HAlignType.center;
//         sheet.getRangeByName('A1:S1').merge();

//         sheet.getRangeByName('A2').text = 'Product';
//         sheet.getRangeByName('B2').text = productName;
//         sheet.getRangeByName('A3').text = 'Period';
//         sheet.getRangeByName('B3').text = '$startDate - $endDate';

//         final sections = [
//           {'name': 'Opening', 'col': 2},
//           {'name': 'Purchase', 'col': 5},
//           {'name': 'Pur Return', 'col': 8},
//           {'name': 'Sales', 'col': 11},
//           {'name': 'Sale Return', 'col': 14},
//           {'name': 'Closing', 'col': 17},
//         ];

//         for (final sec in sections) {
//           final int col = sec['col'] as int;
//           final String startCol = _colLetter(col);
//           final String endCol = _colLetter(col + 2);
//           final String mergeRange = '${startCol}5:${endCol}5';
//           sheet.getRangeByName(mergeRange).merge();
//           final xlsio.Range cell = sheet.getRangeByName('${startCol}5');
//           cell.text = sec['name'] as String;
//           cell.cellStyle.bold = true;
//           cell.cellStyle.hAlign = xlsio.HAlignType.center;
//           cell.cellStyle.backColor = '#D3D3D3';
//         }

//         for (int i = 0; i < 6; i++) {
//           final int col = 2 + i * 3;
//           sheet.getRangeByName('${_colLetter(col)}6').text = 'Qty';
//           sheet.getRangeByName('${_colLetter(col + 1)}6').text = 'Rate';
//           sheet.getRangeByName('${_colLetter(col + 2)}6').text = 'Amount';
//           for (int j = 0; j < 3; j++) {
//             final xlsio.Range cell =
//                 sheet.getRangeByName('${_colLetter(col + j)}6');
//             cell.cellStyle.bold = true;
//             cell.cellStyle.hAlign = xlsio.HAlignType.center;
//           }
//         }

//         final List<String> dataValues = [
//           productName,
//           openingQty.toStringAsFixed(0),
//           openingRate.toStringAsFixed(2),
//           '0',
//           purchaseQty.toStringAsFixed(0),
//           purchaseRate.toStringAsFixed(2),
//           purchaseAmt.toStringAsFixed(2),
//           (purRetQty).toStringAsFixed(0),
//           purRetRate.toStringAsFixed(2),
//           (purRetAmt).toStringAsFixed(2),
//           (salesQty).toStringAsFixed(0),
//           sellingPrice.toStringAsFixed(2),
//           (salesAmt).toStringAsFixed(2),
//           saleRetQty.toStringAsFixed(0),
//           saleRetPrice.toStringAsFixed(2),
//           saleRetAmt.toStringAsFixed(2),
//           closingQty.toStringAsFixed(0),
//           closingRate.toStringAsFixed(2),
//           closingAmt.toStringAsFixed(2),
//         ];

//         for (int i = 0; i < dataValues.length; i++) {
//           final xlsio.Range cell =
//               sheet.getRangeByName('${_colLetter(i + 1)}7');
//           cell.text = dataValues[i];
//           cell.cellStyle.borders.all.lineStyle = xlsio.LineStyle.thin;
//           cell.cellStyle.hAlign = xlsio.HAlignType.center;
//         }

//         for (int r = 5; r <= 7; r++) {
//           for (int c = 1; c <= 19; c++) {
//             final xlsio.Range cell = sheet.getRangeByName('${_colLetter(c)}$r');
//             cell.cellStyle.borders.all.lineStyle = xlsio.LineStyle.thin;
//           }
//         }

//         for (int i = 1; i <= 19; i++) {
//           final int width = i == 1 ? 135 : 90;
//           sheet.setColumnWidthInPixels(i, width);
//         }

//         final List<int> xlsxBytes = workbook.saveAsStream();
//         workbook.dispose();

//         final xlsxFile = File(
//             '${dir.path}/stock_ledger_${DateTime.now().millisecondsSinceEpoch}.xlsx');
//         await xlsxFile.writeAsBytes(xlsxBytes);
//         print('XLSX SAVED → ${xlsxFile.path}');
//       } catch (e, stackTrace) {
//         print('XLSX FAILED → $e');
//         print(stackTrace);
//       }
//     } catch (e, s) {
//       print('EXPORT FAILED → $e\n$s');
//       rethrow;
//     }
//   }

// // ========================================
// // FIXED HELPERS
// // ========================================
//   double? _safeDouble(
//     Map<String, dynamic> map,
//     Object key1, [
//     Object? key2,
//     Object? key3,
//     Object? key4,
//   ]) {
//     try {
//       dynamic value = map[key1];
//       if (value == null) return null;

//       if (key2 != null) {
//         value = (value is List && key2 is int) ? value[key2] : value[key2];
//       }
//       if (key3 != null) {
//         value = (value is List && key3 is int) ? value[key3] : value[key3];
//       }
//       if (key4 != null) {
//         value = (value is List && key4 is int) ? value[key4] : value[key4];
//       }

//       if (value is num) return value.toDouble();
//       if (value is String) return double.tryParse(value);
//       return null;
//     } catch (e) {
//       return null;
//     }
//   }

//   String? _safeString(
//     Map<String, dynamic> map,
//     Object key1, [
//     Object? key2,
//     Object? key3,
//     Object? key4,
//   ]) {
//     try {
//       dynamic value = map[key1];
//       if (value == null) return null;

//       if (key2 != null) {
//         value = (value is List && key2 is int) ? value[key2] : value[key2];
//       }
//       if (key3 != null) {
//         value = (value is List && key3 is int) ? value[key3] : value[key3];
//       }
//       if (key4 != null) {
//         value = (value is List && key4 is int) ? value[key4] : value[key4];
//       }

//       return value?.toString();
//     } catch (e) {
//       return null;
//     }
//   }

//   String _colLetter(int col) {
//     String letter = '';
//     while (col > 0) {
//       col--;
//       letter = String.fromCharCode(65 + (col % 26)) + letter;
//       col = col ~/ 26;
//     }
//     return letter;
//   }

//   // ─────────────────────────────────────────────────────────────
//   // ORIGINAL LEDGER PDF/EXCEL (UNTOUCHED)
//   // ─────────────────────────────────────────────────────────────
//   Future<void> downloadAsPdf(
//     LedgerReport ledgerReport,
//     String startDate,
//     String endDate,
//   ) async {
//     try {
//       final granted = await _requestPermission();
//       if (!granted) throw Exception('Permission denied');

//       final pdf = pw.Document();
//       if (ledgerReport.data!.isNotEmpty) {
//         final account = ledgerReport.data!.first;
//         pdf.addPage(
//           pw.Page(
//             build: (_) => pw.Column(
//               crossAxisAlignment: pw.CrossAxisAlignment.start,
//               children: [
//                 pw.Text(
//                   'Ledger Report',
//                   style: pw.TextStyle(
//                     fontSize: 24,
//                     fontWeight: pw.FontWeight.bold,
//                   ),
//                 ),
//                 pw.Text(
//                   'Account: ${account.accountName}',
//                   style: const pw.TextStyle(fontSize: 16),
//                 ),
//                 pw.Text(
//                   'Period: $startDate to $endDate',
//                   style: const pw.TextStyle(fontSize: 16),
//                 ),
//                 pw.SizedBox(height: 20),
//                 pw.Table.fromTextArray(
//                   headers: ['Date', 'Voucher #', 'Debit', 'Credit', 'Balance'],
//                   data: account.ledger!
//                       .map(
//                         (e) => [
//                           e.voucherDate!.split('T')[0],
//                           e.voucherNumber,
//                           e.debit!.toStringAsFixed(2),
//                           e.credit!.toStringAsFixed(2),
//                           e.runningBalance!.toStringAsFixed(2),
//                         ],
//                       )
//                       .toList(),
//                 ),
//               ],
//             ),
//           ),
//         );
//       } else {
//         pdf.addPage(pw.Page(build: (_) => pw.Text('No data')));
//       }

//       final dir = await _getDownloadDirectory();
//       final file = File(
//         '${dir.path}/ledger_${DateTime.now().millisecondsSinceEpoch}.pdf',
//       );
//       await file.writeAsBytes(await pdf.save());
//       log('Ledger PDF saved: ${file.path}');
//     } catch (e) {
//       log('Ledger PDF failed: $e');
//       rethrow;
//     }
//   }

//   Future<void> downloadAsExcel(
//     LedgerReport ledgerReport,
//     String startDate,
//     String endDate,
//   ) async {
//     try {
//       final granted = await _requestPermission();
//       if (!granted) throw Exception('Permission denied');

//       final rows = <List<dynamic>>[
//         ['Date', 'Voucher #', 'Debit', 'Credit', 'Balance'],
//         ...?ledgerReport.data?.first.ledger?.map(
//           (e) => [
//             e.voucherDate!.split('T')[0],
//             e.voucherNumber,
//             e.debit!.toStringAsFixed(2),
//             e.credit!.toStringAsFixed(2),
//             e.runningBalance!.toStringAsFixed(2),
//           ],
//         ),
//       ];

//       final csv = const ListToCsvConverter().convert(rows);
//       final dir = await _getDownloadDirectory();
//       final file = File(
//         '${dir.path}/ledger_${DateTime.now().millisecondsSinceEpoch}.csv',
//       );
//       await file.writeAsString(csv);
//       log('Ledger CSV saved: ${file.path}');
//     } catch (e) {
//       log('Ledger CSV failed: $e');
//       rethrow;
//     }
//   }

//   // ─────────────────────────────────────────────────────────────
//   // TRIAL BALANCE
//   // ─────────────────────────────────────────────────────────────
//   Future<TrialBalanceReport> fetchTrialBalance(String start, String end) async {
//     final response = await dio.get(
//       '/ledger/get_trial_balance/',
//       queryParameters: {'start_date': start, 'end_date': end},
//     );
//     return TrialBalanceReport.fromJson(response.data);
//   }

//   Future<void> downloadTrialBalanceAsPdf(
//     TrialBalanceReport report,
//     String startDate,
//     String endDate,
//   ) async {
//     try {
//       final granted = await _requestPermission();
//       if (!granted) throw Exception('Permission denied');

//       final pdf = pw.Document();
//       final accounts = report.data ?? [];

//       pdf.addPage(
//         pw.Page(
//           pageFormat: PdfPageFormat.a4,
//           margin: const pw.EdgeInsets.all(40),
//           build: (_) => pw.Column(
//             crossAxisAlignment: pw.CrossAxisAlignment.start,
//             children: [
//               pw.Text(
//                 'Trial Balance Report',
//                 style: pw.TextStyle(
//                   fontSize: 22,
//                   fontWeight: pw.FontWeight.bold,
//                 ),
//               ),
//               pw.SizedBox(height: 8),
//               pw.Text('Period: $startDate to $endDate'),
//               pw.Text(
//                 report.isDayOpen == true ? 'Day is OPEN' : 'Day is CLOSED',
//                 style: pw.TextStyle(
//                   color: report.isDayOpen == true
//                       ? PdfColors.green
//                       : PdfColors.red,
//                   fontWeight: pw.FontWeight.bold,
//                 ),
//               ),
//               pw.SizedBox(height: 20),
//               pw.Table(
//                 border: pw.TableBorder.all(),
//                 columnWidths: {
//                   0: const pw.FlexColumnWidth(4),
//                   1: const pw.FlexColumnWidth(2),
//                   2: const pw.FlexColumnWidth(2),
//                 },
//                 children: [
//                   pw.TableRow(
//                     decoration: const pw.BoxDecoration(
//                       color: PdfColors.grey300,
//                     ),
//                     children: [
//                       pw.Padding(
//                         padding: const pw.EdgeInsets.all(8),
//                         child: pw.Text(
//                           'Account',
//                           style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
//                         ),
//                       ),
//                       pw.Padding(
//                         padding: const pw.EdgeInsets.all(8),
//                         child: pw.Text(
//                           'Debit',
//                           style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
//                         ),
//                       ),
//                       pw.Padding(
//                         padding: const pw.EdgeInsets.all(8),
//                         child: pw.Text(
//                           'Credit',
//                           style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
//                         ),
//                       ),
//                     ],
//                   ),
//                   ...accounts.map(
//                     (a) => pw.TableRow(
//                       children: [
//                         pw.Padding(
//                           padding: const pw.EdgeInsets.all(8),
//                           child: pw.Text(a.accountName ?? ''),
//                         ),
//                         pw.Padding(
//                           padding: const pw.EdgeInsets.all(8),
//                           child: pw.Text((a.debit ?? 0).toStringAsFixed(2)),
//                         ),
//                         pw.Padding(
//                           padding: const pw.EdgeInsets.all(8),
//                           child: pw.Text((a.credit ?? 0).toStringAsFixed(2)),
//                         ),
//                       ],
//                     ),
//                   ),
//                   pw.TableRow(
//                     decoration: const pw.BoxDecoration(
//                       color: PdfColors.grey200,
//                     ),
//                     children: [
//                       pw.Padding(
//                         padding: const pw.EdgeInsets.all(8),
//                         child: pw.Text(
//                           'TOTAL',
//                           style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
//                         ),
//                       ),
//                       pw.Padding(
//                         padding: const pw.EdgeInsets.all(8),
//                         child: pw.Text(
//                           accounts
//                               .fold(0.0, (p, e) => p + (e.debit ?? 0))
//                               .toStringAsFixed(2),
//                           style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
//                         ),
//                       ),
//                       pw.Padding(
//                         padding: const pw.EdgeInsets.all(8),
//                         child: pw.Text(
//                           accounts
//                               .fold(0.0, (p, e) => p + (e.credit ?? 0))
//                               .toStringAsFixed(2),
//                           style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       );

//       final dir = await _getDownloadDirectory();
//       final file = File(
//         '${dir.path}/trial_balance_${DateTime.now().millisecondsSinceEpoch}.pdf',
//       );
//       await file.writeAsBytes(await pdf.save());
//       log('Trial Balance PDF saved: ${file.path}');
//     } catch (e) {
//       log('Trial Balance PDF failed: $e');
//       rethrow;
//     }
//   }

//   Future<void> downloadTrialBalanceAsExcel(
//     TrialBalanceReport report,
//     String startDate,
//     String endDate,
//   ) async {
//     try {
//       final granted = await _requestPermission();
//       if (!granted) throw Exception('Permission denied');

//       final rows = <List<dynamic>>[
//         ['Trial Balance Report'],
//         ['Period', '$startDate - $endDate'],
//         ['Day Status', report.isDayOpen == true ? 'OPEN' : 'CLOSED'],
//         [],
//         ['Account', 'Debit', 'Credit'],
//         ...?report.data?.map(
//           (a) => [
//             a.accountName ?? '',
//             (a.debit ?? 0).toStringAsFixed(2),
//             (a.credit ?? 0).toStringAsFixed(2),
//           ],
//         ),
//         [
//           'TOTAL',
//           report.data
//               ?.fold(0.0, (p, e) => p + (e.debit ?? 0))
//               .toStringAsFixed(2),
//           report.data
//               ?.fold(0.0, (p, e) => p + (e.credit ?? 0))
//               .toStringAsFixed(2),
//         ],
//       ];

//       final csv = const ListToCsvConverter().convert(rows);
//       final dir = await _getDownloadDirectory();
//       final file = File(
//         '${dir.path}/trial_balance_${DateTime.now().millisecondsSinceEpoch}.csv',
//       );
//       await file.writeAsString(csv);
//       log('Trial Balance CSV saved: ${file.path}');
//     } catch (e) {
//       log('Trial Balance CSV failed: $e');
//       rethrow;
//     }
//   }
// }
//fixed codeimport 'dart:convert';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:csv/csv.dart';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:saleup_app/core/network/api_endpoints.dart';
import 'package:saleup_app/model/ledger_report_response.dart';
import 'package:saleup_app/model/stock_ledger_response.dart';
import 'package:saleup_app/model/trial_balance_report_response.dart';
import 'package:saleup_app/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' as xlsio;

class DioClient {
  static final DioClient _instance = DioClient._internal();
  final Dio dio = Dio();

  factory DioClient() => _instance;

  DioClient._internal() {
    dio.options.baseUrl = Api.backendUrl;
    dio.options.connectTimeout = const Duration(seconds: 30);
    dio.options.receiveTimeout = const Duration(seconds: 30);
    dio.options.sendTimeout = const Duration(seconds: 30);

    dio.options.headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    (dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
      final client = HttpClient();
      client.badCertificateCallback = (cert, host, port) => true;
      return client;
    };

    dio.options.validateStatus = (status) => status != null && status < 500;

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final unauthenticatedEndpoints = [
            '/auth/login/',
            '/auth/forgot_password/',
            '/auth/verify_forgot_password_otp/',
            '/auth/reset_password/',
            '/chat/',
          ];
          if (!unauthenticatedEndpoints.contains(options.path)) {
            final token = await AuthService().getAccessToken();
            if (token != null) {
              options.headers['Authorization'] = 'Bearer $token';
              log('Authorization header set for ${options.path}');
            }
          }
          log('Request: ${options.method} ${options.path}');
          return handler.next(options);
        },
        onResponse: (response, handler) {
          log('Response: ${response.statusCode} ${response.requestOptions.path}');
          return handler.next(response);
        },
        onError: (DioException error, handler) async {
          log('Error: ${error.response?.statusCode} ${error.requestOptions.path}');
          if (error.response?.statusCode == 401 &&
              !error.requestOptions.path.contains('/auth/login/')) {
            await AuthService().clearTokens();
          }
          return handler.next(error);
        },
      ),
    );
  }

  Future<bool> isTokenValid() async {
    try {
      return await AuthService().getAccessToken() != null;
    } catch (e) {
      log('Token check error: $e');
      return false;
    }
  }

  Future<void> logout(BuildContext context) async {
    await AuthService().clearTokens();
    context.go('/login');
  }

  Future<bool> refreshToken() async {
    final refreshToken = await AuthService().getRefreshToken();
    if (refreshToken == null) return false;

    try {
      final response = await dio.post(
        '/auth/refresh/',
        data: {'refresh_token': refreshToken},
      );
      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'];
        await AuthService().saveTokens(
          accessToken: data['access_token'],
          refreshToken: data['refresh_token'] ?? refreshToken,
          userId: await AuthService().getUserId() ?? 0,
        );
        return true;
      }
    } catch (e) {
      log('Refresh failed: $e');
    }
    return false;
  }

  Future<bool> _requestPermission() async {
    if (Platform.isAndroid) {
      final status = await Permission.storage.request();
      return status.isGranted;
    }
    return true;
  }

  Future<Directory> _getDownloadDirectory() async {
    if (Platform.isAndroid) {
      final dir = await getDownloadsDirectory();
      if (dir != null) return dir;
    }
    return await getApplicationDocumentsDirectory();
  }

  // ─────────────────────────────────────────────────────────────
  // PDF HELPER WIDGETS
  // ─────────────────────────────────────────────────────────────
  pw.Widget _headerCell(String text) => pw.Container(
        padding: const pw.EdgeInsets.all(6),
        alignment: pw.Alignment.center,
        child: pw.Text(
          text,
          style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11),
        ),
      );

  pw.Widget _subHeaderCell(String text) => pw.Container(
        padding: const pw.EdgeInsets.all(4),
        alignment: pw.Alignment.center,
        child: pw.Text(
          text,
          style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9),
        ),
      );

  pw.Widget _dataCell(String text, {bool bold = false}) => pw.Container(
        padding: const pw.EdgeInsets.all(4),
        alignment: pw.Alignment.center,
        child: pw.Text(
          text,
          style: pw.TextStyle(
            fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
            fontSize: 10,
          ),
        ),
      );

  pw.Widget _sectionLabelOneLine(String text) => pw.Container(
        padding: const pw.EdgeInsets.all(6),
        alignment: pw.Alignment.center,
        decoration: const pw.BoxDecoration(color: PdfColors.grey300),
        child: pw.Text(
          text,
          style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11),
          textAlign: pw.TextAlign.center,
        ),
      );

  // ─────────────────────────────────────────────────────────────
  // DYNAMIC HELPERS (PER SECTION)
  // ─────────────────────────────────────────────────────────────
  double _getQty(Map<String, dynamic> data, String section, String? subKey) {
    try {
      dynamic list = data[section];
      if (subKey != null) list = list?[subKey];
      if (list is List && list.isNotEmpty) {
        final qty = list[0]['quantity'];
        if (qty is num) return qty.toDouble();
        if (qty is String) return double.tryParse(qty) ?? 0.0;
      }
    } catch (e) {
      // silent
    }
    return 0.0;
  }

  double _getRate(Map<String, dynamic> data, String section, String? subKey,
      String rateType) {
    try {
      dynamic list = data[section];
      if (subKey != null) list = list?[subKey];
      if (list is List && list.isNotEmpty) {
        final item = list[0];
        final key = rateType == 'selling' ? 'selling_price' : 'cost_price';
        final value = item[key];
        if (value is num) return value.toDouble();
        if (value is String) return double.tryParse(value) ?? 0.0;
      }
    } catch (e) {
      // silent
    }
    return 0.0;
  }

  String _getProductName(Map<String, dynamic> data) {
    return _safeString(data, 'purchases', 0, 'product_name') ??
        _safeString(data, 'sales', 0, 'product_name') ??
        _safeString(data, 'closing_stock', 'summary', 0, 'product_name') ??
        'N/A';
  }

  // ─────────────────────────────────────────────────────────────
  // STOCK LEDGER PDF – DYNAMIC RATE PER SECTION
  // ─────────────────────────────────────────────────────────────
  Future<void> downloadStockLedgerAsPdf(
    Map<String, dynamic> json,
    String startDate,
    String endDate,
    String rateType, // 'cost' or 'selling'
  ) async {
    try {
      final granted = await _requestPermission();
      if (!granted) throw Exception('Permission denied');
      final pdf = pw.Document();

      log('PDF EXPORT STARTED → rateType: $rateType');
      log('RAW JSON:\n${const JsonEncoder.withIndent('  ').convert(json)}');

      final data = json['data'] as Map<String, dynamic>;
      final productName = _getProductName(data);

      // === DYNAMIC RATE & QTY PER SECTION ===
      final openingQty = _getQty(data, 'opening_stock', 'summary');
      final openingRate = _getRate(data, 'opening_stock', 'summary', rateType);
      final openingAmt = openingQty * openingRate;

      final purchaseQty = _getQty(data, 'purchases', null);
      final purchaseRate = _getRate(data, 'purchases', null, rateType);
      final purchaseAmt = purchaseQty * purchaseRate;

      final purRetQty = _getQty(data, 'purchase_returns', null);
      final purRetRate = _getRate(data, 'purchase_returns', null, rateType);
      final purRetAmt = purRetQty * purRetRate;

      final salesQty = _getQty(data, 'sales', null);
      final salesRate = _getRate(data, 'sales', null, rateType);
      final salesAmt = salesQty * salesRate;

      final saleRetQty = _getQty(data, 'sale_returns', null);
      final saleRetRate = _getRate(data, 'sale_returns', null, rateType);
      final saleRetAmt = saleRetQty * saleRetRate;

      final closingQty = _getQty(data, 'closing_stock', 'summary');
      final closingRate = _getRate(data, 'closing_stock', 'summary', rateType);
      final closingAmt = closingQty * closingRate;

      log('CALCULATED VALUES (DYNAMIC PER SECTION):');
      log('  Product: $productName');
      log('  Opening: Qty=$openingQty, Rate=$openingRate, Amt=$openingAmt');
      log('  Purchase: Qty=$purchaseQty, Rate=$purchaseRate, Amt=$purchaseAmt');
      log('  Pur Return: Qty=$purRetQty, Rate=$purRetRate, Amt=$purRetAmt');
      log('  Sales: Qty=$salesQty, Rate=$salesRate, Amt=$salesAmt');
      log('  Sale Return: Qty=$saleRetQty, Rate=$saleRetRate, Amt=$saleRetAmt');
      log('  Closing: Qty=$closingQty, Rate=$closingRate, Amt=$closingAmt');

      // === PDF TABLE ===
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4.landscape,
          margin: const pw.EdgeInsets.all(20),
          build: (_) => pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'Stock Ledger Summary (${rateType == 'selling' ? 'Selling Price' : 'Cost Price'})',
                style:
                    pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
              ),
              pw.Text('Product: $productName'),
              pw.Text('Period: $startDate to $endDate'),
              pw.SizedBox(height: 16),
              pw.Table(
                border: pw.TableBorder.all(),
                columnWidths: {
                  0: const pw.FixedColumnWidth(90),
                  for (int i = 1; i < 19; i++) i: const pw.FixedColumnWidth(78),
                },
                children: [
                  pw.TableRow(
                    decoration: pw.BoxDecoration(color: PdfColors.grey300),
                    children: [
                      pw.Container(),
                      ...[
                        'Opening',
                        'Purchase',
                        'Pur Return',
                        'Sales',
                        'Sale Return',
                        'Closing'
                      ]
                          .expand((l) => [
                                _sectionLabelOneLine(l),
                                pw.Container(),
                                pw.Container()
                              ])
                          .toList(),
                    ],
                  ),
                  pw.TableRow(
                    children: [
                      _headerCell('Product'),
                      ...List.generate(
                          18,
                          (i) =>
                              _subHeaderCell(['Qty', 'Rate', 'Amount'][i % 3])),
                    ],
                  ),
                  pw.TableRow(
                    children: [
                      _dataCell(productName, bold: true),
                      _dataCell(openingQty.toStringAsFixed(0)),
                      _dataCell(openingRate.toStringAsFixed(2)),
                      _dataCell(openingAmt.toStringAsFixed(2)),
                      _dataCell(purchaseQty.toStringAsFixed(0)),
                      _dataCell(purchaseRate.toStringAsFixed(2)),
                      _dataCell(purchaseAmt.toStringAsFixed(2)),
                      _dataCell(purRetQty.toStringAsFixed(0)),
                      _dataCell(purRetRate.toStringAsFixed(2)),
                      _dataCell(purRetAmt.toStringAsFixed(2)),
                      _dataCell(salesQty.toStringAsFixed(0)),
                      _dataCell(salesRate.toStringAsFixed(2)),
                      _dataCell(salesAmt.toStringAsFixed(2)),
                      _dataCell(saleRetQty.toStringAsFixed(0)),
                      _dataCell(saleRetRate.toStringAsFixed(2)),
                      _dataCell(saleRetAmt.toStringAsFixed(2)),
                      _dataCell(closingQty.toStringAsFixed(0)),
                      _dataCell(closingRate.toStringAsFixed(2)),
                      _dataCell(closingAmt.toStringAsFixed(2)),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      );

      final dir = await _getDownloadDirectory();
      final file = File(
          '${dir.path}/stock_ledger_${DateTime.now().millisecondsSinceEpoch}.pdf');
      await file.writeAsBytes(await pdf.save());
      log('PDF SAVED → ${file.path}');
    } catch (e, s) {
      log('PDF FAILED → $e\n$s');
      rethrow;
    }
  }

  // ─────────────────────────────────────────────────────────────
  // STOCK LEDGER EXCEL – DYNAMIC RATE PER SECTION
  // ─────────────────────────────────────────────────────────────
  Future<void> downloadStockLedgerAsExcel(
    Map<String, dynamic> json,
    String startDate,
    String endDate,
    String rateType,
  ) async {
    try {
      final granted = await _requestPermission();
      if (!granted) throw Exception('Permission denied');

      log('EXCEL EXPORT STARTED → rateType: $rateType');
      log('RAW JSON:\n${const JsonEncoder.withIndent('  ').convert(json)}');

      final data = json['data'] as Map<String, dynamic>;
      final productName = _getProductName(data);

      final openingQty = _getQty(data, 'opening_stock', 'summary');
      final openingRate = _getRate(data, 'opening_stock', 'summary', rateType);
      final openingAmt = openingQty * openingRate;

      final purchaseQty = _getQty(data, 'purchases', null);
      final purchaseRate = _getRate(data, 'purchases', null, rateType);
      final purchaseAmt = purchaseQty * purchaseRate;

      final purRetQty = _getQty(data, 'purchase_returns', null);
      final purRetRate = _getRate(data, 'purchase_returns', null, rateType);
      final purRetAmt = purRetQty * purRetRate;

      final salesQty = _getQty(data, 'sales', null);
      final salesRate = _getRate(data, 'sales', null, rateType);
      final salesAmt = salesQty * salesRate;

      final saleRetQty = _getQty(data, 'sale_returns', null);
      final saleRetRate = _getRate(data, 'sale_returns', null, rateType);
      final saleRetAmt = saleRetQty * saleRetRate;

      final closingQty = _getQty(data, 'closing_stock', 'summary');
      final closingRate = _getRate(data, 'closing_stock', 'summary', rateType);
      final closingAmt = closingQty * closingRate;

      log('CALCULATED VALUES (DYNAMIC PER SECTION):');
      log('  Product: $productName');
      log('  Opening: Qty=$openingQty, Rate=$openingRate, Amt=$openingAmt');
      log('  Purchase: Qty=$purchaseQty, Rate=$purchaseRate, Amt=$purchaseAmt');
      log('  Pur Return: Qty=$purRetQty, Rate=$purRetRate, Amt=$purRetAmt');
      log('  Sales: Qty=$salesQty, Rate=$salesRate, Amt=$salesAmt');
      log('  Sale Return: Qty=$saleRetQty, Rate=$saleRetRate, Amt=$saleRetAmt');
      log('  Closing: Qty=$closingQty, Rate=$closingRate, Amt=$closingAmt');

      final rows = <List<dynamic>>[
        [
          'Stock Ledger Summary (${rateType == 'selling' ? 'Selling Price' : 'Cost Price'})'
        ],
        ['Product', productName],
        ['Period', '$startDate - $endDate'],
        [],
        [
          'Product',
          'Opening',
          '',
          '',
          'Purchase',
          '',
          '',
          'Pur Return',
          '',
          '',
          'Sales',
          '',
          '',
          'Sale Return',
          '',
          '',
          'Closing',
          '',
          ''
        ],
        [
          '',
          'Qty',
          'Rate',
          'Amount',
          'Qty',
          'Rate',
          'Amount',
          'Qty',
          'Rate',
          'Amount',
          'Qty',
          'Rate',
          'Amount',
          'Qty',
          'Rate',
          'Amount',
          'Qty',
          'Rate',
          'Amount'
        ],
        [
          productName,
          openingQty.toStringAsFixed(0),
          openingRate.toStringAsFixed(2),
          openingAmt.toStringAsFixed(2),
          purchaseQty.toStringAsFixed(0),
          purchaseRate.toStringAsFixed(2),
          purchaseAmt.toStringAsFixed(2),
          purRetQty.toStringAsFixed(0),
          purRetRate.toStringAsFixed(2),
          purRetAmt.toStringAsFixed(2),
          salesQty.toStringAsFixed(0),
          salesRate.toStringAsFixed(2),
          salesAmt.toStringAsFixed(2),
          saleRetQty.toStringAsFixed(0),
          saleRetRate.toStringAsFixed(2),
          saleRetAmt.toStringAsFixed(2),
          closingQty.toStringAsFixed(0),
          closingRate.toStringAsFixed(2),
          closingAmt.toStringAsFixed(2),
        ],
      ];

      final csv = const ListToCsvConverter().convert(rows);
      final dir = await _getDownloadDirectory();
      final csvFile = File(
          '${dir.path}/stock_ledger_${DateTime.now().millisecondsSinceEpoch}.csv');
      await csvFile.writeAsString(csv);
      log('CSV SAVED → ${csvFile.path}');

      // === XLSX: FIXED + LOGS ===
      try {
        final workbook = xlsio.Workbook();
        final sheet = workbook.worksheets[0];
        sheet.name = 'Stock Ledger';

        // Title
        sheet.getRangeByIndex(1, 1, 1, 19).merge();
        sheet.getRangeByIndex(1, 1).text =
            'Stock Ledger Summary (${rateType == 'selling' ? 'Selling Price' : 'Cost Price'})';
        sheet.getRangeByIndex(1, 1).cellStyle.fontSize = 16;
        sheet.getRangeByIndex(1, 1).cellStyle.bold = true;
        sheet.getRangeByIndex(1, 1).cellStyle.hAlign = xlsio.HAlignType.center;

        // Product & Period
        sheet.getRangeByIndex(2, 1).text = 'Product';
        sheet.getRangeByIndex(2, 2).text = productName;
        sheet.getRangeByIndex(3, 1).text = 'Period';
        sheet.getRangeByIndex(3, 2).text = '$startDate - $endDate';

        // Section Headers
        final sections = [
          {'name': 'Opening', 'col': 2},
          {'name': 'Purchase', 'col': 5},
          {'name': 'Pur Return', 'col': 8},
          {'name': 'Sales', 'col': 11},
          {'name': 'Sale Return', 'col': 14},
          {'name': 'Closing', 'col': 17},
        ];

        for (final sec in sections) {
          final col = sec['col'] as int;
          sheet.getRangeByIndex(5, col, 5, col + 2).merge();
          final cell = sheet.getRangeByIndex(5, col);
          cell.text = sec['name'] as String;
          cell.cellStyle.bold = true;
          cell.cellStyle.hAlign = xlsio.HAlignType.center;
          cell.cellStyle.backColor = '#D3D3D3';
        }

        // Subheaders
        for (int i = 0; i < 6; i++) {
          final col = 2 + i * 3;
          sheet.getRangeByIndex(6, col).text = 'Qty';
          sheet.getRangeByIndex(6, col + 1).text = 'Rate';
          sheet.getRangeByIndex(6, col + 2).text = 'Amount';
          for (int j = 0; j < 3; j++) {
            sheet.getRangeByIndex(6, col + j).cellStyle.bold = true;
            sheet.getRangeByIndex(6, col + j).cellStyle.hAlign =
                xlsio.HAlignType.center;
          }
        }

        // Data Row
        final dataValues = [
          productName,
          openingQty.toStringAsFixed(0),
          openingRate.toStringAsFixed(2),
          openingAmt.toStringAsFixed(2),
          purchaseQty.toStringAsFixed(0),
          purchaseRate.toStringAsFixed(2),
          purchaseAmt.toStringAsFixed(2),
          purRetQty.toStringAsFixed(0),
          purRetRate.toStringAsFixed(2),
          purRetAmt.toStringAsFixed(2),
          salesQty.toStringAsFixed(0),
          salesRate.toStringAsFixed(2),
          salesAmt.toStringAsFixed(2),
          saleRetQty.toStringAsFixed(0),
          saleRetRate.toStringAsFixed(2),
          saleRetAmt.toStringAsFixed(2),
          closingQty.toStringAsFixed(0),
          closingRate.toStringAsFixed(2),
          closingAmt.toStringAsFixed(2),
        ];

        for (int i = 0; i < dataValues.length; i++) {
          final cell = sheet.getRangeByIndex(7, i + 1);
          cell.text = dataValues[i];
          cell.cellStyle.borders.all.lineStyle = xlsio.LineStyle.thin;
          cell.cellStyle.hAlign = xlsio.HAlignType.center;
        }

        // Borders
        for (int r = 5; r <= 7; r++) {
          for (int c = 1; c <= 19; c++) {
            sheet.getRangeByIndex(r, c).cellStyle.borders.all.lineStyle =
                xlsio.LineStyle.thin;
          }
        }

        // Column widths
        for (int i = 1; i <= 19; i++) {
          sheet.setColumnWidthInPixels(i, i == 1 ? 135 : 90);
        }

        final xlsxBytes = workbook.saveAsStream();
        workbook.dispose();

        final xlsxFile = File(
            '${dir.path}/stock_ledger_${DateTime.now().millisecondsSinceEpoch}.xlsx');
        await xlsxFile.writeAsBytes(xlsxBytes);
        log('XLSX SAVED → ${xlsxFile.path}');
      } catch (e, s) {
        log('XLSX FAILED → $e\n$s');
      }
    } catch (e, s) {
      log('EXPORT FAILED → $e\n$s');
      rethrow;
    }
  }

  // ========================================
  // SAFE HELPERS
  // ========================================
  String? _safeString(Map<String, dynamic> map, Object key1,
      [Object? key2, Object? key3, Object? key4]) {
    try {
      dynamic value = map[key1];
      if (value == null) return null;
      if (key2 != null) {
        value = (value is List && key2 is int) ? value[key2] : value[key2];
      }
      if (key3 != null) {
        value = (value is List && key3 is int) ? value[key3] : value[key3];
      }
      if (key4 != null) {
        value = (value is List && key4 is int) ? value[key4] : value[key4];
      }
      return value?.toString();
    } catch (e) {
      return null;
    }
  }

  // ─────────────────────────────────────────────────────────────
  // LEDGER & TRIAL BALANCE (UNCHANGED)
  // ─────────────────────────────────────────────────────────────
  Future<void> downloadAsPdf(
    LedgerReport ledgerReport,
    String startDate,
    String endDate,
  ) async {
    try {
      final granted = await _requestPermission();
      if (!granted) throw Exception('Permission denied');

      final pdf = pw.Document();
      if (ledgerReport.data!.isNotEmpty) {
        final account = ledgerReport.data!.first;
        pdf.addPage(
          pw.Page(
            build: (_) => pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('Ledger Report',
                    style: pw.TextStyle(
                        fontSize: 24, fontWeight: pw.FontWeight.bold)),
                pw.Text('Account: ${account.accountName}',
                    style: const pw.TextStyle(fontSize: 16)),
                pw.Text('Period: $startDate to $endDate',
                    style: const pw.TextStyle(fontSize: 16)),
                pw.SizedBox(height: 20),
                pw.Table.fromTextArray(
                  headers: ['Date', 'Voucher #', 'Debit', 'Credit', 'Balance'],
                  data: account.ledger!
                      .map((e) => [
                            e.voucherDate!.split('T')[0],
                            e.voucherNumber,
                            e.debit!.toStringAsFixed(2),
                            e.credit!.toStringAsFixed(2),
                            e.runningBalance!.toStringAsFixed(2),
                          ])
                      .toList(),
                ),
              ],
            ),
          ),
        );
      } else {
        pdf.addPage(pw.Page(build: (_) => pw.Text('No data')));
      }

      final dir = await _getDownloadDirectory();
      final file = File(
          '${dir.path}/ledger_${DateTime.now().millisecondsSinceEpoch}.pdf');
      await file.writeAsBytes(await pdf.save());
      log('Ledger PDF saved: ${file.path}');
    } catch (e) {
      log('Ledger PDF failed: $e');
      rethrow;
    }
  }

  Future<void> downloadAsExcel(
    LedgerReport ledgerReport,
    String startDate,
    String endDate,
  ) async {
    try {
      final granted = await _requestPermission();
      if (!granted) throw Exception('Permission denied');

      final rows = <List<dynamic>>[
        ['Date', 'Voucher #', 'Debit', 'Credit', 'Balance'],
        ...?ledgerReport.data?.first.ledger?.map(
          (e) => [
            e.voucherDate!.split('T')[0],
            e.voucherNumber,
            e.debit!.toStringAsFixed(2),
            e.credit!.toStringAsFixed(2),
            e.runningBalance!.toStringAsFixed(2),
          ],
        ),
      ];

      final csv = const ListToCsvConverter().convert(rows);
      final dir = await _getDownloadDirectory();
      final file = File(
          '${dir.path}/ledger_${DateTime.now().millisecondsSinceEpoch}.csv');
      await file.writeAsString(csv);
      log('Ledger CSV saved: ${file.path}');
    } catch (e) {
      log('Ledger CSV failed: $e');
      rethrow;
    }
  }

  Future<TrialBalanceReport> fetchTrialBalance(String start, String end) async {
    final response = await dio.get(
      '/ledger/get_trial_balance/',
      queryParameters: {'start_date': start, 'end_date': end},
    );
    return TrialBalanceReport.fromJson(response.data);
  }

  Future<void> downloadTrialBalanceAsPdf(
    TrialBalanceReport report,
    String startDate,
    String endDate,
  ) async {
    try {
      final granted = await _requestPermission();
      if (!granted) throw Exception('Permission denied');

      final pdf = pw.Document();
      final accounts = report.data ?? [];

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(40),
          build: (_) => pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Trial Balance Report',
                  style: pw.TextStyle(
                      fontSize: 22, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 8),
              pw.Text('Period: $startDate to $endDate'),
              pw.Text(
                report.isDayOpen == true ? 'Day is OPEN' : 'Day is CLOSED',
                style: pw.TextStyle(
                  color: report.isDayOpen == true
                      ? PdfColors.green
                      : PdfColors.red,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 20),
              pw.Table(
                border: pw.TableBorder.all(),
                columnWidths: {
                  0: const pw.FlexColumnWidth(4),
                  1: const pw.FlexColumnWidth(2),
                  2: const pw.FlexColumnWidth(2),
                },
                children: [
                  pw.TableRow(
                    decoration:
                        const pw.BoxDecoration(color: PdfColors.grey300),
                    children: [
                      pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text('Account',
                              style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold))),
                      pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text('Debit',
                              style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold))),
                      pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text('Credit',
                              style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold))),
                    ],
                  ),
                  ...accounts.map(
                    (a) => pw.TableRow(
                      children: [
                        pw.Padding(
                            padding: const pw.EdgeInsets.all(8),
                            child: pw.Text(a.accountName ?? '')),
                        pw.Padding(
                            padding: const pw.EdgeInsets.all(8),
                            child: pw.Text((a.debit ?? 0).toStringAsFixed(2))),
                        pw.Padding(
                            padding: const pw.EdgeInsets.all(8),
                            child: pw.Text((a.credit ?? 0).toStringAsFixed(2))),
                      ],
                    ),
                  ),
                  pw.TableRow(
                    decoration:
                        const pw.BoxDecoration(color: PdfColors.grey200),
                    children: [
                      pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text('TOTAL',
                              style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold))),
                      pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(
                            accounts
                                .fold(0.0, (p, e) => p + (e.debit ?? 0))
                                .toStringAsFixed(2),
                            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                          )),
                      pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(
                            accounts
                                .fold(0.0, (p, e) => p + (e.credit ?? 0))
                                .toStringAsFixed(2),
                            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                          )),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      );

      final dir = await _getDownloadDirectory();
      final file = File(
          '${dir.path}/trial_balance_${DateTime.now().millisecondsSinceEpoch}.pdf');
      await file.writeAsBytes(await pdf.save());
      log('Trial Balance PDF saved: ${file.path}');
    } catch (e) {
      log('Trial Balance PDF failed: $e');
      rethrow;
    }
  }

  Future<void> downloadTrialBalanceAsExcel(
    TrialBalanceReport report,
    String startDate,
    String endDate,
  ) async {
    try {
      final granted = await _requestPermission();
      if (!granted) throw Exception('Permission denied');

      final rows = <List<dynamic>>[
        ['Trial Balance Report'],
        ['Period', '$startDate - $endDate'],
        ['Day Status', report.isDayOpen == true ? 'OPEN' : 'CLOSED'],
        [],
        ['Account', 'Debit', 'Credit'],
        ...?report.data?.map(
          (a) => [
            a.accountName ?? '',
            (a.debit ?? 0).toStringAsFixed(2),
            (a.credit ?? 0).toStringAsFixed(2),
          ],
        ),
        [
          'TOTAL',
          report.data
              ?.fold(0.0, (p, e) => p + (e.debit ?? 0))
              .toStringAsFixed(2),
          report.data
              ?.fold(0.0, (p, e) => p + (e.credit ?? 0))
              .toStringAsFixed(2),
        ],
      ];

      final csv = const ListToCsvConverter().convert(rows);
      final dir = await _getDownloadDirectory();
      final file = File(
          '${dir.path}/trial_balance_${DateTime.now().millisecondsSinceEpoch}.csv');
      await file.writeAsString(csv);
      log('Trial Balance CSV saved: ${file.path}');
    } catch (e) {
      log('Trial Balance CSV failed: $e');
      rethrow;
    }
  }
}
