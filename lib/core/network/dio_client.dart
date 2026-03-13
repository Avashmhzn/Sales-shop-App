// //news
// import 'dart:convert';
// import 'dart:developer';
// import 'dart:io';

// import 'package:csv/csv.dart';
// import 'package:cookie_jar/cookie_jar.dart';
// import 'package:dio/dio.dart';
// import 'package:dio/io.dart';
// import 'package:dio_cookie_manager/dio_cookie_manager.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:pdf/pdf.dart';
// import 'package:pdf/widgets.dart' as pw;
// import 'package:saleup_app/core/network/api_endpoints.dart';
// import 'package:saleup_app/model/ledger_report_response.dart';
// import 'package:saleup_app/model/trial_balance_report_response.dart';
// import 'package:saleup_app/services/auth_service.dart';
// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:syncfusion_flutter_xlsio/xlsio.dart' as xlsio;

// class DioClient {
//   static final DioClient _instance = DioClient._internal();
//   factory DioClient() => _instance;

//   late final Dio dio;
//   late final CookieJar cookieJar;

//   DioClient._internal() {
//     dio = Dio();

//     dio.options
//       ..baseUrl = Api.currentBaseUrl
//       ..connectTimeout = const Duration(seconds: 60)
//       ..receiveTimeout = const Duration(seconds: 120)
//       ..sendTimeout = const Duration(seconds: 60)
//       ..headers = {
//         'Content-Type': 'application/json',
//         'Accept': 'application/json',
//       }
//       ..validateStatus = (status) => status != null && status < 500;

//     // Enable session cookies (important for Django session auth if used)
//     cookieJar = CookieJar();
//     dio.interceptors.add(CookieManager(cookieJar));

//     (dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
//       final client = HttpClient();
//       client.badCertificateCallback = (cert, host, port) => true;
//       return client;
//     };

//     dio.interceptors.add(
//       InterceptorsWrapper(
//         onRequest: (options, handler) async {
//           options.extra['requestStartTime'] = DateTime.now();

//           // Small delay helps with secure storage read-after-write
//           await Future.delayed(const Duration(milliseconds: 100));

//           log('→ START [${options.method}] ${options.uri.toString()}');
//           log('  Using base URL: ${options.baseUrl}');

//           final unauthenticatedEndpoints = [
//             '/auth/login/',
//             '/auth/forgot_password/',
//             '/auth/verify_forgot_password_otp/',
//             '/auth/reset_password/',
//             '/chat/',
//           ];

//           if (!unauthenticatedEndpoints.contains(options.path)) {
//             final token = await AuthService().getAccessToken();
//             log('Token check for ${options.path}: ${token != null ? "YES (len ${token.length ?? 0})" : "NULL"}');

//             if (token != null) {
//               options.headers['Authorization'] = 'Bearer $token';
//               log('Authorization header set for ${options.path}');
//             } else {
//               log('WARNING: No token available for protected endpoint ${options.path}');
//             }
//           }

//           handler.next(options);
//         },
//         onResponse: (response, handler) {
//           final start =
//               response.requestOptions.extra['requestStartTime'] as DateTime?;
//           final duration = start != null
//               ? DateTime.now().difference(start).inMilliseconds
//               : 0;

//           log('← DONE [${response.statusCode}] ${response.requestOptions.path} (${duration}ms)');

//           handler.next(response);
//         },
//         onError: (DioException error, handler) async {
//           final start =
//               error.requestOptions.extra['requestStartTime'] as DateTime?;
//           final duration = start != null
//               ? DateTime.now().difference(start).inMilliseconds
//               : 0;

//           log('✗ ERROR after ${duration}ms → ${error.message} → ${error.requestOptions.uri}');

//           if (error.response?.statusCode == 401 &&
//               !error.requestOptions.path.contains('/auth/login/') &&
//               !error.requestOptions.path.contains('/auth/refresh/')) {
//             log('401 detected - attempting token refresh');

//             final refreshed = await refreshToken();
//             if (refreshed) {
//               log('Token refreshed - retrying original request');
//               final token = await AuthService().getAccessToken();
//               if (token != null) {
//                 error.requestOptions.headers['Authorization'] = 'Bearer $token';
//                 return handler.resolve(await dio.fetch(error.requestOptions));
//               }
//             } else {
//               log('Refresh failed - logging out');
//               await AuthService().clearTokens();
//               await cookieJar.deleteAll();
//               Api.resetToPublic();
//               // Optional: navigate to login if you have context
//               // navigatorKey.currentContext?.go('/login');
//             }
//           }

//           handler.next(error);
//         },
//       ),
//     );
//   }
//   // ─── NEW METHOD ────────────────────────────────────────────────
//   void updateBaseUrl(String newBaseUrl) {
//     final cleanUrl = newBaseUrl.endsWith('') ? newBaseUrl : newBaseUrl;
//     dio.options.baseUrl = cleanUrl;
//     log('Dio baseUrl CHANGED to → $cleanUrl', name: 'DioClient');
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
//     await cookieJar.deleteAll();
//     Api.resetToPublic();
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
//       var status = await Permission.storage.request();
//       if (!status.isGranted) {
//         status = await Permission.manageExternalStorage.request();
//       }
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
//   // PDF HELPER WIDGETS
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

//   pw.Widget _dataCell(String? text, {bool bold = false}) => pw.Container(
//         padding: const pw.EdgeInsets.all(4),
//         alignment: pw.Alignment.center,
//         child: pw.Text(
//           text ?? '0.00',
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
//   // SAFE HELPERS
//   // ─────────────────────────────────────────────────────────────
//   String? _safeString(
//     Map<String, dynamic>? map,
//     Object key1, [
//     Object? key2,
//     Object? key3,
//     Object? key4,
//   ]) {
//     if (map == null) return null;
//     try {
//       dynamic value = map[key1];
//       if (value == null) return null;

//       if (key2 != null) {
//         if (value is List && key2 is int && key2 < value.length) {
//           value = value[key2];
//         } else if (value is Map) {
//           value = value[key2];
//         } else {
//           return null;
//         }
//       }
//       if (key3 != null) {
//         if (value is List && key3 is int && key3 < value.length) {
//           value = value[key3];
//         } else if (value is Map) {
//           value = value[key3];
//         } else {
//           return null;
//         }
//       }
//       if (key4 != null) {
//         if (value is List && key4 is int && key4 < value.length) {
//           value = value[key4];
//         } else if (value is Map) {
//           value = value[key4];
//         } else {
//           return null;
//         }
//       }
//       return value?.toString();
//     } catch (e) {
//       return null;
//     }
//   }

//   double _safeDouble(dynamic value) {
//     if (value == null) return 0.0;
//     if (value is num) return value.toDouble();
//     if (value is String) return double.tryParse(value) ?? 0.0;
//     return 0.0;
//   }

//   // ─────────────────────────────────────────────────────────────
//   // STOCK LEDGER HELPERS
//   // ─────────────────────────────────────────────────────────────
//   double _getQty(Map<String, dynamic>? data, String section, [String? subKey]) {
//     try {
//       dynamic list = data?[section];
//       if (subKey != null) list = list?[subKey];
//       if (list is List && list.isNotEmpty) {
//         final qty = list[0]['quantity'] ?? list[0]['qty'] ?? 0;
//         return _safeDouble(qty);
//       }
//     } catch (_) {}
//     return 0.0;
//   }

//   double _getRate(
//     Map<String, dynamic>? data,
//     String section,
//     String? subKey,
//     String rateType,
//   ) {
//     try {
//       dynamic list = data?[section];
//       if (subKey != null) list = list?[subKey];
//       if (list is List && list.isNotEmpty) {
//         final item = list[0];
//         final key = rateType == 'selling' ? 'selling_price' : 'cost_price';
//         final rate = item[key] ?? item['rate'] ?? 0;
//         return _safeDouble(rate);
//       }
//     } catch (_) {}
//     return 0.0;
//   }

//   String _getProductName(Map<String, dynamic>? data) {
//     if (data == null) return 'Unknown Product';

//     return _safeString(data, 'product_name') ??
//         _safeString(data, 'purchases', 0, 'product_name') ??
//         _safeString(data, 'sales', 0, 'product_name') ??
//         _safeString(data, 'opening_stock', 'summary', 0, 'product_name') ??
//         _safeString(data, 'closing_stock', 'summary', 0, 'product_name') ??
//         'Unnamed Product';
//   }

//   // ─────────────────────────────────────────────────────────────
//   // STOCK LEDGER PDF
//   // ─────────────────────────────────────────────────────────────
//   Future<void> downloadStockLedgerAsPdf(
//     Map<String, dynamic> json,
//     String startDate,
//     String endDate,
//     String rateType,
//   ) async {
//     try {
//       final granted = await _requestPermission();
//       if (!granted) throw Exception('Permission denied');

//       final pdf = pw.Document();

//       log('PDF EXPORT STARTED → rateType: $rateType');
//       log('RAW JSON:\n${const JsonEncoder.withIndent('  ').convert(json)}');

//       final responseData = json['data'] as Map<String, dynamic>?;
//       if (responseData == null) throw Exception('No data in response');

//       final productName = _getProductName(responseData);

//       final closingCostPrice =
//           _getRate(responseData, 'closing_stock', 'summary', 'cost');

//       final openingQty = _getQty(responseData, 'opening_stock', 'summary');
//       final openingAmt = openingQty * closingCostPrice;

//       final closingQty = _getQty(responseData, 'closing_stock', 'summary');
//       final closingAmt = closingQty * closingCostPrice;

//       final purchaseQty = _getQty(responseData, 'purchases');
//       final purchaseRate = _getRate(responseData, 'purchases', null, rateType);
//       final purchaseAmt = purchaseQty * purchaseRate;

//       final purRetQty = _getQty(responseData, 'purchase_returns');
//       final purRetRate =
//           _getRate(responseData, 'purchase_returns', null, rateType);
//       final purRetAmt = purRetQty * purRetRate;

//       final salesQty = _getQty(responseData, 'sales');
//       final salesRate = _getRate(responseData, 'sales', null, rateType);
//       final salesAmt = salesQty * salesRate;

//       final saleRetQty = _getQty(responseData, 'sale_returns');
//       final saleRetRate =
//           _getRate(responseData, 'sale_returns', null, rateType);
//       final saleRetAmt = saleRetQty * saleRetRate;

//       log('CALCULATED VALUES:');
//       log('  Product: $productName');
//       log('  Opening:  Qty=$openingQty   Rate=$closingCostPrice   Amt=$openingAmt');
//       log('  Closing:  Qty=$closingQty   Rate=$closingCostPrice   Amt=$closingAmt');
//       log('  Purchase: Qty=$purchaseQty  Rate=$purchaseRate  Amt=$purchaseAmt');
//       log('  Pur Ret:  Qty=$purRetQty    Rate=$purRetRate    Amt=$purRetAmt');
//       log('  Sales:    Qty=$salesQty     Rate=$salesRate     Amt=$salesAmt');
//       log('  Sale Ret: Qty=$saleRetQty   Rate=$saleRetRate   Amt=$saleRetAmt');

//       pdf.addPage(
//         pw.Page(
//           pageFormat: PdfPageFormat.a4.landscape,
//           margin: const pw.EdgeInsets.all(24),
//           build: (_) => pw.Column(
//             crossAxisAlignment: pw.CrossAxisAlignment.start,
//             children: [
//               pw.Text(
//                 'Stock Ledger Summary (${rateType == 'selling' ? 'Selling Price' : 'Cost Price'})',
//                 style:
//                     pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
//               ),
//               pw.SizedBox(height: 4),
//               pw.Text('Product: $productName'),
//               pw.Text('Period: $startDate to $endDate'),
//               pw.SizedBox(height: 16),
//               pw.Table(
//                 border: pw.TableBorder.all(width: 0.8),
//                 columnWidths: {
//                   0: const pw.FixedColumnWidth(110),
//                   for (int i = 1; i <= 18; i++)
//                     i: const pw.FixedColumnWidth(72),
//                 },
//                 children: [
//                   pw.TableRow(
//                     decoration:
//                         const pw.BoxDecoration(color: PdfColors.grey300),
//                     children: [
//                       pw.Container(),
//                       ...[
//                         'Opening',
//                         'Purchase',
//                         'Pur Return',
//                         'Sales',
//                         'Sale Return',
//                         'Closing'
//                       ].expand((title) => [
//                             _sectionLabelOneLine(title),
//                             pw.Container(),
//                             pw.Container(),
//                           ]),
//                     ],
//                   ),
//                   pw.TableRow(
//                     decoration:
//                         const pw.BoxDecoration(color: PdfColors.grey200),
//                     children: [
//                       _headerCell('Product'),
//                       ...List.generate(
//                         18,
//                         (i) => _subHeaderCell(['Qty', 'Rate', 'Amount'][i % 3]),
//                       ),
//                     ],
//                   ),
//                   pw.TableRow(
//                     children: [
//                       _dataCell(productName, bold: true),
//                       _dataCell(openingQty.toStringAsFixed(0)),
//                       _dataCell(closingCostPrice.toStringAsFixed(2)),
//                       _dataCell(openingAmt.toStringAsFixed(2)),
//                       _dataCell(purchaseQty.toStringAsFixed(0)),
//                       _dataCell(purchaseRate.toStringAsFixed(2)),
//                       _dataCell(purchaseAmt.toStringAsFixed(2)),
//                       _dataCell(purRetQty.toStringAsFixed(0)),
//                       _dataCell(purRetRate.toStringAsFixed(2)),
//                       _dataCell(purRetAmt.toStringAsFixed(2)),
//                       _dataCell(salesQty.toStringAsFixed(0)),
//                       _dataCell(salesRate.toStringAsFixed(2)),
//                       _dataCell(salesAmt.toStringAsFixed(2)),
//                       _dataCell(saleRetQty.toStringAsFixed(0)),
//                       _dataCell(saleRetRate.toStringAsFixed(2)),
//                       _dataCell(saleRetAmt.toStringAsFixed(2)),
//                       _dataCell(closingQty.toStringAsFixed(0)),
//                       _dataCell(closingCostPrice.toStringAsFixed(2)),
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
//       final timestamp = DateTime.now().millisecondsSinceEpoch;
//       final file = File('${dir.path}/stock_ledger_$timestamp.pdf');
//       await file.writeAsBytes(await pdf.save());
//       log('PDF SAVED → ${file.path}');
//     } catch (e, stack) {
//       log('PDF EXPORT FAILED → $e\n$stack');
//       rethrow;
//     }
//   }

//   // ─────────────────────────────────────────────────────────────
//   // STOCK LEDGER EXCEL
//   // ─────────────────────────────────────────────────────────────
//   Future<void> downloadStockLedgerAsExcel(
//     Map<String, dynamic> json,
//     String startDate,
//     String endDate,
//     String rateType,
//   ) async {
//     try {
//       final granted = await _requestPermission();
//       if (!granted) throw Exception('Permission denied');

//       log('EXCEL EXPORT STARTED → rateType: $rateType');

//       final responseData = json['data'] as Map<String, dynamic>?;
//       if (responseData == null) throw Exception('No data in response');

//       final productName = _getProductName(responseData);

//       final closingCostPrice =
//           _getRate(responseData, 'closing_stock', 'summary', 'cost');

//       final openingQty = _getQty(responseData, 'opening_stock', 'summary');
//       final openingAmt = openingQty * closingCostPrice;

//       final closingQty = _getQty(responseData, 'closing_stock', 'summary');
//       final closingAmt = closingQty * closingCostPrice;

//       final purchaseQty = _getQty(responseData, 'purchases');
//       final purchaseRate = _getRate(responseData, 'purchases', null, rateType);
//       final purchaseAmt = purchaseQty * purchaseRate;

//       final purRetQty = _getQty(responseData, 'purchase_returns');
//       final purRetRate =
//           _getRate(responseData, 'purchase_returns', null, rateType);
//       final purRetAmt = purRetQty * purRetRate;

//       final salesQty = _getQty(responseData, 'sales');
//       final salesRate = _getRate(responseData, 'sales', null, rateType);
//       final salesAmt = salesQty * salesRate;

//       final saleRetQty = _getQty(responseData, 'sale_returns');
//       final saleRetRate =
//           _getRate(responseData, 'sale_returns', null, rateType);
//       final saleRetAmt = saleRetQty * saleRetRate;

//       log('CALCULATED VALUES:');
//       log('  Product: $productName');
//       log('  Opening:  Qty=$openingQty   Rate=$closingCostPrice   Amt=$openingAmt');
//       log('  Closing:  Qty=$closingQty   Rate=$closingCostPrice   Amt=$closingAmt');
//       log('  Purchase: Qty=$purchaseQty  Rate=$purchaseRate  Amt=$purchaseAmt');
//       log('  Pur Ret:  Qty=$purRetQty    Rate=$purRetRate    Amt=$purRetAmt');
//       log('  Sales:    Qty=$salesQty     Rate=$salesRate     Amt=$salesAmt');
//       log('  Sale Ret: Qty=$saleRetQty   Rate=$saleRetRate   Amt=$saleRetAmt');

//       final workbook = xlsio.Workbook();
//       final sheet = workbook.worksheets[0];
//       sheet.name = 'Stock Ledger';

//       // Title
//       sheet.getRangeByIndex(1, 1, 1, 19).merge();
//       sheet.getRangeByIndex(1, 1).setText(
//           'Stock Ledger Summary (${rateType == 'selling' ? 'Selling Price' : 'Cost Price'})');
//       sheet.getRangeByIndex(1, 1).cellStyle.fontSize = 16;
//       sheet.getRangeByIndex(1, 1).cellStyle.bold = true;
//       sheet.getRangeByIndex(1, 1).cellStyle.hAlign = xlsio.HAlignType.center;

//       // Product & Period
//       sheet.getRangeByIndex(3, 1).setText('Product');
//       sheet.getRangeByIndex(3, 2).setText(productName);
//       sheet.getRangeByIndex(4, 1).setText('Period');
//       sheet.getRangeByIndex(4, 2).setText('$startDate - $endDate');

//       // Headers
//       final sections = [
//         {'name': 'Opening', 'startCol': 2},
//         {'name': 'Purchase', 'startCol': 5},
//         {'name': 'Pur Return', 'startCol': 8},
//         {'name': 'Sales', 'startCol': 11},
//         {'name': 'Sale Return', 'startCol': 14},
//         {'name': 'Closing', 'startCol': 17},
//       ];

//       for (final sec in sections) {
//         final col = sec['startCol'] as int;
//         sheet.getRangeByIndex(6, col, 6, col + 2).merge();
//         final cell = sheet.getRangeByIndex(6, col);
//         cell.setText(sec['name'] as String);
//         cell.cellStyle.bold = true;
//         cell.cellStyle.hAlign = xlsio.HAlignType.center;
//         cell.cellStyle.backColor = '#D3D3D3';
//       }

//       // Sub-headers Qty / Rate / Amount
//       for (int i = 0; i < 6; i++) {
//         final col = 2 + i * 3;
//         sheet.getRangeByIndex(7, col).setText('Qty');
//         sheet.getRangeByIndex(7, col + 1).setText('Rate');
//         sheet.getRangeByIndex(7, col + 2).setText('Amount');
//       }

//       // Data row (row 8)
//       final dataRow = [
//         productName,
//         openingQty.toStringAsFixed(0),
//         closingCostPrice.toStringAsFixed(2),
//         openingAmt.toStringAsFixed(2),
//         purchaseQty.toStringAsFixed(0),
//         purchaseRate.toStringAsFixed(2),
//         purchaseAmt.toStringAsFixed(2),
//         purRetQty.toStringAsFixed(0),
//         purRetRate.toStringAsFixed(2),
//         purRetAmt.toStringAsFixed(2),
//         salesQty.toStringAsFixed(0),
//         salesRate.toStringAsFixed(2),
//         salesAmt.toStringAsFixed(2),
//         saleRetQty.toStringAsFixed(0),
//         saleRetRate.toStringAsFixed(2),
//         saleRetAmt.toStringAsFixed(2),
//         closingQty.toStringAsFixed(0),
//         closingCostPrice.toStringAsFixed(2),
//         closingAmt.toStringAsFixed(2),
//       ];

//       for (int i = 0; i < dataRow.length; i++) {
//         final cell = sheet.getRangeByIndex(8, i + 1);
//         cell.setText(dataRow[i]);
//         cell.cellStyle.hAlign = xlsio.HAlignType.center;
//       }

//       // Borders & formatting
//       final tableRange = sheet.getRangeByIndex(6, 1, 8, 19);
//       tableRange.cellStyle.borders.all.lineStyle = xlsio.LineStyle.thin;

//       // Auto-fit columns
//       for (int i = 1; i <= 19; i++) {
//         sheet.autoFitColumn(i);
//       }

//       final bytes = workbook.saveAsStream();
//       workbook.dispose();

//       final dir = await _getDownloadDirectory();
//       final timestamp = DateTime.now().millisecondsSinceEpoch;
//       final file = File('${dir.path}/stock_ledger_$timestamp.xlsx');
//       await file.writeAsBytes(bytes);

//       log('XLSX SAVED → ${file.path}');
//     } catch (e, stack) {
//       log('EXCEL EXPORT FAILED → $e\n$stack');
//       rethrow;
//     }
//   }

//   // ─────────────────────────────────────────────────────────────
//   // LEDGER PDF
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
//       if (ledgerReport.data?.isNotEmpty ?? false) {
//         final account = ledgerReport.data!.first;
//         pdf.addPage(
//           pw.Page(
//             build: (_) => pw.Column(
//               crossAxisAlignment: pw.CrossAxisAlignment.start,
//               children: [
//                 pw.Text('Ledger Report',
//                     style: pw.TextStyle(
//                         fontSize: 24, fontWeight: pw.FontWeight.bold)),
//                 pw.Text('Account: ${account.accountName ?? "N/A"}',
//                     style: const pw.TextStyle(fontSize: 16)),
//                 pw.Text('Period: $startDate to $endDate',
//                     style: const pw.TextStyle(fontSize: 16)),
//                 pw.SizedBox(height: 20),
//                 pw.Table.fromTextArray(
//                   headers: ['Date', 'Voucher #', 'Debit', 'Credit', 'Balance'],
//                   data: account.ledger
//                           ?.map((e) => [
//                                 e.voucherDate?.split('T')[0] ?? '',
//                                 e.voucherNumber ?? '',
//                                 (e.debit ?? 0).toStringAsFixed(2),
//                                 (e.credit ?? 0).toStringAsFixed(2),
//                                 (e.runningBalance ?? 0).toStringAsFixed(2),
//                               ])
//                           .toList() ??
//                       [],
//                 ),
//               ],
//             ),
//           ),
//         );
//       } else {
//         pdf.addPage(pw.Page(build: (_) => pw.Text('No ledger data available')));
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

//   // ─────────────────────────────────────────────────────────────
//   // LEDGER EXCEL
//   // ─────────────────────────────────────────────────────────────
//   Future<void> downloadAsExcel(
//     LedgerReport ledgerReport,
//     String startDate,
//     String endDate,
//   ) async {
//     try {
//       final granted = await _requestPermission();
//       if (!granted) throw Exception('Permission denied');

//       final rows = <List<dynamic>>[
//         ['Ledger Report'],
//         ['Account', ledgerReport.data?.first.accountName ?? 'N/A'],
//         ['Period', '$startDate - $endDate'],
//         [],
//         ['Date', 'Voucher #', 'Debit', 'Credit', 'Balance'],
//         ...?ledgerReport.data?.first.ledger?.map(
//           (e) => [
//             e.voucherDate?.split('T')[0] ?? '',
//             e.voucherNumber ?? '',
//             (e.debit ?? 0).toStringAsFixed(2),
//             (e.credit ?? 0).toStringAsFixed(2),
//             (e.runningBalance ?? 0).toStringAsFixed(2),
//           ],
//         ),
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
//               pw.Text('Trial Balance Report',
//                   style: pw.TextStyle(
//                       fontSize: 22, fontWeight: pw.FontWeight.bold)),
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
//                   ...accounts.map(
//                     (a) => pw.TableRow(
//                       children: [
//                         pw.Padding(
//                             padding: const pw.EdgeInsets.all(8),
//                             child: pw.Text(a.accountName ?? '')),
//                         pw.Padding(
//                             padding: const pw.EdgeInsets.all(8),
//                             child: pw.Text((a.debit ?? 0).toStringAsFixed(2))),
//                         pw.Padding(
//                             padding: const pw.EdgeInsets.all(8),
//                             child: pw.Text((a.credit ?? 0).toStringAsFixed(2))),
//                       ],
//                     ),
//                   ),
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
//                             accounts
//                                 .fold(0.0, (p, e) => p + (e.debit ?? 0))
//                                 .toStringAsFixed(2),
//                             style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
//                           )),
//                       pw.Padding(
//                           padding: const pw.EdgeInsets.all(8),
//                           child: pw.Text(
//                             accounts
//                                 .fold(0.0, (p, e) => p + (e.credit ?? 0))
//                                 .toStringAsFixed(2),
//                             style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
//                           )),
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
//           '${dir.path}/trial_balance_${DateTime.now().millisecondsSinceEpoch}.pdf');
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
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:saleup_app/core/network/api_endpoints.dart';
import 'package:saleup_app/model/ledger_report_response.dart';
import 'package:saleup_app/model/trial_balance_report_response.dart';
import 'package:saleup_app/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' as xlsio;

class DioClient {
  static final DioClient _instance = DioClient._internal();
  factory DioClient() => _instance;

  late final Dio dio;
  late final CookieJar cookieJar;

  DioClient._internal() {
    dio = Dio();

    dio.options
      ..baseUrl = Api.currentBaseUrl
      ..connectTimeout = const Duration(seconds: 60)
      ..receiveTimeout = const Duration(seconds: 120)
      ..sendTimeout = const Duration(seconds: 60)
      ..headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      }
      // ✅ FIXED: was < 500, now < 600 so 500 errors reach your bloc
      ..validateStatus = (status) => status != null && status < 600;

    cookieJar = CookieJar();
    dio.interceptors.add(CookieManager(cookieJar));

    (dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
      final client = HttpClient();
      client.badCertificateCallback = (cert, host, port) => true;
      return client;
    };

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          options.extra['requestStartTime'] = DateTime.now();

          await Future.delayed(const Duration(milliseconds: 100));

          log('→ START [${options.method}] ${options.uri.toString()}');
          log('  Using base URL: ${options.baseUrl}');

          final unauthenticatedEndpoints = [
            '/auth/login/',
            '/auth/forgot_password/',
            '/auth/verify_forgot_password_otp/',
            '/auth/reset_password/',
            '/chat/',
          ];

          if (!unauthenticatedEndpoints.contains(options.path)) {
            final token = await AuthService().getAccessToken();
            log('Token check for ${options.path}: ${token != null ? "YES (len ${token.length})" : "NULL"}');

            if (token != null) {
              options.headers['Authorization'] = 'Bearer $token';
              log('Authorization header set for ${options.path}');
            } else {
              log('WARNING: No token available for protected endpoint ${options.path}');
            }
          }

          handler.next(options);
        },
        onResponse: (response, handler) {
          final start =
              response.requestOptions.extra['requestStartTime'] as DateTime?;
          final duration = start != null
              ? DateTime.now().difference(start).inMilliseconds
              : 0;

          log('← DONE [${response.statusCode}] ${response.requestOptions.path} (${duration}ms)');

          handler.next(response);
        },
        onError: (DioException error, handler) async {
          final start =
              error.requestOptions.extra['requestStartTime'] as DateTime?;
          final duration = start != null
              ? DateTime.now().difference(start).inMilliseconds
              : 0;

          log('✗ ERROR after ${duration}ms → ${error.message} → ${error.requestOptions.uri}');

          if (error.response?.statusCode == 401 &&
              !error.requestOptions.path.contains('/auth/login/') &&
              !error.requestOptions.path.contains('/auth/refresh/')) {
            log('401 detected - attempting token refresh');

            final refreshed = await refreshToken();
            if (refreshed) {
              log('Token refreshed - retrying original request');
              final token = await AuthService().getAccessToken();
              if (token != null) {
                error.requestOptions.headers['Authorization'] = 'Bearer $token';
                return handler.resolve(await dio.fetch(error.requestOptions));
              }
            } else {
              log('Refresh failed - logging out');
              await AuthService().clearTokens();
              await cookieJar.deleteAll();
              Api.resetToPublic();
            }
          }

          handler.next(error);
        },
      ),
    );
  }

  void updateBaseUrl(String newBaseUrl) {
    dio.options.baseUrl = newBaseUrl;
    log('Dio baseUrl CHANGED to → $newBaseUrl', name: 'DioClient');
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
    await cookieJar.deleteAll();
    Api.resetToPublic();
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
      var status = await Permission.storage.request();
      if (!status.isGranted) {
        status = await Permission.manageExternalStorage.request();
      }
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

  pw.Widget _dataCell(String? text, {bool bold = false}) => pw.Container(
        padding: const pw.EdgeInsets.all(4),
        alignment: pw.Alignment.center,
        child: pw.Text(
          text ?? '0.00',
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
  // SAFE HELPERS
  // ─────────────────────────────────────────────────────────────
  String? _safeString(
    Map<String, dynamic>? map,
    Object key1, [
    Object? key2,
    Object? key3,
    Object? key4,
  ]) {
    if (map == null) return null;
    try {
      dynamic value = map[key1];
      if (value == null) return null;
      if (key2 != null) {
        if (value is List && key2 is int && key2 < value.length) {
          value = value[key2];
        } else if (value is Map) {
          value = value[key2];
        } else {
          return null;
        }
      }
      if (key3 != null) {
        if (value is List && key3 is int && key3 < value.length) {
          value = value[key3];
        } else if (value is Map) {
          value = value[key3];
        } else {
          return null;
        }
      }
      if (key4 != null) {
        if (value is List && key4 is int && key4 < value.length) {
          value = value[key4];
        } else if (value is Map) {
          value = value[key4];
        } else {
          return null;
        }
      }
      return value?.toString();
    } catch (e) {
      return null;
    }
  }

  double _safeDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  // ─────────────────────────────────────────────────────────────
  // STOCK LEDGER HELPERS
  // ─────────────────────────────────────────────────────────────
  double _getQty(Map<String, dynamic>? data, String section, [String? subKey]) {
    try {
      dynamic list = data?[section];
      if (subKey != null) list = list?[subKey];
      if (list is List && list.isNotEmpty) {
        final qty = list[0]['quantity'] ?? list[0]['qty'] ?? 0;
        return _safeDouble(qty);
      }
    } catch (_) {}
    return 0.0;
  }

  double _getRate(
    Map<String, dynamic>? data,
    String section,
    String? subKey,
    String rateType,
  ) {
    try {
      dynamic list = data?[section];
      if (subKey != null) list = list?[subKey];
      if (list is List && list.isNotEmpty) {
        final item = list[0];
        final key = rateType == 'selling' ? 'selling_price' : 'cost_price';
        final rate = item[key] ?? item['rate'] ?? 0;
        return _safeDouble(rate);
      }
    } catch (_) {}
    return 0.0;
  }

  String _getProductName(Map<String, dynamic>? data) {
    if (data == null) return 'Unknown Product';
    return _safeString(data, 'product_name') ??
        _safeString(data, 'purchases', 0, 'product_name') ??
        _safeString(data, 'sales', 0, 'product_name') ??
        _safeString(data, 'opening_stock', 'summary', 0, 'product_name') ??
        _safeString(data, 'closing_stock', 'summary', 0, 'product_name') ??
        'Unnamed Product';
  }

  // ─────────────────────────────────────────────────────────────
  // STOCK LEDGER PDF
  // ─────────────────────────────────────────────────────────────
  Future<void> downloadStockLedgerAsPdf(
    Map<String, dynamic> json,
    String startDate,
    String endDate,
    String rateType,
  ) async {
    try {
      final granted = await _requestPermission();
      if (!granted) throw Exception('Permission denied');

      final pdf = pw.Document();

      log('PDF EXPORT STARTED → rateType: $rateType');

      final responseData = json['data'] as Map<String, dynamic>?;
      if (responseData == null) throw Exception('No data in response');

      final productName = _getProductName(responseData);
      final closingCostPrice =
          _getRate(responseData, 'closing_stock', 'summary', 'cost');
      final openingQty = _getQty(responseData, 'opening_stock', 'summary');
      final openingAmt = openingQty * closingCostPrice;
      final closingQty = _getQty(responseData, 'closing_stock', 'summary');
      final closingAmt = closingQty * closingCostPrice;
      final purchaseQty = _getQty(responseData, 'purchases');
      final purchaseRate = _getRate(responseData, 'purchases', null, rateType);
      final purchaseAmt = purchaseQty * purchaseRate;
      final purRetQty = _getQty(responseData, 'purchase_returns');
      final purRetRate =
          _getRate(responseData, 'purchase_returns', null, rateType);
      final purRetAmt = purRetQty * purRetRate;
      final salesQty = _getQty(responseData, 'sales');
      final salesRate = _getRate(responseData, 'sales', null, rateType);
      final salesAmt = salesQty * salesRate;
      final saleRetQty = _getQty(responseData, 'sale_returns');
      final saleRetRate =
          _getRate(responseData, 'sale_returns', null, rateType);
      final saleRetAmt = saleRetQty * saleRetRate;

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4.landscape,
          margin: const pw.EdgeInsets.all(24),
          build: (_) => pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'Stock Ledger Summary (${rateType == 'selling' ? 'Selling Price' : 'Cost Price'})',
                style:
                    pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 4),
              pw.Text('Product: $productName'),
              pw.Text('Period: $startDate to $endDate'),
              pw.SizedBox(height: 16),
              pw.Table(
                border: pw.TableBorder.all(width: 0.8),
                columnWidths: {
                  0: const pw.FixedColumnWidth(110),
                  for (int i = 1; i <= 18; i++)
                    i: const pw.FixedColumnWidth(72),
                },
                children: [
                  pw.TableRow(
                    decoration:
                        const pw.BoxDecoration(color: PdfColors.grey300),
                    children: [
                      pw.Container(),
                      ...[
                        'Opening',
                        'Purchase',
                        'Pur Return',
                        'Sales',
                        'Sale Return',
                        'Closing'
                      ].expand((title) => [
                            _sectionLabelOneLine(title),
                            pw.Container(),
                            pw.Container(),
                          ]),
                    ],
                  ),
                  pw.TableRow(
                    decoration:
                        const pw.BoxDecoration(color: PdfColors.grey200),
                    children: [
                      _headerCell('Product'),
                      ...List.generate(
                        18,
                        (i) => _subHeaderCell(['Qty', 'Rate', 'Amount'][i % 3]),
                      ),
                    ],
                  ),
                  pw.TableRow(
                    children: [
                      _dataCell(productName, bold: true),
                      _dataCell(openingQty.toStringAsFixed(0)),
                      _dataCell(closingCostPrice.toStringAsFixed(2)),
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
                      _dataCell(closingCostPrice.toStringAsFixed(2)),
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
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final file = File('${dir.path}/stock_ledger_$timestamp.pdf');
      await file.writeAsBytes(await pdf.save());
      log('PDF SAVED → ${file.path}');
    } catch (e, stack) {
      log('PDF EXPORT FAILED → $e\n$stack');
      rethrow;
    }
  }

  // ─────────────────────────────────────────────────────────────
  // STOCK LEDGER EXCEL
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

      final responseData = json['data'] as Map<String, dynamic>?;
      if (responseData == null) throw Exception('No data in response');

      final productName = _getProductName(responseData);
      final closingCostPrice =
          _getRate(responseData, 'closing_stock', 'summary', 'cost');
      final openingQty = _getQty(responseData, 'opening_stock', 'summary');
      final openingAmt = openingQty * closingCostPrice;
      final closingQty = _getQty(responseData, 'closing_stock', 'summary');
      final closingAmt = closingQty * closingCostPrice;
      final purchaseQty = _getQty(responseData, 'purchases');
      final purchaseRate = _getRate(responseData, 'purchases', null, rateType);
      final purchaseAmt = purchaseQty * purchaseRate;
      final purRetQty = _getQty(responseData, 'purchase_returns');
      final purRetRate =
          _getRate(responseData, 'purchase_returns', null, rateType);
      final purRetAmt = purRetQty * purRetRate;
      final salesQty = _getQty(responseData, 'sales');
      final salesRate = _getRate(responseData, 'sales', null, rateType);
      final salesAmt = salesQty * salesRate;
      final saleRetQty = _getQty(responseData, 'sale_returns');
      final saleRetRate =
          _getRate(responseData, 'sale_returns', null, rateType);
      final saleRetAmt = saleRetQty * saleRetRate;

      final workbook = xlsio.Workbook();
      final sheet = workbook.worksheets[0];
      sheet.name = 'Stock Ledger';

      sheet.getRangeByIndex(1, 1, 1, 19).merge();
      sheet.getRangeByIndex(1, 1).setText(
          'Stock Ledger Summary (${rateType == 'selling' ? 'Selling Price' : 'Cost Price'})');
      sheet.getRangeByIndex(1, 1).cellStyle.fontSize = 16;
      sheet.getRangeByIndex(1, 1).cellStyle.bold = true;
      sheet.getRangeByIndex(1, 1).cellStyle.hAlign = xlsio.HAlignType.center;

      sheet.getRangeByIndex(3, 1).setText('Product');
      sheet.getRangeByIndex(3, 2).setText(productName);
      sheet.getRangeByIndex(4, 1).setText('Period');
      sheet.getRangeByIndex(4, 2).setText('$startDate - $endDate');

      final sections = [
        {'name': 'Opening', 'startCol': 2},
        {'name': 'Purchase', 'startCol': 5},
        {'name': 'Pur Return', 'startCol': 8},
        {'name': 'Sales', 'startCol': 11},
        {'name': 'Sale Return', 'startCol': 14},
        {'name': 'Closing', 'startCol': 17},
      ];

      for (final sec in sections) {
        final col = sec['startCol'] as int;
        sheet.getRangeByIndex(6, col, 6, col + 2).merge();
        final cell = sheet.getRangeByIndex(6, col);
        cell.setText(sec['name'] as String);
        cell.cellStyle.bold = true;
        cell.cellStyle.hAlign = xlsio.HAlignType.center;
        cell.cellStyle.backColor = '#D3D3D3';
      }

      for (int i = 0; i < 6; i++) {
        final col = 2 + i * 3;
        sheet.getRangeByIndex(7, col).setText('Qty');
        sheet.getRangeByIndex(7, col + 1).setText('Rate');
        sheet.getRangeByIndex(7, col + 2).setText('Amount');
      }

      final dataRow = [
        productName,
        openingQty.toStringAsFixed(0),
        closingCostPrice.toStringAsFixed(2),
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
        closingCostPrice.toStringAsFixed(2),
        closingAmt.toStringAsFixed(2),
      ];

      for (int i = 0; i < dataRow.length; i++) {
        final cell = sheet.getRangeByIndex(8, i + 1);
        cell.setText(dataRow[i]);
        cell.cellStyle.hAlign = xlsio.HAlignType.center;
      }

      final tableRange = sheet.getRangeByIndex(6, 1, 8, 19);
      tableRange.cellStyle.borders.all.lineStyle = xlsio.LineStyle.thin;

      for (int i = 1; i <= 19; i++) {
        sheet.autoFitColumn(i);
      }

      final bytes = workbook.saveAsStream();
      workbook.dispose();

      final dir = await _getDownloadDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final file = File('${dir.path}/stock_ledger_$timestamp.xlsx');
      await file.writeAsBytes(bytes);
      log('XLSX SAVED → ${file.path}');
    } catch (e, stack) {
      log('EXCEL EXPORT FAILED → $e\n$stack');
      rethrow;
    }
  }

  // ─────────────────────────────────────────────────────────────
  // LEDGER PDF
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
      if (ledgerReport.data?.isNotEmpty ?? false) {
        final account = ledgerReport.data!.first;
        pdf.addPage(
          pw.Page(
            build: (_) => pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('Ledger Report',
                    style: pw.TextStyle(
                        fontSize: 24, fontWeight: pw.FontWeight.bold)),
                pw.Text('Account: ${account.accountName ?? "N/A"}',
                    style: const pw.TextStyle(fontSize: 16)),
                pw.Text('Period: $startDate to $endDate',
                    style: const pw.TextStyle(fontSize: 16)),
                pw.SizedBox(height: 20),
                pw.Table.fromTextArray(
                  headers: ['Date', 'Voucher #', 'Debit', 'Credit', 'Balance'],
                  data: account.ledger
                          ?.map((e) => [
                                e.voucherDate?.split('T')[0] ?? '',
                                e.voucherNumber ?? '',
                                (e.debit ?? 0).toStringAsFixed(2),
                                (e.credit ?? 0).toStringAsFixed(2),
                                (e.runningBalance ?? 0).toStringAsFixed(2),
                              ])
                          .toList() ??
                      [],
                ),
              ],
            ),
          ),
        );
      } else {
        pdf.addPage(pw.Page(build: (_) => pw.Text('No ledger data available')));
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

  // ─────────────────────────────────────────────────────────────
  // LEDGER EXCEL
  // ─────────────────────────────────────────────────────────────
  Future<void> downloadAsExcel(
    LedgerReport ledgerReport,
    String startDate,
    String endDate,
  ) async {
    try {
      final granted = await _requestPermission();
      if (!granted) throw Exception('Permission denied');

      final rows = <List<dynamic>>[
        ['Ledger Report'],
        ['Account', ledgerReport.data?.first.accountName ?? 'N/A'],
        ['Period', '$startDate - $endDate'],
        [],
        ['Date', 'Voucher #', 'Debit', 'Credit', 'Balance'],
        ...?ledgerReport.data?.first.ledger?.map(
          (e) => [
            e.voucherDate?.split('T')[0] ?? '',
            e.voucherNumber ?? '',
            (e.debit ?? 0).toStringAsFixed(2),
            (e.credit ?? 0).toStringAsFixed(2),
            (e.runningBalance ?? 0).toStringAsFixed(2),
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

  // ─────────────────────────────────────────────────────────────
  // TRIAL BALANCE
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
