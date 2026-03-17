// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_sale_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateSaleRequest _$CreateSaleRequestFromJson(Map<String, dynamic> json) =>
    CreateSaleRequest(
      bill_type: json['bill_type'] as String,
      customer: json['customer'] as String,
      payment_mode: json['payment_mode'] as String,
      items: (json['items'] as List<dynamic>)
          .map((e) => CreateSaleItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      narration: json['narration'] as String?,
      total: (json['total'] as num).toDouble(),
    );

Map<String, dynamic> _$CreateSaleRequestToJson(CreateSaleRequest instance) =>
    <String, dynamic>{
      'bill_type': instance.bill_type,
      'customer': instance.customer,
      'payment_mode': instance.payment_mode,
      'items': instance.items,
      'narration': instance.narration,
      'total': instance.total,
    };

CreateSaleItem _$CreateSaleItemFromJson(Map<String, dynamic> json) =>
    CreateSaleItem(
      product: json['product'] as String,
      quantity: (json['quantity'] as num).toInt(),
      rate: (json['rate'] as num).toDouble(),
    );

Map<String, dynamic> _$CreateSaleItemToJson(CreateSaleItem instance) =>
    <String, dynamic>{
      'product': instance.product,
      'quantity': instance.quantity,
      'rate': instance.rate,
    };
