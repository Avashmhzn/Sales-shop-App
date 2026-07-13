// // lib/screen/reports/services/report_service.dart

// import 'dart:io';
// import 'dart:developer';
// import 'package:dio/dio.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:saleup_app/core/network/dio_client.dart';
// import 'package:saleup_app/model/fiscal_year_response.dart';
// import 'package:saleup_app/model/product_category_response.dart';
// import 'package:saleup_app/screen/dayClosing/model/day_closing_model.dart';

// class DefaultDateRange {
//   final String? startDate;
//   final String? endDate;
//   DefaultDateRange({this.startDate, this.endDate});
//   bool get isValid => startDate != null && endDate != null;
// }

// class ReportService {
//   final DioClient _dioClient;
//   ReportService({DioClient? dioClient}) : _dioClient = dioClient ?? DioClient();
//   Dio get dio => _dioClient.dio;

//   // ──────────────────────────────────────────────
//   //  Fiscal Year Start Date
//   // ──────────────────────────────────────────────
//   Future<String?> getFiscalYearStartDate() async {
//     try {
//       final response = await dio.get('/fiscal-year/get_current_fiscal_year/');
//       final d = response.data;
//       if (d is Map<String, dynamic> && d['data'] != null) {
//         final data = d['data'] is Map<String, dynamic>
//             ? d['data']
//             : Map<String, dynamic>.from(d['data']);
//         return data['start_date'] ?? data['fiscal_year_start'];
//       }
//       return null;
//     } catch (e) {
//       log('⚠️ Fiscal year fetch failed: $e');
//       return null;
//     }
//   }

//   // ──────────────────────────────────────────────
//   //  Day Closing Open Date (Using your Model)
//   // ──────────────────────────────────────────────
//   Future<String?> getOpenDayDate() async {
//     try {
//       final response = await dio.get('/day-closing/get_day_data/');

//       final dayClosingResponse = DayClosingResponse.fromJson(
//           response.data is Map<String, dynamic>
//               ? response.data
//               : Map<String, dynamic>.from(response.data));

//       if (dayClosingResponse.success && dayClosingResponse.data != null) {
//         return dayClosingResponse.data!.date;
//       }
//       return null;
//     } catch (e) {
//       log('⚠️ Day data fetch failed: $e');
//       return null;
//     }
//   }

//   // ──────────────────────────────────────────────
//   //  Default Date Range (fiscal start → open day)
//   // ──────────────────────────────────────────────
//   Future<DefaultDateRange> getDefaultDateRange() async {
//     final results = await Future.wait([
//       getFiscalYearStartDate(),
//       getOpenDayDate(),
//     ]);
//     return DefaultDateRange(
//       startDate: results[0], // Fiscal Year Start
//       endDate: results[1], // Open Day Date
//     );
//   }

//   // ──────────────────────────────────────────────
//   //  Products & Categories
//   // ──────────────────────────────────────────────
//   Future<List<ProductData>> getProducts({String search = ''}) async {
//     try {
//       final response = await dio.get(
//         '/product/get_products/',
//         queryParameters: {'limit': 5000, 'offset': 0, 'search': search},
//       );
//       final results = response.data['data']['results'] as List? ?? [];
//       return results
//           .map((p) => ProductData(id: p['id'], name: p['name']))
//           .toList();
//     } catch (e) {
//       log('⚠️ Products fetch failed: $e');
//       return [];
//     }
//   }

//   Future<List<CategoryData>> getCategories() async {
//     try {
//       final response = await dio.get('/category/get_categories/');
//       final list = response.data['data'] as List? ?? [];
//       return list
//           .map((c) => CategoryData(id: c['id'], name: c['name']))
//           .toList();
//     } catch (e) {
//       log('⚠️ Categories fetch failed: $e');
//       return [];
//     }
//   }

//   // ──────────────────────────────────────────────
//   //  Generic Report Fetch
//   // ──────────────────────────────────────────────
//   Future<Map<String, dynamic>> fetchReport(
//       String endpoint, Map<String, dynamic> params) async {
//     final response = await dio.get(endpoint, queryParameters: params);
//     return response.data is Map<String, dynamic>
//         ? response.data
//         : Map<String, dynamic>.from(response.data);
//   }

//   // ──────────────────────────────────────────────
//   //  Export via /export/report/
//   // ──────────────────────────────────────────────
//   Future<String> exportReport({
//     required String reportType,
//     required String startDate,
//     required String endDate,
//     int? productId,
//     int? categoryId,
//     String? accHead,
//   }) async {
//     final granted = await _requestPermission();
//     if (!granted) throw Exception('Storage permission denied');

//     final params = <String, String>{
//       'report_type': reportType,
//       'start_date': startDate,
//       'end_date': endDate,
//       if (productId != null) 'product_id': productId.toString(),
//       if (categoryId != null) 'category_id': categoryId.toString(),
//       if (accHead != null) 'acc_head': accHead,
//     };

//     log('📤 Exporting: $params');

//     final response = await dio.get(
//       '/export/report/',
//       queryParameters: params,
//       options: Options(responseType: ResponseType.bytes),
//     );

//     final contentType = response.headers['content-type']?.first ?? '';
//     final ext = contentType.contains('pdf')
//         ? 'pdf'
//         : contentType.contains('sheet') || contentType.contains('excel')
//             ? 'xlsx'
//             : 'pdf';

//     final dir = await _getDownloadDirectory();
//     final timestamp = DateTime.now().millisecondsSinceEpoch;
//     final file = File('${dir.path}/${reportType}_$timestamp.$ext');
//     await file.writeAsBytes(response.data);

//     log('✅ Export saved → ${file.path}');
//     return file.path;
//   }

//   // ──────────────────────────────────────────────
//   //  Helpers
//   // ──────────────────────────────────────────────
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
// }

// lib/screen/reports/services/report_service.dart

import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:saleup_app/core/network/dio_client.dart';
import 'package:saleup_app/model/fiscal_year_response.dart';
import 'package:saleup_app/model/product_category_response.dart';
import 'package:saleup_app/screen/dayClosing/model/day_closing_model.dart';

class DefaultDateRange {
  final String? startDate;
  final String? endDate;
  DefaultDateRange({this.startDate, this.endDate});
  bool get isValid => startDate != null && endDate != null;
}

class ReportService {
  final DioClient _dioClient;
  ReportService({DioClient? dioClient}) : _dioClient = dioClient ?? DioClient();
  Dio get dio => _dioClient.dio;

  // ... (Keep getFiscalYearStartDate, getOpenDayDate, getDefaultDateRange, getProducts, getCategories, fetchReport from previous response)

  Future<String?> getFiscalYearStartDate() async {
    try {
      final response = await dio.get('/fiscal-year/get_current_fiscal_year/');
      final d = response.data;
      if (d is Map<String, dynamic> && d['data'] != null) {
        final data = d['data'] is Map<String, dynamic>
            ? d['data']
            : Map<String, dynamic>.from(d['data']);
        return data['start_date'] ?? data['fiscal_year_start'];
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<String?> getOpenDayDate() async {
    try {
      final response = await dio.get('/day-closing/get_day_data/');
      final dayClosingResponse = DayClosingResponse.fromJson(
          response.data is Map<String, dynamic>
              ? response.data
              : Map<String, dynamic>.from(response.data));
      if (dayClosingResponse.success && dayClosingResponse.data != null) {
        return dayClosingResponse.data!.date;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<DefaultDateRange> getDefaultDateRange() async {
    final results =
        await Future.wait([getFiscalYearStartDate(), getOpenDayDate()]);
    return DefaultDateRange(startDate: results[0], endDate: results[1]);
  }

  Future<List<ProductData>> getProducts({String search = ''}) async {
    try {
      final response = await dio.get('/product/get_products/',
          queryParameters: {'limit': 5000, 'offset': 0, 'search': search});
      final results = response.data['data']['results'] as List? ?? [];
      return results
          .map((p) => ProductData(id: p['id'], name: p['name']))
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<CategoryData>> getCategories() async {
    try {
      final response = await dio.get('/category/get_categories/');
      final list = response.data['data'] as List? ?? [];
      return list
          .map((c) => CategoryData(id: c['id'], name: c['name']))
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<Map<String, dynamic>> fetchReport(
      String endpoint, Map<String, dynamic> params) async {
    final response = await dio.get(endpoint, queryParameters: params);
    return response.data is Map<String, dynamic>
        ? response.data
        : Map<String, dynamic>.from(response.data);
  }

  // ═══════════════════════════════════════════════════════
  //  FIXED EXPORT - Saves to visible Downloads folder
  // ═══════════════════════════════════════════════════════
  Future<String> exportReport({
    required String reportType,
    required String startDate,
    required String endDate,
    int? productId,
    int? categoryId,
    String? accHead,
  }) async {
    final granted = await _requestPermission();
    if (!granted) throw Exception('Storage permission denied');

    final params = <String, String>{
      'report_type': reportType,
      'start_date': startDate,
      'end_date': endDate,
      if (productId != null) 'product_id': productId.toString(),
      if (categoryId != null) 'category_id': categoryId.toString(),
      if (accHead != null) 'acc_head': accHead,
    };

    final response = await dio.get(
      '/export/report/',
      queryParameters: params,
      options: Options(responseType: ResponseType.bytes),
    );

    final contentType = response.headers['content-type']?.first ?? '';
    final ext = contentType.contains('pdf')
        ? 'pdf'
        : contentType.contains('sheet') || contentType.contains('excel')
            ? 'xlsx'
            : 'pdf';

    final dir = await _getDownloadDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final file = File('${dir.path}/${reportType}_$timestamp.$ext');
    await file.writeAsBytes(response.data);

    return file.path;
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

  // ★ FIX: Get the actual public Downloads directory
  Future<Directory> _getDownloadDirectory() async {
    if (Platform.isAndroid) {
      // 1. Try standard Android public Downloads folder
      try {
        final dir = Directory('/storage/emulated/0/Download');
        if (await dir.exists()) return dir;
      } catch (_) {}

      // 2. Try path_provider
      final dir = await getDownloadsDirectory();
      if (dir != null) return dir;

      // 3. Fallback to app external storage
      final externalDir = await getExternalStorageDirectory();
      if (externalDir != null) return externalDir;
    }
    return await getApplicationDocumentsDirectory();
  }

  Future<FiscalYearData?> getActiveFiscalYear() async {
    try {
      final resp =
          await DioClient().dio.get('/fiscal-year/get_current_fiscal_year/');
      final raw = resp.data;
      if (raw is String) return null;

      if (raw is Map<String, dynamic>) {
        if (raw['success'] == true && raw['data'] != null) {
          return FiscalYearData.fromJson(raw['data'] as Map<String, dynamic>);
        } else {
          return FiscalYearData.fromJson(raw);
        }
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  /// Fetches the dynamic Day Open Date for the current user
  Future<String?> getDayOpenDate() async {
    try {
      final resp = await DioClient().dio.get('/day-closing/get_day_data/');
      final raw = resp.data;
      if (raw is Map<String, dynamic>) {
        final data = raw['data'];
        if (data is Map) {
          return data['open_date'] as String? ?? data['date'] as String?;
        }
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  /// Returns the fiscal year whose start_date <= [date] <= end_date.
  /// Falls back to the active fiscal year if none matches.
  Future<FiscalYearData?> getFiscalYearContaining(DateTime date) async {
    try {
      final resp = await DioClient().dio.get('/fiscal-year/get_fiscal_years/');
      final raw = resp.data;
      List<dynamic>? list;
      if (raw is Map<String, dynamic>) {
        final d = raw['data'];
        if (d is List) {
          list = d;
        } else if (d is Map) list = d['results'] as List?;
      } else if (raw is List) {
        list = raw;
      }
      if (list != null) {
        for (final item in list) {
          final fy = FiscalYearData.fromJson(item as Map<String, dynamic>);
          final start = DateTime.tryParse(fy.startDate);
          final end = fy.endDate != null ? DateTime.tryParse(fy.endDate!) : null;
          if (start != null && end != null &&
              !date.isBefore(start) && !date.isAfter(end)) {
            return fy;
          }
        }
      }
    } catch (_) {}
    // fallback
    return getActiveFiscalYear();
  }
}
