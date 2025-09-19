// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account_head_details_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AccountHeadDetailsResponse _$AccountHeadDetailsResponseFromJson(
        Map<String, dynamic> json) =>
    AccountHeadDetailsResponse(
      success: json['success'] as bool,
      message: json['message'] as String?,
      data:
          AccountHeadDetailData.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$AccountHeadDetailsResponseToJson(
        AccountHeadDetailsResponse instance) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
      'data': instance.data,
    };

AccountHeadDetailData _$AccountHeadDetailDataFromJson(
        Map<String, dynamic> json) =>
    AccountHeadDetailData(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      mainGroup: json['main_group'] as String?,
      parent: json['parent'] as String?,
      drCr: json['dr_cr'] as String?,
      accountType: json['account_type'] as String?,
      openingBalance: json['opening_balance'] as String?,
      description: json['description'] as String?,
      status: json['status'] as bool?,
      createdOn: json['created_on'] as String?,
      updatedOn: json['updated_on'] as String?,
    );

Map<String, dynamic> _$AccountHeadDetailDataToJson(
        AccountHeadDetailData instance) =>
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
