import 'package:equatable/equatable.dart';
import 'package:saleup_app/model/sale_response.dart' as sale_response;

class DashboardState extends Equatable {
  final bool isLoading;
  final double? totalPurchases;
  final double? totalVatCollected;
  final double? purchaseReturns;
  final int? totalSalesTransactions;
  final double? totalSales;
  final double? salesReturns;
  final sale_response.SaleResponse? salesData;
  final int? quantitySold;
  final String? errorMessage;
  final Map<String, double>? returnReasons;

  const DashboardState({
    this.isLoading = false,
    this.totalPurchases,
    this.totalVatCollected,
    this.purchaseReturns,
    this.totalSalesTransactions,
    this.totalSales,
    this.salesReturns,
    this.salesData,
    this.quantitySold,
    this.errorMessage,
    this.returnReasons,
  });

  DashboardState copyWith({
    bool? isLoading,
    double? totalPurchases,
    double? totalVatCollected,
    double? purchaseReturns,
    int? totalSalesTransactions,
    double? totalSales,
    double? salesReturns,
    sale_response.SaleResponse? salesData,
    int? quantitySold,
    String? errorMessage,
    Map<String, double>? returnReasons,
  }) {
    return DashboardState(
      isLoading: isLoading ?? this.isLoading,
      totalPurchases: totalPurchases ?? this.totalPurchases,
      totalVatCollected: totalVatCollected ?? this.totalVatCollected,
      purchaseReturns: purchaseReturns ?? this.purchaseReturns,
      totalSalesTransactions:
          totalSalesTransactions ?? this.totalSalesTransactions,
      totalSales: totalSales ?? this.totalSales,
      salesReturns: salesReturns ?? this.salesReturns,
      salesData: salesData ?? this.salesData,
      quantitySold: quantitySold ?? this.quantitySold,
      errorMessage: errorMessage,
      returnReasons: returnReasons ?? this.returnReasons,
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        totalPurchases,
        totalVatCollected,
        purchaseReturns,
        totalSalesTransactions,
        totalSales,
        salesReturns,
        salesData,
        quantitySold,
        errorMessage,
        returnReasons,
      ];
}
