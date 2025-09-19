import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'sale_return_response.g.dart';

@JsonSerializable()
class SaleReturnResponse extends Equatable {
  final bool success;
  final String? message;
  final dynamic data; // Dynamic to handle both List and Map

  const SaleReturnResponse({
    required this.success,
    this.message,
    this.data,
  });

  factory SaleReturnResponse.fromJson(Map<String, dynamic> json) =>
      _$SaleReturnResponseFromJson(json);

  Map<String, dynamic> toJson() => _$SaleReturnResponseToJson(this);

  @override
  List<Object?> get props => [success, message, data];
}

@JsonSerializable()
class SaleReturnData extends Equatable {
  final int id;
  final int sale;
  @JsonKey(name: 'return_date')
  final String returnDate;
  final String reason;
  @JsonKey(name: 'sub_total', fromJson: _parseDouble)
  final double subTotal;
  @JsonKey(name: 'vat', fromJson: _parseDouble)
  final double vat;
  @JsonKey(name: 'discount', fromJson: _parseDouble)
  final double discount;
  @JsonKey(name: 'total', fromJson: _parseDouble)
  final double total;
  final List<SaleReturnItem> items;

  const SaleReturnData({
    required this.id,
    required this.sale,
    required this.returnDate,
    required this.reason,
    required this.subTotal,
    required this.vat,
    required this.discount,
    required this.total,
    required this.items,
  });

  factory SaleReturnData.fromJson(Map<String, dynamic> json) =>
      _$SaleReturnDataFromJson(json);

  Map<String, dynamic> toJson() => _$SaleReturnDataToJson(this);

  @override
  List<Object?> get props =>
      [id, sale, returnDate, reason, subTotal, vat, discount, total, items];

  static double _parseDouble(dynamic value) {
    if (value is String) return double.tryParse(value) ?? 0.0;
    if (value is num) return value.toDouble();
    return 0.0; // Default value if parsing fails
  }
}

@JsonSerializable()
class SaleReturnItem extends Equatable {
  final int id;
  final String product;
  final int quantity;
  @JsonKey(name: 'rate', fromJson: _parseDouble)
  final double rate;
  @JsonKey(name: 'total', fromJson: _parseDouble)
  final double total;

  const SaleReturnItem({
    required this.id,
    required this.product,
    required this.quantity,
    required this.rate,
    required this.total,
  });

  factory SaleReturnItem.fromJson(Map<String, dynamic> json) =>
      _$SaleReturnItemFromJson(json);

  Map<String, dynamic> toJson() => _$SaleReturnItemToJson(this);

  @override
  List<Object?> get props => [id, product, quantity, rate, total];

  static double _parseDouble(dynamic value) {
    if (value is String) return double.tryParse(value) ?? 0.0;
    if (value is num) return value.toDouble();
    return 0.0; // Default value if parsing fails
  }
}
