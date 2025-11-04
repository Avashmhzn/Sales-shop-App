import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:saleup_app/core/network/dio_client.dart';

class DayClosingService {
  final Dio _dio = DioClient().dio;

  // --------------------------------------------------------------
  // GET current open day summary
  // --------------------------------------------------------------
  Future<Map<String, dynamic>?> getSummary() async {
    try {
      final resp = await _dio.get('/day-closing/get_day_data/');
      final data = resp.data['data'] as Map<String, dynamic>?;
      if (data == null) return null;

      final totals = data['totals'] as Map<String, dynamic>?;
      if (totals != null) {
        totals['cash'] = _toDouble(totals['cash']);
        totals['bank'] = _toDouble(totals['bank']);
        totals['fonepay'] = _toDouble(totals['fonepay']);
        totals['credit'] = _toDouble(totals['credit']);
      }
      return data;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      debugPrint('getSummary error: ${e.response?.data}');
      return null;
    }
  }

  // --------------------------------------------------------------
  // OPEN TODAY – sends DEVICE TODAY (2025-11-02)
  // --------------------------------------------------------------
  Future<bool> openToday() async {
    try {
      final deviceToday = DateFormat('yyyy-MM-dd').format(DateTime.now());
      final payload = {'date': deviceToday};

      debugPrint('Opening day for DEVICE TODAY: $deviceToday');
      final resp = await _dio.post('/day-closing/open_day/', data: payload);
      debugPrint('Day opened for $deviceToday');
      return resp.data['success'] == true;
    } on DioException catch (e) {
      debugPrint('openToday error: ${e.response?.data}');
      return false;
    }
  }

  // --------------------------------------------------------------
  // Check if TODAY (device date) is already open
  // --------------------------------------------------------------
  Future<bool> isTodayOpen() async {
    final summary = await getSummary();
    if (summary == null) return false;

    final openDate = summary['date'] as String?;
    if (openDate == null) return false;

    final deviceToday = DateFormat('yyyy-MM-dd').format(DateTime.now());
    return openDate == deviceToday;
  }

  // --------------------------------------------------------------
  // Helper – safely convert to double
  // --------------------------------------------------------------
  double _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}
