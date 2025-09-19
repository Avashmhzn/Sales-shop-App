import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'payment_response.g.dart';

@JsonSerializable()
class PaymentResponse extends Equatable {
  final bool success;
  final String? message;
  final dynamic data;

  const PaymentResponse({
    required this.success,
    this.message,
    this.data,
  });

  factory PaymentResponse.fromJson(Map<String, dynamic> json) {
    print('Parsing PaymentResponse: $json');
    return _$PaymentResponseFromJson(json);
  }

  Map<String, dynamic> toJson() => _$PaymentResponseToJson(this);

  @override
  List<Object?> get props => [success, message, data];
}

@JsonSerializable()
class PaymentData extends Equatable {
  final int id;
  @JsonKey(name: 'ref_number')
  final String? refNumber;
  final String? supplier;
  @JsonKey(fromJson: _parseDouble)
  final double amount;
  @JsonKey(name: 'payment_mode')
  final String? paymentMode;
  @JsonKey(name: 'cheque_number')
  final String? chequeNumber;
  @JsonKey(name: 'cheque_date')
  final String? chequeDate;
  final String? signature;
  final String? narration;
  @JsonKey(name: 'created_on')
  final String? createdOn;
  @JsonKey(name: 'updated_on')
  final String? updatedOn;

  const PaymentData({
    required this.id,
    this.refNumber,
    this.supplier,
    required this.amount,
    this.paymentMode,
    this.chequeNumber,
    this.chequeDate,
    this.signature,
    this.narration,
    this.createdOn,
    this.updatedOn,
  });

  factory PaymentData.fromJson(Map<String, dynamic> json) {
    print('Parsing PaymentData: $json');
    return _$PaymentDataFromJson(json);
  }

  Map<String, dynamic> toJson() => _$PaymentDataToJson(this);

  @override
  List<Object?> get props => [
        id,
        refNumber,
        supplier,
        amount,
        paymentMode,
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
}
