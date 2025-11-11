// // lib/screen/stock_ledger/bloc/stock_ledger_state.dart
// import 'package:saleup_app/model/product_category_response.dart';
// import 'package:saleup_app/model/stock_ledger_response.dart';

// abstract class StockLedgerState {}

// class StockLedgerInitial extends StockLedgerState {}

// class StockLedgerLoading extends StockLedgerState {}

// class StockLedgerSuccess extends StockLedgerState {
//   final StockLedgerReport report;
//   StockLedgerSuccess(this.report);
// }

// class StockLedgerFailure extends StockLedgerState {
//   final String message;
//   StockLedgerFailure(this.message);
// }

// class FilterOptionsLoaded extends StockLedgerState {
//   final List<ProductData> products;
//   final List<CategoryData> categories;
//   final Map<int, String> productMap;
//   final Map<int, String> categoryMap;

//   FilterOptionsLoaded({
//     required this.products,
//     required this.categories,
//     required this.productMap,
//     required this.categoryMap,
//   });
// }
import 'package:saleup_app/model/product_category_response.dart';
import 'package:saleup_app/model/stock_ledger_response.dart';

abstract class StockLedgerState {}

class StockLedgerInitial extends StockLedgerState {}

class StockLedgerLoading extends StockLedgerState {}

class StockLedgerSuccess extends StockLedgerState {
  final StockLedgerReport report;
  StockLedgerSuccess(this.report);
}

class StockLedgerFailure extends StockLedgerState {
  final String message;
  StockLedgerFailure(this.message);
}

class FilterOptionsLoaded extends StockLedgerState {
  final List<ProductData> products;
  final List<CategoryData> categories;
  final Map<int, String> productMap;
  final Map<int, String> categoryMap;

  FilterOptionsLoaded({
    required this.products,
    required this.categories,
    required this.productMap,
    required this.categoryMap,
  });
}
