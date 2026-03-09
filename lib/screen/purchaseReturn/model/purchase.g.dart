// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'purchase.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Purchase _$PurchaseFromJson(Map<String, dynamic> json) => Purchase(
      id: (json['id'] as num).toInt(),
      voucherNumber: json['voucher_number'] as String,
      invoiceNumber: json['invoice_number'] as String,
      billType: json['bill_type'] as String,
      chequeNumber: json['cheque_number'] as String?,
      chequeDate: _parseDateNullable(json['cheque_date'] as String?),
      party: json['party'] as String,
      subTotal: _parseDouble(json['sub_total']),
      vatableAmount: _parseDouble(json['vatable_amount']),
      vat: _parseDouble(json['vat']),
      discount: _parseDouble(json['discount']),
      total: _parseDouble(json['total']),
      tenderAmount: _parseDouble(json['tender_amount']),
      items: (json['items'] as List<dynamic>)
          .map((e) => PurchaseItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      createdOn: _parseDate(json['created_on'] as String),
      updatedOn: _parseDate(json['updated_on'] as String),
      staff: json['staff'] as String,
    );

Map<String, dynamic> _$PurchaseToJson(Purchase instance) => <String, dynamic>{
      'id': instance.id,
      'voucher_number': instance.voucherNumber,
      'invoice_number': instance.invoiceNumber,
      'bill_type': instance.billType,
      'cheque_number': instance.chequeNumber,
      'cheque_date': instance.chequeDate?.toIso8601String(),
      'party': instance.party,
      'sub_total': instance.subTotal,
      'vatable_amount': instance.vatableAmount,
      'vat': instance.vat,
      'discount': instance.discount,
      'total': instance.total,
      'tender_amount': instance.tenderAmount,
      'items': instance.items.map((e) => e.toJson()).toList(),
      'created_on': instance.createdOn.toIso8601String(),
      'updated_on': instance.updatedOn.toIso8601String(),
      'staff': instance.staff,
    };

PurchaseItem _$PurchaseItemFromJson(Map<String, dynamic> json) => PurchaseItem(
      id: (json['id'] as num).toInt(),
      product: json['product'] as String,
      quantity: _parseInt(json['quantity']),
      unit: json['unit'] as String,
      costPrice: _parseDouble(json['cost_price']),
      sellingPrice: _parseDouble(json['selling_price']),
      total: _parseDouble(json['total']),
      expiryDate: _parseDateNullable(json['expiry_date'] as String?),
      batchNumber: json['batch_number'] as String?,
      isComplementary: json['is_complementary'] as bool,
    );

Map<String, dynamic> _$PurchaseItemToJson(PurchaseItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'product': instance.product,
      'quantity': instance.quantity,
      'unit': instance.unit,
      'cost_price': instance.costPrice,
      'selling_price': instance.sellingPrice,
      'total': instance.total,
      'expiry_date': instance.expiryDate?.toIso8601String(),
      'batch_number': instance.batchNumber,
      'is_complementary': instance.isComplementary,
    };
