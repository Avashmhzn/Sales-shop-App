// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stock_ledger_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StockLedgerReport _$StockLedgerReportFromJson(Map<String, dynamic> json) =>
    StockLedgerReport(
      success: json['success'] as bool,
      message: json['message'] as String,
      data: (json['data'] as List<dynamic>?)
          ?.map((e) => StockLedgerAccount.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$StockLedgerReportToJson(StockLedgerReport instance) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
      'data': instance.data,
    };

StockLedgerAccount _$StockLedgerAccountFromJson(Map<String, dynamic> json) =>
    StockLedgerAccount(
      productName: json['productName'] as String?,
      ledger: (json['ledger'] as List<dynamic>?)
          ?.map((e) => StockLedgerEntry.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$StockLedgerAccountToJson(StockLedgerAccount instance) =>
    <String, dynamic>{
      'productName': instance.productName,
      'ledger': instance.ledger,
    };

StockLedgerEntry _$StockLedgerEntryFromJson(Map<String, dynamic> json) =>
    StockLedgerEntry(
      date: json['date'] as String?,
      opening: (json['opening'] as num?)?.toDouble(),
      purchase: (json['purchase'] as num?)?.toDouble(),
      sales: (json['sales'] as num?)?.toDouble(),
      costPrice: (json['costPrice'] as num?)?.toDouble(),
      sellingPrice: (json['sellingPrice'] as num?)?.toDouble(),
      closing: (json['closing'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$StockLedgerEntryToJson(StockLedgerEntry instance) =>
    <String, dynamic>{
      'date': instance.date,
      'opening': instance.opening,
      'purchase': instance.purchase,
      'sales': instance.sales,
      'costPrice': instance.costPrice,
      'sellingPrice': instance.sellingPrice,
      'closing': instance.closing,
    };
