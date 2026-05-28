// import 'package:dio/dio.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:saleup_app/core/network/dio_client.dart';

// class DayClosingService {
//   final Dio _dio = DioClient().dio;

//   // --------------------------------------------------------------
//   // GET current open day summary
//   // --------------------------------------------------------------
//   Future<Map<String, dynamic>?> getSummary() async {
//     try {
//       final resp = await _dio.get('/day-closing/get_day_data/');
//       final data = resp.data['data'] as Map<String, dynamic>?;
//       if (data == null) return null;

//       final totals = data['totals'] as Map<String, dynamic>?;
//       if (totals != null) {
//         totals['cash'] = _toDouble(totals['cash']);
//         totals['bank'] = _toDouble(totals['bank']);
//         totals['fonepay'] = _toDouble(totals['fonepay']);
//         totals['credit'] = _toDouble(totals['credit']);
//       }
//       return data;
//     } on DioException catch (e) {
//       if (e.response?.statusCode == 404) return null;
//       debugPrint('getSummary error: ${e.response?.data}');
//       return null;
//     }
//   }

//   // --------------------------------------------------------------
//   // OPEN TODAY – sends DEVICE TODAY (2025-11-02)
//   // --------------------------------------------------------------
//   Future<bool> openToday() async {
//     try {
//       final deviceToday = DateFormat('yyyy-MM-dd').format(DateTime.now());
//       final payload = {'date': deviceToday};

//       debugPrint('Opening day for DEVICE TODAY: $deviceToday');
//       final resp = await _dio.post('/day-closing/open_day/', data: payload);
//       debugPrint('Day opened for $deviceToday');
//       return resp.data['success'] == true;
//     } on DioException catch (e) {
//       debugPrint('openToday error: ${e.response?.data}');
//       return false;
//     }
//   }

//   // --------------------------------------------------------------
//   // Check if TODAY (device date) is already open
//   // --------------------------------------------------------------
//   Future<bool> isTodayOpen() async {
//     final summary = await getSummary();
//     if (summary == null) return false;

//     final openDate = summary['date'] as String?;
//     if (openDate == null) return false;

//     final deviceToday = DateFormat('yyyy-MM-dd').format(DateTime.now());
//     return openDate == deviceToday;
//   }

//   // --------------------------------------------------------------
//   // Helper – safely convert to double
//   // --------------------------------------------------------------
//   double _toDouble(dynamic value) {
//     if (value is num) return value.toDouble();
//     if (value is String) return double.tryParse(value) ?? 0.0;
//     return 0.0;
//   }
// }

// import 'package:dio/dio.dart';
// import 'package:flutter/foundation.dart';
// import 'package:intl/intl.dart';
// import 'package:saleup_app/core/network/dio_client.dart';
// import 'package:saleup_app/services/auth_service.dart';

// class DayClosingService {
//   final Dio _dio = DioClient().dio;
//   final AuthService _authService = AuthService();

//   /// Fetch current day data (open or not)
//   /// Returns null if no open day or on error
//   Future<Map<String, dynamic>?> getDayData() async {
//     try {
//       final response = await _dio.get('/day-closing/get_day_data/');

//       if (response.statusCode == 200) {
//         final body = response.data as Map<String, dynamic>;
//         if (body['success'] == true) {
//           final data = body['data'] as Map<String, dynamic>?;
//           debugPrint('getDayData success: $data');
//           return data;
//         } else {
//           debugPrint('getDayData: ${body['message']}');
//         }
//       }
//       return null;
//     } on DioException catch (e) {
//       _logDioError('getDayData', e);
//       // If 401, attempt refresh and retry once
//       if (e.response?.statusCode == 401) {
//         final refreshed = await _refreshTokenIfNeeded();
//         if (refreshed) {
//           try {
//             final retryResponse = await _dio.get('/day-closing/get_day_data/');
//             if (retryResponse.statusCode == 200 &&
//                 retryResponse.data['success'] == true) {
//               return retryResponse.data['data'] as Map<String, dynamic>?;
//             }
//           } catch (retryError) {
//             debugPrint('Retry after refresh failed: $retryError');
//           }
//         }
//       }
//       return null;
//     } catch (e) {
//       debugPrint('getDayData unexpected error: $e');
//       return null;
//     }
//   }

//   /// Checks if today's day (based on device date) is open
//   Future<bool> isTodayOpen() async {
//     final dayData = await getDayData();
//     if (dayData == null) {
//       debugPrint('isTodayOpen: no day data → considered closed');
//       return false;
//     }

//     final openDateStr = dayData['date'] as String?;
//     if (openDateStr == null || openDateStr.isEmpty) {
//       return false;
//     }

//     // Normalize dates (ignore time and timezone)
//     final cleanOpenDate = openDateStr.substring(0, 10); // yyyy-MM-dd
//     final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

//     final isOpen = cleanOpenDate == today;
//     debugPrint('isTodayOpen: openDate=$cleanOpenDate, today=$today → $isOpen');
//     return isOpen;
//   }

//   /// Opens the day for today's date (device local date)
//   Future<bool> openToday() async {
//     try {
//       final todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
//       final payload = {'date': todayStr};

//       debugPrint('openToday → sending: $payload');

//       final response = await _dio.post(
//         '/day-closing/open_day/',
//         data: payload,
//       );

//       if (response.statusCode == 200 || response.statusCode == 201) {
//         final body = response.data as Map<String, dynamic>;
//         final success = body['success'] == true;
//         if (success) {
//           debugPrint('openToday success: ${body['message']}');
//           debugPrint('Returned data: ${body['data']}');
//           return true;
//         } else {
//           debugPrint('openToday reported failure: ${body['message']}');
//         }
//       } else {
//         debugPrint('openToday HTTP ${response.statusCode}: ${response.data}');
//       }
//       return false;
//     } on DioException catch (e) {
//       _logDioError('openToday', e);

//       if (e.response?.statusCode == 401) {
//         final refreshed = await _refreshTokenIfNeeded();
//         if (refreshed) {
//           debugPrint('Token refreshed → retrying openToday');
//           return openToday(); // retry once
//         }
//       }

//       return false;
//     } catch (e) {
//       debugPrint('openToday unexpected error: $e');
//       return false;
//     }
//   }

//   // Add this method to your DayClosingService class
//   // In DayClosingService.dart
//   Future<bool> closeToday() async {
//     try {
//       final response = await _dio.put(
//         // ← change POST → PUT
//         '/day-closing/close_day/',
//         data: {}, // add body if needed
//       );

//       if (response.statusCode == 200) {
//         final body = response.data as Map<String, dynamic>;
//         debugPrint('closeToday success: ${body['message']}');
//         return body['success'] == true;
//       }
//       return false;
//     } on DioException catch (e) {
//       debugPrint('closeToday error: ${e.response?.data}');
//       return false;
//     }
//   }

//   // ────────────────────────────────────────────────
//   //  Private helpers
//   // ────────────────────────────────────────────────

//   Future<bool> _refreshTokenIfNeeded() async {
//     debugPrint('401 detected → attempting token refresh...');
//     final refreshed = await DioClient().refreshToken();
//     if (refreshed) {
//       debugPrint('Refresh successful');
//       return true;
//     } else {
//       debugPrint('Refresh failed - user may need to login again');
//       return false;
//     }
//   }

//   void _logDioError(String method, DioException e) {
//     final status = e.response?.statusCode ?? 'unknown';
//     final detail = e.response?.data?['detail'] ?? e.message ?? 'no detail';
//     debugPrint('✗ $method failed ($status): $detail');
//     if (kDebugMode && e.response?.data != null) {
//       debugPrint('Full response: ${e.response?.data}');
//     }
//   }
// }// lib/core/services/day_closing_service.dart

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:saleup_app/core/network/dio_client.dart';
import 'package:saleup_app/services/auth_service.dart';

class DayClosingService {
  final Dio _dio = DioClient().dio;
  final AuthService _authService = AuthService();

  Future<Map<String, dynamic>?> getDayData() async {
    try {
      final response = await _dio.get('/day-closing/get_day_data/');

      if (response.statusCode == 200) {
        final body = response.data as Map<String, dynamic>;
        if (body['success'] == true) {
          final data = body['data'] as Map<String, dynamic>?;
          debugPrint('getDayData success: $data');
          return body;
        } else {
          debugPrint('getDayData: ${body['message']}');
        }
      }
      return null;
    } on DioException catch (e) {
      _logDioError('getDayData', e);
      return null;
    } catch (e) {
      debugPrint('getDayData error: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>> checkDayStatus() async {
    final responseBody = await getDayData();

    if (responseBody == null) {
      final today = DateTime.now();
      final todayStr = DateFormat('yyyy-MM-dd').format(today);
      return {
        'isOpen': false,
        'status': 'no_open_day',
        'openDate': null,
        'currentServerDate': todayStr,
        'message': 'No response from server',
      };
    }

    if (responseBody['data'] == null &&
        responseBody['message']
                ?.toString()
                .toLowerCase()
                .contains('no open day') ==
            true) {
      final today = DateTime.now();
      final todayStr = DateFormat('yyyy-MM-dd').format(today);
      return {
        'isOpen': false,
        'status': 'no_open_day',
        'openDate': null,
        'currentServerDate': todayStr,
        'message': responseBody['message'],
      };
    }

    final data = responseBody['data'] as Map<String, dynamic>?;

    if (data == null || data.isEmpty) {
      final today = DateTime.now();
      final todayStr = DateFormat('yyyy-MM-dd').format(today);
      return {
        'isOpen': false,
        'status': 'no_open_day',
        'openDate': null,
        'currentServerDate': todayStr,
        'message': 'No day data',
      };
    }

    final openDateRaw = data['date'] as String?;
    if (openDateRaw == null || openDateRaw.isEmpty) {
      final today = DateTime.now();
      final todayStr = DateFormat('yyyy-MM-dd').format(today);
      return {
        'isOpen': false,
        'status': 'invalid',
        'openDate': null,
        'currentServerDate': todayStr,
        'message': 'Invalid date format',
      };
    }

    final openDate = openDateRaw.substring(0, 10);

    String? currentServerDate = data['current_date'] as String? ??
        data['server_date'] as String? ??
        data['business_date'] as String? ??
        openDate;

    currentServerDate = currentServerDate.substring(0, 10);

    if (openDate == currentServerDate) {
      return {
        'isOpen': true,
        'status': 'today_open',
        'openDate': openDate,
        'currentServerDate': currentServerDate,
        'message': 'Today is open',
      };
    } else if (openDate.compareTo(currentServerDate) < 0) {
      return {
        'isOpen': false,
        'status': 'previous_open',
        'openDate': openDate,
        'currentServerDate': currentServerDate,
        'message': 'Previous day still open',
      };
    } else {
      return {
        'isOpen': false,
        'status': 'future_error',
        'openDate': openDate,
        'currentServerDate': currentServerDate,
        'message': 'Future date detected',
      };
    }
  }

  Future<bool> openToday() async {
    try {
      final response = await _dio.post(
        '/day-closing/open_day/',
        data: {},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final body = response.data as Map<String, dynamic>;
        return body['success'] == true;
      }
      return false;
    } on DioException catch (e) {
      _logDioError('openToday', e);
      return false;
    }
  }

  Future<bool> closeToday() async {
    try {
      final response = await _dio.put(
        '/day-closing/close_day/',
        data: {},
      );

      if (response.statusCode == 200) {
        final body = response.data as Map<String, dynamic>;
        return body['success'] == true;
      }
      return false;
    } on DioException catch (e) {
      debugPrint('closeToday error: ${e.response?.data}');
      return false;
    }
  }

  // ── BULK CLOSE DAYS ─────────────────────────────────
  Future<String?> bulkCloseDays() async {
    const String endpoint = '/day-closing/bulk_close_days/';

    try {
      final res = await DioClient().dio.post(endpoint);

      if (res.statusCode == 200) {
        final responseData = res.data as Map<String, dynamic>;
        if (responseData['success'] == true) {
          debugPrint('Bulk day close success: ${responseData['message']}');
          return responseData['message'];
        }
      }
      debugPrint('Bulk close failed — status: ${res.statusCode}');
      return null;
    } catch (e, stack) {
      debugPrint('Bulk day close error: $e\n$stack');
      return null;
    }
  }

  void _logDioError(String method, DioException e) {
    debugPrint(
        '$method failed: ${e.response?.statusCode} – ${e.response?.data}');
  }
}
