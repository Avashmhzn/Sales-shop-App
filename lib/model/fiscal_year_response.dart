class FiscalYearData {
  final int id;
  final String startDate;
  final String? endDate;
  final String? name;
  final bool? isActive;

  FiscalYearData({
    required this.id,
    required this.startDate,
    this.endDate,
    this.name,
    this.isActive,
  });

  factory FiscalYearData.fromJson(Map<String, dynamic> json) {
    return FiscalYearData(
      id: json['id'] ?? 0,
      startDate: json['start_date'] ?? json['fiscal_year_start'] ?? '',
      endDate: json['end_date'] ?? json['fiscal_year_end'] ?? '',
      name: json['name'] ?? json['fiscal_year_name'] ?? '',
      isActive: json['is_active'] ?? json['active'] ?? false,
    );
  }
}
