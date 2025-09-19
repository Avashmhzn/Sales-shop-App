import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'purchase_return_response.g.dart';

@JsonSerializable()
class PurchaseReturnResponse extends Equatable {
  final bool success;
  final String? message;
  final dynamic data; // Dynamic to handle both List and Map

  const PurchaseReturnResponse({
    required this.success,
    this.message,
    this.data,
  });

  factory PurchaseReturnResponse.fromJson(Map<String, dynamic> json) =>
      _$PurchaseReturnResponseFromJson(json);

  Map<String, dynamic> toJson() => _$PurchaseReturnResponseToJson(this);

  @override
  List<Object?> get props => [success, message, data];
}

@JsonSerializable()
class PurchaseReturnData extends Equatable {
  final int id;
  final int purchase;
  @JsonKey(name: 'return_date')
  final String returnDate;
  final String reason;
  @JsonKey(name: 'sub_total', fromJson: _parseDouble)
  final double subTotal;
  @JsonKey(name: 'discount', fromJson: _parseDouble)
  final double discount;
  @JsonKey(name: 'vat', fromJson: _parseDouble)
  final double vat;
  @JsonKey(name: 'total', fromJson: _parseDouble)
  final double total;
  final List<PurchaseReturnItem> items;

  const PurchaseReturnData({
    required this.id,
    required this.purchase,
    required this.returnDate,
    required this.reason,
    required this.subTotal,
    required this.discount,
    required this.vat,
    required this.total,
    required this.items,
  });

  factory PurchaseReturnData.fromJson(Map<String, dynamic> json) =>
      _$PurchaseReturnDataFromJson(json);

  Map<String, dynamic> toJson() => _$PurchaseReturnDataToJson(this);

  @override
  List<Object?> get props =>
      [id, purchase, returnDate, reason, subTotal, discount, vat, total, items];

  static double _parseDouble(dynamic value) {
    if (value is String) return double.tryParse(value) ?? 0.0;
    if (value is num) return value.toDouble();
    return 0.0; // Default value if parsing fails
  }
}

@JsonSerializable()
class PurchaseReturnItem extends Equatable {
  final int id;
  final String product;
  final int quantity;
  @JsonKey(name: 'rate', fromJson: _parseDouble)
  final double rate;
  @JsonKey(name: 'total', fromJson: _parseDouble)
  final double total;

  const PurchaseReturnItem({
    required this.id,
    required this.product,
    required this.quantity,
    required this.rate,
    required this.total,
  });

  factory PurchaseReturnItem.fromJson(Map<String, dynamic> json) =>
      _$PurchaseReturnItemFromJson(json);

  Map<String, dynamic> toJson() => _$PurchaseReturnItemToJson(this);

  @override
  List<Object?> get props => [id, product, quantity, rate, total];

  static double _parseDouble(dynamic value) {
    if (value is String) return double.tryParse(value) ?? 0.0;
    if (value is num) return value.toDouble();
    return 0.0; // Default value if parsing fails
  }
}
