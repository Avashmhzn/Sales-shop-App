// import 'package:equatable/equatable.dart';
// import 'package:json_annotation/json_annotation.dart';

// part 'purchase_response.g.dart';

// @JsonSerializable()
// class PurchaseResponse {
//   final bool success;
//   final String? message;
//   final dynamic data; // Changed to dynamic to handle both List and Map

//   PurchaseResponse({
//     required this.success,
//     this.message,
//     this.data,
//   });

//   factory PurchaseResponse.fromJson(Map<String, dynamic> json) =>
//       _$PurchaseResponseFromJson(json);

//   Map<String, dynamic> toJson() => _$PurchaseResponseToJson(this);
// }

// @JsonSerializable()
// class PurchaseData extends Equatable {
//   final int? id;
//   @JsonKey(name: 'voucher_number')
//   final int? voucherNumber;
//   @JsonKey(name: 'invoice_number')
//   final String? invoiceNumber;
//   @JsonKey(name: 'bill_type')
//   final String? billType;
//   @JsonKey(name: 'cheque_number')
//   final String? chequeNumber;
//   @JsonKey(name: 'cheque_date')
//   final String? chequeDate;
//   final String? party;
//   @JsonKey(name: 'sub_total')
//   final String? subTotal;
//   @JsonKey(name: 'vatable_amount')
//   final String? vatableAmount;
//   final String? vat;
//   final String? discount;
//   final String? total;
//   @JsonKey(name: 'tender_amount')
//   final String? tenderAmount;
//   @JsonKey(name: 'items')
//   final List<PurchaseItem>? purchaseItems;
//   @JsonKey(name: 'created_on', fromJson: _dateTimeFromJson)
//   final DateTime? createdOn;
//   @JsonKey(name: 'updated_on', fromJson: _dateTimeFromJson)
//   final DateTime? updatedOn;

//   const PurchaseData({
//     this.id,
//     this.voucherNumber,
//     this.invoiceNumber,
//     this.billType,
//     this.chequeNumber,
//     this.chequeDate,
//     this.party,
//     this.subTotal,
//     this.vatableAmount,
//     this.vat,
//     this.discount,
//     this.total,
//     this.tenderAmount,
//     this.purchaseItems,
//     this.createdOn,
//     this.updatedOn,
//   });

//   factory PurchaseData.fromJson(Map<String, dynamic> json) =>
//       _$PurchaseDataFromJson(json);

//   Map<String, dynamic> toJson() => _$PurchaseDataToJson(this);

//   static DateTime? _dateTimeFromJson(String? dateTimeStr) {
//     if (dateTimeStr == null) return null;
//     return DateTime.tryParse(dateTimeStr);
//   }

//   @override
//   List<Object?> get props => [
//         id,
//         voucherNumber,
//         invoiceNumber,
//         billType,
//         chequeNumber,
//         chequeDate,
//         party,
//         subTotal,
//         vatableAmount,
//         vat,
//         discount,
//         total,
//         tenderAmount,
//         purchaseItems,
//         createdOn,
//         updatedOn,
//       ];
// }

// @JsonSerializable()
// class PurchaseItem extends Equatable {
//   final int? id;
//   final String? product;
//   final int? quantity;
//   final String? unit;
//   @JsonKey(name: 'cost_price')
//   final String? costPrice;
//   @JsonKey(name: 'selling_price')
//   final String? sellingPrice;
//   final String? total;
//   @JsonKey(name: 'expiry_date', fromJson: _dateFromJson)
//   final DateTime? expiryDate;
//   @JsonKey(name: 'batch_number')
//   final String? batchNumber;
//   @JsonKey(name: 'is_complementary', defaultValue: false)
//   final bool isComplementary;

//   const PurchaseItem({
//     this.id,
//     this.product,
//     this.quantity,
//     this.unit,
//     this.costPrice,
//     this.sellingPrice,
//     this.total,
//     this.expiryDate,
//     this.batchNumber,
//     this.isComplementary = false,
//   });

//   factory PurchaseItem.fromJson(Map<String, dynamic> json) =>
//       _$PurchaseItemFromJson(json);

//   Map<String, dynamic> toJson() => _$PurchaseItemToJson(this);

//   static DateTime? _dateFromJson(String? dateStr) {
//     if (dateStr == null) return null;
//     return DateTime.tryParse(dateStr);
//   }

//   @override
//   List<Object?> get props => [
//         id,
//         product,
//         quantity,
//         unit,
//         costPrice,
//         sellingPrice,
//         total,
//         expiryDate,
//         batchNumber,
//         isComplementary,
//       ];
// }
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'purchase_response.g.dart';

// Safe parsers
double? _parseDouble(dynamic v) {
  if (v == null) return null;
  if (v is double) return v;
  if (v is int) return v.toDouble();
  if (v is String) return double.tryParse(v.trim());
  return null;
}

DateTime? _parseDateTime(dynamic value) {
  if (value == null) return null;
  final s = value.toString().trim();
  if (s.isEmpty) return null;
  try {
    return DateTime.parse(s);
  } catch (_) {
    return null;
  }
}

// Prevents "Null is not a subtype of type 'bool'" crash
bool _parseBool(dynamic v) {
  if (v == null) return false;
  if (v is bool) return v;
  if (v is int) return v != 0;
  if (v is String) {
    final lower = v.trim().toLowerCase();
    return lower == 'true' || lower == '1';
  }
  return false;
}

@JsonSerializable()
class PurchaseResponse {
  @JsonKey(fromJson: _parseBool)
  final bool success;
  final String? message;
  final dynamic data;

  PurchaseResponse({
    required this.success,
    this.message,
    this.data,
  });

  factory PurchaseResponse.fromJson(Map<String, dynamic> json) =>
      _$PurchaseResponseFromJson(json);

  Map<String, dynamic> toJson() => _$PurchaseResponseToJson(this);
}

@JsonSerializable()
class PurchaseData extends Equatable {
  final int? id;

  @JsonKey(name: 'voucher_number')
  final String? voucherNumber;

  @JsonKey(name: 'invoice_number')
  final String? invoiceNumber;

  @JsonKey(name: 'bill_type')
  final String? billType;

  @JsonKey(name: 'cheque_number')
  final String? chequeNumber;

  @JsonKey(name: 'cheque_date')
  final String? chequeDate;

  final String? party;

  @JsonKey(name: 'sub_total', fromJson: _parseDouble)
  final double? subTotal;

  @JsonKey(name: 'vatable_amount', fromJson: _parseDouble)
  final double? vatableAmount;

  @JsonKey(fromJson: _parseDouble)
  final double? vat;

  @JsonKey(fromJson: _parseDouble)
  final double? discount;

  @JsonKey(fromJson: _parseDouble)
  final double? total;

  @JsonKey(name: 'tender_amount', fromJson: _parseDouble)
  final double? tenderAmount;

  @JsonKey(name: 'items')
  final List<PurchaseItem>? purchaseItems;

  @JsonKey(name: 'created_on', fromJson: _parseDateTime)
  final DateTime? createdOn;

  @JsonKey(name: 'updated_on', fromJson: _parseDateTime)
  final DateTime? updatedOn;

  const PurchaseData({
    this.id,
    this.voucherNumber,
    this.invoiceNumber,
    this.billType,
    this.chequeNumber,
    this.chequeDate,
    this.party,
    this.subTotal,
    this.vatableAmount,
    this.vat,
    this.discount,
    this.total,
    this.tenderAmount,
    this.purchaseItems,
    this.createdOn,
    this.updatedOn,
  });

  factory PurchaseData.fromJson(Map<String, dynamic> json) =>
      _$PurchaseDataFromJson(json);

  Map<String, dynamic> toJson() => _$PurchaseDataToJson(this);

  @override
  List<Object?> get props => [
        id,
        voucherNumber,
        invoiceNumber,
        billType,
        chequeNumber,
        chequeDate,
        party,
        subTotal,
        vatableAmount,
        vat,
        discount,
        total,
        tenderAmount,
        purchaseItems,
        createdOn,
        updatedOn,
      ];
}

@JsonSerializable()
class PurchaseItem extends Equatable {
  final int? id;
  final String? product;
  final int? quantity;
  final String? unit;

  @JsonKey(name: 'cost_price', fromJson: _parseDouble)
  final double? costPrice;

  @JsonKey(name: 'selling_price', fromJson: _parseDouble)
  final double? sellingPrice;

  @JsonKey(fromJson: _parseDouble)
  final double? total;

  @JsonKey(name: 'expiry_date', fromJson: _parseDateTime)
  final DateTime? expiryDate;

  @JsonKey(name: 'batch_number')
  final String? batchNumber;

  // Safe bool with default false if null or invalid
  @JsonKey(name: 'is_complementary', fromJson: _parseBool)
  final bool isComplementary;

  const PurchaseItem({
    this.id,
    this.product,
    this.quantity,
    this.unit,
    this.costPrice,
    this.sellingPrice,
    this.total,
    this.expiryDate,
    this.batchNumber,
    this.isComplementary = false,
  });

  factory PurchaseItem.fromJson(Map<String, dynamic> json) =>
      _$PurchaseItemFromJson(json);

  Map<String, dynamic> toJson() => _$PurchaseItemToJson(this);

  @override
  List<Object?> get props => [
        id,
        product,
        quantity,
        unit,
        costPrice,
        sellingPrice,
        total,
        expiryDate,
        batchNumber,
        isComplementary,
      ];
}
