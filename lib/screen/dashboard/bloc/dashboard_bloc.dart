import 'package:dio/dio.dart' as dio;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:saleup_app/core/network/dio_client.dart';
import 'package:saleup_app/model/purchase_response.dart';
import 'package:saleup_app/model/sale_response.dart';
import 'package:saleup_app/model/purchase_return_response.dart';
import 'package:saleup_app/model/sale_return_response.dart';
import 'package:saleup_app/model/fiscal_year.dart';
import 'package:saleup_app/screen/dashboard/bloc/dashboard_event.dart';
import 'package:saleup_app/screen/dashboard/bloc/dashboard_state.dart';
import 'dart:developer';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  DashboardBloc() : super(const DashboardState()) {
    on<FetchDashboardData>(_onFetchDashboardData);
    on<FetchFiscalYears>(_onFetchFiscalYears);
    on<ChangeFiscalYear>(_onChangeFiscalYear);
    on<ResetRefreshFlag>(_onResetRefreshFlag);
  }

  // ─────────────────────────────────────────────────────────────
  // FETCH FISCAL YEARS
  // ─────────────────────────────────────────────────────────────
  Future<void> _onFetchFiscalYears(
    FetchFiscalYears event,
    Emitter<DashboardState> emit,
  ) async {
    try {
      final currentRes = await DioClient().dio.get(
            '/fiscal-year/get_current_fiscal_year/',
          );

      // Guard: don't parse error response body
      if (currentRes.statusCode != 200) {
        log('get_current_fiscal_year → ${currentRes.statusCode} — no fiscal year set yet');
        emit(state.copyWith(
          currentFiscalYear: null,
          allFiscalYears: [],
        ));
        return;
      }

      final currentData = FiscalYearResponse.fromJson(currentRes.data);

      final allRes = await DioClient().dio.get(
            '/fiscal-year/get_all_fiscal_years/',
          );

      if (allRes.statusCode != 200) {
        log('get_all_fiscal_years → ${allRes.statusCode} — no fiscal years available');
        emit(state.copyWith(allFiscalYears: []));
        return;
      }

      final allData = FiscalYearListResponse.fromJson(allRes.data);

      emit(state.copyWith(
        currentFiscalYear: currentData.data,
        allFiscalYears: allData.data ?? [],
      ));
    } catch (e, stack) {
      log('Error loading fiscal years: $e\n$stack');
      emit(state.copyWith(currentFiscalYear: null, allFiscalYears: []));
    }
  }

  // ─────────────────────────────────────────────────────────────
  // CHANGE FISCAL YEAR
  // ─────────────────────────────────────────────────────────────
  Future<void> _onChangeFiscalYear(
    ChangeFiscalYear event,
    Emitter<DashboardState> emit,
  ) async {
    emit(state.copyWith(isChangingFiscalYear: true));

    try {
      final res = await DioClient().dio.post(
        '/fiscal-year/set_current_fiscal_year/',
        data: {'id': event.fiscalYearId},
      );

      final parsed = FiscalYearResponse.fromJson(res.data);
      if (!parsed.success || parsed.data == null) {
        throw Exception(parsed.message ?? 'Set fiscal year failed');
      }

      emit(state.copyWith(
        currentFiscalYear: parsed.data,
        isChangingFiscalYear: false,
        refreshDashboard: true,
      ));

      log('Fiscal year changed to ID: ${parsed.data?.id} → triggering refresh');
    } catch (e, stack) {
      log('Change fiscal year failed: $e\n$stack');
      emit(state.copyWith(isChangingFiscalYear: false));
    }
  }

  // ─────────────────────────────────────────────────────────────
  // FETCH DASHBOARD DATA
  // ─────────────────────────────────────────────────────────────
  Future<void> _onFetchDashboardData(
    FetchDashboardData event,
    Emitter<DashboardState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));

    if (state.currentFiscalYear == null ||
        state.allFiscalYears == null ||
        state.allFiscalYears!.isEmpty) {
      add(const FetchFiscalYears());
      await Future.delayed(const Duration(milliseconds: 500));
    }

    try {
      log('Dashboard fetch — baseUrl: ${DioClient().dio.options.baseUrl}');

      // ── Purchases ──────────────────────────────────────────────
      final purchaseResponse =
          await DioClient().dio.get('/purchase/get_purchases/');
      log('Purchases → Status: ${purchaseResponse.statusCode}');
      if (purchaseResponse.statusCode != 200) {
        log('Purchases → ${purchaseResponse.statusCode} — day not open, showing zeros');
        emit(state.copyWith(
          isLoading: false,
          totalPurchases: 0,
          totalVatCollected: 0,
          purchaseReturns: 0,
          totalSales: 0,
          salesReturns: 0,
          quantitySold: 0,
          totalSalesTransactions: 0,
          returnReasons: {},
          errorMessage: null,
        ));
        return;
      }
      final purchaseData = PurchaseResponse.fromJson(purchaseResponse.data);

      // ── Purchase Returns ────────────────────────────────────────
      final purchaseReturnResponse =
          await DioClient().dio.get('/purchase-return/get_purchase_returns/');
      log('Purchase Returns → Status: ${purchaseReturnResponse.statusCode}');
      if (purchaseReturnResponse.statusCode != 200) {
        log('Purchase Returns → ${purchaseReturnResponse.statusCode} — skipping');
        emit(state.copyWith(isLoading: false));
        return;
      }
      final purchaseReturnData =
          PurchaseReturnResponse.fromJson(purchaseReturnResponse.data);

      // ── Sales ───────────────────────────────────────────────────
      final saleResponse = await DioClient().dio.get('/sale/get_sales/');
      log('Sales → Status: ${saleResponse.statusCode}');
      if (saleResponse.statusCode != 200) {
        log('Sales → ${saleResponse.statusCode} — skipping');
        emit(state.copyWith(isLoading: false));
        return;
      }
      final saleData = SaleResponse.fromJson(saleResponse.data);

      // ── Sale Returns ────────────────────────────────────────────
      final saleReturnResponse =
          await DioClient().dio.get('/sale-return/get_sale_returns/');
      log('Sale Returns → Status: ${saleReturnResponse.statusCode}');
      if (saleReturnResponse.statusCode != 200) {
        log('Sale Returns → ${saleReturnResponse.statusCode} — skipping');
        emit(state.copyWith(isLoading: false));
        return;
      }
      final saleReturnData =
          SaleReturnResponse.fromJson(saleReturnResponse.data);

      // ── Calculations ────────────────────────────────────────────
      final totalPurchases = _calculateTotal(purchaseData.data as List?,
          (item) => item['total']?.toString() ?? '0');
      final totalVatCollected = _calculateTotal(
          purchaseData.data as List?, (item) => item['vat']?.toString() ?? '0');
      final purchaseReturns = _calculateTotal(purchaseReturnData.data as List?,
          (item) => item['total']?.toString() ?? '0');
      final totalSalesTransactions =
          saleData.data is List ? (saleData.data as List).length : 0;
      final totalSales = _calculateTotal(
          saleData.data as List?, (item) => item['total']?.toString() ?? '0');
      final salesReturns = _calculateTotal(saleReturnData.data as List?,
          (item) => item['total']?.toString() ?? '0');
      final quantitySold = _calculateQuantitySold(saleData.data as List?);

      final returnReasons = <String, double>{};
      if (saleReturnData.data is List && saleReturnData.data!.isNotEmpty) {
        for (var returnItem in saleReturnData.data!) {
          if (returnItem is Map<String, dynamic>) {
            final reason = returnItem['reason'] as String? ?? 'Unknown';
            final total =
                double.tryParse(returnItem['total']?.toString() ?? '0') ?? 0.0;
            returnReasons[reason] = (returnReasons[reason] ?? 0.0) + total;
          }
        }
      }
      log('Return Reasons: $returnReasons');

      emit(state.copyWith(
        isLoading: false,
        totalPurchases: totalPurchases,
        totalVatCollected: totalVatCollected,
        purchaseReturns: purchaseReturns,
        totalSalesTransactions: totalSalesTransactions,
        totalSales: totalSales,
        salesReturns: salesReturns,
        quantitySold: quantitySold,
        salesData: saleData,
        returnReasons: returnReasons,
        errorMessage: null,
      ));
    } on dio.DioException catch (e) {
      final errorMsg = e.response != null
          ? 'Server error ${e.response!.statusCode}'
          : 'Network error: ${e.message}';
      log('Dio error: $errorMsg');
      emit(state.copyWith(isLoading: false, errorMessage: errorMsg));
    } catch (e, stack) {
      log('Unexpected error: $e\n$stack');
      emit(state.copyWith(
          isLoading: false, errorMessage: 'Failed to load dashboard data'));
    }
  }

  // ─────────────────────────────────────────────────────────────
  // HELPERS
  // ─────────────────────────────────────────────────────────────
  double _calculateTotal(
      List? data, String Function(Map<String, dynamic>) getter) {
    if (data == null || data.isEmpty) return 0.0;
    return data
        .whereType<Map<String, dynamic>>()
        .map((item) => double.tryParse(getter(item)) ?? 0.0)
        .fold(0.0, (sum, v) => sum + v);
  }

  int _calculateQuantitySold(List? data) {
    if (data == null || data.isEmpty) return 0;
    return data.whereType<Map<String, dynamic>>().map((e) {
      final items = e['items'] as List?;
      if (items == null) return 0;
      return items
          .whereType<Map<String, dynamic>>()
          .fold<int>(0, (sum, i) => sum + (i['quantity'] as int? ?? 0));
    }).fold(0, (sum, qty) => sum + qty);
  }

  Future<void> _onResetRefreshFlag(
    ResetRefreshFlag event,
    Emitter<DashboardState> emit,
  ) async {
    emit(state.copyWith(refreshDashboard: false));
  }
}
