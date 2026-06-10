// // lib/screen/stockLedger/bloc/stock_ledger_state.dart

// import 'package:saleup_app/model/product_category_response.dart';
// import 'package:saleup_app/model/stock_ledger_response.dart';

// abstract class StockLedgerState {}

// class StockLedgerInitial extends StockLedgerState {}

// class StockLedgerLoading extends StockLedgerState {}

// class StockLedgerSuccess extends StockLedgerState {
//   final StockLedgerReport report;
//   final Map<String, dynamic> rawJson;
//   StockLedgerSuccess(this.report, this.rawJson);
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

// lib/screen/reports/bloc/stock_ledger_state.dart

import 'package:saleup_app/model/product_category_response.dart';
import 'package:saleup_app/model/stock_ledger_response.dart';

abstract class StockLedgerState {}

class StockLedgerInitial extends StockLedgerState {}

class StockLedgerLoading extends StockLedgerState {}

/// Holds filter metadata + report data together so nothing is lost
class StockLedgerSuccess extends StockLedgerState {
  final StockLedgerReport report;
  final Map<String, dynamic> rawJson;

  // Filter metadata (always available after init)
  final List<ProductData> products;
  final List<CategoryData> categories;
  final DateTime defaultStartDate;
  final DateTime defaultEndDate;

  StockLedgerSuccess({
    required this.report,
    required this.rawJson,
    required this.products,
    required this.categories,
    required this.defaultStartDate,
    required this.defaultEndDate,
  });

  StockLedgerSuccess copyWith({
    StockLedgerReport? report,
    Map<String, dynamic>? rawJson,
    List<ProductData>? products,
    List<CategoryData>? categories,
    DateTime? defaultStartDate,
    DateTime? defaultEndDate,
  }) {
    return StockLedgerSuccess(
      report: report ?? this.report,
      rawJson: rawJson ?? this.rawJson,
      products: products ?? this.products,
      categories: categories ?? this.categories,
      defaultStartDate: defaultStartDate ?? this.defaultStartDate,
      defaultEndDate: defaultEndDate ?? this.defaultEndDate,
    );
  }
}

class StockLedgerExporting extends StockLedgerState {}

class StockLedgerExportSuccess extends StockLedgerState {
  final String filePath;
  StockLedgerExportSuccess(this.filePath);
}

class StockLedgerFailure extends StockLedgerState {
  final String message;
  StockLedgerFailure(this.message);
}
