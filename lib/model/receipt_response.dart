import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'receipt_response.g.dart';

@JsonSerializable()
class ReceiptResponse extends Equatable {
  final bool success;
  final String? message;
  final dynamic data;

  const ReceiptResponse({
    required this.success,
    this.message,
    this.data,
  });

  factory ReceiptResponse.fromJson(Map<String, dynamic> json) {
    print('Parsing ReceiptResponse: $json');
    return _$ReceiptResponseFromJson(json);
  }

  Map<String, dynamic> toJson() => _$ReceiptResponseToJson(this);

  @override
  List<Object?> get props => [success, message, data];
}

@JsonSerializable()
class ReceiptData extends Equatable {
  final int id;
  @JsonKey(name: 'ref_number', fromJson: _parseString)
  final String? refNumber;
  final String? customer;
  @JsonKey(fromJson: _parseDouble)
  final double amount;
  @JsonKey(name: 'deposited_in')
  final String? depositedIn;
  @JsonKey(name: 'cheque_number')
  final String? chequeNumber;
  @JsonKey(name: 'cheque_date')
  final String? chequeDate;
  @JsonKey(fromJson: _parseString)
  final String? signature;
  final String? narration;
  @JsonKey(name: 'created_on')
  final String? createdOn;
  @JsonKey(name: 'updated_on')
  final String? updatedOn;

  const ReceiptData({
    required this.id,
    this.refNumber,
    this.customer,
    required this.amount,
    this.depositedIn,
    this.chequeNumber,
    this.chequeDate,
    this.signature,
    this.narration,
    this.createdOn,
    this.updatedOn,
  });

  factory ReceiptData.fromJson(Map<String, dynamic> json) {
    print('Parsing ReceiptData: $json');
    return _$ReceiptDataFromJson(json);
  }

  Map<String, dynamic> toJson() => _$ReceiptDataToJson(this);

  @override
  List<Object?> get props => [
        id,
        refNumber,
        customer,
        amount,
        depositedIn,
        chequeNumber,
        chequeDate,
        signature,
        narration,
        createdOn,
        updatedOn,
      ];

  static double _parseDouble(dynamic value) {
    if (value is String) return double.tryParse(value) ?? 0.0;
    if (value is num) return value.toDouble();
    return 0.0;
  }

  static String? _parseString(dynamic value) {
    if (value == null) return null;
    return value.toString();
  }
}

@JsonSerializable()
class RemainingReceiptData extends Equatable {
  @JsonKey(name: 'invoice_number', fromJson: _parseString)
  final String invoiceNumber;
  final String date;
  @JsonKey(fromJson: _parseDouble)
  final double total;
  @JsonKey(fromJson: _parseDouble)
  final double received;
  @JsonKey(fromJson: _parseDouble)
  final double remaining;

  const RemainingReceiptData({
    required this.invoiceNumber,
    required this.date,
    required this.total,
    required this.received,
    required this.remaining,
  });

  factory RemainingReceiptData.fromJson(Map<String, dynamic> json) {
    print('Parsing RemainingReceiptData: $json');
    return _$RemainingReceiptDataFromJson(json);
  }

  Map<String, dynamic> toJson() => _$RemainingReceiptDataToJson(this);

  String get dropdownLabel =>
      '$invoiceNumber — Remaining: ${remaining.toStringAsFixed(2)}';

  @override
  List<Object?> get props => [invoiceNumber, date, total, received, remaining];

  static double _parseDouble(dynamic value) {
    if (value is String) return double.tryParse(value) ?? 0.0;
    if (value is num) return value.toDouble();
    return 0.0;
  }

  static String _parseString(dynamic value) {
    if (value == null) return '';
    return value.toString();
  }
}
