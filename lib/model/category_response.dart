import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'category_response.g.dart';

@JsonSerializable()
class CategoryResponse {
  final bool success;
  final String? message;
  final List<CategoryData> data;

  CategoryResponse({
    required this.success,
    this.message,
    required this.data,
  });

  factory CategoryResponse.fromJson(Map<String, dynamic> json) =>
      _$CategoryResponseFromJson(json);

  Map<String, dynamic> toJson() => _$CategoryResponseToJson(this);
}

@JsonSerializable()
class CategoryData extends Equatable {
  final int id;
  final String? name;
  @JsonKey(name: 'short_code') // Changed to nullable
  final String? shortCode; // Changed to nullable
  final String? description;
  final bool status;
  @JsonKey(name: 'created_on')
  final DateTime createdOn;
  @JsonKey(name: 'updated_on')
  final DateTime updatedOn;
  final int? parent;
  final List<CategoryData> subcategories;

  const CategoryData({
    required this.id,
    this.name, // Updated to handle null
    this.shortCode, // Updated to handle null
    this.description,
    required this.status,
    required this.createdOn,
    required this.updatedOn,
    this.parent,
    required this.subcategories,
  });

  factory CategoryData.fromJson(Map<String, dynamic> json) =>
      _$CategoryDataFromJson(json);

  Map<String, dynamic> toJson() => _$CategoryDataToJson(this);

  @override
  List<Object?> get props => [
        id,
        name,
        shortCode,
        description,
        status,
        createdOn,
        updatedOn,
        parent,
        subcategories,
      ];
}
