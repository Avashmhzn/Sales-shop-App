// lib/screen/stock_ledger/bloc/stock_ledger_bloc.dart
import 'dart:convert'; // ← ADD THIS
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

  // Future<void> _loadReport(
  //     FetchStockLedgerReport event, Emitter<StockLedgerState> emit) async {
  //   emit(StockLedgerLoading());

  //   if (event.productId == null && event.categoryId == null) {
  //     emit(StockLedgerFailure('Select Product or Category'));
  //     return;
  //   }

  //   final from = event.startDate ??
  //       DateFormat('yyyy-MM-dd')
  //           .format(DateTime.now().subtract(const Duration(days: 30)));
  //   final to = event.endDate ?? DateFormat('yyyy-MM-dd').format(DateTime.now());

  //   final params = <String, String>{
  //     'from_date': from,
  //     'to_date': to,
  //   };

  //   if (event.productId != null) {
  //     params['product_id'] = event.productId.toString();
  //   }
  //   if (event.categoryId != null) {
  //     params['category_id'] = event.categoryId.toString();
  //   }

  //   log('SENDING → $params');

  //   try {
  //     final resp = await dioClient.dio.get(
  //       '/ledger/get_stock_ledger/',
  //       queryParameters: params,
  //     );

  //     log('RAW → ${resp.data}');

  //     // ← FIX: PARSE STRING → MAP
  //     final Map<String, dynamic> data =
  //         resp.data is String ? jsonDecode(resp.data) : resp.data;

  //     if (data['success'] == true) {
  //       emit(StockLedgerSuccess(StockLedgerReport.fromJson(data)));
  //     } else {
  //       emit(StockLedgerFailure(data['message'] ?? 'Failed'));
  //     }
  //   } catch (e, s) {
  //     log('ERROR', error: e, stackTrace: s);
  //     emit(StockLedgerFailure('Check internet'));
  //   }
  // }
  // lib/screen/stock_ledger/bloc/stock_ledger_bloc.dart
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
      'start_date': from, // ← YOUR ENDPOINT USES start_date
      'end_date': to, // ← YOUR ENDPOINT USES end_date
      if (event.productId != null) 'product_id': event.productId.toString(),
      if (event.categoryId != null) 'category_id': event.categoryId.toString(),
    };

    log('SENDING → $params');

    try {
      final resp = await dioClient.dio.get(
        '/ledger/get_stock_ledger/', // ← YOUR CONFIRMED ENDPOINT
        queryParameters: params,
      );

      log('RAW → ${resp.data}');

      final Map<String, dynamic> data =
          resp.data is String ? jsonDecode(resp.data) : resp.data;

      if (data['success'] == true) {
        emit(StockLedgerSuccess(StockLedgerReport.fromJson(data)));
      } else {
        emit(StockLedgerFailure(data['message'] ?? 'Failed'));
      }
    } catch (e, s) {
      log('ERROR', error: e, stackTrace: s);
      emit(StockLedgerFailure('Check internet'));
    }
  }
}
