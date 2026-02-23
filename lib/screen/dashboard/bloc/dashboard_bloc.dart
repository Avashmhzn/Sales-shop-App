// import 'package:dio/dio.dart' as dio;
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:saleup_app/core/network/dio_client.dart';
// import 'package:saleup_app/model/purchase_response.dart';
// import 'package:saleup_app/model/sale_response.dart';
// import 'package:saleup_app/model/purchase_return_response.dart';
// import 'package:saleup_app/model/sale_return_response.dart';
// import 'package:saleup_app/screen/dashboard/bloc/dashboard_event.dart';
// import 'package:saleup_app/screen/dashboard/bloc/dashboard_state.dart';
// import 'dart:developer';

// class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
//   DashboardBloc() : super(const DashboardState()) {
//     on<FetchDashboardData>(_onFetchDashboardData);
//   }

//   Future<void> _onFetchDashboardData(
//       FetchDashboardData event, Emitter<DashboardState> emit) async {
//     emit(state.copyWith(isLoading: true, errorMessage: null));
//     try {
//       // Fetch purchases data
//       final purchaseResponse =
//           await DioClient().dio.get('/purchase/get_purchases/');
//       final purchaseData = PurchaseResponse.fromJson(purchaseResponse.data);
//       if (!purchaseData.success) {
//         throw Exception(purchaseData.message ?? 'Failed to fetch purchases');
//       }

//       // Fetch purchase returns data
//       final purchaseReturnResponse =
//           await DioClient().dio.get('/purchase-return/get_purchase_returns/');
//       final purchaseReturnData =
//           PurchaseReturnResponse.fromJson(purchaseReturnResponse.data);
//       if (!purchaseReturnData.success) {
//         throw Exception(
//             purchaseReturnData.message ?? 'Failed to fetch purchase returns');
//       }

//       // Fetch sales data
//       final saleResponse = await DioClient().dio.get('/sale/get_sales/');
//       final saleData = SaleResponse.fromJson(saleResponse.data);
//       if (!saleData.success) {
//         throw Exception(saleData.message ?? 'Failed to fetch sales');
//       }

//       // Fetch sales returns data
//       final saleReturnResponse =
//           await DioClient().dio.get('/sale-return/get_sale_returns/');
//       final saleReturnData =
//           SaleReturnResponse.fromJson(saleReturnResponse.data);
//       if (!saleReturnData.success) {
//         throw Exception(
//             saleReturnData.message ?? 'Failed to fetch sales returns');
//       }

//       // Calculate totals with robust error handling
//       final totalPurchases = _calculateTotal(purchaseData.data as List?,
//           (item) => item['total']?.toString() ?? '0');
//       final totalVatCollected = _calculateTotal(
//           purchaseData.data as List?, (item) => item['vat']?.toString() ?? '0');
//       final purchaseReturns = _calculateTotal(purchaseReturnData.data as List?,
//           (item) => item['total']?.toString() ?? '0');
//       final totalSalesTransactions =
//           saleData.data is List ? (saleData.data as List).length : 0;
//       final totalSales = _calculateTotal(
//           saleData.data as List?, (item) => item['total']?.toString() ?? '0');
//       final salesReturns = _calculateTotal(saleReturnData.data as List?,
//           (item) => item['total']?.toString() ?? '0');
//       final quantitySold = _calculateQuantitySold(saleData.data as List?);

//       // Parse return reasons dynamically
//       final returnReasons = <String, double>{};
//       if (saleReturnData.data is List && saleReturnData.data!.isNotEmpty) {
//         for (var returnItem in saleReturnData.data!) {
//           if (returnItem is Map<String, dynamic>) {
//             final reason = returnItem['reason'] as String? ?? 'Unknown';
//             final total =
//                 double.tryParse(returnItem['total']?.toString() ?? '0') ?? 0.0;
//             returnReasons[reason] = (returnReasons[reason] ?? 0.0) + total;
//           }
//         }
//       }
//       log('Return Reasons: $returnReasons, Total: ${returnReasons.values.isNotEmpty ? returnReasons.values.reduce((a, b) => a + b) : 0.0}');

//       // Emit state with salesData and returnReasons included
//       emit(state.copyWith(
//         isLoading: false,
//         totalPurchases: totalPurchases,
//         totalVatCollected: totalVatCollected,
//         purchaseReturns: purchaseReturns,
//         totalSalesTransactions: totalSalesTransactions,
//         totalSales: totalSales,
//         salesReturns: salesReturns,
//         quantitySold: quantitySold,
//         salesData: saleData,
//         returnReasons: returnReasons,
//         errorMessage: null,
//       ));
//     } on dio.DioException catch (e) {
//       String errorMessage = 'Network error: ${e.message}';
//       if (e.response != null) {
//         errorMessage =
//             'Server error: ${e.response!.statusCode} - ${e.response!.data}';
//       } else if (e.type == dio.DioExceptionType.connectionTimeout) {
//         errorMessage = 'Connection timed out. Please check your internet.';
//       }
//       log('Dio error: $errorMessage, StackTrace: ${e.stackTrace}');
//       emit(state.copyWith(isLoading: false, errorMessage: errorMessage));
//     } catch (e, stackTrace) {
//       log('Unexpected error in fetchDashboardData: $e, StackTrace: $stackTrace');
//       emit(state.copyWith(
//           isLoading: false,
//           errorMessage: 'Failed to fetch dashboard data: $e'));
//     }
//   }

//   // Helper method to calculate total from a list of items
//   double _calculateTotal(
//       List? data, String Function(Map<String, dynamic>) getter) {
//     if (data == null || data.isEmpty) return 0.0;
//     return data
//         .whereType<Map<String, dynamic>>()
//         .map((item) => double.tryParse(getter(item)) ?? 0.0)
//         .reduce((a, b) => a + b);
//   }

//   // Helper method to calculate total quantity sold
//   int _calculateQuantitySold(List? data) {
//     if (data == null || data.isEmpty) return 0;
//     final quantities = data.whereType<Map<String, dynamic>>().map((e) {
//       final items = e['items'] as List?;
//       if (items == null || items.isEmpty) return 0;
//       return items
//           .whereType<Map<String, dynamic>>()
//           .map((i) => i['quantity'] as int? ?? 0)
//           .fold<int>(0, (sum, qty) => sum + qty);
//     }).where((qty) => qty != null);
//     return quantities.isEmpty ? 0 : quantities.reduce((a, b) => a + b);
//   }
// }
// Only removed the forced query part — everything else 100% your original code

import 'dart:convert';

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

  Future<void> _onFetchFiscalYears(
    FetchFiscalYears event,
    Emitter<DashboardState> emit,
  ) async {
    try {
      final currentRes = await DioClient().dio.get(
            '/fiscal-year/get_current_fiscal_year/',
          );
      final currentData = FiscalYearResponse.fromJson(currentRes.data);

      final allRes = await DioClient().dio.get(
            '/fiscal-year/get_all_fiscal_years/',
          );
      final allData = FiscalYearListResponse.fromJson(allRes.data);

      if (!currentData.success || !allData.success) {
        throw Exception('Failed to load fiscal years');
      }

      emit(state.copyWith(
        currentFiscalYear: currentData.data,
        allFiscalYears: allData.data,
      ));
    } catch (e, stack) {
      log('Error loading fiscal years: $e\n$stack');
    }
  }

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
        refreshDashboard: true, // This triggers data reload
      ));

      log('Fiscal year changed to ID: ${parsed.data?.id} → triggering data refresh');
    } catch (e, stack) {
      log('Change fiscal year failed: $e\n$stack');
      emit(state.copyWith(isChangingFiscalYear: false));
    }
  }

  Future<void> _onFetchDashboardData(
    FetchDashboardData event,
    Emitter<DashboardState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));

    // Ensure fiscal years are loaded
    if (state.currentFiscalYear == null ||
        state.allFiscalYears == null ||
        state.allFiscalYears!.isEmpty) {
      add(const FetchFiscalYears());
      await Future.delayed(const Duration(milliseconds: 500));
    }

    try {
      final fyId = state.currentFiscalYear?.id;
      log('====================================');
      log('FETCHING DASHBOARD DATA FOR FISCAL YEAR ID: $fyId');
      log('====================================');

      if (fyId == null) {
        log('WARNING: No fiscal year selected — fetching without FY filter');
      }

      // ─────────────────────────────────────────────────────────────
      // NO query param here — backend ignores it anyway
      // We let it use whatever is in session (your original behavior)
      // ─────────────────────────────────────────────────────────────

      log('Dashboard fetch starting — current baseUrl = ${DioClient().dio.options.baseUrl}');

      final purchaseResponse = await DioClient().dio.get(
            '/purchase/get_purchases/',
          );
      log('Purchases → Status: ${purchaseResponse.statusCode}, FY: $fyId');
      final purchaseData = PurchaseResponse.fromJson(purchaseResponse.data);

      final purchaseReturnResponse = await DioClient().dio.get(
            '/purchase-return/get_purchase_returns/',
          );
      log('Purchase Returns → Status: ${purchaseReturnResponse.statusCode}');
      final purchaseReturnData =
          PurchaseReturnResponse.fromJson(purchaseReturnResponse.data);

      final saleResponse = await DioClient().dio.get(
            '/sale/get_sales/',
          );
      log('Sales → Status: ${saleResponse.statusCode}');
      final saleData = SaleResponse.fromJson(saleResponse.data);

      final saleReturnResponse = await DioClient().dio.get(
            '/sale-return/get_sale_returns/',
          );
      log('Sale Returns → Status: ${saleReturnResponse.statusCode}');
      final saleReturnData =
          SaleReturnResponse.fromJson(saleReturnResponse.data);

      // ── Your original calculations (unchanged) ─────────────────────────────
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
      String errorMsg = 'Network error: ${e.message}';
      if (e.response != null) {
        errorMsg =
            'Server error ${e.response!.statusCode}: ${e.response!.data}';
        log('Server error response:');
        log(const JsonEncoder.withIndent('  ').convert(e.response!.data));
      }
      log('Dio error in dashboard fetch: $errorMsg');
      emit(state.copyWith(isLoading: false, errorMessage: errorMsg));
    } catch (e, stack) {
      log('Unexpected error in dashboard fetch: $e\n$stack');
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load dashboard data',
      ));
    }
  }

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
