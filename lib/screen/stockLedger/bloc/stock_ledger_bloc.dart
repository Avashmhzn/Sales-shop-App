// // lib/screen/stock_ledger/bloc/stock_ledger_bloc.dart

// import 'dart:convert';
// import 'dart:developer';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:intl/intl.dart';
// import 'package:saleup_app/core/network/dio_client.dart';
// import 'package:saleup_app/model/product_category_response.dart';
// import 'package:saleup_app/model/stock_ledger_response.dart';
// import 'stock_ledger_event.dart';
// import 'stock_ledger_state.dart';

// class StockLedgerBloc extends Bloc<StockLedgerEvent, StockLedgerState> {
//   final DioClient dioClient;

//   StockLedgerBloc({required this.dioClient}) : super(StockLedgerInitial()) {
//     on<FetchFilterOptions>(_loadFilters);
//     on<FetchStockLedgerReport>(_loadReport);
//   }

//   // SAFELY PARSE ANY NUMBER (String, int, double)
//   double safeDouble(dynamic value) {
//     if (value == null) return 0.0;
//     if (value is num) return value.toDouble();
//     if (value is String) {
//       final cleaned = value.trim();
//       if (cleaned.isEmpty) return 0.0;
//       return double.tryParse(cleaned) ?? 0.0;
//     }
//     return 0.0;
//   }

//   // CRITICAL FIX: Correctly get product name in ALL cases
//   String getProductName(dynamic item) {
//     // Case 1: When filtering by product/category → has 'product_name'
//     if (item['product_name'] != null) {
//       return (item['product_name'] as String).trim();
//     }
//     // Case 2: When "All Products" → has 'product': { 'name': '...' }
//     if (item['product'] != null && item['product'] is Map) {
//       return (item['product']['name'] ?? 'Unknown Product').toString().trim();
//     }
//     // Fallback
//     return 'Unknown Product';
//   }

//   Future<void> _loadFilters(
//       FetchFilterOptions event, Emitter<StockLedgerState> emit) async {
//     emit(StockLedgerLoading());
//     try {
//       final catResp = await dioClient.dio.get('/category/get_categories');
//       final prodResp = await dioClient.dio
//           .get('/product/get_products/', queryParameters: {'limit': 5000});

//       final cats = <CategoryData>[];
//       final prods = <ProductData>[];

//       for (var c in catResp.data['data']) {
//         cats.add(CategoryData(id: c['id'], name: c['name']));
//       }
//       for (var p in prodResp.data['data']['results']) {
//         prods.add(ProductData(id: p['id'], name: p['name']));
//       }

//       emit(FilterOptionsLoaded(
//         products: prods,
//         categories: cats,
//         productMap: {},
//         categoryMap: {},
//       ));
//     } catch (e) {
//       emit(StockLedgerFailure('Failed to load filters: $e'));
//     }
//   }

//   Future<void> _loadReport(
//     FetchStockLedgerReport event,
//     Emitter<StockLedgerState> emit,
//   ) async {
//     emit(StockLedgerLoading());

//     final from = event.startDate ??
//         DateFormat('yyyy-MM-dd')
//             .format(DateTime.now().subtract(const Duration(days: 30)));
//     final to = event.endDate ?? DateFormat('yyyy-MM-dd').format(DateTime.now());

//     final params = <String, String>{
//       'start_date': from,
//       'end_date': to,
//       if (event.productId != null) 'product_id': event.productId.toString(),
//       if (event.categoryId != null) 'category_id': event.categoryId.toString(),
//     };

//     log('SENDING → $params');

//     try {
//       final resp = await dioClient.dio.get(
//         '/ledger/get_stock_ledger/',
//         queryParameters: params,
//       );

//       dynamic raw = resp.data;
//       if (raw is String) raw = jsonDecode(raw);
//       if (raw is! Map<String, dynamic>) {
//         emit(StockLedgerFailure('Invalid response'));
//         return;
//       }

//       if (!(raw['success'] as bool? ?? false)) {
//         emit(StockLedgerFailure(raw['message'] ?? 'Failed'));
//         return;
//       }

//       final dataJson = raw['data'] as Map<String, dynamic>;

//       // PRODUCT → TOTALS MAP
//       final Map<String, Map<String, double>> productTotals = {};

//       void add(
//           String name, String qtyKey, double qty, String valKey, double val) {
//         name = name.trim();
//         productTotals.putIfAbsent(
//             name,
//             () => {
//                   'opening_qty': 0.0,
//                   'opening_val': 0.0,
//                   'purchase_qty': 0.0,
//                   'purchase_val': 0.0,
//                   'pur_ret_qty': 0.0,
//                   'pur_ret_val': 0.0,
//                   'sales_qty': 0.0,
//                   'sales_val': 0.0,
//                   'sales_ret_qty': 0.0,
//                   'sales_ret_val': 0.0,
//                   'closing_qty': 0.0,
//                   'closing_val': 0.0,
//                 });

//         final t = productTotals[name]!;
//         t[qtyKey] = (t[qtyKey] ?? 0.0) + qty;
//         t[valKey] = (t[valKey] ?? 0.0) + val;
//       }

//       void process(
//         List<dynamic>? list,
//         String qtyKey,
//         String rateKey,
//         String totalQtyKey,
//         String totalValKey, {
//         bool negative = false,
//       }) {
//         if (list == null || list.isEmpty) return;
//         for (final item in list) {
//           final name = getProductName(item);
//           final qty = safeDouble(item[qtyKey]);
//           final rate = safeDouble(item[rateKey]);
//           final val = qty * rate;

//           add(
//             name,
//             totalQtyKey,
//             negative ? -qty : qty,
//             totalValKey,
//             negative ? -val : val,
//           );
//         }
//       }

//       // PROCESS EVERY SECTION
//       process(dataJson['opening_stock']?['summary'], 'quantity', 'cost_price',
//           'opening_qty', 'opening_val');

//       process(dataJson['purchases'], 'quantity', 'cost_price', 'purchase_qty',
//           'purchase_val');

//       process(dataJson['purchase_returns'], 'quantity', 'cost_price',
//           'pur_ret_qty', 'pur_ret_val',
//           negative: true);

//       process(
//           dataJson['sales'],
//           'quantity',
//           event.rateType == 'cost' ? 'cost_price' : 'selling_price',
//           'sales_qty',
//           'sales_val',
//           negative: true);

//       process(
//           dataJson['sale_returns'],
//           'quantity',
//           event.rateType == 'cost' ? 'cost_price' : 'selling_price',
//           'sales_ret_qty',
//           'sales_ret_val');

//       process(dataJson['closing_stock']?['summary'], 'quantity', 'cost_price',
//           'closing_qty', 'closing_val');

//       // BUILD FINAL LIST – ONE ROW PER PRODUCT
//       final accounts = productTotals.entries.map((e) {
//         final name = e.key;
//         final t = e.value;

//         return StockLedgerAccount(
//           productName: name,
//           ledger: [
//             StockLedgerEntry(
//               date: to,
//               opening: t['opening_qty']!,
//               purchase: t['purchase_qty']!,
//               sales: t['sales_qty']!,
//               closing: t['closing_qty']!,
//               costPrice: t['closing_qty']! > 0
//                   ? t['closing_val']! / t['closing_qty']!
//                   : 0.0,
//               sellingPrice: 0.0,
//             ),
//           ],
//         );
//       }).toList();

//       final report = StockLedgerReport(
//         success: true,
//         message: 'Success',
//         data: accounts.isNotEmpty ? accounts : null,
//       );

//       emit(StockLedgerSuccess(report, raw));
//       log('ALL PRODUCTS LOADED → ${accounts.length} products (PDF/Excel will have ALL)');
//     } catch (e, s) {
//       log('ERROR', error: e, stackTrace: s);
//       emit(StockLedgerFailure('Failed: $e'));
//     }
//   }
// }
import 'dart:developer';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:saleup_app/model/product_category_response.dart';
import 'package:saleup_app/model/stock_ledger_response.dart';
import 'package:saleup_app/services/report_service.dart';
import 'stock_ledger_event.dart';
import 'stock_ledger_state.dart';

class StockLedgerBloc extends Bloc<StockLedgerEvent, StockLedgerState> {
  final ReportService reportService;

  List<ProductData> _products = [];
  List<CategoryData> _categories = [];

  DateTime _defaultStart = DateTime.now().subtract(const Duration(days: 30));
  DateTime _defaultEnd = DateTime.now();

  StockLedgerBloc({required this.reportService}) : super(StockLedgerInitial()) {
    on<InitializeStockLedger>(_onInitialize);
    on<FetchStockLedgerReport>(_loadReport);
    on<ExportStockLedger>(_onExport);
  }

  Future<void> _onInitialize(
      InitializeStockLedger event, Emitter<StockLedgerState> emit) async {
    emit(StockLedgerLoading());
    try {
      final results = await Future.wait([
        reportService.getProducts(),
        reportService.getCategories(),
      ]);

      _products = results[0] as List<ProductData>;
      _categories = results[1] as List<CategoryData>;

      // Get day open date first, then find the fiscal year containing it
      final dayOpenDate = await reportService.getDayOpenDate();
      final dayOpen = dayOpenDate != null ? DateTime.tryParse(dayOpenDate) : null;
      final fiscalYear = dayOpen != null
          ? await reportService.getFiscalYearContaining(dayOpen)
          : await reportService.getActiveFiscalYear();

      if (fiscalYear != null && fiscalYear.startDate.isNotEmpty) {
        _defaultStart =
            DateTime.tryParse(fiscalYear.startDate) ?? _defaultStart;
      }

      // End = day open date (guaranteed within fiscal year now)
      _defaultEnd = dayOpen ??
          (fiscalYear?.endDate != null
              ? DateTime.tryParse(fiscalYear!.endDate!) ?? _defaultEnd
              : _defaultEnd);

      add(FetchStockLedgerReport(
        startDate: _fmt(_defaultStart),
        endDate: _fmt(_defaultEnd),
        rateType: 'cost',
      ));
    } catch (e) {
      emit(StockLedgerFailure('Initialization failed: $e'));
    }
  }

  Future<void> _loadReport(
      FetchStockLedgerReport event, Emitter<StockLedgerState> emit) async {
    emit(StockLedgerLoading());

    final params = <String, dynamic>{
      'start_date': event.startDate,
      'end_date': event.endDate,
      if (event.productId != null) 'product_id': event.productId,
      if (event.categoryId != null) 'category_id': event.categoryId,
    };

    try {
      final raw =
          await reportService.fetchReport('/ledger/get_stock_ledger/', params);

      if (!(raw['success'] as bool? ?? false)) {
        emit(StockLedgerFailure(raw['message'] ?? 'Request failed'));
        return;
      }

      // ★ PARSE THE NEW JSON RESPONSE FORMAT
      final report = _parseStockLedgerResponse(raw, event.rateType);

      emit(StockLedgerSuccess(
        report: report,
        rawJson: raw,
        products: _products,
        categories: _categories,
        defaultStartDate: _defaultStart,
        defaultEndDate: _defaultEnd,
      ));
    } catch (e, s) {
      log('❌ Report error', error: e, stackTrace: s);
      emit(StockLedgerFailure('Failed: $e'));
    }
  }

  // ★ NEW PARSER: Correctly extracts data from your backend's JSON structure
  StockLedgerReport _parseStockLedgerResponse(
      Map<String, dynamic> raw, String rateType) {
    final dataJson = raw['data'] as Map<String, dynamic>? ?? {};

    final Map<int, Map<String, dynamic>> productData = {};

    void processList(List<dynamic>? list, String targetKey,
        {bool negative = false}) {
      if (list == null) return;
      for (var item in list) {
        final id = item['product_id'] as int? ?? 0;
        final name = item['product_name'] as String? ?? 'Unknown';
        final qty = (item['quantity'] as num? ?? 0.0).toDouble();

        // Use total_cost_price for all, fallback to total_amount
        final val = (item['total_cost_price'] as num? ??
                item['total_amount'] as num? ??
                0.0)
            .toDouble();

        productData.putIfAbsent(
            id,
            () => {
                  'name': name,
                  'opening_qty': 0.0,
                  'opening_val': 0.0,
                  'purchase_qty': 0.0,
                  'purchase_val': 0.0,
                  'pur_ret_qty': 0.0,
                  'pur_ret_val': 0.0,
                  'sales_qty': 0.0,
                  'sales_val': 0.0,
                  'sales_ret_qty': 0.0,
                  'sales_ret_val': 0.0,
                  'closing_qty': 0.0,
                  'closing_val': 0.0,
                  'cost_price': 0.0,
                  'selling_price': 0.0,
                });

        productData[id]!['name'] = name;
        productData[id]![targetKey] =
            (productData[id]![targetKey] as double) + (negative ? -qty : qty);
        productData[id]![targetKey.replaceAll('qty', 'val')] =
            (productData[id]![targetKey.replaceAll('qty', 'val')] as double) +
                (negative ? -val.abs() : val.abs());
      }
    }

    // Process all sections based on your JSON
    processList(
        dataJson['opening_stock']?['summary'] as List<dynamic>?, 'opening_qty');
    processList(dataJson['purchases'] as List<dynamic>?, 'purchase_qty');
    processList(dataJson['purchase_returns'] as List<dynamic>?, 'pur_ret_qty',
        negative: true);
    processList(dataJson['sales'] as List<dynamic>?, 'sales_qty',
        negative: true);
    processList(dataJson['sale_returns'] as List<dynamic>?, 'sales_ret_qty');

    // Process closing stock summary
    final closingSummary =
        dataJson['closing_stock']?['summary'] as List<dynamic>?;
    if (closingSummary != null) {
      for (var item in closingSummary) {
        final id = item['product_id'] as int? ?? 0;
        final name = item['product_name'] as String? ?? 'Unknown';
        productData.putIfAbsent(
            id,
            () => {
                  'name': name,
                  'opening_qty': 0.0,
                  'opening_val': 0.0,
                  'purchase_qty': 0.0,
                  'purchase_val': 0.0,
                  'pur_ret_qty': 0.0,
                  'pur_ret_val': 0.0,
                  'sales_qty': 0.0,
                  'sales_val': 0.0,
                  'sales_ret_qty': 0.0,
                  'sales_ret_val': 0.0,
                  'closing_qty': 0.0,
                  'closing_val': 0.0,
                  'cost_price': 0.0,
                  'selling_price': 0.0,
                });

        productData[id]!['name'] = name;
        productData[id]!['closing_qty'] =
            (item['quantity'] as num? ?? 0.0).toDouble();
        productData[id]!['closing_val'] =
            (item['total_cost_price'] as num? ?? 0.0).toDouble();
        productData[id]!['cost_price'] =
            (item['weighted_avg_cost_price'] as num? ?? 0.0).toDouble();
        productData[id]!['selling_price'] =
            (item['weighted_avg_selling_price'] as num? ?? 0.0).toDouble();
      }
    }

    // Map to StockLedgerAccount objects
    final accounts = productData.entries.map((e) {
      final t = e.value;
      return StockLedgerAccount(
        productName: t['name'] as String,
        ledger: [
          StockLedgerEntry(
            date: '',
            opening: t['opening_qty'] as double,
            purchase: t['purchase_qty'] as double,
            sales: t['sales_qty'] as double,
            closing: t['closing_qty'] as double,
            costPrice: t['cost_price'] as double,
            sellingPrice: t['selling_price'] as double,
            openingValue: t['opening_val'] as double,
            purchaseValue: t['purchase_val'] as double,
            salesValue: t['sales_val'] as double,
            salesReturnQty: t['sales_ret_qty'] as double,
            salesReturnValue: t['sales_ret_val'] as double,
            closingValue: t['closing_val'] as double,
          ),
        ],
      );
    }).toList();

    return StockLedgerReport(success: true, message: 'Success', data: accounts);
  }

  Future<void> _onExport(
      ExportStockLedger event, Emitter<StockLedgerState> emit) async {
    emit(StockLedgerExporting());
    try {
      final path = await reportService.exportReport(
        reportType: 'stock_ledger',
        startDate: event.startDate,
        endDate: event.endDate,
        productId: event.productId,
        categoryId: event.categoryId,
      );
      emit(StockLedgerExportSuccess(path));
    } catch (e) {
      emit(StockLedgerFailure('Export failed: $e'));
    }
  }

  String _fmt(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}
