// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_sale_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateSaleResponse _$CreateSaleResponseFromJson(Map<String, dynamic> json) =>
    CreateSaleResponse(
      success: json['success'] as bool,
      message: json['message'] as String,
      data: CreateSaleData.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$CreateSaleResponseToJson(CreateSaleResponse instance) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
      'data': instance.data,
    };

CreateSaleData _$CreateSaleDataFromJson(Map<String, dynamic> json) =>
    CreateSaleData(
      id: (json['id'] as num).toInt(),
      invoice_number: (json['invoice_number'] as num).toInt(),
      date: json['date'] as String,
    );

Map<String, dynamic> _$CreateSaleDataToJson(CreateSaleData instance) =>
    <String, dynamic>{
      'id': instance.id,
      'invoice_number': instance.invoice_number,
      'date': instance.date,
    };
