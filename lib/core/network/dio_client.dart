
// import 'package:dio/dio.dart';
// import 'package:dio/io.dart';
// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';
// import 'package:saleup_app/core/network/api_endpoints.dart';
// import 'package:saleup_app/services/auth_service.dart';
// import 'dart:developer';
// import 'dart:io';

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
// }
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:saleup_app/core/network/api_endpoints.dart';
import 'package:saleup_app/model/ledger_report_response.dart';
import 'package:saleup_app/services/auth_service.dart';
import 'dart:developer';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:csv/csv.dart';

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
            log('Authorization header set for ${options.path} with token: $token at ${DateTime.now().toIso8601String()}');
          } else {
            log('No access token available for ${options.path} at ${DateTime.now().toIso8601String()}');
          }
        } else {
          log('Skipping Authorization header for ${options.path} at ${DateTime.now().toIso8601String()}');
        }
        log('Request: ${options.method} ${options.path}, Headers: ${options.headers}, Data: ${options.data} at ${DateTime.now().toIso8601String()}');
        return handler.next(options);
      },
      onResponse: (response, handler) {
        log('Response: ${response.statusCode} ${response.requestOptions.path}, Data: ${response.data} at ${DateTime.now().toIso8601String()}');
        return handler.next(response);
      },
      onError: (DioException error, ErrorInterceptorHandler handler) async {
        log('Error: ${error.response?.statusCode} ${error.requestOptions.path}, Data: ${error.response?.data}, Message: ${error.message} at ${DateTime.now().toIso8601String()}');
        if (error.response?.statusCode == 401) {
          log('401 error: Token invalid or expired at ${DateTime.now().toIso8601String()}');
          if (!error.requestOptions.path.contains('/auth/login/')) {
            log('Clearing tokens and navigating to login at ${DateTime.now().toIso8601String()}');
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
      log('Token validity checked at ${DateTime.now().toIso8601String()}: ${token != null}');
      return token != null;
    } catch (e) {
      log('Error checking token validity: $e at ${DateTime.now().toIso8601String()}');
      return false;
    }
  }

  Future<void> logout(BuildContext context) async {
    try {
      await AuthService().clearTokens();
      log('Logout successful at ${DateTime.now().toIso8601String()}');
      context.go('/login');
    } catch (e) {
      log('Error during logout: $e at ${DateTime.now().toIso8601String()}');
    }
  }

  Future<bool> refreshToken() async {
    try {
      final refreshToken = await AuthService().getRefreshToken();
      if (refreshToken == null) {
        log('No refresh token available at ${DateTime.now().toIso8601String()}');
        return false;
      }

      log('Attempting to refresh token at ${DateTime.now().toIso8601String()}');
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
          log('Token refresh successful at ${DateTime.now().toIso8601String()}');
          return true;
        }
      }
      log('Token refresh failed: ${response.data} at ${DateTime.now().toIso8601String()}');
      return false;
    } catch (e) {
      log('Refresh token error: $e at ${DateTime.now().toIso8601String()}');
      return false;
    }
  }

  Future<void> downloadAsPdf(LedgerReport ledgerReport, String startDate, String endDate) async {
    final pdf = pw.Document();

    if (ledgerReport.data.isNotEmpty) {
      final account = ledgerReport.data.first;
      pdf.addPage(
        pw.Page(
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('Ledger Report',
                    style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
                pw.Text('Account: ${account.accountName}',
                    style: pw.TextStyle(fontSize: 16)),
                pw.Text('Period: $startDate to $endDate',
                    style: pw.TextStyle(fontSize: 16)),
                pw.SizedBox(height: 20),
                pw.Table.fromTextArray(
                  headers: ['Date', 'Voucher #', 'Debit', 'Credit', 'Balance'],
                  data: account.ledger.map((entry) {
                    return [
                      entry.voucherDate.split('T')[0],
                      entry.voucherNumber,
                      entry.debit.toStringAsFixed(2),
                      entry.credit.toStringAsFixed(2),
                      entry.runningBalance.toStringAsFixed(2),
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
                style: pw.TextStyle(fontSize: 16));
          },
        ),
      );
    }

    final output = await getTemporaryDirectory();
    final file = File('${output.path}/ledger_report_${DateTime.now().toIso8601String().replaceAll(':', '-')}.pdf');
    await file.writeAsBytes(await pdf.save());
  }

  Future<void> downloadAsExcel(LedgerReport ledgerReport, String startDate, String endDate) async {
    final csvData = <List<dynamic>>[];
    csvData.add(['Date', 'Voucher #', 'Debit', 'Credit', 'Balance']);

    if (ledgerReport.data.isNotEmpty) {
      final account = ledgerReport.data.first;
      csvData.addAll(account.ledger.map((entry) => [
            entry.voucherDate.split('T')[0],
            entry.voucherNumber,
            entry.debit.toStringAsFixed(2),
            entry.credit.toStringAsFixed(2),
            entry.runningBalance.toStringAsFixed(2),
          ]));
    }

    final csv = const ListToCsvConverter().convert(csvData);
    final output = await getTemporaryDirectory();
    final file = File('${output.path}/ledger_report_${DateTime.now().toIso8601String().replaceAll(':', '-')}.csv');
    await file.writeAsString(csv);
  }
}