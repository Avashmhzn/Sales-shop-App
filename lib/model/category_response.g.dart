// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CategoryResponse _$CategoryResponseFromJson(Map<String, dynamic> json) =>
    CategoryResponse(
      success: json['success'] as bool,
      message: json['message'] as String?,
      data: (json['data'] as List<dynamic>)
          .map((e) => CategoryData.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$CategoryResponseToJson(CategoryResponse instance) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
      'data': instance.data,
    };

CategoryData _$CategoryDataFromJson(Map<String, dynamic> json) => CategoryData(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String?,
      shortCode: json['short_code'] as String?,
      description: json['description'] as String?,
      status: json['status'] as bool,
      createdOn: DateTime.parse(json['created_on'] as String),
      updatedOn: DateTime.parse(json['updated_on'] as String),
      parent: (json['parent'] as num?)?.toInt(),
      subcategories: (json['subcategories'] as List<dynamic>)
          .map((e) => CategoryData.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$CategoryDataToJson(CategoryData instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'short_code': instance.shortCode,
      'description': instance.description,
      'status': instance.status,
      'created_on': instance.createdOn.toIso8601String(),
      'updated_on': instance.updatedOn.toIso8601String(),
      'parent': instance.parent,
      'subcategories': instance.subcategories,
    };
