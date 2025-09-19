// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sale_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SaleResponse _$SaleResponseFromJson(Map<String, dynamic> json) => SaleResponse(
      success: json['success'] as bool,
      message: json['message'] as String?,
      data: json['data'],
    );

Map<String, dynamic> _$SaleResponseToJson(SaleResponse instance) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
      'data': instance.data,
    };

SaleData _$SaleDataFromJson(Map<String, dynamic> json) => SaleData(
      id: SaleData._intFromJson(json['id']),
      invoiceNumber: SaleData._intFromJson(json['invoice_number']),
      date: json['date'] as String?,
      billType: json['bill_type'] as String?,
      chequeNumber: json['cheque_number'] as String?,
      chequeDate: json['cheque_date'] as String?,
      paymentMode: json['payment_mode'] as String?,
      customer: json['customer'] as String?,
      description: json['description'] as String?,
      items: (json['items'] as List<dynamic>)
          .map((e) => SaleItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      subTotal: SaleData._doubleFromJson(json['sub_total']),
      vatableAmount: SaleData._doubleFromJson(json['vatable_amount']),
      vat: SaleData._doubleFromJson(json['vat']),
      discount: SaleData._doubleFromJson(json['discount']),
      total: SaleData._doubleFromJson(json['total']),
      tenderAmount: SaleData._doubleFromJson(json['tender_amount']),
      createdOn: json['created_on'] as String?,
      updatedOn: json['updated_on'] as String?,
    );

Map<String, dynamic> _$SaleDataToJson(SaleData instance) => <String, dynamic>{
      'id': instance.id,
      'invoice_number': instance.invoiceNumber,
      'date': instance.date,
      'bill_type': instance.billType,
      'cheque_number': instance.chequeNumber,
      'cheque_date': instance.chequeDate,
      'payment_mode': instance.paymentMode,
      'customer': instance.customer,
      'description': instance.description,
      'items': instance.items,
      'sub_total': instance.subTotal,
      'vatable_amount': instance.vatableAmount,
      'vat': instance.vat,
      'discount': instance.discount,
      'total': instance.total,
      'tender_amount': instance.tenderAmount,
      'created_on': instance.createdOn,
      'updated_on': instance.updatedOn,
    };

SaleItem _$SaleItemFromJson(Map<String, dynamic> json) => SaleItem(
      id: SaleItem._intFromJson(json['id']),
      product: SaleItem._intFromJson(json['product']),
      quantity: SaleItem._intFromJson(json['quantity']),
      rate: SaleItem._doubleFromJson(json['rate']),
      total: SaleItem._doubleFromJson(json['total']),
      productName: json['product_name'] as String?,
    );

Map<String, dynamic> _$SaleItemToJson(SaleItem instance) => <String, dynamic>{
      'id': instance.id,
      'product': instance.product,
      'quantity': instance.quantity,
      'rate': instance.rate,
      'total': instance.total,
      'product_name': instance.productName,
    };
