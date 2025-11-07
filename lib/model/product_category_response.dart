// lib/model/product_category_response.dart
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'product_category_response.g.dart';

@JsonSerializable()
class ProductData extends Equatable {
  final int id;
  final String name;

  const ProductData({required this.id, required this.name});

  factory ProductData.fromJson(Map<String, dynamic> json) =>
      _$ProductDataFromJson(json);

  Map<String, dynamic> toJson() => _$ProductDataToJson(this);

  @override
  List<Object?> get props => [id, name];
}

@JsonSerializable()
class CategoryData extends Equatable {
  final int id;
  final String name;

  const CategoryData({required this.id, required this.name});

  factory CategoryData.fromJson(Map<String, dynamic> json) =>
      _$CategoryDataFromJson(json);

  Map<String, dynamic> toJson() => _$CategoryDataToJson(this);

  @override
  List<Object?> get props => [id, name];
}
