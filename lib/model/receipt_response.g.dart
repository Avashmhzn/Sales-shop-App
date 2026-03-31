// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'receipt_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReceiptResponse _$ReceiptResponseFromJson(Map<String, dynamic> json) =>
    ReceiptResponse(
      success: json['success'] as bool,
      message: json['message'] as String?,
      data: json['data'],
    );

Map<String, dynamic> _$ReceiptResponseToJson(ReceiptResponse instance) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
      'data': instance.data,
    };

ReceiptData _$ReceiptDataFromJson(Map<String, dynamic> json) => ReceiptData(
      id: (json['id'] as num).toInt(),
      refNumber: json['ref_number'] as String?,
      customer: json['customer'] as String?,
      amount: ReceiptData._parseDouble(json['amount']),
      depositedIn: json['deposited_in'] as String?,
      chequeNumber: json['cheque_number'] as String?,
      chequeDate: json['cheque_date'] as String?,
      signature: json['signature'] as String?,
      narration: json['narration'] as String?,
      createdOn: json['created_on'] as String?,
      updatedOn: json['updated_on'] as String?,
    );

Map<String, dynamic> _$ReceiptDataToJson(ReceiptData instance) =>
    <String, dynamic>{
      'id': instance.id,
      'ref_number': instance.refNumber,
      'customer': instance.customer,
      'amount': instance.amount,
      'deposited_in': instance.depositedIn,
      'cheque_number': instance.chequeNumber,
      'cheque_date': instance.chequeDate,
      'signature': instance.signature,
      'narration': instance.narration,
      'created_on': instance.createdOn,
      'updated_on': instance.updatedOn,
    };

RemainingReceiptData _$RemainingReceiptDataFromJson(
        Map<String, dynamic> json) =>
    RemainingReceiptData(
      invoiceNumber: RemainingReceiptData._parseString(json['invoice_number']),
      date: json['date'] as String,
      total: RemainingReceiptData._parseDouble(json['total']),
      received: RemainingReceiptData._parseDouble(json['received']),
      remaining: RemainingReceiptData._parseDouble(json['remaining']),
    );

Map<String, dynamic> _$RemainingReceiptDataToJson(
        RemainingReceiptData instance) =>
    <String, dynamic>{
      'invoice_number': instance.invoiceNumber,
      'date': instance.date,
      'total': instance.total,
      'received': instance.received,
      'remaining': instance.remaining,
    };
