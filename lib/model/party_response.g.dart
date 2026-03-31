// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'party_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PartyResponse _$PartyResponseFromJson(Map<String, dynamic> json) =>
    PartyResponse(
      success: json['success'] as bool,
      message: json['message'] as String?,
      detail: json['detail'] as String?,
      total: const NullableIntConverter().fromJson(json['total']),
      data: (json['data'] as List<dynamic>)
          .map((e) => PartyData.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$PartyResponseToJson(PartyResponse instance) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
      'detail': instance.detail,
      'total': const NullableIntConverter().toJson(instance.total),
      'data': instance.data,
    };

PartyData _$PartyDataFromJson(Map<String, dynamic> json) => PartyData(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      type: json['type'] as String?,
      accType: json['acc_type'] as String?,
      panNumber: json['pan_number'] as String?,
      phone: json['phone'] as String?,
      address: json['address'] as String?,
      description: json['description'] as String?,
      openingBalance:
          const NullableDoubleConverter().fromJson(json['opening_balance']),
      status: json['status'] as bool?,
      createdOn: json['created_on'] == null
          ? null
          : DateTime.parse(json['created_on'] as String),
      updatedOn: json['updated_on'] == null
          ? null
          : DateTime.parse(json['updated_on'] as String),
      accId: const NullableIntConverter().fromJson(json['acc_id']),
    );

Map<String, dynamic> _$PartyDataToJson(PartyData instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'type': instance.type,
      'acc_type': instance.accType,
      'pan_number': instance.panNumber,
      'phone': instance.phone,
      'address': instance.address,
      'description': instance.description,
      'opening_balance':
          const NullableDoubleConverter().toJson(instance.openingBalance),
      'status': instance.status,
      'created_on': instance.createdOn?.toIso8601String(),
      'updated_on': instance.updatedOn?.toIso8601String(),
      'acc_id': const NullableIntConverter().toJson(instance.accId),
    };
