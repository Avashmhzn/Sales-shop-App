import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'product_response.g.dart';

@JsonSerializable()
class ProductResponse {
  final bool success;
  final String? message;
  final List<ProductData> data;

  ProductResponse({
    required this.success,
    this.message,
    required this.data,
  });

  factory ProductResponse.fromJson(Map<String, dynamic> json) =>
      _$ProductResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ProductResponseToJson(this);
}

@JsonSerializable()
class ProductData extends Equatable {
  final int? id;
  final String? name;
  final String? category;
  final bool? service;
  final String? unit;
  final String? location;
  final int? stockQuantity;
  final bool? isVat; // Changed to nullable
  @JsonKey(name: 'created_on')
  final DateTime? createdOn;
  @JsonKey(name: 'updated_on')
  final DateTime? updatedOn;

  const ProductData({
    this.id,
    required this.name,
    required this.category,
    required this.unit,
    required this.location,
    this.stockQuantity,
    this.isVat, // Updated to handle null
    this.createdOn,
    this.updatedOn,
    this.service,
  });

  factory ProductData.fromJson(Map<String, dynamic> json) =>
      _$ProductDataFromJson(json);

  Map<String, dynamic> toJson() => _$ProductDataToJson(this);

  @override
  List<Object?> get props => [
        id,
        name,
        category,
        unit,
        location,
        stockQuantity,
        isVat,
        createdOn,
        updatedOn,
      ];
}
