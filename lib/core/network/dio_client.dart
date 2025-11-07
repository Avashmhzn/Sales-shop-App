// import 'dart:developer';
// import 'dart:io';
// import 'package:csv/csv.dart';
// import 'package:dio/dio.dart';
// import 'package:dio/io.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:pdf/widgets.dart' as pw;
// import 'package:saleup_app/core/network/api_endpoints.dart';
// import 'package:saleup_app/model/ledger_report_response.dart';
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
//     // No permission needed for Documents directory on iOS
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
//     // Use Documents directory for iOS or as fallback for Android
//     return await getApplicationDocumentsDirectory();
//   }

//   Future<void> downloadAsPdf(
//       LedgerReport ledgerReport, String startDate, String endDate) async {
//     try {
//       // Request permission before saving
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
//       // Request permission before saving
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
// }
// core/network/dio_client.dart
import 'dart:developer';
import 'dart:io';
import 'package:csv/csv.dart';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:saleup_app/core/network/api_endpoints.dart';
import 'package:saleup_app/model/ledger_report_response.dart';
import 'package:saleup_app/model/stock_ledger_response.dart'; // ← ADDED
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
  // NEW: STOCK LEDGER EXPORT (ADDED – NO CHANGE TO YOUR CODE)
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

      if (report.data?.isNotEmpty == true) {
        final account = report.data!.first;
        final entries = account.ledger ?? [];

        pdf.addPage(
          pw.Page(
            build: (pw.Context context) => pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('Stock Ledger Report',
                    style: pw.TextStyle(
                        fontSize: 24, fontWeight: pw.FontWeight.bold)),
                pw.Text('Product: ${account.productName ?? 'N/A'}',
                    style: const pw.TextStyle(fontSize: 16)),
                pw.Text('Period: $startDate to $endDate',
                    style: const pw.TextStyle(fontSize: 16)),
                pw.SizedBox(height: 20),
                pw.Table.fromTextArray(
                  headers: [
                    'Date',
                    'Opening',
                    'Purchase',
                    'Sales',
                    'Closing',
                    'Cost',
                    'Selling'
                  ],
                  data: entries
                      .map((e) => [
                            e.date?.split('T')[0] ?? '',
                            (e.opening ?? 0).toStringAsFixed(2),
                            (e.purchase ?? 0).toStringAsFixed(2),
                            (e.sales ?? 0).toStringAsFixed(2),
                            (e.closing ?? 0).toStringAsFixed(2),
                            (e.costPrice ?? 0).toStringAsFixed(2),
                            (e.sellingPrice ?? 0).toStringAsFixed(2),
                          ])
                      .toList(),
                ),
              ],
            ),
          ),
        );
      } else {
        pdf.addPage(
            pw.Page(build: (_) => pw.Center(child: pw.Text('No data'))));
      }

      final dir = await _getDownloadDirectory();
      final file = File(
          '${dir.path}/stock_ledger_${DateTime.now().millisecondsSinceEpoch}.pdf');
      await file.writeAsBytes(await pdf.save());
      log('Stock Ledger PDF saved: ${file.path}');
    } catch (e) {
      log('Stock Ledger PDF failed: $e');
      rethrow;
    }
  }

  Future<void> downloadStockLedgerAsExcel(
    StockLedgerReport report,
    String startDate,
    String endDate,
  ) async {
    try {
      final granted = await _requestPermission();
      if (!granted) throw Exception('Permission denied');

      final rows = <List<dynamic>>[
        ['Stock Ledger Report'],
        ['Product', report.data?.first.productName ?? 'N/A'],
        ['Period', '$startDate - $endDate'],
        [],
        [
          'Date',
          'Opening',
          'Purchase',
          'Sales',
          'Closing',
          'Cost Price',
          'Selling Price'
        ],
      ];

      if (report.data?.isNotEmpty == true) {
        for (final e in report.data!.first.ledger!) {
          rows.add([
            e.date?.split('T')[0] ?? '',
            (e.opening ?? 0).toStringAsFixed(2),
            (e.purchase ?? 0).toStringAsFixed(2),
            (e.sales ?? 0).toStringAsFixed(2),
            (e.closing ?? 0).toStringAsFixed(2),
            (e.costPrice ?? 0).toStringAsFixed(2),
            (e.sellingPrice ?? 0).toStringAsFixed(2),
          ]);
        }
      }

      final csv = const ListToCsvConverter().convert(rows);
      final dir = await _getDownloadDirectory();
      final file = File(
          '${dir.path}/stock_ledger_${DateTime.now().millisecondsSinceEpoch}.csv');
      await file.writeAsString(csv);
      log('Stock Ledger CSV saved: ${file.path}');
    } catch (e) {
      log('Stock Ledger CSV failed: $e');
      rethrow;
    }
  }
}
