// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'purchase_return_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PurchaseReturnResponse _$PurchaseReturnResponseFromJson(
        Map<String, dynamic> json) =>
    PurchaseReturnResponse(
      success: json['success'] as bool,
      message: json['message'] as String?,
      data: json['data'],
    );

Map<String, dynamic> _$PurchaseReturnResponseToJson(
        PurchaseReturnResponse instance) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
      'data': instance.data,
    };

PurchaseReturnData _$PurchaseReturnDataFromJson(Map<String, dynamic> json) =>
    PurchaseReturnData(
      id: (json['id'] as num).toInt(),
      purchase: (json['purchase'] as num).toInt(),
      returnDate: json['return_date'] as String,
      reason: json['reason'] as String,
      subTotal: PurchaseReturnData._parseDouble(json['sub_total']),
      discount: PurchaseReturnData._parseDouble(json['discount']),
      vat: PurchaseReturnData._parseDouble(json['vat']),
      total: PurchaseReturnData._parseDouble(json['total']),
      items: (json['items'] as List<dynamic>)
          .map((e) => PurchaseReturnItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$PurchaseReturnDataToJson(PurchaseReturnData instance) =>
    <String, dynamic>{
      'id': instance.id,
      'purchase': instance.purchase,
      'return_date': instance.returnDate,
      'reason': instance.reason,
      'sub_total': instance.subTotal,
      'discount': instance.discount,
      'vat': instance.vat,
      'total': instance.total,
      'items': instance.items,
    };

PurchaseReturnItem _$PurchaseReturnItemFromJson(Map<String, dynamic> json) =>
    PurchaseReturnItem(
      id: (json['id'] as num).toInt(),
      product: json['product'] as String,
      quantity: (json['quantity'] as num).toInt(),
      rate: PurchaseReturnItem._parseDouble(json['rate']),
      total: PurchaseReturnItem._parseDouble(json['total']),
    );

Map<String, dynamic> _$PurchaseReturnItemToJson(PurchaseReturnItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'product': instance.product,
      'quantity': instance.quantity,
      'rate': instance.rate,
      'total': instance.total,
    };
