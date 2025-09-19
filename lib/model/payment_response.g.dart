// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PaymentResponse _$PaymentResponseFromJson(Map<String, dynamic> json) =>
    PaymentResponse(
      success: json['success'] as bool,
      message: json['message'] as String?,
      data: json['data'],
    );

Map<String, dynamic> _$PaymentResponseToJson(PaymentResponse instance) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
      'data': instance.data,
    };

PaymentData _$PaymentDataFromJson(Map<String, dynamic> json) => PaymentData(
      id: (json['id'] as num).toInt(),
      refNumber: json['ref_number'] as String?,
      supplier: json['supplier'] as String?,
      amount: PaymentData._parseDouble(json['amount']),
      paymentMode: json['payment_mode'] as String?,
      chequeNumber: json['cheque_number'] as String?,
      chequeDate: json['cheque_date'] as String?,
      signature: json['signature'] as String?,
      narration: json['narration'] as String?,
      createdOn: json['created_on'] as String?,
      updatedOn: json['updated_on'] as String?,
    );

Map<String, dynamic> _$PaymentDataToJson(PaymentData instance) =>
    <String, dynamic>{
      'id': instance.id,
      'ref_number': instance.refNumber,
      'supplier': instance.supplier,
      'amount': instance.amount,
      'payment_mode': instance.paymentMode,
      'cheque_number': instance.chequeNumber,
      'cheque_date': instance.chequeDate,
      'signature': instance.signature,
      'narration': instance.narration,
      'created_on': instance.createdOn,
      'updated_on': instance.updatedOn,
    };
