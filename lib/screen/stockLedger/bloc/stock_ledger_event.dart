// // lib/screen/stock_ledger/bloc/stock_ledger_event.dart
// abstract class StockLedgerEvent {}

// class FetchFilterOptions extends StockLedgerEvent {}

// class FetchStockLedgerReport extends StockLedgerEvent {
//   final String? startDate;
//   final String? endDate;
//   final int? productId;
//   final int? categoryId;

//   FetchStockLedgerReport({
//     this.startDate,
//     this.endDate,
//     this.productId,
//     this.categoryId,
//   });
// }
abstract class StockLedgerEvent {}

class FetchFilterOptions extends StockLedgerEvent {}

class FetchStockLedgerReport extends StockLedgerEvent {
  final String? startDate;
  final String? endDate;
  final int? productId;
  final int? categoryId;

  FetchStockLedgerReport({
    this.startDate,
    this.endDate,
    this.productId,
    this.categoryId,
  });
}
