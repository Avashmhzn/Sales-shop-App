import 'package:json_annotation/json_annotation.dart';

part 'create_sale_request.g.dart';

@JsonSerializable()
class CreateSaleRequest {
  final String bill_type;
  final String customer;
  final String payment_mode;
  final List<CreateSaleItem> items;
  final String? narration;
  final double total;

  CreateSaleRequest({
    required this.bill_type,
    required this.customer,
    required this.payment_mode,
    required this.items,
    this.narration,
    required this.total,
  });

  factory CreateSaleRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateSaleRequestFromJson(json);
  Map<String, dynamic> toJson() => _$CreateSaleRequestToJson(this);
}

@JsonSerializable()
class CreateSaleItem {
  final String product;
  final int quantity;
  final double rate;

  CreateSaleItem({
    required this.product,
    required this.quantity,
    required this.rate,
  });

  factory CreateSaleItem.fromJson(Map<String, dynamic> json) =>
      _$CreateSaleItemFromJson(json);
  Map<String, dynamic> toJson() => _$CreateSaleItemToJson(this);
}
