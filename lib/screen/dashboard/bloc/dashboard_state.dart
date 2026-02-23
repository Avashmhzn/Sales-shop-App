// import 'package:equatable/equatable.dart';
// import 'package:saleup_app/model/sale_response.dart' as sale_response;

// class DashboardState extends Equatable {
//   final bool isLoading;
//   final double? totalPurchases;
//   final double? totalVatCollected;
//   final double? purchaseReturns;
//   final int? totalSalesTransactions;
//   final double? totalSales;
//   final double? salesReturns;
//   final sale_response.SaleResponse? salesData;
//   final int? quantitySold;
//   final String? errorMessage;
//   final Map<String, double>? returnReasons;

//   const DashboardState({
//     this.isLoading = false,
//     this.totalPurchases,
//     this.totalVatCollected,
//     this.purchaseReturns,
//     this.totalSalesTransactions,
//     this.totalSales,
//     this.salesReturns,
//     this.salesData,
//     this.quantitySold,
//     this.errorMessage,
//     this.returnReasons,
//   });

//   DashboardState copyWith({
//     bool? isLoading,
//     double? totalPurchases,
//     double? totalVatCollected,
//     double? purchaseReturns,
//     int? totalSalesTransactions,
//     double? totalSales,
//     double? salesReturns,
//     sale_response.SaleResponse? salesData,
//     int? quantitySold,
//     String? errorMessage,
//     Map<String, double>? returnReasons,
//   }) {
//     return DashboardState(
//       isLoading: isLoading ?? this.isLoading,
//       totalPurchases: totalPurchases ?? this.totalPurchases,
//       totalVatCollected: totalVatCollected ?? this.totalVatCollected,
//       purchaseReturns: purchaseReturns ?? this.purchaseReturns,
//       totalSalesTransactions:
//           totalSalesTransactions ?? this.totalSalesTransactions,
//       totalSales: totalSales ?? this.totalSales,
//       salesReturns: salesReturns ?? this.salesReturns,
//       salesData: salesData ?? this.salesData,
//       quantitySold: quantitySold ?? this.quantitySold,
//       errorMessage: errorMessage,
//       returnReasons: returnReasons ?? this.returnReasons,
//     );
//   }

//   @override
//   List<Object?> get props => [
//         isLoading,
//         totalPurchases,
//         totalVatCollected,
//         purchaseReturns,
//         totalSalesTransactions,
//         totalSales,
//         salesReturns,
//         salesData,
//         quantitySold,
//         errorMessage,
//         returnReasons,
//       ];
// }

// lib/screen/dashboard/bloc/dashboard_state.dart

import 'package:equatable/equatable.dart';
import 'package:saleup_app/model/fiscal_year.dart';
import 'package:saleup_app/model/sale_response.dart' as sale_response;

class DashboardState extends Equatable {
  final bool isLoading;
  final bool isLoadingFiscalYears;
  final bool isChangingFiscalYear;
  final bool refreshDashboard;
  final String? errorMessage;

  final double? totalPurchases;
  final double? totalVatCollected;
  final double? purchaseReturns;
  final double? totalSales;
  final double? salesReturns;
  final int? totalSalesTransactions;
  final int? quantitySold;

  final sale_response.SaleResponse? salesData;
  final Map<String, double>? returnReasons;

  final FiscalYear? currentFiscalYear;
  final List<FiscalYear>? allFiscalYears;

  const DashboardState({
    this.isLoading = false,
    this.isLoadingFiscalYears = false,
    this.isChangingFiscalYear = false,
    this.refreshDashboard = false,
    this.errorMessage,
    this.totalPurchases,
    this.totalVatCollected,
    this.purchaseReturns,
    this.totalSales,
    this.salesReturns,
    this.totalSalesTransactions,
    this.quantitySold,
    this.salesData,
    this.returnReasons,
    this.currentFiscalYear,
    this.allFiscalYears,
  });

  DashboardState copyWith({
    bool? isLoading,
    bool? isLoadingFiscalYears,
    bool? isChangingFiscalYear,
    bool? refreshDashboard,
    String? errorMessage,
    double? totalPurchases,
    double? totalVatCollected,
    double? purchaseReturns,
    double? totalSales,
    double? salesReturns,
    int? totalSalesTransactions,
    int? quantitySold,
    sale_response.SaleResponse? salesData,
    Map<String, double>? returnReasons,
    FiscalYear? currentFiscalYear,
    List<FiscalYear>? allFiscalYears,
  }) {
    return DashboardState(
      isLoading: isLoading ?? this.isLoading,
      isLoadingFiscalYears: isLoadingFiscalYears ?? this.isLoadingFiscalYears,
      isChangingFiscalYear: isChangingFiscalYear ?? this.isChangingFiscalYear,
      refreshDashboard: refreshDashboard ?? this.refreshDashboard,
      errorMessage: errorMessage ?? this.errorMessage,
      totalPurchases: totalPurchases ?? this.totalPurchases,
      totalVatCollected: totalVatCollected ?? this.totalVatCollected,
      purchaseReturns: purchaseReturns ?? this.purchaseReturns,
      totalSales: totalSales ?? this.totalSales,
      salesReturns: salesReturns ?? this.salesReturns,
      totalSalesTransactions:
          totalSalesTransactions ?? this.totalSalesTransactions,
      quantitySold: quantitySold ?? this.quantitySold,
      salesData: salesData ?? this.salesData,
      returnReasons: returnReasons ?? this.returnReasons,
      currentFiscalYear: currentFiscalYear ?? this.currentFiscalYear,
      allFiscalYears: allFiscalYears ?? this.allFiscalYears,
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        isLoadingFiscalYears,
        isChangingFiscalYear,
        refreshDashboard,
        errorMessage,
        totalPurchases,
        totalVatCollected,
        purchaseReturns,
        totalSales,
        salesReturns,
        totalSalesTransactions,
        quantitySold,
        salesData,
        returnReasons,
        currentFiscalYear,
        allFiscalYears,
      ];
}
