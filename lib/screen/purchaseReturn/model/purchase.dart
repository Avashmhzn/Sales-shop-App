import 'package:json_annotation/json_annotation.dart';

part 'purchase.g.dart';

// Safe parsing helpers
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

DateTime _parseDate(String value) => DateTime.parse(value);

DateTime? _parseDateNullable(String? value) =>
    value != null ? DateTime.parse(value) : null;

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class Purchase {
  final int id;
  final String voucherNumber;
  final String invoiceNumber;
  final String billType;
  final String? chequeNumber;

  @JsonKey(fromJson: _parseDateNullable)
  final DateTime? chequeDate;

  final String party;

  @JsonKey(fromJson: _parseDouble)
  final double subTotal;

  @JsonKey(fromJson: _parseDouble)
  final double vatableAmount;

  @JsonKey(fromJson: _parseDouble)
  final double vat;

  @JsonKey(fromJson: _parseDouble)
  final double discount;

  @JsonKey(fromJson: _parseDouble)
  final double total;

  @JsonKey(fromJson: _parseDouble)
  final double tenderAmount;

  final List<PurchaseItem> items;

  @JsonKey(fromJson: _parseDate)
  final DateTime createdOn;

  @JsonKey(fromJson: _parseDate)
  final DateTime updatedOn;

  final String staff;

  Purchase({
    required this.id,
    required this.voucherNumber,
    required this.invoiceNumber,
    required this.billType,
    this.chequeNumber,
    this.chequeDate,
    required this.party,
    required this.subTotal,
    required this.vatableAmount,
    required this.vat,
    required this.discount,
    required this.total,
    required this.tenderAmount,
    required this.items,
    required this.createdOn,
    required this.updatedOn,
    required this.staff,
  });

  factory Purchase.fromJson(Map<String, dynamic> json) =>
      _$PurchaseFromJson(json);

  Map<String, dynamic> toJson() => _$PurchaseToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class PurchaseItem {
  final int id;
  final String product;

  @JsonKey(fromJson: _parseInt)
  final int quantity;

  final String unit;

  @JsonKey(fromJson: _parseDouble)
  final double costPrice;

  @JsonKey(fromJson: _parseDouble)
  final double sellingPrice;

  @JsonKey(fromJson: _parseDouble)
  final double total;

  @JsonKey(fromJson: _parseDateNullable)
  final DateTime? expiryDate;

  final String? batchNumber;
  final bool isComplementary;

  PurchaseItem({
    required this.id,
    required this.product,
    required this.quantity,
    required this.unit,
    required this.costPrice,
    required this.sellingPrice,
    required this.total,
    this.expiryDate,
    this.batchNumber,
    required this.isComplementary,
  });

  factory PurchaseItem.fromJson(Map<String, dynamic> json) =>
      _$PurchaseItemFromJson(json);

  Map<String, dynamic> toJson() => _$PurchaseItemToJson(this);
}
