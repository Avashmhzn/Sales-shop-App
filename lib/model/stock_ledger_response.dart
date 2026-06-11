// // FILE: lib/model/stock_ledger_response.dart

// import 'package:json_annotation/json_annotation.dart';
// import 'package:equatable/equatable.dart';

// part 'stock_ledger_response.g.dart';

// @JsonSerializable()
// class StockLedgerReport extends Equatable {
//   final bool success;
//   final String message;
//   final List<StockLedgerAccount>? data;

//   const StockLedgerReport({
//     required this.success,
//     required this.message,
//     this.data,
//   });

//   factory StockLedgerReport.fromJson(Map<String, dynamic> json) =>
//       _$StockLedgerReportFromJson(json);

//   Map<String, dynamic> toJson() => _$StockLedgerReportToJson(this);

//   @override
//   List<Object?> get props => [success, message, data];
// }

// @JsonSerializable()
// class StockLedgerAccount extends Equatable {
//   final String? productName;
//   final List<StockLedgerEntry>? ledger;

//   const StockLedgerAccount({this.productName, this.ledger});

//   factory StockLedgerAccount.fromJson(Map<String, dynamic> json) =>
//       _$StockLedgerAccountFromJson(json);

//   Map<String, dynamic> toJson() => _$StockLedgerAccountToJson(this);

//   @override
//   List<Object?> get props => [productName, ledger];
// }

// // @JsonSerializable()
// // class StockLedgerEntry extends Equatable {
// //   final String? date;
// //   final double? opening;
// //   final double? purchase;
// //   final double? sales;
// //   final double? costPrice;
// //   final double? sellingPrice;

// //   // Use @JsonKey to handle mutable closing
// //   @JsonKey(name: 'closing')
// //   double? _closing;
// //   double? get closing => _closing;
// //   set closing(double? value) => _closing = value;

// //   StockLedgerEntry({
// //     this.date,
// //     this.opening,
// //     this.purchase,
// //     this.sales,
// //     this.costPrice,
// //     this.sellingPrice,
// //     double? closing,
// //   }) : _closing = closing;

// //   factory StockLedgerEntry.fromJson(Map<String, dynamic> json) =>
// //       _$StockLedgerEntryFromJson(json);

// //   Map<String, dynamic> toJson() => _$StockLedgerEntryToJson(this);

// //   @override
// //   List<Object?> get props => [
// //         date,
// //         opening,
// //         purchase,
// //         sales,
// //         _closing,
// //         costPrice,
// //         sellingPrice,
// //       ];
// // }
// @JsonSerializable()
// class StockLedgerEntry extends Equatable {
//   final String? date;
//   final double? opening;
//   final double? purchase;
//   final double? sales;
//   final double? costPrice;
//   final double? sellingPrice;
//   final double? closing;

//   const StockLedgerEntry({
//     this.date,
//     this.opening,
//     this.purchase,
//     this.sales,
//     this.costPrice,
//     this.sellingPrice,
//     this.closing,
//   });

//   factory StockLedgerEntry.fromJson(Map<String, dynamic> json) =>
//       _$StockLedgerEntryFromJson(json);

//   Map<String, dynamic> toJson() => _$StockLedgerEntryToJson(this);

//   @override
//   List<Object?> get props => [
//         date,
//         opening,
//         purchase,
//         sales,
//         closing,
//         costPrice,
//         sellingPrice,
//       ];
// }

// lib/model/stock_ledger_response.dart

import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';

part 'stock_ledger_response.g.dart';

// ★ We use createFactory: false because we are writing a custom fromJson
// to handle the deeply nested API response structure
@JsonSerializable(createFactory: false)
class StockLedgerReport extends Equatable {
  final bool success;
  final String message;
  final List<StockLedgerAccount>? data;

  const StockLedgerReport({
    required this.success,
    required this.message,
    this.data,
  });

  // ★ CUSTOM fromJson - Reads the nested structure and maps it to your flat models
  factory StockLedgerReport.fromJson(Map<String, dynamic> json) {
    final success = json['success'] as bool? ?? false;
    final message = json['message'] as String? ?? '';
    final dataJson = json['data'] as Map<String, dynamic>?;

    final Map<int, Map<String, dynamic>> productMap = {};

    if (dataJson != null) {
      void processList(List<dynamic>? list, String type) {
        if (list == null) return;
        for (var item in list) {
          final pId = item['product_id'] as int? ?? 0;
          productMap.putIfAbsent(
              pId,
              () => {
                    'product_name': item['product_name'] ?? 'Unknown',
                    'opening': 0.0,
                    'openingValue': 0.0,
                    'purchase': 0.0,
                    'purchaseValue': 0.0,
                    'purReturnQty': 0.0,
                    'purReturnValue': 0.0,
                    'sales': 0.0,
                    'salesValue': 0.0,
                    'salesReturnQty': 0.0,
                    'salesReturnValue': 0.0,
                    'closing': 0.0,
                    'closingValue': 0.0,
                    'costPrice': 0.0,
                    'sellingPrice': 0.0,
                  });

          final map = productMap[pId]!;
          final qty = _toDouble(item['quantity']);
          final total = _toDouble(item['total'] ?? item['total_amount']);

          if (type == 'opening') {
            map['opening'] = qty;
            map['openingValue'] = total;
          } else if (type == 'purchase') {
            map['purchase'] = qty;
            map['purchaseValue'] = total;
          } else if (type == 'pur_return') {
            map['purReturnQty'] = qty;
            map['purReturnValue'] = total;
          } else if (type == 'sales') {
            map['sales'] = qty;
            map['salesValue'] = total;
          } else if (type == 'sales_return') {
            map['salesReturnQty'] = qty;
            map['salesReturnValue'] = total;
          } else if (type == 'closing') {
            map['closing'] = qty;
            map['closingValue'] = total;
            map['costPrice'] = _toDouble(item['weighted_avg_cost_price']);
            map['sellingPrice'] = _toDouble(item['weighted_avg_selling_price']);
          }
        }
      }

      // 1. Process Opening Stock Summary
      processList((dataJson['opening_stock']?['summary']) as List?, 'opening');
      // 2. Process Movements (Top level arrays)
      processList(dataJson['purchases'] as List?, 'purchase');
      processList(dataJson['purchase_returns'] as List?, 'pur_return');
      processList(dataJson['sales'] as List?, 'sales');
      processList(dataJson['sale_returns'] as List?, 'sales_return');
      // 3. Process Closing Stock Summary
      processList((dataJson['closing_stock']?['summary']) as List?, 'closing');
    }

    // Build the final list of accounts
    final accounts = productMap.values
        .map((m) => StockLedgerAccount(
              productName: m['product_name'] as String?,
              ledger: [
                StockLedgerEntry(
                  opening: m['opening'] as double?,
                  openingValue: m['openingValue'] as double?,
                  purchase: m['purchase'] as double?,
                  purchaseValue: m['purchaseValue'] as double?,
                  purReturnQty: m['purReturnQty'] as double?,
                  purReturnValue: m['purReturnValue'] as double?,
                  sales: m['sales'] as double?,
                  salesValue: m['salesValue'] as double?,
                  salesReturnQty: m['salesReturnQty'] as double?,
                  salesReturnValue: m['salesReturnValue'] as double?,
                  closing: m['closing'] as double?,
                  closingValue: m['closingValue'] as double?,
                  costPrice: m['costPrice'] as double?,
                  sellingPrice: m['sellingPrice'] as double?,
                )
              ],
            ))
        .toList();

    return StockLedgerReport(
      success: success,
      message: message,
      data: accounts.isEmpty ? null : accounts,
    );
  }

  static double _toDouble(dynamic v) {
    if (v == null) return 0.0;
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v.trim()) ?? 0.0;
    return 0.0;
  }

  Map<String, dynamic> toJson() => _$StockLedgerReportToJson(this);

  @override
  List<Object?> get props => [success, message, data];
}

@JsonSerializable()
class StockLedgerAccount extends Equatable {
  final String? productName;
  final List<StockLedgerEntry>? ledger;

  const StockLedgerAccount({this.productName, this.ledger});

  factory StockLedgerAccount.fromJson(Map<String, dynamic> json) =>
      _$StockLedgerAccountFromJson(json);

  Map<String, dynamic> toJson() => _$StockLedgerAccountToJson(this);

  @override
  List<Object?> get props => [productName, ledger];
}

// ★ ENHANCED: Added missing Value fields so the UI can display totals
@JsonSerializable()
class StockLedgerEntry extends Equatable {
  final String? date;

  // Opening
  final double? opening;
  final double? openingValue;

  // Purchase
  final double? purchase;
  final double? purchaseValue;

  // Purchase Return
  final double? purReturnQty;
  final double? purReturnValue;

  // Sales
  final double? sales;
  final double? salesValue;

  // Sales Return
  final double? salesReturnQty;
  final double? salesReturnValue;

  // Closing
  final double? closing;
  final double? closingValue;

  // Rates
  final double? costPrice;
  final double? sellingPrice;

  const StockLedgerEntry({
    this.date,
    this.opening,
    this.openingValue,
    this.purchase,
    this.purchaseValue,
    this.purReturnQty,
    this.purReturnValue,
    this.sales,
    this.salesValue,
    this.salesReturnQty,
    this.salesReturnValue,
    this.closing,
    this.closingValue,
    this.costPrice,
    this.sellingPrice,
  });

  factory StockLedgerEntry.fromJson(Map<String, dynamic> json) =>
      _$StockLedgerEntryFromJson(json);

  Map<String, dynamic> toJson() => _$StockLedgerEntryToJson(this);

  @override
  List<Object?> get props => [
        date,
        opening,
        openingValue,
        purchase,
        purchaseValue,
        purReturnQty,
        purReturnValue,
        sales,
        salesValue,
        salesReturnQty,
        salesReturnValue,
        closing,
        closingValue,
        costPrice,
        sellingPrice,
      ];
}
