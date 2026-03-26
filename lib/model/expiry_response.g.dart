// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'expiry_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ExpiryResponse _$ExpiryResponseFromJson(Map<String, dynamic> json) =>
    ExpiryResponse(
      success: json['success'] as bool,
      message: json['message'] as String?,
      data: (json['data'] as List<dynamic>?)
          ?.map((e) => ExpiryData.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ExpiryResponseToJson(ExpiryResponse instance) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
      'data': instance.data,
    };

ExpiryData _$ExpiryDataFromJson(Map<String, dynamic> json) => ExpiryData(
      id: (json['id'] as num?)?.toInt(),
      product: json['product'] as String?,
      batchNumber: json['batch_number'] as String?,
      expiryDate: ExpiryData._dateFromJson(json['expiry_date']),
      isExpired: json['is_expired'] as bool?,
      quantity: (json['quantity'] as num?)?.toInt(),
      costPrice: ExpiryData._parseDouble(json['cost_price']),
      sellingPrice: ExpiryData._parseDouble(json['selling_prices']),
      bulkPrice: json['bulk_price'] as Map<String, dynamic>? ?? {},
      daysToExpiry: (json['days_to_expiry'] as num?)?.toInt(),
      createdOn: ExpiryData._dateTimeFromJson(json['created_on']),
      updatedOn: ExpiryData._dateTimeFromJson(json['updated_on']),
    );

Map<String, dynamic> _$ExpiryDataToJson(ExpiryData instance) =>
    <String, dynamic>{
      'id': instance.id,
      'product': instance.product,
      'batch_number': instance.batchNumber,
      'expiry_date': instance.expiryDate?.toIso8601String(),
      'is_expired': instance.isExpired,
      'quantity': instance.quantity,
      'cost_price': instance.costPrice,
      'selling_prices': instance.sellingPrice,
      'bulk_price': instance.bulkPrice,
      'days_to_expiry': instance.daysToExpiry,
      'created_on': instance.createdOn?.toIso8601String(),
      'updated_on': instance.updatedOn?.toIso8601String(),
    };
