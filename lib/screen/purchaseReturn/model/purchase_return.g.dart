// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'purchase_return.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PurchaseReturn _$PurchaseReturnFromJson(Map<String, dynamic> json) =>
    PurchaseReturn(
      id: (json['id'] as num).toInt(),
      purchase: (json['purchase'] as num).toInt(),
      invoiceNumber: json['invoice_number'] as String,
      partyName: json['party_name'] as String,
      returnDate: _parseDate(json['return_date'] as String),
      reason: json['reason'] as String,
      subTotal: _parseDouble(json['sub_total']),
      discount: _parseDouble(json['discount']),
      vat: _parseDouble(json['vat']),
      total: _parseDouble(json['total']),
      items: (json['items'] as List<dynamic>)
          .map((e) => PurchaseReturnItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      staff: json['staff'] as String,
      companyName: json['company_name'] as String,
      address: json['address'] as String,
      contactNumber: json['contact_number'] as String,
      panNumber: json['pan_number'] as String,
      tagline: json['tagline'] as String,
      taxPercent:
          json['tax_percent'] == null ? 0.0 : _parseDouble(json['tax_percent']),
    );

Map<String, dynamic> _$PurchaseReturnToJson(PurchaseReturn instance) =>
    <String, dynamic>{
      'id': instance.id,
      'purchase': instance.purchase,
      'invoice_number': instance.invoiceNumber,
      'party_name': instance.partyName,
      'return_date': instance.returnDate.toIso8601String(),
      'reason': instance.reason,
      'sub_total': instance.subTotal,
      'discount': instance.discount,
      'vat': instance.vat,
      'total': instance.total,
      'items': instance.items.map((e) => e.toJson()).toList(),
      'staff': instance.staff,
      'company_name': instance.companyName,
      'address': instance.address,
      'contact_number': instance.contactNumber,
      'pan_number': instance.panNumber,
      'tagline': instance.tagline,
      'tax_percent': instance.taxPercent,
    };

PurchaseReturnItem _$PurchaseReturnItemFromJson(Map<String, dynamic> json) =>
    PurchaseReturnItem(
      id: (json['id'] as num).toInt(),
      product: json['product'] as String,
      productName: json['product_name'] as String,
      batchNumber: json['batch_number'] as String,
      quantity: _parseInt(json['quantity']),
      rate: _parseDouble(json['rate']),
      total: _parseDouble(json['total']),
      isPartialRefund: json['is_partial_refund'] as bool,
      refundAmount: json['refund_amount'] == null
          ? 0.0
          : _parseDouble(json['refund_amount']),
    );

Map<String, dynamic> _$PurchaseReturnItemToJson(PurchaseReturnItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'product': instance.product,
      'product_name': instance.productName,
      'batch_number': instance.batchNumber,
      'quantity': instance.quantity,
      'rate': instance.rate,
      'total': instance.total,
      'is_partial_refund': instance.isPartialRefund,
      'refund_amount': instance.refundAmount,
    };
