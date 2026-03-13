import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'voucher_response.g.dart';

@JsonSerializable()
class VoucherResponse extends Equatable {
  final bool success;
  final String? message;
  final dynamic data;

  const VoucherResponse({
    required this.success,
    this.message,
    this.data,
  });

  factory VoucherResponse.fromJson(Map<String, dynamic> json) {
    print('Parsing VoucherResponse: $json');
    return _$VoucherResponseFromJson(json);
  }

  Map<String, dynamic> toJson() => _$VoucherResponseToJson(this);

  @override
  List<Object?> get props => [success, message, data];
}

@JsonSerializable()
class VoucherData extends Equatable {
  final int id;
  final String? type;
  @JsonKey(name: 'voucher_number')
  final String? voucherNumber;
  final String? status;
  @JsonKey(name: 'total_debit', fromJson: _parseDouble)
  final double totalDebit;
  @JsonKey(name: 'total_credit', fromJson: _parseDouble)
  final double totalCredit;
  @JsonKey(name: 'voucher_date')
  final String? voucherDate;
  final String? signature;
  final String? narration;
  @JsonKey(name: 'created_by')
  final String? createdBy;
  @JsonKey(name: 'created_on')
  final String? createdOn;
  @JsonKey(name: 'updated_on')
  final String? updatedOn;
  @JsonKey(name: 'voucher_items', defaultValue: [])
  final List<VoucherItem> voucherItems;

  const VoucherData({
    required this.id,
    this.type,
    this.voucherNumber,
    this.status,
    required this.totalDebit,
    required this.totalCredit,
    this.voucherDate,
    this.signature,
    this.narration,
    this.createdBy,
    this.createdOn,
    this.updatedOn,
    this.voucherItems = const [],
  });

  factory VoucherData.fromJson(Map<String, dynamic> json) {
    print('Parsing VoucherData: $json');
    return _$VoucherDataFromJson(json);
  }

  Map<String, dynamic> toJson() => _$VoucherDataToJson(this);

  @override
  List<Object?> get props => [
        id,
        type,
        voucherNumber,
        status,
        totalDebit,
        totalCredit,
        voucherDate,
        signature,
        narration,
        createdBy,
        createdOn,
        updatedOn,
        voucherItems
      ];

  static double _parseDouble(dynamic value) {
    if (value is String) return double.tryParse(value) ?? 0.0;
    if (value is num) return value.toDouble();
    return 0.0;
  }
}

@JsonSerializable()
class VoucherItem extends Equatable {
  final int id;
  final int voucher;
  final String? account;
  @JsonKey(fromJson: _parseDouble)
  final double debit;
  @JsonKey(fromJson: _parseDouble)
  final double credit;
  @JsonKey(name: 'is_tax_line')
  final bool? isTaxLine;

  const VoucherItem({
    required this.id,
    required this.voucher,
    this.account,
    required this.debit,
    required this.credit,
    this.isTaxLine,
  });

  factory VoucherItem.fromJson(Map<String, dynamic> json) {
    print('Parsing VoucherItem: $json');
    return _$VoucherItemFromJson(json);
  }

  Map<String, dynamic> toJson() => _$VoucherItemToJson(this);

  @override
  List<Object?> get props => [id, voucher, account, debit, credit, isTaxLine];

  static double _parseDouble(dynamic value) {
    if (value is String) return double.tryParse(value) ?? 0.0;
    if (value is num) return value.toDouble();
    return 0.0;
  }
}
