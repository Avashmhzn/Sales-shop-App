// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stock_ledger_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Map<String, dynamic> _$StockLedgerReportToJson(StockLedgerReport instance) =>
    <String, dynamic>{
      'stringify': instance.stringify,
      'hashCode': instance.hashCode,
      'success': instance.success,
      'message': instance.message,
      'data': instance.data,
      'props': instance.props,
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
      openingValue: (json['openingValue'] as num?)?.toDouble(),
      purchase: (json['purchase'] as num?)?.toDouble(),
      purchaseValue: (json['purchaseValue'] as num?)?.toDouble(),
      purReturnQty: (json['purReturnQty'] as num?)?.toDouble(),
      purReturnValue: (json['purReturnValue'] as num?)?.toDouble(),
      sales: (json['sales'] as num?)?.toDouble(),
      salesValue: (json['salesValue'] as num?)?.toDouble(),
      salesReturnQty: (json['salesReturnQty'] as num?)?.toDouble(),
      salesReturnValue: (json['salesReturnValue'] as num?)?.toDouble(),
      closing: (json['closing'] as num?)?.toDouble(),
      closingValue: (json['closingValue'] as num?)?.toDouble(),
      costPrice: (json['costPrice'] as num?)?.toDouble(),
      sellingPrice: (json['sellingPrice'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$StockLedgerEntryToJson(StockLedgerEntry instance) =>
    <String, dynamic>{
      'date': instance.date,
      'opening': instance.opening,
      'openingValue': instance.openingValue,
      'purchase': instance.purchase,
      'purchaseValue': instance.purchaseValue,
      'purReturnQty': instance.purReturnQty,
      'purReturnValue': instance.purReturnValue,
      'sales': instance.sales,
      'salesValue': instance.salesValue,
      'salesReturnQty': instance.salesReturnQty,
      'salesReturnValue': instance.salesReturnValue,
      'closing': instance.closing,
      'closingValue': instance.closingValue,
      'costPrice': instance.costPrice,
      'sellingPrice': instance.sellingPrice,
    };
