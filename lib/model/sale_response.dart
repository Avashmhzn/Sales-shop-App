import 'package:json_annotation/json_annotation.dart';

part 'sale_response.g.dart';

@JsonSerializable()
class SaleResponse {
  final bool success;
  final String? message;
  final dynamic data;

  SaleResponse({
    required this.success,
    this.message,
    this.data,
  });

  factory SaleResponse.fromJson(Map<String, dynamic> json) =>
      _$SaleResponseFromJson(json);
  Map<String, dynamic> toJson() => _$SaleResponseToJson(this);
}

@JsonSerializable()
class SaleData {
  @JsonKey(name: 'id', fromJson: _intFromJson)
  final int? id;
  @JsonKey(name: 'invoice_number', fromJson: _intFromJson)
  final int? invoiceNumber;
  @JsonKey(name: 'date')
  final String? date;
  @JsonKey(name: 'bill_type')
  final String? billType;
  @JsonKey(name: 'cheque_number')
  final String? chequeNumber;
  @JsonKey(name: 'cheque_date')
  final String? chequeDate;
  @JsonKey(name: 'payment_mode')
  final String? paymentMode;
  @JsonKey(name: 'customer')
  final String? customer;
  @JsonKey(name: 'description')
  final String? description;
  @JsonKey(name: 'items')
  final List<SaleItem> items;
  @JsonKey(name: 'sub_total', fromJson: _doubleFromJson)
  final double? subTotal;
  @JsonKey(name: 'vatable_amount', fromJson: _doubleFromJson)
  final double? vatableAmount;
  @JsonKey(name: 'vat', fromJson: _doubleFromJson)
  final double? vat;
  @JsonKey(name: 'discount', fromJson: _doubleFromJson)
  final double? discount;
  @JsonKey(name: 'total', fromJson: _doubleFromJson)
  final double? total;
  @JsonKey(name: 'tender_amount', fromJson: _doubleFromJson)
  final double? tenderAmount;
  @JsonKey(name: 'created_on')
  final String? createdOn;
  @JsonKey(name: 'updated_on')
  final String? updatedOn;

  SaleData({
    this.id,
    this.invoiceNumber,
    this.date,
    this.billType,
    this.chequeNumber,
    this.chequeDate,
    this.paymentMode,
    this.customer,
    this.description,
    required this.items,
    this.subTotal,
    this.vatableAmount,
    this.vat,
    this.discount,
    this.total,
    this.tenderAmount,
    this.createdOn,
    this.updatedOn,
  });

  factory SaleData.fromJson(Map<String, dynamic> json) =>
      _$SaleDataFromJson(json);
  Map<String, dynamic> toJson() => _$SaleDataToJson(this);

  static int? _intFromJson(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) {
      return int.tryParse(value) ?? double.tryParse(value)?.toInt();
    }
    if (value is double) return value.toInt();
    return null;
  }

  static double? _doubleFromJson(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }
}

@JsonSerializable()
class SaleItem {
  @JsonKey(name: 'id', fromJson: _intFromJson)
  final int? id;
  @JsonKey(name: 'product', fromJson: _intFromJson)
  final int? product;
  @JsonKey(name: 'quantity', fromJson: _intFromJson)
  final int? quantity;
  @JsonKey(name: 'rate', fromJson: _doubleFromJson)
  final double? rate;
  @JsonKey(name: 'total', fromJson: _doubleFromJson)
  final double? total;
  @JsonKey(name: 'product_name')
  final String? productName;

  SaleItem({
    this.id,
    this.product,
    this.quantity,
    this.rate,
    this.total,
    this.productName,
  });

  factory SaleItem.fromJson(Map<String, dynamic> json) =>
      _$SaleItemFromJson(json);
  Map<String, dynamic> toJson() => _$SaleItemToJson(this);

  static int? _intFromJson(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) {
      return int.tryParse(value) ?? double.tryParse(value)?.toInt();
    }
    if (value is double) return value.toInt();
    return null;
  }

  static double? _doubleFromJson(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }
}
