class DayClosingTotals {
  final double cash;
  final double bank;
  final double fonepay;
  final double credit;

  const DayClosingTotals({
    this.cash = 0,
    this.bank = 0,
    this.fonepay = 0,
    this.credit = 0,
  });

  factory DayClosingTotals.fromJson(Map<String, dynamic> json) {
    return DayClosingTotals(
      cash: _toDouble(json['cash']),
      bank: _toDouble(json['bank']),
      fonepay: _toDouble(json['fonepay']),
      credit: _toDouble(json['credit']),
    );
  }

  double get total => cash + bank + fonepay + credit;

  static double _toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}

class DayClosingData {
  final String date;
  final DayClosingTotals totals;

  const DayClosingData({
    required this.date,
    required this.totals,
  });

  factory DayClosingData.fromJson(Map<String, dynamic> json) {
    return DayClosingData(
      date: json['date'] as String? ?? '',
      totals: json['totals'] != null
          ? DayClosingTotals.fromJson(json['totals'] as Map<String, dynamic>)
          : const DayClosingTotals(),
    );
  }
}

class DayClosingResponse {
  final bool success;
  final String message;
  final DayClosingData? data;

  const DayClosingResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory DayClosingResponse.fromJson(Map<String, dynamic> json) {
    return DayClosingResponse(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      data: json['data'] != null
          ? DayClosingData.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }
}
