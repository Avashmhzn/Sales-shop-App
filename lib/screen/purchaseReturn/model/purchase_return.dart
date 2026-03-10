import 'package:json_annotation/json_annotation.dart';

part 'purchase_return.g.dart';

// Safe number parsing helpers
double _parseDouble(dynamic value) {
  if (value == null) return 0.0;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? 0.0;
  return 0.0;
}

int _parseInt(dynamic value) {
  if (value == null) return 0;
  if (value is int) return value;
  if (value is double) return value.toInt();
  if (value is String) return int.tryParse(value) ?? 0;
  return 0;
}

DateTime _parseDate(String? value) {
  if (value == null) return DateTime.now();
  return DateTime.parse(value);
}

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class PurchaseReturn {
  final int id;
  final int purchase;
  final String? invoiceNumber;
  final String? partyName;

  @JsonKey(fromJson: _parseDate)
  final DateTime returnDate;

  final String? reason;

  @JsonKey(fromJson: _parseDouble)
  final double subTotal;

  @JsonKey(fromJson: _parseDouble)
  final double discount;

  @JsonKey(fromJson: _parseDouble)
  final double vat;

  @JsonKey(fromJson: _parseDouble)
  final double total;

  final List<PurchaseReturnItem> items;
  final String? staff;
  final String? companyName;
  final String? address;
  final String? contactNumber;
  final String? panNumber;
  final String? tagline;

  @JsonKey(fromJson: _parseDouble, defaultValue: 0.0)
  final double taxPercent;

  PurchaseReturn({
    required this.id,
    required this.purchase,
    this.invoiceNumber,
    this.partyName,
    required this.returnDate,
    this.reason,
    required this.subTotal,
    required this.discount,
    required this.vat,
    required this.total,
    required this.items,
    this.staff,
    this.companyName,
    this.address,
    this.contactNumber,
    this.panNumber,
    this.tagline,
    this.taxPercent = 0.0,
  });

  factory PurchaseReturn.fromJson(Map<String, dynamic> json) =>
      _$PurchaseReturnFromJson(json);

  Map<String, dynamic> toJson() => _$PurchaseReturnToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class PurchaseReturnItem {
  final int id;
  final String? product;
  final String? productName;
  final String? batchNumber;

  @JsonKey(fromJson: _parseInt)
  final int quantity;

  @JsonKey(fromJson: _parseDouble)
  final double rate;

  @JsonKey(fromJson: _parseDouble)
  final double total;

  final bool isPartialRefund;

  @JsonKey(fromJson: _parseDouble, defaultValue: 0.0)
  final double refundAmount;

  PurchaseReturnItem({
    required this.id,
    this.product,
    this.productName,
    this.batchNumber,
    required this.quantity,
    required this.rate,
    required this.total,
    required this.isPartialRefund,
    this.refundAmount = 0.0,
  });

  factory PurchaseReturnItem.fromJson(Map<String, dynamic> json) =>
      _$PurchaseReturnItemFromJson(json);

  Map<String, dynamic> toJson() => _$PurchaseReturnItemToJson(this);
}
