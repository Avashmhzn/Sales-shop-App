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
// }import 'dart:convert';import 'dart:convert';
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

  Future<void> _loadFilters(
      FetchFilterOptions event, Emitter<StockLedgerState> emit) async {
    emit(StockLedgerLoading());
    try {
      final catResp = await dioClient.dio.get('/category/get_categories');
      final prodResp = await dioClient.dio
          .get('/product/get_products/', queryParameters: {'limit': 5000});

      final cats = <CategoryData>[];
      final catMap = <int, String>{};
      final prods = <ProductData>[];
      final prodMap = <int, String>{};

      for (var c in catResp.data['data']) {
        final cat = CategoryData(id: c['id'], name: c['name']);
        cats.add(cat);
        catMap[cat.id] = cat.name;
      }

      for (var p in prodResp.data['data']['results']) {
        final prod = ProductData(id: p['id'], name: p['name']);
        prods.add(prod);
        prodMap[prod.id] = prod.name;
      }

      emit(FilterOptionsLoaded(
        products: prods,
        categories: cats,
        productMap: prodMap,
        categoryMap: catMap,
      ));
    } catch (e) {
      emit(StockLedgerFailure('Failed to load filters: $e'));
    }
  }

  Future<void> _loadReport(
      FetchStockLedgerReport event, Emitter<StockLedgerState> emit) async {
    emit(StockLedgerLoading());

    if (event.productId == null && event.categoryId == null) {
      emit(StockLedgerFailure('Select Product or Category'));
      return;
    }

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

      if (raw is String) {
        try {
          raw = jsonDecode(raw);
        } catch (e) {
          log('JSON DECODE FAILED → $e');
          emit(StockLedgerFailure('Invalid JSON from server'));
          return;
        }
      }

      if (raw is! Map<String, dynamic>) {
        log('NOT A MAP → $raw');
        emit(StockLedgerFailure('Unexpected response format'));
        return;
      }

      log('PARSED JSON → $raw');

      final bool success = raw['success'] as bool? ?? false;
      final String message = raw['message'] as String? ?? 'Unknown error';

      if (!success) {
        emit(StockLedgerFailure(message));
        return;
      }

      final dataJson = raw['data'];
      if (dataJson is! Map<String, dynamic>) {
        log('data is not a map: $dataJson');
        emit(StockLedgerFailure('Invalid data structure'));
        return;
      }

      // ---------- Extract product name ----------
      String? productName;
      for (final list in [
        dataJson['purchases'],
        dataJson['purchase_returns'],
        dataJson['sales'],
        dataJson['sale_returns'],
      ]) {
        if (list is List && list.isNotEmpty) {
          productName = list.first['product_name'] as String?;
          break;
        }
      }

      final Map<String, StockLedgerEntry> ledgerMap = {};

      void addEntry(
        String date, {
        double? opening,
        double? purchase,
        double? purchaseReturn,
        double? sale,
        double? saleReturn,
        double? costPrice,
        double? sellingPrice,
      }) {
        final key = date.split('T').first;
        final existing = ledgerMap[key] ?? StockLedgerEntry(date: key);
        ledgerMap[key] = StockLedgerEntry(
          date: key,
          opening: opening ?? existing.opening,
          purchase: (existing.purchase ?? 0) + (purchase ?? 0),
          sales: (existing.sales ?? 0) + (sale ?? 0),
          closing: existing.closing,
          costPrice: costPrice ?? existing.costPrice,
          sellingPrice: sellingPrice ?? existing.sellingPrice,
        );
      }

      // ---------- Helper that returns **double** ----------
      void processList(
        List<dynamic>? list, {
        required double Function(Map<String, dynamic>) getQty,
        double Function(Map<String, dynamic>)? getCost,
        double Function(Map<String, dynamic>)? getSelling,
        required bool isPurchase,
      }) {
        if (list == null) return;
        for (final item in list) {
          if (item is! Map<String, dynamic>) continue;
          final date =
              item['date'] as String? ?? item['voucher_date'] as String?;
          if (date == null) continue;

          final qty = getQty(item);
          final cost = getCost?.call(item) ?? 0.0;
          final sell = getSelling?.call(item) ?? 0.0;

          addEntry(
            date,
            purchase: isPurchase ? qty : null,
            purchaseReturn: isPurchase ? null : (qty > 0 ? qty : null),
            sale: !isPurchase && qty < 0 ? -qty : null,
            saleReturn: !isPurchase && qty > 0 ? qty : null,
            costPrice: cost,
            sellingPrice: sell,
          );
        }
      }

      // ---------- Process all transaction types ----------
      processList(
        dataJson['purchases'] as List<dynamic>?,
        getQty: (m) => (m['quantity'] as num?)?.toDouble() ?? 0.0,
        getCost: (m) => (m['cost_price'] as num?)?.toDouble() ?? 0.0,
        isPurchase: true,
      );
      processList(
        dataJson['purchase_returns'] as List<dynamic>?,
        getQty: (m) => -((m['quantity'] as num?)?.toDouble() ?? 0.0),
        getCost: (m) => (m['cost_price'] as num?)?.toDouble() ?? 0.0,
        isPurchase: true,
      );
      processList(
        dataJson['sales'] as List<dynamic>?,
        getQty: (m) => -((m['quantity'] as num?)?.toDouble() ?? 0.0),
        getCost: (m) => (m['cost_price'] as num?)?.toDouble() ?? 0.0,
        getSelling: (m) => (m['selling_price'] as num?)?.toDouble() ?? 0.0,
        isPurchase: false,
      );
      processList(
        dataJson['sale_returns'] as List<dynamic>?,
        getQty: (m) => (m['quantity'] as num?)?.toDouble() ?? 0.0,
        getCost: (m) => (m['cost_price'] as num?)?.toDouble() ?? 0.0,
        getSelling: (m) => (m['selling_price'] as num?)?.toDouble() ?? 0.0,
        isPurchase: false,
      );

      // ---------- Opening stock ----------
      final openingStock = dataJson['opening_stock'] as Map<String, dynamic>?;
      if (openingStock != null) {
        final summary = openingStock['summary'] as List<dynamic>?;
        if (summary != null && summary.isNotEmpty) {
          final item = summary.first as Map<String, dynamic>;
          addEntry(
            from,
            opening: (item['quantity'] as num?)?.toDouble() ?? 0.0,
            costPrice: (item['cost_price'] as num?)?.toDouble() ?? 0.0,
          );
        }
      }

      // ---------- Closing stock ----------
      final closingStock = dataJson['closing_stock'] as Map<String, dynamic>?;
      if (closingStock != null) {
        final summary = closingStock['summary'] as List<dynamic>?;
        if (summary != null && summary.isNotEmpty) {
          final item = summary.first as Map<String, dynamic>;
          final entry = ledgerMap[to] ?? StockLedgerEntry(date: to);
          ledgerMap[to] = StockLedgerEntry(
            date: to,
            opening: entry.opening,
            purchase: entry.purchase,
            sales: entry.sales,
            closing: (item['quantity'] as num?)?.toDouble() ?? 0.0,
            costPrice: (item['cost_price'] as num?)?.toDouble() ?? 0.0,
            sellingPrice: (item['selling_price'] as num?)?.toDouble() ?? 0.0,
          );
        }
      }

      // ---------- Sort by date ----------
      final sortedEntries = ledgerMap.values.toList()
        ..sort((a, b) => (a.date ?? '').compareTo(b.date ?? ''));

      // ---------- Compute running closing ----------
      double running = 0.0;
      for (final e in sortedEntries) {
        final open = e.opening ?? 0.0;
        final inflow = e.purchase ?? 0.0;
        final outflow = e.sales ?? 0.0;
        running = open + inflow - outflow;
        e.closing = running;
      }

      final account = StockLedgerAccount(
        productName: productName ?? 'Unknown Product',
        ledger: sortedEntries,
      );

      final report = StockLedgerReport(
        success: true,
        message: message,
        data: [account],
      );

      log('REPORT → 1 account, ${sortedEntries.length} ledger entries');
      emit(StockLedgerSuccess(report));
    } catch (e, s) {
      log('UNEXPECTED ERROR', error: e, stackTrace: s);
      emit(StockLedgerFailure('Failed to process data'));
    }
  }
}
