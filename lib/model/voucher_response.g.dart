// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'voucher_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VoucherResponse _$VoucherResponseFromJson(Map<String, dynamic> json) =>
    VoucherResponse(
      success: json['success'] as bool,
      message: json['message'] as String?,
      data: json['data'],
    );

Map<String, dynamic> _$VoucherResponseToJson(VoucherResponse instance) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
      'data': instance.data,
    };

VoucherData _$VoucherDataFromJson(Map<String, dynamic> json) => VoucherData(
      id: (json['id'] as num).toInt(),
      type: json['type'] as String?,
      voucherNumber: json['voucher_number'] as String?,
      status: json['status'] as String?,
      totalDebit: VoucherData._parseDouble(json['total_debit']),
      totalCredit: VoucherData._parseDouble(json['total_credit']),
      voucherDate: json['voucher_date'] as String?,
      signature: json['signature'] as String?,
      narration: json['narration'] as String?,
      createdBy: json['created_by'] as String?,
      createdOn: json['created_on'] as String?,
      updatedOn: json['updated_on'] as String?,
      voucherItems: (json['voucher_items'] as List<dynamic>?)
              ?.map((e) => VoucherItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );

Map<String, dynamic> _$VoucherDataToJson(VoucherData instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': instance.type,
      'voucher_number': instance.voucherNumber,
      'status': instance.status,
      'total_debit': instance.totalDebit,
      'total_credit': instance.totalCredit,
      'voucher_date': instance.voucherDate,
      'signature': instance.signature,
      'narration': instance.narration,
      'created_by': instance.createdBy,
      'created_on': instance.createdOn,
      'updated_on': instance.updatedOn,
      'voucher_items': instance.voucherItems,
    };

VoucherItem _$VoucherItemFromJson(Map<String, dynamic> json) => VoucherItem(
      id: (json['id'] as num).toInt(),
      voucher: (json['voucher'] as num).toInt(),
      account: json['account'] as String?,
      debit: VoucherItem._parseDouble(json['debit']),
      credit: VoucherItem._parseDouble(json['credit']),
      isTaxLine: json['is_tax_line'] as bool?,
    );

Map<String, dynamic> _$VoucherItemToJson(VoucherItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'voucher': instance.voucher,
      'account': instance.account,
      'debit': instance.debit,
      'credit': instance.credit,
      'is_tax_line': instance.isTaxLine,
    };
