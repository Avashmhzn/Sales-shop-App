import 'package:json_annotation/json_annotation.dart';

part 'create_sale_response.g.dart';

@JsonSerializable()
class CreateSaleResponse {
  final bool success;
  final String message;
  final CreateSaleData data;

  CreateSaleResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory CreateSaleResponse.fromJson(Map<String, dynamic> json) =>
      _$CreateSaleResponseFromJson(json);
  Map<String, dynamic> toJson() => _$CreateSaleResponseToJson(this);
}

@JsonSerializable()
class CreateSaleData {
  final int id;
  final int invoice_number;
  final String date;
  // Add other fields...

  CreateSaleData({
    required this.id,
    required this.invoice_number,
    required this.date,
  });

  factory CreateSaleData.fromJson(Map<String, dynamic> json) =>
      _$CreateSaleDataFromJson(json);
  Map<String, dynamic> toJson() => _$CreateSaleDataToJson(this);
}
