// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'location_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LocationResponse _$LocationResponseFromJson(Map<String, dynamic> json) =>
    LocationResponse(
      success: json['success'] as bool,
      message: json['message'] as String?,
      detail: json['detail'] as String?,
      total: (json['total'] as num?)?.toInt(),
      data: (json['data'] as List<dynamic>?)
              ?.map((e) => LocationData.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );

Map<String, dynamic> _$LocationResponseToJson(LocationResponse instance) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
      'detail': instance.detail,
      'total': instance.total,
      'data': instance.data,
    };

LocationData _$LocationDataFromJson(Map<String, dynamic> json) => LocationData(
      id: (json['id'] as num).toInt(),
      code: json['code'] as String,
      name: json['name'] as String,
    );

Map<String, dynamic> _$LocationDataToJson(LocationData instance) =>
    <String, dynamic>{
      'id': instance.id,
      'code': instance.code,
      'name': instance.name,
    };
