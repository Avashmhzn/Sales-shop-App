// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sale_return_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SaleReturnResponse _$SaleReturnResponseFromJson(Map<String, dynamic> json) =>
    SaleReturnResponse(
      success: json['success'] as bool,
      message: json['message'] as String?,
      data: json['data'],
    );

Map<String, dynamic> _$SaleReturnResponseToJson(SaleReturnResponse instance) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
      'data': instance.data,
    };

SaleReturnData _$SaleReturnDataFromJson(Map<String, dynamic> json) =>
    SaleReturnData(
      id: (json['id'] as num).toInt(),
      sale: (json['sale'] as num).toInt(),
      returnDate: json['return_date'] as String,
      reason: json['reason'] as String,
      subTotal: SaleReturnData._parseDouble(json['sub_total']),
      vat: SaleReturnData._parseDouble(json['vat']),
      discount: SaleReturnData._parseDouble(json['discount']),
      total: SaleReturnData._parseDouble(json['total']),
      items: (json['items'] as List<dynamic>)
          .map((e) => SaleReturnItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$SaleReturnDataToJson(SaleReturnData instance) =>
    <String, dynamic>{
      'id': instance.id,
      'sale': instance.sale,
      'return_date': instance.returnDate,
      'reason': instance.reason,
      'sub_total': instance.subTotal,
      'vat': instance.vat,
      'discount': instance.discount,
      'total': instance.total,
      'items': instance.items,
    };

SaleReturnItem _$SaleReturnItemFromJson(Map<String, dynamic> json) =>
    SaleReturnItem(
      id: (json['id'] as num).toInt(),
      product: json['product'] as String,
      quantity: (json['quantity'] as num).toInt(),
      rate: SaleReturnItem._parseDouble(json['rate']),
      total: SaleReturnItem._parseDouble(json['total']),
    );

Map<String, dynamic> _$SaleReturnItemToJson(SaleReturnItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'product': instance.product,
      'quantity': instance.quantity,
      'rate': instance.rate,
      'total': instance.total,
    };
