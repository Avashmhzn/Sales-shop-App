import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'expiry_response.g.dart';

@JsonSerializable()
class ExpiryResponse {
  final bool success;
  final String? message;
  final List<ExpiryData> data;

  ExpiryResponse({
    required this.success,
    this.message,
    required this.data,
  });

  factory ExpiryResponse.fromJson(Map<String, dynamic> json) =>
      _$ExpiryResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ExpiryResponseToJson(this);
}

@JsonSerializable()
class ExpiryData extends Equatable {
  final int? id;
  final String? product;
  final String? batchNumber;
  @JsonKey(name: 'expiry_date', fromJson: _dateFromJson)
  final DateTime? expiryDate;
  final int? quantity;
  @JsonKey(name: 'cost_price', fromJson: _parseDouble)
  final double? costPrice;
  @JsonKey(name: 'selling_prices', fromJson: _parseDouble)
  final double? sellingPrice;
  @JsonKey(name: 'bulk_price', defaultValue: {})
  final Map<String, double> bulkPrices;
  @JsonKey(name: 'created_on', fromJson: _dateTimeFromJson)
  final DateTime createdOn;
  @JsonKey(name: 'updated_on', fromJson: _dateTimeFromJson)
  final DateTime updatedOn;

  const ExpiryData({
    this.id,
    this.product,
    this.batchNumber,
    this.expiryDate,
    this.quantity,
    this.costPrice,
    this.sellingPrice,
    required this.bulkPrices,
    required this.createdOn,
    required this.updatedOn,
  });

  factory ExpiryData.fromJson(Map<String, dynamic> json) =>
      _$ExpiryDataFromJson(json);

  Map<String, dynamic> toJson() => _$ExpiryDataToJson(this);

  static DateTime? _dateFromJson(dynamic dateStr) {
    if (dateStr == null) return null;
    return DateTime.parse(dateStr as String);
  }

  static DateTime _dateTimeFromJson(String dateTimeStr) =>
      DateTime.parse(dateTimeStr);

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is String) return double.tryParse(value) ?? 0.0;
    if (value is num) return value.toDouble();
    return null;
  }

  @override
  List<Object?> get props => [
        id,
        product,
        batchNumber,
        expiryDate,
        quantity,
        costPrice,
        sellingPrice,
        bulkPrices,
        createdOn,
        updatedOn,
      ];
}
