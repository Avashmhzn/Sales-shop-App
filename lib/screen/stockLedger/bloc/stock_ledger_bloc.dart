// // lib/screen/stock_ledger/bloc/stock_ledger_bloc.dart
// import 'dart:convert'; // ← ADD THIS
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

//   Future<void> _loadFilters(
//       FetchFilterOptions event, Emitter<StockLedgerState> emit) async {
//     emit(StockLedgerLoading());
//     try {
//       final catResp = await dioClient.dio.get('/category/get_categories');
//       final prodResp = await dioClient.dio
//           .get('/product/get_products/', queryParameters: {'limit': 5000});

//       final cats = <CategoryData>[];
//       final catMap = <int, String>{};
//       final prods = <ProductData>[];
//       final prodMap = <int, String>{};

//       for (var c in catResp.data['data']) {
//         final cat = CategoryData(id: c['id'], name: c['name']);
//         cats.add(cat);
//         catMap[cat.id] = cat.name;
//       }

//       for (var p in prodResp.data['data']['results']) {
//         final prod = ProductData(id: p['id'], name: p['name']);
//         prods.add(prod);
//         prodMap[prod.id] = prod.name;
//       }

//       emit(FilterOptionsLoaded(
//         products: prods,
//         categories: cats,
//         productMap: prodMap,
//         categoryMap: catMap,
//       ));
//     } catch (e) {
//       emit(StockLedgerFailure('Failed to load filters: $e'));
//     }
//   }

//   Future<void> _loadReport(
//       FetchStockLedgerReport event, Emitter<StockLedgerState> emit) async {
//     emit(StockLedgerLoading());

//     if (event.productId == null && event.categoryId == null) {
//       emit(StockLedgerFailure('Select Product or Category'));
//       return;
//     }

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

//       log('RAW → ${resp.data}');
//       log('TYPE → ${resp.data.runtimeType}');

//       dynamic jsonData = resp.data;
//       if (jsonData is String) {
//         try {
//           jsonData = jsonDecode(jsonData);
//         } catch (e) {
//           log('JSON PARSE FAILED: $e');
//           emit(StockLedgerFailure('Invalid JSON'));
//           return;
//         }
//       }

//       if (jsonData is! Map<String, dynamic>) {
//         log('NOT A MAP: $jsonData');
//         emit(StockLedgerFailure('Invalid response'));
//         return;
//       }

//       log('PARSED JSON → $jsonData'); // ADD THIS LINE

//       if (jsonData['success'] == true) {
//         final report = StockLedgerReport.fromJson(jsonData);
//         log('REPORT → data: ${report.data}'); // ADD THIS LINE
//         emit(StockLedgerSuccess(report));
//       } else {
//         emit(StockLedgerFailure(jsonData['message'] ?? 'Failed'));
//       }
//     } catch (e, s) {
//       log('ERROR', error: e, stackTrace: s);
//       emit(StockLedgerFailure('Check internet'));
//     }
//   }
// // }import 'dart:convert';import 'dart:convert';
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

//   Future<void> _loadFilters(
//       FetchFilterOptions event, Emitter<StockLedgerState> emit) async {
//     emit(StockLedgerLoading());
//     try {
//       final catResp = await dioClient.dio.get('/category/get_categories');
//       final prodResp = await dioClient.dio
//           .get('/product/get_products/', queryParameters: {'limit': 5000});

//       final cats = <CategoryData>[];
//       final catMap = <int, String>{};
//       final prods = <ProductData>[];
//       final prodMap = <int, String>{};

//       for (var c in catResp.data['data']) {
//         final cat = CategoryData(id: c['id'], name: c['name']);
//         cats.add(cat);
//         catMap[cat.id] = cat.name;
//       }

//       for (var p in prodResp.data['data']['results']) {
//         final prod = ProductData(id: p['id'], name: p['name']);
//         prods.add(prod);
//         prodMap[prod.id] = prod.name;
//       }

//       emit(FilterOptionsLoaded(
//         products: prods,
//         categories: cats,
//         productMap: prodMap,
//         categoryMap: catMap,
//       ));
//     } catch (e) {
//       emit(StockLedgerFailure('Failed to load filters: $e'));
//     }
//   }

//   Future<void> _loadReport(
//       FetchStockLedgerReport event, Emitter<StockLedgerState> emit) async {
//     emit(StockLedgerLoading());

//     if (event.productId == null && event.categoryId == null) {
//       emit(StockLedgerFailure('Select Product or Category'));
//       return;
//     }

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

//       if (raw is String) {
//         try {
//           raw = jsonDecode(raw);
//         } catch (e) {
//           log('JSON DECODE FAILED → $e');
//           emit(StockLedgerFailure('Invalid JSON from server'));
//           return;
//         }
//       }

//       if (raw is! Map<String, dynamic>) {
//         log('NOT A MAP → $raw');
//         emit(StockLedgerFailure('Unexpected response format'));
//         return;
//       }

//       log('PARSED JSON → $raw');

//       final bool success = raw['success'] as bool? ?? false;
//       final String message = raw['message'] as String? ?? 'Unknown error';

//       if (!success) {
//         emit(StockLedgerFailure(message));
//         return;
//       }

//       final dataJson = raw['data'];
//       if (dataJson is! Map<String, dynamic>) {
//         log('data is not a map: $dataJson');
//         emit(StockLedgerFailure('Invalid data structure'));
//         return;
//       }

//       // ---------- Extract product name ----------
//       String? productName;
//       for (final list in [
//         dataJson['purchases'],
//         dataJson['purchase_returns'],
//         dataJson['sales'],
//         dataJson['sale_returns'],
//       ]) {
//         if (list is List && list.isNotEmpty) {
//           productName = list.first['product_name'] as String?;
//           break;
//         }
//       }

//       final Map<String, StockLedgerEntry> ledgerMap = {};

//       void addEntry(
//         String date, {
//         double? opening,
//         double? purchase,
//         double? purchaseReturn,
//         double? sale,
//         double? saleReturn,
//         double? costPrice,
//         double? sellingPrice,
//       }) {
//         final key = date.split('T').first;
//         final existing = ledgerMap[key] ?? StockLedgerEntry(date: key);
//         ledgerMap[key] = StockLedgerEntry(
//           date: key,
//           opening: opening ?? existing.opening,
//           purchase: (existing.purchase ?? 0) + (purchase ?? 0),
//           sales: (existing.sales ?? 0) + (sale ?? 0),
//           closing: existing.closing,
//           costPrice: costPrice ?? existing.costPrice,
//           sellingPrice: sellingPrice ?? existing.sellingPrice,
//         );
//       }

//       // ---------- Helper that returns **double** ----------
//       void processList(
//         List<dynamic>? list, {
//         required double Function(Map<String, dynamic>) getQty,
//         double Function(Map<String, dynamic>)? getCost,
//         double Function(Map<String, dynamic>)? getSelling,
//         required bool isPurchase,
//       }) {
//         if (list == null) return;
//         for (final item in list) {
//           if (item is! Map<String, dynamic>) continue;
//           final date =
//               item['date'] as String? ?? item['voucher_date'] as String?;
//           if (date == null) continue;

//           final qty = getQty(item);
//           final cost = getCost?.call(item) ?? 0.0;
//           final sell = getSelling?.call(item) ?? 0.0;

//           addEntry(
//             date,
//             purchase: isPurchase ? qty : null,
//             purchaseReturn: isPurchase ? null : (qty > 0 ? qty : null),
//             sale: !isPurchase && qty < 0 ? -qty : null,
//             saleReturn: !isPurchase && qty > 0 ? qty : null,
//             costPrice: cost,
//             sellingPrice: sell,
//           );
//         }
//       }

//       // ---------- Process all transaction types ----------
//       processList(
//         dataJson['purchases'] as List<dynamic>?,
//         getQty: (m) => (m['quantity'] as num?)?.toDouble() ?? 0.0,
//         getCost: (m) => (m['cost_price'] as num?)?.toDouble() ?? 0.0,
//         isPurchase: true,
//       );
//       processList(
//         dataJson['purchase_returns'] as List<dynamic>?,
//         getQty: (m) => -((m['quantity'] as num?)?.toDouble() ?? 0.0),
//         getCost: (m) => (m['cost_price'] as num?)?.toDouble() ?? 0.0,
//         isPurchase: true,
//       );
//       processList(
//         dataJson['sales'] as List<dynamic>?,
//         getQty: (m) => -((m['quantity'] as num?)?.toDouble() ?? 0.0),
//         getCost: (m) => (m['cost_price'] as num?)?.toDouble() ?? 0.0,
//         getSelling: (m) => (m['selling_price'] as num?)?.toDouble() ?? 0.0,
//         isPurchase: false,
//       );
//       processList(
//         dataJson['sale_returns'] as List<dynamic>?,
//         getQty: (m) => (m['quantity'] as num?)?.toDouble() ?? 0.0,
//         getCost: (m) => (m['cost_price'] as num?)?.toDouble() ?? 0.0,
//         getSelling: (m) => (m['selling_price'] as num?)?.toDouble() ?? 0.0,
//         isPurchase: false,
//       );

//       // ---------- Opening stock ----------
//       final openingStock = dataJson['opening_stock'] as Map<String, dynamic>?;
//       if (openingStock != null) {
//         final summary = openingStock['summary'] as List<dynamic>?;
//         if (summary != null && summary.isNotEmpty) {
//           final item = summary.first as Map<String, dynamic>;
//           addEntry(
//             from,
//             opening: (item['quantity'] as num?)?.toDouble() ?? 0.0,
//             costPrice: (item['cost_price'] as num?)?.toDouble() ?? 0.0,
//           );
//         }
//       }

//       // ---------- Closing stock ----------
//       final closingStock = dataJson['closing_stock'] as Map<String, dynamic>?;
//       if (closingStock != null) {
//         final summary = closingStock['summary'] as List<dynamic>?;
//         if (summary != null && summary.isNotEmpty) {
//           final item = summary.first as Map<String, dynamic>;
//           final entry = ledgerMap[to] ?? StockLedgerEntry(date: to);
//           ledgerMap[to] = StockLedgerEntry(
//             date: to,
//             opening: entry.opening,
//             purchase: entry.purchase,
//             sales: entry.sales,
//             closing: (item['quantity'] as num?)?.toDouble() ?? 0.0,
//             costPrice: (item['cost_price'] as num?)?.toDouble() ?? 0.0,
//             sellingPrice: (item['selling_price'] as num?)?.toDouble() ?? 0.0,
//           );
//         }
//       }

//       // ---------- Sort by date ----------
//       final sortedEntries = ledgerMap.values.toList()
//         ..sort((a, b) => (a.date ?? '').compareTo(b.date ?? ''));

//       // ---------- Compute running closing ----------
//       double running = 0.0;
//       for (final e in sortedEntries) {
//         final open = e.opening ?? 0.0;
//         final inflow = e.purchase ?? 0.0;
//         final outflow = e.sales ?? 0.0;
//         running = open + inflow - outflow;
//         e.closing = running;
//       }

//       final account = StockLedgerAccount(
//         productName: productName ?? 'Unknown Product',
//         ledger: sortedEntries,
//       );

//       final report = StockLedgerReport(
//         success: true,
//         message: message,
//         data: [account],
//       );

//       log('REPORT → 1 account, ${sortedEntries.length} ledger entries');
//       emit(StockLedgerSuccess(report));
//     } catch (e, s) {
//       log('UNEXPECTED ERROR', error: e, stackTrace: s);
//       emit(StockLedgerFailure('Failed to process data'));
//     }
//   }
// }

// lib/screen/stock_ledger/bloc/stock_ledger_bloc.dart

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

//   Future<void> _loadFilters(
//       FetchFilterOptions event, Emitter<StockLedgerState> emit) async {
//     emit(StockLedgerLoading());
//     try {
//       final catResp = await dioClient.dio.get('/category/get_categories');
//       final prodResp = await dioClient.dio
//           .get('/product/get_products/', queryParameters: {'limit': 5000});

//       final cats = <CategoryData>[];
//       final catMap = <int, String>{};
//       final prods = <ProductData>[];
//       final prodMap = <int, String>{};

//       for (var c in catResp.data['data']) {
//         final cat = CategoryData(id: c['id'], name: c['name']);
//         cats.add(cat);
//         catMap[cat.id] = cat.name;
//       }

//       for (var p in prodResp.data['data']['results']) {
//         final prod = ProductData(id: p['id'], name: p['name']);
//         prods.add(prod);
//         prodMap[prod.id] = prod.name;
//       }

//       emit(FilterOptionsLoaded(
//         products: prods,
//         categories: cats,
//         productMap: prodMap,
//         categoryMap: catMap,
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

//     if (event.productId == null && event.categoryId == null) {
//       emit(StockLedgerFailure('Select Product or Category'));
//       return;
//     }

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
//         emit(StockLedgerFailure('Invalid response format'));
//         return;
//       }

//       final success = raw['success'] as bool? ?? false;
//       final message = raw['message'] as String? ?? 'Unknown error';
//       if (!success) {
//         emit(StockLedgerFailure(message));
//         return;
//       }

//       final dataJson = raw['data'] as Map<String, dynamic>;

//       // Extract product name
//       String? productName;
//       for (final list in [
//         dataJson['purchases'],
//         dataJson['purchase_returns'],
//         dataJson['sales'],
//         dataJson['sale_returns'],
//       ]) {
//         if (list is List && list.isNotEmpty) {
//           productName = list.first['product_name'] as String?;
//           break;
//         }
//       }

//       final ledgerMap = <String, StockLedgerEntry>{};

//       void addEntry(String date,
//           {double? opening,
//           double? purchase,
//           double? sale,
//           double? costPrice,
//           double? sellingPrice}) {
//         final key = date.split('T').first;
//         final existing = ledgerMap[key] ?? StockLedgerEntry(date: key);

//         ledgerMap[key] = StockLedgerEntry(
//           date: key,
//           opening: opening ?? existing.opening,
//           purchase: (existing.purchase ?? 0) + (purchase ?? 0),
//           sales: (existing.sales ?? 0) + (sale ?? 0),
//           closing: existing.closing,
//           costPrice: costPrice ?? existing.costPrice,
//           sellingPrice: sellingPrice ?? existing.sellingPrice,
//         );
//       }

//       // Global cost price from closing stock
//       double globalCostPrice = 0.0;
//       final closingStock = dataJson['closing_stock'] as Map<String, dynamic>?;
//       if (closingStock != null) {
//         final summary = closingStock['summary'] as List<dynamic>?;
//         if (summary != null && summary.isNotEmpty) {
//           final item = summary.first;
//           globalCostPrice = (item['cost_price'] as num?)?.toDouble() ?? 0.0;
//         }
//       }
//       log('GLOBAL COST PRICE → $globalCostPrice');

//       // Process transactions
//       void processList(
//         List<dynamic>? list, {
//         required double Function(Map<String, dynamic>) getQty,
//         double Function(Map<String, dynamic>)? getCost,
//         double Function(Map<String, dynamic>)? getSelling,
//         required bool isPurchase,
//       }) {
//         if (list == null) return;
//         for (final item in list) {
//           if (item is! Map<String, dynamic>) continue;
//           final date = item['date'] as String? ?? from;
//           final qty = getQty(item);
//           final cost = getCost?.call(item) ?? 0.0;
//           final sell = getSelling?.call(item) ?? 0.0;

//           if (isPurchase) {
//             addEntry(date, purchase: qty, costPrice: cost);
//           } else {
//             addEntry(date, sale: qty < 0 ? -qty : qty, sellingPrice: sell);
//           }
//         }
//       }

//       // Purchases
//       processList(
//         dataJson['purchases'] as List<dynamic>?,
//         getQty: (m) => (m['quantity'] as num?)?.toDouble() ?? 0.0,
//         getCost: (m) => globalCostPrice,
//         isPurchase: true,
//       );

//       // Purchase Returns
//       processList(
//         dataJson['purchase_returns'] as List<dynamic>?,
//         getQty: (m) => -((m['quantity'] as num?)?.toDouble() ?? 0.0),
//         getCost: (m) => globalCostPrice,
//         isPurchase: true,
//       );

//       // Sales
//       processList(
//         dataJson['sales'] as List<dynamic>?,
//         getQty: (m) => -((m['quantity'] as num?)?.toDouble() ?? 0.0),
//         getCost: (m) => globalCostPrice,
//         getSelling: (m) {
//           final sp = m['selling_price'];
//           return sp is String
//               ? (double.tryParse(sp) ?? 0.0)
//               : (sp as num?)?.toDouble() ?? 0.0;
//         },
//         isPurchase: false,
//       );

//       // Sale Returns
//       processList(
//         dataJson['sale_returns'] as List<dynamic>?,
//         getQty: (m) => (m['quantity'] as num?)?.toDouble() ?? 0.0,
//         getCost: (m) => globalCostPrice,
//         getSelling: (m) {
//           final sp = m['selling_price'];
//           return sp is String
//               ? (double.tryParse(sp) ?? 0.0)
//               : (sp as num?)?.toDouble() ?? 0.0;
//         },
//         isPurchase: false,
//       );

//       // Opening Stock
//       final openingStock = dataJson['opening_stock'] as Map<String, dynamic>?;
//       if (openingStock != null) {
//         final summary = openingStock['summary'] as List<dynamic>?;
//         if (summary != null && summary.isNotEmpty) {
//           final item = summary.first;
//           final qty = (item['quantity'] as num?)?.toDouble() ?? 0.0;
//           addEntry(from, opening: qty, costPrice: globalCostPrice);
//         }
//       }

//       // Closing Stock
//       if (closingStock != null) {
//         final summary = closingStock['summary'] as List<dynamic>?;
//         if (summary != null && summary.isNotEmpty) {
//           final item = summary.first;
//           final qty = (item['quantity'] as num?)?.toDouble() ?? 0.0;
//           final entry = ledgerMap[to] ?? StockLedgerEntry(date: to);
//           ledgerMap[to] = StockLedgerEntry(
//             date: to,
//             opening: entry.opening,
//             purchase: entry.purchase,
//             sales: entry.sales,
//             closing: qty,
//             costPrice: globalCostPrice,
//             sellingPrice: entry.sellingPrice,
//           );
//         }
//       }

//       // Sort entries
//       final sorted = ledgerMap.values.toList()
//         ..sort((a, b) => (a.date ?? '').compareTo(b.date ?? ''));

//       // Compute running balance
//       double running = 0.0;
//       for (final e in sorted) {
//         final inflow = (e.opening ?? 0) + (e.purchase ?? 0);
//         final outflow = e.sales ?? 0;
//         running = inflow - outflow;
//         e.closing = running;
//       }

//       final account = StockLedgerAccount(
//           productName: productName ?? 'Unknown', ledger: sorted);
//       final report =
//           StockLedgerReport(success: true, message: message, data: [account]);

//       log('SUCCESS → ${sorted.length} entries, closing: ${sorted.last.closing}');
//       emit(StockLedgerSuccess(report, raw));
//     } catch (e, s) {
//       log('ERROR', error: e, stackTrace: s);
//       emit(StockLedgerFailure('Failed: $e'));
//     }
//   }
// }
// lib/screen/stock_ledger/bloc/stock_ledger_bloc.dart

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

//   Future<void> _loadFilters(
//       FetchFilterOptions event, Emitter<StockLedgerState> emit) async {
//     emit(StockLedgerLoading());
//     try {
//       final catResp = await dioClient.dio.get('/category/get_categories');
//       final prodResp = await dioClient.dio
//           .get('/product/get_products/', queryParameters: {'limit': 5000});

//       final cats = <CategoryData>[];
//       final catMap = <int, String>{};
//       final prods = <ProductData>[];
//       final prodMap = <int, String>{};

//       for (var c in catResp.data['data']) {
//         final cat = CategoryData(id: c['id'], name: c['name']);
//         cats.add(cat);
//         catMap[cat.id] = cat.name;
//       }

//       for (var p in prodResp.data['data']['results']) {
//         final prod = ProductData(id: p['id'], name: p['name']);
//         prods.add(prod);
//         prodMap[prod.id] = prod.name;
//       }

//       emit(FilterOptionsLoaded(
//         products: prods,
//         categories: cats,
//         productMap: prodMap,
//         categoryMap: catMap,
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
//         emit(StockLedgerFailure('Invalid response format'));
//         return;
//       }

//       final success = raw['success'] as bool? ?? false;
//       final message = raw['message'] as String? ?? 'Unknown error';
//       if (!success) {
//         emit(StockLedgerFailure(message));
//         return;
//       }

//       final dataJson = raw['data'] as Map<String, dynamic>;

//       // === SUPPORT "ALL PRODUCTS" - COLLECT ALL PRODUCTS INTO ONE MAP ===
//       final Map<String, Map<String, dynamic>> productLedgerMap = {};

//       void addToProduct(String productName, Map<String, dynamic> update) {
//         productName = productName.trim();
//         if (!productLedgerMap.containsKey(productName)) {
//           productLedgerMap[productName] = {
//             'product_name': productName,
//             'opening_qty': 0.0,
//             'opening_rate': 0.0,
//             'opening_amount': 0.0,
//             'purchase_qty': 0.0,
//             'purchase_rate': 0.0,
//             'purchase_amount': 0.0,
//             'purchase_return_qty': 0.0,
//             'purchase_return_rate': 0.0,
//             'purchase_return_amount': 0.0,
//             'sales_qty': 0.0,
//             'sales_rate': 0.0,
//             'sales_amount': 0.0,
//             'sales_return_qty': 0.0,
//             'sales_return_rate': 0.0,
//             'sales_return_amount': 0.0,
//             'closing_qty': 0.0,
//             'closing_rate': 0.0,
//             'closing_amount': 0.0,
//           };
//         }
//         final entry = productLedgerMap[productName]!;
//         update.forEach((key, value) {
//           if (value is num) {
//             entry[key] = (entry[key] as num) + value;
//           } else {
//             entry[key] = value;
//           }
//         });
//       }

//       void processItems(
//         List<dynamic>? items,
//         String type, {
//         required String qtyKey,
//         required String rateKey,
//         bool negativeQty = false,
//       }) {
//         if (items == null) return;
//         for (final item in items) {
//           final productName = (item['product_name'] ??
//               item['product']?['name'] ??
//               'Unknown') as String;
//           final qty = (item[qtyKey] as num?)?.toDouble() ?? 0.0;
//           final rate = (item[rateKey] as num?)?.toDouble() ?? 0.0;
//           final amount = qty * rate;

//           final update = <String, dynamic>{
//             '${type}_qty': negativeQty ? -qty : qty,
//             '${type}_rate': rate,
//             '${type}_amount': negativeQty ? -amount : amount,
//           };
//           addToProduct(productName, update);
//         }
//       }

//       // Process all sections
//       processItems(dataJson['opening_stock']?['summary'], 'opening',
//           qtyKey: 'quantity', rateKey: 'cost_price');
//       processItems(dataJson['purchases'], 'purchase',
//           qtyKey: 'quantity', rateKey: 'cost_price');
//       processItems(dataJson['purchase_returns'], 'purchase_return',
//           qtyKey: 'quantity', rateKey: 'cost_price', negativeQty: true);
//       processItems(dataJson['sales'], 'sales',
//           qtyKey: 'quantity',
//           rateKey: event.rateType == 'cost' ? 'cost_price' : 'selling_price',
//           negativeQty: true);
//       processItems(dataJson['sale_returns'], 'sales_return',
//           qtyKey: 'quantity',
//           rateKey: event.rateType == 'cost' ? 'cost_price' : 'selling_price');
//       processItems(dataJson['closing_stock']?['summary'], 'closing',
//           qtyKey: 'quantity', rateKey: 'cost_price');

//       // Convert to list of accounts
//       final accounts = productLedgerMap.values.map((data) {
//         return StockLedgerAccount(
//           productName: data['product_name'] as String,
//           ledger: [
//             StockLedgerEntry(
//               date: to,
//               opening: data['opening_qty'] as double,
//               purchase: data['purchase_qty'] as double,
//               sales: data['sales_qty'] as double,
//               closing: data['closing_qty'] as double,
//               costPrice: data['opening_rate'] as double,
//               sellingPrice: data['sales_rate'] as double,
//             )
//           ],
//         );
//       }).toList();

//       final report = StockLedgerReport(
//         success: true,
//         message: 'Success',
//         data: accounts.isNotEmpty ? accounts : null,
//       );

//       emit(StockLedgerSuccess(report, raw));
//     } catch (e, s) {
//       log('ERROR', error: e, stackTrace: s);
//       emit(StockLedgerFailure('Failed: $e'));
//     }
//   }
// }
// lib/screen/stock_ledger/bloc/stock_ledger_bloc.dart

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

//   // ──────────────────────────────────────────────────────────────
//   // SAFE DOUBLE PARSER (handles String, int, double, null)
//   // ──────────────────────────────────────────────────────────────
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

//   Future<void> _loadFilters(
//       FetchFilterOptions event, Emitter<StockLedgerState> emit) async {
//     emit(StockLedgerLoading());
//     try {
//       final catResp = await dioClient.dio.get('/category/get_categories');
//       final prodResp = await dioClient.dio
//           .get('/product/get_products/', queryParameters: {'limit': 5000});

//       final cats = <CategoryData>[];
//       final catMap = <int, String>{};
//       final prods = <ProductData>[];
//       final prodMap = <int, String>{};

//       for (var c in catResp.data['data']) {
//         final cat = CategoryData(id: c['id'], name: c['name']);
//         cats.add(cat);
//         catMap[cat.id] = cat.name;
//       }

//       for (var p in prodResp.data['data']['results']) {
//         final prod = ProductData(id: p['id'], name: p['name']);
//         prods.add(prod);
//         prodMap[prod.id] = prod.name;
//       }

//       emit(FilterOptionsLoaded(
//         products: prods,
//         categories: cats,
//         productMap: prodMap,
//         categoryMap: catMap,
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
//         emit(StockLedgerFailure('Invalid response format'));
//         return;
//       }

//       final success = raw['success'] as bool? ?? false;
//       final message = raw['message'] as String? ?? 'Unknown error';
//       if (!success) {
//         emit(StockLedgerFailure(message));
//         return;
//       }

//       final dataJson = raw['data'] as Map<String, dynamic>;

//       // ──────────────────────────────────────────────────────────────
//       // AGGREGATE ALL PRODUCTS (Supports "All Products" like web)
//       // ──────────────────────────────────────────────────────────────
//       final Map<String, Map<String, dynamic>> aggregated = {};

//       void addEntry(String productName, Map<String, dynamic> updates) {
//         productName = productName.trim();
//         if (!aggregated.containsKey(productName)) {
//           aggregated[productName] = {
//             'product_name': productName,
//             'opening_qty': 0.0,
//             'opening_amount': 0.0,
//             'purchase_qty': 0.0,
//             'purchase_amount': 0.0,
//             'purchase_return_qty': 0.0,
//             'purchase_return_amount': 0.0,
//             'sales_qty': 0.0,
//             'sales_amount': 0.0,
//             'sales_return_qty': 0.0,
//             'sales_return_amount': 0.0,
//             'closing_qty': 0.0,
//             'closing_amount': 0.0,
//           };
//         }
//         final entry = aggregated[productName]!;
//         updates.forEach((key, value) {
//           if (value is num) {
//             entry[key] = (entry[key] as num) + value;
//           }
//         });
//       }

//       void processList(
//         List<dynamic>? list,
//         String prefix, {
//         required String qtyKey,
//         required String rateKey,
//         bool negative = false,
//       }) {
//         if (list == null || list.isEmpty) return;
//         for (final item in list) {
//           final name = (item['product_name'] ??
//               item['product']?['name'] ??
//               'Unknown Product') as String;

//           final qty = safeDouble(item[qtyKey]);
//           final rate = safeDouble(item[rateKey]);
//           final amount = qty * rate;

//           addEntry(name, {
//             '${prefix}_qty': negative ? -qty : qty,
//             '${prefix}_amount': negative ? -amount : amount,
//           });
//         }
//       }

//       // ──────────────────────────────────────────────────────────────
//       // PROCESS ALL SECTIONS SAFELY
//       // ──────────────────────────────────────────────────────────────
//       processList(
//         dataJson['opening_stock']?['summary'],
//         'opening',
//         qtyKey: 'quantity',
//         rateKey: 'cost_price',
//       );

//       processList(
//         dataJson['purchases'],
//         'purchase',
//         qtyKey: 'quantity',
//         rateKey: 'cost_price',
//       );

//       processList(
//         dataJson['purchase_returns'],
//         'purchase_return',
//         qtyKey: 'quantity',
//         rateKey: 'cost_price',
//         negative: true,
//       );

//       processList(
//         dataJson['sales'],
//         'sales',
//         qtyKey: 'quantity',
//         rateKey: event.rateType == 'cost' ? 'cost_price' : 'selling_price',
//         negative: true,
//       );

//       processList(
//         dataJson['sale_returns'],
//         'sales_return',
//         qtyKey: 'quantity',
//         rateKey: event.rateType == 'cost' ? 'cost_price' : 'selling_price',
//       );

//       processList(
//         dataJson['closing_stock']?['summary'],
//         'closing',
//         qtyKey: 'quantity',
//         rateKey: 'cost_price',
//       );

//       // ──────────────────────────────────────────────────────────────
//       // BUILD FINAL REPORT
//       // ──────────────────────────────────────────────────────────────
//       final accounts = aggregated.values.map((data) {
//         return StockLedgerAccount(
//           productName: data['product_name'] as String,
//           ledger: [
//             StockLedgerEntry(
//               date: to,
//               opening: data['opening_qty'] as double,
//               purchase: data['purchase_qty'] as double,
//               sales: data['sales_qty'] as double,
//               closing: data['closing_qty'] as double,
//               costPrice: 1.0,
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
//       log('SUCCESS → ${accounts.length} products loaded');
//     } catch (e, s) {
//       log('ERROR', error: e, stackTrace: s);
//       emit(StockLedgerFailure('Failed to load report: $e'));
//     }
//   }
// }
// lib/screen/stock_ledger/bloc/stock_ledger_bloc.dart

import 'dart:convert';
import 'dart:developer';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:saleup_app/core/network/dio_client.dart';
import 'package:saleup_app/model/product_category_response.dart';
import 'package:saleup_app/model/stock_ledger_response.dart';
import 'stock_ledger_event.dart';
import 'stock_ledger_state.dart';

class StockLedgerBloc extends Bloc<StockLedgerEvent, StockLedgerState> {
  final DioClient dioClient;

  StockLedgerBloc({required this.dioClient}) : super(StockLedgerInitial()) {
    on<FetchFilterOptions>(_loadFilters);
    on<FetchStockLedgerReport>(_loadReport);
  }

  // SAFELY PARSE ANY NUMBER (String, int, double)
  double safeDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    if (value is String) {
      final cleaned = value.trim();
      if (cleaned.isEmpty) return 0.0;
      return double.tryParse(cleaned) ?? 0.0;
    }
    return 0.0;
  }

  // CRITICAL FIX: Correctly get product name in ALL cases
  String getProductName(dynamic item) {
    // Case 1: When filtering by product/category → has 'product_name'
    if (item['product_name'] != null) {
      return (item['product_name'] as String).trim();
    }
    // Case 2: When "All Products" → has 'product': { 'name': '...' }
    if (item['product'] != null && item['product'] is Map) {
      return (item['product']['name'] ?? 'Unknown Product').toString().trim();
    }
    // Fallback
    return 'Unknown Product';
  }

  Future<void> _loadFilters(
      FetchFilterOptions event, Emitter<StockLedgerState> emit) async {
    emit(StockLedgerLoading());
    try {
      final catResp = await dioClient.dio.get('/category/get_categories');
      final prodResp = await dioClient.dio
          .get('/product/get_products/', queryParameters: {'limit': 5000});

      final cats = <CategoryData>[];
      final prods = <ProductData>[];

      for (var c in catResp.data['data']) {
        cats.add(CategoryData(id: c['id'], name: c['name']));
      }
      for (var p in prodResp.data['data']['results']) {
        prods.add(ProductData(id: p['id'], name: p['name']));
      }

      emit(FilterOptionsLoaded(
        products: prods,
        categories: cats,
        productMap: {},
        categoryMap: {},
      ));
    } catch (e) {
      emit(StockLedgerFailure('Failed to load filters: $e'));
    }
  }

  Future<void> _loadReport(
    FetchStockLedgerReport event,
    Emitter<StockLedgerState> emit,
  ) async {
    emit(StockLedgerLoading());

    final from = event.startDate ??
        DateFormat('yyyy-MM-dd')
            .format(DateTime.now().subtract(const Duration(days: 30)));
    final to = event.endDate ?? DateFormat('yyyy-MM-dd').format(DateTime.now());

    final params = <String, String>{
      'start_date': from,
      'end_date': to,
      if (event.productId != null) 'product_id': event.productId.toString(),
      if (event.categoryId != null) 'category_id': event.categoryId.toString(),
    };

    log('SENDING → $params');

    try {
      final resp = await dioClient.dio.get(
        '/ledger/get_stock_ledger/',
        queryParameters: params,
      );

      dynamic raw = resp.data;
      if (raw is String) raw = jsonDecode(raw);
      if (raw is! Map<String, dynamic>) {
        emit(StockLedgerFailure('Invalid response'));
        return;
      }

      if (!(raw['success'] as bool? ?? false)) {
        emit(StockLedgerFailure(raw['message'] ?? 'Failed'));
        return;
      }

      final dataJson = raw['data'] as Map<String, dynamic>;

      // PRODUCT → TOTALS MAP
      final Map<String, Map<String, double>> productTotals = {};

      void add(
          String name, String qtyKey, double qty, String valKey, double val) {
        name = name.trim();
        productTotals.putIfAbsent(
            name,
            () => {
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
                });

        final t = productTotals[name]!;
        t[qtyKey] = (t[qtyKey] ?? 0.0) + qty;
        t[valKey] = (t[valKey] ?? 0.0) + val;
      }

      void process(
        List<dynamic>? list,
        String qtyKey,
        String rateKey,
        String totalQtyKey,
        String totalValKey, {
        bool negative = false,
      }) {
        if (list == null || list.isEmpty) return;
        for (final item in list) {
          final name = getProductName(item);
          final qty = safeDouble(item[qtyKey]);
          final rate = safeDouble(item[rateKey]);
          final val = qty * rate;

          add(
            name,
            totalQtyKey,
            negative ? -qty : qty,
            totalValKey,
            negative ? -val : val,
          );
        }
      }

      // PROCESS EVERY SECTION
      process(dataJson['opening_stock']?['summary'], 'quantity', 'cost_price',
          'opening_qty', 'opening_val');

      process(dataJson['purchases'], 'quantity', 'cost_price', 'purchase_qty',
          'purchase_val');

      process(dataJson['purchase_returns'], 'quantity', 'cost_price',
          'pur_ret_qty', 'pur_ret_val',
          negative: true);

      process(
          dataJson['sales'],
          'quantity',
          event.rateType == 'cost' ? 'cost_price' : 'selling_price',
          'sales_qty',
          'sales_val',
          negative: true);

      process(
          dataJson['sale_returns'],
          'quantity',
          event.rateType == 'cost' ? 'cost_price' : 'selling_price',
          'sales_ret_qty',
          'sales_ret_val');

      process(dataJson['closing_stock']?['summary'], 'quantity', 'cost_price',
          'closing_qty', 'closing_val');

      // BUILD FINAL LIST – ONE ROW PER PRODUCT
      final accounts = productTotals.entries.map((e) {
        final name = e.key;
        final t = e.value;

        return StockLedgerAccount(
          productName: name,
          ledger: [
            StockLedgerEntry(
              date: to,
              opening: t['opening_qty']!,
              purchase: t['purchase_qty']!,
              sales: t['sales_qty']!,
              closing: t['closing_qty']!,
              costPrice: t['closing_qty']! > 0
                  ? t['closing_val']! / t['closing_qty']!
                  : 0.0,
              sellingPrice: 0.0,
            ),
          ],
        );
      }).toList();

      final report = StockLedgerReport(
        success: true,
        message: 'Success',
        data: accounts.isNotEmpty ? accounts : null,
      );

      emit(StockLedgerSuccess(report, raw));
      log('ALL PRODUCTS LOADED → ${accounts.length} products (PDF/Excel will have ALL)');
    } catch (e, s) {
      log('ERROR', error: e, stackTrace: s);
      emit(StockLedgerFailure('Failed: $e'));
    }
  }
}
