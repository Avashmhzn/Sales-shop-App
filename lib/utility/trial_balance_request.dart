class TrialBalanceRequestDateRange {
  final String startDate;
  final String endDate;

  const TrialBalanceRequestDateRange({
    required this.startDate,
    required this.endDate,
  });
}

List<TrialBalanceRequestDateRange> buildTrialBalanceRequestDateRanges(
  String startDate,
  String endDate,
) {
  final normalizedStart = startDate.trim();
  final normalizedEnd = endDate.trim();

  final startParsed = DateTime.tryParse(normalizedStart);
  final endParsed = DateTime.tryParse(normalizedEnd);

  if (startParsed != null &&
      endParsed != null &&
      startParsed.isAfter(endParsed)) {
    return [
      TrialBalanceRequestDateRange(
        startDate: normalizedEnd,
        endDate: normalizedStart,
      ),
    ];
  }

  return [
    TrialBalanceRequestDateRange(
      startDate: normalizedStart,
      endDate: normalizedEnd,
    ),
  ];
}
