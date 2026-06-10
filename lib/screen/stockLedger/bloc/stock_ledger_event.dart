// // stock_ledger_event.dart
// abstract class StockLedgerEvent {}

// class FetchFilterOptions extends StockLedgerEvent {}

// class FetchStockLedgerReport extends StockLedgerEvent {
//   final String? startDate;
//   final String? endDate;
//   final int? productId;
//   final int? categoryId;
//   final String rateType; // 'cost' or 'selling'

//   FetchStockLedgerReport({
//     this.startDate,
//     this.endDate,
//     this.productId,
//     this.categoryId,
//     required this.rateType,
//   });
// }

// lib/screen/reports/bloc/stock_ledger_event.dart

abstract class StockLedgerEvent {}

/// One-shot init: fiscal year + day closing + products + categories + first report
class InitializeStockLedger extends StockLedgerEvent {}

/// Fetch / refill report with current filters
class FetchStockLedgerReport extends StockLedgerEvent {
  final String startDate;
  final String endDate;
  final int? productId;
  final int? categoryId;
  final String rateType; // 'cost' | 'selling'

  FetchStockLedgerReport({
    required this.startDate,
    required this.endDate,
    this.productId,
    this.categoryId,
    required this.rateType,
  });
}

/// Server-side export via /export/report/
class ExportStockLedger extends StockLedgerEvent {
  final String startDate;
  final String endDate;
  final int? productId;
  final int? categoryId;

  ExportStockLedger({
    required this.startDate,
    required this.endDate,
    this.productId,
    this.categoryId,
  });
}
