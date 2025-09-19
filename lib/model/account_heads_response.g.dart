// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account_heads_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AccountHeadsResponse _$AccountHeadsResponseFromJson(
        Map<String, dynamic> json) =>
    AccountHeadsResponse(
      success: json['success'] as bool?,
      message: json['message'] as String?,
      data: (json['data'] as List<dynamic>)
          .map((e) => AccountHeadData.fromJson(e as Map<String, dynamic>))
          .toList(),
      total: (json['total'] as num?)?.toInt(),
    );

Map<String, dynamic> _$AccountHeadsResponseToJson(
        AccountHeadsResponse instance) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
      'data': instance.data,
      'total': instance.total,
    };

AccountHeadData _$AccountHeadDataFromJson(Map<String, dynamic> json) =>
    AccountHeadData(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      mainGroup: json['main_group'] as String?,
      parent: json['parent'] as String?,
      drCr: json['dr_cr'] as String?,
      accountType: json['account_type'] as String?,
      openingBalance:
          AccountHeadData._parseOpeningBalance(json['opening_balance']),
      description: json['description'] as String?,
      status: json['status'] as bool?,
      createdOn: json['created_on'] as String?,
      updatedOn: json['updated_on'] as String?,
    );

Map<String, dynamic> _$AccountHeadDataToJson(AccountHeadData instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'main_group': instance.mainGroup,
      'parent': instance.parent,
      'dr_cr': instance.drCr,
      'account_type': instance.accountType,
      'opening_balance': instance.openingBalance,
      'description': instance.description,
      'status': instance.status,
      'created_on': instance.createdOn,
      'updated_on': instance.updatedOn,
    };
