// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'purchase_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PurchaseResponse _$PurchaseResponseFromJson(Map<String, dynamic> json) =>
    PurchaseResponse(
      success: json['success'] as bool,
      message: json['message'] as String?,
      data: json['data'],
    );

Map<String, dynamic> _$PurchaseResponseToJson(PurchaseResponse instance) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
      'data': instance.data,
    };

PurchaseData _$PurchaseDataFromJson(Map<String, dynamic> json) => PurchaseData(
      id: (json['id'] as num?)?.toInt(),
      voucherNumber: (json['voucher_number'] as num?)?.toInt(),
      invoiceNumber: json['invoice_number'] as String?,
      billType: json['bill_type'] as String?,
      chequeNumber: json['cheque_number'] as String?,
      chequeDate: json['cheque_date'] as String?,
      party: json['party'] as String?,
      subTotal: json['sub_total'] as String?,
      vatableAmount: json['vatable_amount'] as String?,
      vat: json['vat'] as String?,
      discount: json['discount'] as String?,
      total: json['total'] as String?,
      tenderAmount: json['tender_amount'] as String?,
      purchaseItems: (json['items'] as List<dynamic>?)
          ?.map((e) => PurchaseItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      createdOn: PurchaseData._dateTimeFromJson(json['created_on'] as String?),
      updatedOn: PurchaseData._dateTimeFromJson(json['updated_on'] as String?),
    );

Map<String, dynamic> _$PurchaseDataToJson(PurchaseData instance) =>
    <String, dynamic>{
      'id': instance.id,
      'voucher_number': instance.voucherNumber,
      'invoice_number': instance.invoiceNumber,
      'bill_type': instance.billType,
      'cheque_number': instance.chequeNumber,
      'cheque_date': instance.chequeDate,
      'party': instance.party,
      'sub_total': instance.subTotal,
      'vatable_amount': instance.vatableAmount,
      'vat': instance.vat,
      'discount': instance.discount,
      'total': instance.total,
      'tender_amount': instance.tenderAmount,
      'items': instance.purchaseItems,
      'created_on': instance.createdOn?.toIso8601String(),
      'updated_on': instance.updatedOn?.toIso8601String(),
    };

PurchaseItem _$PurchaseItemFromJson(Map<String, dynamic> json) => PurchaseItem(
      id: (json['id'] as num?)?.toInt(),
      product: json['product'] as String?,
      quantity: (json['quantity'] as num?)?.toInt(),
      unit: json['unit'] as String?,
      costPrice: json['cost_price'] as String?,
      sellingPrice: json['selling_price'] as String?,
      total: json['total'] as String?,
      expiryDate: PurchaseItem._dateFromJson(json['expiry_date'] as String?),
      batchNumber: json['batch_number'] as String?,
      isComplementary: json['is_complementary'] as bool? ?? false,
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
