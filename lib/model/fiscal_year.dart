class FiscalYear {
  final int id;
  final String name;
  final String startDate;
  final String endDate;

  FiscalYear({
    required this.id,
    required this.name,
    required this.startDate,
    required this.endDate,
  });

  factory FiscalYear.fromJson(Map<String, dynamic> json) {
    return FiscalYear(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      startDate: json['start_date'] as String? ?? '',
      endDate: json['end_date'] as String? ?? '',
    );
  }
}

class FiscalYearResponse {
  final bool success;
  final String? message;
  final FiscalYear? data;

  FiscalYearResponse({
    required this.success,
    this.message,
    this.data,
  });

  factory FiscalYearResponse.fromJson(Map<String, dynamic> json) {
    return FiscalYearResponse(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String?,
      data: json['data'] != null
          ? FiscalYear.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }
}

class FiscalYearListResponse {
  final bool success;
  final String? message;
  final List<FiscalYear>? data;

  FiscalYearListResponse({
    required this.success,
    this.message,
    this.data,
  });

  factory FiscalYearListResponse.fromJson(Map<String, dynamic> json) {
    return FiscalYearListResponse(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String?,
      data: (json['data'] as List<dynamic>?)
          ?.map((e) => FiscalYear.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
