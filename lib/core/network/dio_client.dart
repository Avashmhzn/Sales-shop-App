// import 'dart:developer';
// import 'dart:io';
// import 'package:csv/csv.dart';
// import 'package:dio/dio.dart';
// import 'package:dio/io.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:pdf/pdf.dart';
// import 'package:pdf/widgets.dart' as pw;
// import 'package:printing/printing.dart'; // ← REQUIRED FOR PNG PREVIEW
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
//   // STOCK LEDGER PDF – FINAL: ONE LINE HEADERS + NO VERTICAL LINES
//   // ─────────────────────────────────────────────────────────────
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

//       // ── Compute totals (same as CSV) ───────────────────────
//       double openingQty = 0, openingRate = 0, openingAmt = 0;
//       double purQty = 0, purRate = 0, purAmt = 0;
//       double purRetQty = 0, purRetRate = 0, purRetAmt = 0;
//       double saleQty = 0, saleRate = 0, saleAmt = 0;
//       double saleRetQty = 0, saleRetRate = 0, saleRetAmt = 0;
//       double closingQty = 0, closingRate = 0, closingAmt = 0;

//       for (final e in entries) {
//         if (e.opening != null && e.opening! > 0) {
//           openingQty += e.opening!;
//           openingRate = e.costPrice ?? 0;
//           openingAmt += e.opening! * openingRate;
//         }
//         if (e.purchase != null && e.purchase! > 0) {
//           purQty += e.purchase!;
//           purRate = e.costPrice ?? 0;
//           purAmt += e.purchase! * purRate;
//         }
//         if (e.purchase != null && e.purchase! < 0) {
//           purRetQty += e.purchase!.abs();
//           purRetRate = e.costPrice ?? 0;
//           purRetAmt += e.purchase!.abs() * purRetRate;
//         }
//         if (e.sales != null && e.sales! > 0) {
//           saleQty += e.sales!;
//           saleRate = e.sellingPrice ?? 0;
//           saleAmt += e.sales! * saleRate;
//         }
//         if (e.sales != null && e.sales! < 0) {
//           saleRetQty += e.sales!.abs();
//           saleRetRate = e.sellingPrice ?? 0;
//           saleRetAmt += e.sales!.abs() * saleRetRate;
//         }
//         if (e.closing != null) {
//           closingQty = e.closing!;
//           closingRate = e.costPrice ?? e.sellingPrice ?? 0;
//           closingAmt = closingQty * closingRate;
//         }
//       }

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

//               // ── MAIN TABLE ─────────────────────────────────────
//               pw.Table(
//                 border: pw.TableBorder.all(width: 1, color: PdfColors.black),
//                 columnWidths: {
//                   0: const pw.FixedColumnWidth(100),
//                   for (int i = 1; i < 19; i++)
//                     i: const pw.FixedColumnWidth(200),
//                 },
//                 children: [
//                   // ── SECTION HEADER ROW (ONE LINE + NO VERTICAL LINES) ───────
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
//                       pw.Container(), // Product
//                       _sectionLabelOneLine('Opening'),
//                       pw.Container(), pw.Container(),
//                       _sectionLabelOneLine('Purchase'),
//                       pw.Container(), pw.Container(),
//                       _sectionLabelOneLine('Purchase Return'),
//                       pw.Container(), pw.Container(),
//                       _sectionLabelOneLine('Sales'),
//                       pw.Container(), pw.Container(),
//                       _sectionLabelOneLine('Sale Return'),
//                       pw.Container(), pw.Container(),
//                       _sectionLabelOneLine('Closing'),
//                       pw.Container(), pw.Container(),
//                     ],
//                   ),

//                   // ── SUB‑HEADER ROW ───────
//                   pw.TableRow(
//                     children: [
//                       _headerCell('Product'),
//                       ...List.generate(18, (i) {
//                         final text = ['Qty', 'Rate', 'Amount'][i % 3];
//                         return _subHeaderCell(text);
//                       }),
//                     ],
//                   ),

//                   // ── DATA ROW ───────────────────────────────────
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

//   // ─────────────────────────────────────────────────────────────
//   // STOCK LEDGER EXCEL (CSV) – ALREADY PERFECT
//   // ─────────────────────────────────────────────────────────────
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
//           if (e.opening != null && e.opening! > 0) {
//             openingQty += e.opening!;
//             openingRate = e.costPrice ?? 0;
//             openingAmt += e.opening! * openingRate;
//           }
//           if (e.purchase != null && e.purchase! > 0) {
//             purQty += e.purchase!;
//             purRate = e.costPrice ?? 0;
//             purAmt += e.purchase! * purRate;
//           }
//           if (e.purchase != null && e.purchase! < 0) {
//             purRetQty += e.purchase!.abs();
//             purRetRate = e.costPrice ?? 0;
//             purRetAmt += e.purchase!.abs() * purRetRate;
//           }
//           if (e.sales != null && e.sales! > 0) {
//             saleQty += e.sales!;
//             saleRate = e.sellingPrice ?? 0;
//             saleAmt += e.sales! * saleRate;
//           }
//           if (e.sales != null && e.sales! < 0) {
//             saleRetQty += e.sales!.abs();
//             saleRetRate = e.sellingPrice ?? 0;
//             saleRetAmt += e.sales!.abs() * saleRetRate;
//           }
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

//   //trial
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

class DioClient {
  static final DioClient _instance = DioClient._internal();
  final Dio dio = Dio();

  factory DioClient() {
    return _instance;
  }

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

    dio.options.validateStatus = (status) {
      return status != null && status < 500;
    };

    dio.interceptors.add(InterceptorsWrapper(
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
            log('Authorization header set for ${options.path} with token: $token');
          } else {
            log('No access token available for ${options.path}');
          }
        } else {
          log('Skipping Authorization header for ${options.path}');
        }
        log('Request: ${options.method} ${options.path}, Headers: ${options.headers}, Data: ${options.data}');
        return handler.next(options);
      },
      onResponse: (response, handler) {
        log('Response: ${response.statusCode} ${response.requestOptions.path}, Data: ${response.data}');
        return handler.next(response);
      },
      onError: (DioException error, ErrorInterceptorHandler handler) async {
        log('Error: ${error.response?.statusCode} ${error.requestOptions.path}, Data: ${error.response?.data}, Message: ${error.message}');
        if (error.response?.statusCode == 401) {
          log('401 error: Token invalid or expired');
          if (!error.requestOptions.path.contains('/auth/login/')) {
            log('Clearing tokens and navigating to login');
            await AuthService().clearTokens();
          }
        }
        return handler.next(error);
      },
    ));
  }

  Future<bool> isTokenValid() async {
    try {
      final token = await AuthService().getAccessToken();
      return token != null;
    } catch (e) {
      log('Error checking token validity: $e');
      return false;
    }
  }

  Future<void> logout(BuildContext context) async {
    try {
      await AuthService().clearTokens();
      context.go('/login');
    } catch (e) {
      log('Error during logout: $e');
    }
  }

  Future<bool> refreshToken() async {
    try {
      final refreshToken = await AuthService().getRefreshToken();
      if (refreshToken == null) {
        log('No refresh token available');
        return false;
      }

      log('Attempting to refresh token');
      final response = await dio
          .post('/auth/refresh/', data: {'refresh_token': refreshToken});

      if (response.statusCode == 200 &&
          response.data['success'] == true &&
          response.data['data'] != null) {
        final data = response.data['data'];
        if (data.containsKey('access_token')) {
          await AuthService().saveTokens(
            accessToken: data['access_token'],
            refreshToken: data['refresh_token'] ?? refreshToken,
            userId: await AuthService().getUserId() ?? 0,
          );
          log('Token refresh successful');
          return true;
        }
      }
      log('Token refresh failed: ${response.data}');
      return false;
    } catch (e) {
      log('Refresh token error: $e');
      return false;
    }
  }

  Future<bool> _requestPermission() async {
    if (Platform.isAndroid) {
      final status = await Permission.storage.request();
      if (!status.isGranted) {
        log('Storage permission denied on Android');
        return false;
      }
      return true;
    }
    return true;
  }

  Future<Directory> _getDownloadDirectory() async {
    if (Platform.isAndroid) {
      try {
        final directory = await getDownloadsDirectory();
        if (directory != null) {
          return directory;
        }
        log('Downloads directory not available, falling back to Documents directory');
      } catch (e) {
        log('Error accessing Downloads directory: $e');
      }
    }
    return await getApplicationDocumentsDirectory();
  }

  // ────────────────────────────
  // YOUR ORIGINAL METHODS (UNTOUCHED)
  // ────────────────────────────
  Future<void> downloadAsPdf(
      LedgerReport ledgerReport, String startDate, String endDate) async {
    try {
      final granted = await _requestPermission();
      if (!granted) {
        log('Permission denied for PDF download');
        throw Exception('Permission denied to save file');
      }

      final pdf = pw.Document();

      if (ledgerReport.data!.isNotEmpty) {
        final account = ledgerReport.data!.first;
        pdf.addPage(
          pw.Page(
            build: (pw.Context context) {
              return pw.Column(
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
                    headers: [
                      'Date',
                      'Voucher #',
                      'Debit',
                      'Credit',
                      'Balance'
                    ],
                    data: account.ledger!.map((entry) {
                      return [
                        entry.voucherDate!.split('T')[0],
                        entry.voucherNumber,
                        entry.debit!.toStringAsFixed(2),
                        entry.credit!.toStringAsFixed(2),
                        entry.runningBalance!.toStringAsFixed(2),
                      ];
                    }).toList(),
                  ),
                ],
              );
            },
          ),
        );
      } else {
        pdf.addPage(
          pw.Page(
            build: (pw.Context context) {
              return pw.Text('No ledger data available',
                  style: const pw.TextStyle(fontSize: 16));
            },
          ),
        );
      }

      final output = await _getDownloadDirectory();
      final file = File(
          '${output.path}/ledger_report_${DateTime.now().toIso8601String().replaceAll(':', '-')}.pdf');
      await file.writeAsBytes(await pdf.save());
      log('PDF download completed successfully: ${file.path}');
    } catch (e) {
      log('PDF download failed: $e');
      rethrow;
    }
  }

  Future<void> downloadAsExcel(
      LedgerReport ledgerReport, String startDate, String endDate) async {
    try {
      final granted = await _requestPermission();
      if (!granted) {
        log('Permission denied for Excel download');
        throw Exception('Permission denied to save file');
      }

      final csvData = <List<dynamic>>[];
      csvData.add(['Date', 'Voucher #', 'Debit', 'Credit', 'Balance']);

      if (ledgerReport.data!.isNotEmpty) {
        final account = ledgerReport.data!.first;
        csvData.addAll(account.ledger!.map((entry) => [
              entry.voucherDate!.split('T')[0],
              entry.voucherNumber,
              entry.debit!.toStringAsFixed(2),
              entry.credit!.toStringAsFixed(2),
              entry.runningBalance!.toStringAsFixed(2),
            ]));
      }

      final csv = const ListToCsvConverter().convert(csvData);
      final output = await _getDownloadDirectory();
      final file = File(
          '${output.path}/ledger_report_${DateTime.now().toIso8601String().replaceAll(':', '-')}.csv');
      await file.writeAsString(csv);
      log('Excel (CSV) download completed successfully: ${file.path}');
    } catch (e) {
      log('Excel (CSV) download failed: $e');
      rethrow;
    }
  }

  // ─────────────────────────────────────────────────────────────
  // STOCK LEDGER PDF – FIXED: NO OVERFLOW, FULL TEXT
  // ─────────────────────────────────────────────────────────────
  Future<void> downloadStockLedgerAsPdf(
    StockLedgerReport report,
    String startDate,
    String endDate,
  ) async {
    try {
      final granted = await _requestPermission();
      if (!granted) throw Exception('Permission denied');

      final pdf = pw.Document();

      if (report.data?.isNotEmpty != true) {
        pdf.addPage(
            pw.Page(build: (_) => pw.Center(child: pw.Text('No data'))));
        return;
      }

      final account = report.data!.first;
      final productName = account.productName ?? 'N/A';
      final entries = account.ledger ?? [];

      // ── Compute totals (same as CSV) ───────────────────────
      double openingQty = 0, openingRate = 0, openingAmt = 0;
      double purQty = 0, purRate = 0, purAmt = 0;
      double purRetQty = 0, purRetRate = 0, purRetAmt = 0;
      double saleQty = 0, saleRate = 0, saleAmt = 0;
      double saleRetQty = 0, saleRetRate = 0, saleRetAmt = 0;
      double closingQty = 0, closingRate = 0, closingAmt = 0;

      for (final e in entries) {
        if (e.opening != null && e.opening! > 0) {
          openingQty += e.opening!;
          openingRate = e.costPrice ?? 0;
          openingAmt += e.opening! * openingRate;
        }
        if (e.purchase != null && e.purchase! > 0) {
          purQty += e.purchase!;
          purRate = e.costPrice ?? 0;
          purAmt += e.purchase! * purRate;
        }
        if (e.purchase != null && e.purchase! < 0) {
          purRetQty += e.purchase!.abs();
          purRetRate = e.costPrice ?? 0;
          purRetAmt += e.purchase!.abs() * purRetRate;
        }
        if (e.sales != null && e.sales! > 0) {
          saleQty += e.sales!;
          saleRate = e.sellingPrice ?? 0;
          saleAmt += e.sales! * saleRate;
        }
        if (e.sales != null && e.sales! < 0) {
          saleRetQty += e.sales!.abs();
          saleRetRate = e.sellingPrice ?? 0;
          saleRetAmt += e.sales!.abs() * saleRetRate;
        }
        if (e.closing != null) {
          closingQty = e.closing!;
          closingRate = e.costPrice ?? e.sellingPrice ?? 0;
          closingAmt = closingQty * closingRate;
        }
      }

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4.landscape,
          margin: const pw.EdgeInsets.all(20),
          build: (_) => pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Stock Ledger Summary',
                  style: pw.TextStyle(
                      fontSize: 20, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 4),
              pw.Text('Product: $productName'),
              pw.Text('Period: $startDate to $endDate'),
              pw.SizedBox(height: 16),

              // ── MAIN TABLE ─────────────────────────────────────
              pw.Table(
                border: pw.TableBorder.all(width: 1, color: PdfColors.black),
                columnWidths: {
                  0: const pw.FixedColumnWidth(90),
                  for (int i = 1; i < 19; i++)
                    i: const pw.FixedColumnWidth(78), // ← FIXED
                },
                children: [
                  // ── SECTION HEADER ROW (ONE LINE + NO VERTICAL LINES) ───────
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(
                      border: pw.TableBorder(
                        top: pw.BorderSide(width: 1, color: PdfColors.black),
                        bottom: pw.BorderSide(width: 1, color: PdfColors.black),
                        left: pw.BorderSide.none,
                        right: pw.BorderSide.none,
                        horizontalInside: pw.BorderSide.none,
                        verticalInside: pw.BorderSide.none,
                      ),
                    ),
                    children: [
                      pw.Container(), // Product
                      _sectionLabelOneLine('Opening'),
                      pw.Container(), pw.Container(),
                      _sectionLabelOneLine('Purchase'),
                      pw.Container(), pw.Container(),
                      _sectionLabelOneLine('Purchase Return'),
                      pw.Container(), pw.Container(),
                      _sectionLabelOneLine('Sales'),
                      pw.Container(), pw.Container(),
                      _sectionLabelOneLine('Sale Return'),
                      pw.Container(), pw.Container(),
                      _sectionLabelOneLine('Closing'),
                      pw.Container(), pw.Container(),
                    ],
                  ),

                  // ── SUB‑HEADER ROW ───────
                  pw.TableRow(
                    children: [
                      _headerCell('Product'),
                      ...List.generate(18, (i) {
                        final text = ['Qty', 'Rate', 'Amount'][i % 3];
                        return _subHeaderCell(text);
                      }),
                    ],
                  ),

                  // ── DATA ROW ───────────────────────────────────
                  pw.TableRow(
                    children: [
                      _dataCell(productName, bold: true),
                      _dataCell(openingQty.toStringAsFixed(0)),
                      _dataCell(openingRate.toStringAsFixed(2)),
                      _dataCell(openingAmt.toStringAsFixed(2)),
                      _dataCell(purQty.toStringAsFixed(0)),
                      _dataCell(purRate.toStringAsFixed(2)),
                      _dataCell(purAmt.toStringAsFixed(2)),
                      _dataCell(purRetQty.toStringAsFixed(0)),
                      _dataCell(purRetRate.toStringAsFixed(2)),
                      _dataCell(purRetAmt.toStringAsFixed(2)),
                      _dataCell(saleQty.toStringAsFixed(0)),
                      _dataCell(saleRate.toStringAsFixed(2)),
                      _dataCell(saleAmt.toStringAsFixed(2)),
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
          '${dir.path}/stock_ledger_summary_${DateTime.now().millisecondsSinceEpoch}.pdf');
      await file.writeAsBytes(await pdf.save());
      log('Stock Ledger PDF saved: ${file.path}');
    } catch (e) {
      log('Stock Ledger PDF failed: $e');
      rethrow;
    }
  }

  // ─────────────────────────────────────────────────────────────
  // STOCK LEDGER EXCEL (CSV) – ALREADY PERFECT
  // ─────────────────────────────────────────────────────────────
  Future<void> downloadStockLedgerAsExcel(
    StockLedgerReport report,
    String startDate,
    String endDate,
  ) async {
    try {
      final granted = await _requestPermission();
      if (!granted) throw Exception('Permission denied');

      double openingQty = 0, openingRate = 0, openingAmt = 0;
      double purQty = 0, purRate = 0, purAmt = 0;
      double purRetQty = 0, purRetRate = 0, purRetAmt = 0;
      double saleQty = 0, saleRate = 0, saleAmt = 0;
      double saleRetQty = 0, saleRetRate = 0, saleRetAmt = 0;
      double closingQty = 0, closingRate = 0, closingAmt = 0;

      if (report.data?.isNotEmpty == true) {
        final entries = report.data!.first.ledger ?? [];
        for (final e in entries) {
          if (e.opening != null && e.opening! > 0) {
            openingQty += e.opening!;
            openingRate = e.costPrice ?? 0;
            openingAmt += e.opening! * openingRate;
          }
          if (e.purchase != null && e.purchase! > 0) {
            purQty += e.purchase!;
            purRate = e.costPrice ?? 0;
            purAmt += e.purchase! * purRate;
          }
          if (e.purchase != null && e.purchase! < 0) {
            purRetQty += e.purchase!.abs();
            purRetRate = e.costPrice ?? 0;
            purRetAmt += e.purchase!.abs() * purRetRate;
          }
          if (e.sales != null && e.sales! > 0) {
            saleQty += e.sales!;
            saleRate = e.sellingPrice ?? 0;
            saleAmt += e.sales! * saleRate;
          }
          if (e.sales != null && e.sales! < 0) {
            saleRetQty += e.sales!.abs();
            saleRetRate = e.sellingPrice ?? 0;
            saleRetAmt += e.sales!.abs() * saleRetRate;
          }
          if (e.closing != null) {
            closingQty = e.closing!;
            closingRate = e.costPrice ?? e.sellingPrice ?? 0;
            closingAmt = closingQty * closingRate;
          }
        }
      }

      final rows = <List<dynamic>>[
        ['Stock Ledger Summary'],
        ['Product', report.data?.first.productName ?? 'N/A'],
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
          'Purchase Return',
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
          '',
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
          'Amount',
        ],
        [
          report.data?.first.productName ?? 'N/A',
          openingQty.toStringAsFixed(0),
          openingRate.toStringAsFixed(2),
          openingAmt.toStringAsFixed(2),
          purQty.toStringAsFixed(0),
          purRate.toStringAsFixed(2),
          purAmt.toStringAsFixed(2),
          purRetQty.toStringAsFixed(0),
          purRetRate.toStringAsFixed(2),
          purRetAmt.toStringAsFixed(2),
          saleQty.toStringAsFixed(0),
          saleRate.toStringAsFixed(2),
          saleAmt.toStringAsFixed(2),
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
      final file = File(
          '${dir.path}/stock_ledger_summary_${DateTime.now().millisecondsSinceEpoch}.csv');
      await file.writeAsString(csv);
      log('Stock Ledger CSV saved: ${file.path}');
    } catch (e) {
      log('Stock Ledger CSV failed: $e');
      rethrow;
    }
  }

  // ─────────────────────────────────────────────────────────────
  // HELPER WIDGETS (PDF ONLY)
  // ─────────────────────────────────────────────────────────────
  pw.Widget _headerCell(String text) => pw.Container(
        padding: const pw.EdgeInsets.all(6),
        alignment: pw.Alignment.center,
        child: pw.Text(text,
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11)),
      );

  pw.Widget _subHeaderCell(String text) => pw.Container(
        padding: const pw.EdgeInsets.all(4),
        alignment: pw.Alignment.center,
        child: pw.Text(text,
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9)),
      );

  pw.Widget _dataCell(String text, {bool bold = false}) => pw.Container(
        padding: const pw.EdgeInsets.all(4),
        alignment: pw.Alignment.center,
        child: pw.Text(
          text,
          style: pw.TextStyle(
              fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
              fontSize: 10),
        ),
      );

  pw.Widget _sectionLabelOneLine(String text) => pw.Container(
        padding: const pw.EdgeInsets.all(6),
        alignment: pw.Alignment.center,
        decoration: const pw.BoxDecoration(color: PdfColors.grey300),
        child: pw.Text(
          text,
          style: pw.TextStyle(
            fontWeight: pw.FontWeight.bold,
            fontSize: 11,
          ),
          textAlign: pw.TextAlign.center,
        ),
      );

  // ─────────────────────────────────────────────────────────────
  // TRIAL BALANCE (UNTOUCHED)
  // ─────────────────────────────────────────────────────────────
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

      final List<TrialBalanceAccount> accounts = report.data ?? [];

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(40),
          build: (pw.Context ctx) => pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Trial Balance Report',
                  style: pw.TextStyle(
                      fontSize: 22, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 8),
              pw.Text('Period: $startDate to $endDate'),
              pw.SizedBox(height: 4),
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
                  ...accounts.map((a) => pw.TableRow(children: [
                        pw.Padding(
                            padding: const pw.EdgeInsets.all(8),
                            child: pw.Text(a.accountName ?? '')),
                        pw.Padding(
                            padding: const pw.EdgeInsets.all(8),
                            child: pw.Text((a.debit ?? 0).toStringAsFixed(2))),
                        pw.Padding(
                            padding: const pw.EdgeInsets.all(8),
                            child: pw.Text((a.credit ?? 0).toStringAsFixed(2))),
                      ])),
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
                                  .fold<double>(0, (p, e) => p + (e.debit ?? 0))
                                  .toStringAsFixed(2),
                              style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold))),
                      pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(
                              accounts
                                  .fold<double>(
                                      0, (p, e) => p + (e.credit ?? 0))
                                  .toStringAsFixed(2),
                              style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold))),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      );

      final pdfBytes = await pdf.save();
      final dir = await _getDownloadDirectory();
      final pdfFile = File(
          '${dir.path}/trial_balance_${DateTime.now().millisecondsSinceEpoch}.pdf');
      await pdfFile.writeAsBytes(pdfBytes);
      log('Trial Balance PDF saved: ${pdfFile.path}');

      // PNG PREVIEW
      try {
        final rasterImages =
            await Printing.raster(pdfBytes, pages: [0], dpi: 150).toList();
        if (rasterImages.isNotEmpty) {
          final raster = rasterImages.first;
          final pngFile = File(
              '${dir.path}/trial_balance_preview_${DateTime.now().millisecondsSinceEpoch}.png');
          await pngFile.writeAsBytes(raster.pixels);
          log('Preview PNG saved: ${pngFile.path}');
        }
      } catch (e) {
        log('PNG preview failed: $e');
      }
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
      ];

      final accounts = report.data ?? [];
      for (final a in accounts) {
        rows.add([
          a.accountName ?? '',
          (a.debit ?? 0).toStringAsFixed(2),
          (a.credit ?? 0).toStringAsFixed(2),
        ]);
      }

      final totalDebit = accounts.fold<double>(0, (p, e) => p + (e.debit ?? 0));
      final totalCredit =
          accounts.fold<double>(0, (p, e) => p + (e.credit ?? 0));
      rows.add([
        'TOTAL',
        totalDebit.toStringAsFixed(2),
        totalCredit.toStringAsFixed(2)
      ]);

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
