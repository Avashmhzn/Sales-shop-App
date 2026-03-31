import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'party_response.g.dart';

// Custom converter to handle double? fields that may be String or num
class NullableDoubleConverter implements JsonConverter<double?, dynamic> {
  const NullableDoubleConverter();

  @override
  double? fromJson(dynamic json) {
    if (json == null) return null;
    if (json is num) return json.toDouble();
    if (json is String) return double.tryParse(json);
    return null;
  }

  @override
  dynamic toJson(double? value) => value;
}

// Custom converter to handle int? fields that may be String or int
class NullableIntConverter implements JsonConverter<int?, dynamic> {
  const NullableIntConverter();

  @override
  int? fromJson(dynamic json) {
    if (json == null) return null;
    if (json is int) return json;
    if (json is String) return int.tryParse(json);
    return null;
  }

  @override
  dynamic toJson(int? value) => value;
}

@JsonSerializable()
class PartyResponse {
  final bool success;
  final String? message;
  final String? detail;
  @NullableIntConverter()
  final int? total;
  final List<PartyData> data;

  PartyResponse({
    required this.success,
    this.message,
    this.detail,
    this.total,
    required this.data,
  });

  factory PartyResponse.fromJson(Map<String, dynamic> json) =>
      _$PartyResponseFromJson(json);

  Map<String, dynamic> toJson() => _$PartyResponseToJson(this);
}

@JsonSerializable()
class PartyData extends Equatable {
  final int id;
  final String name;
  final String? type;
  @JsonKey(name: 'acc_type')
  final String? accType;
  @JsonKey(name: 'pan_number')
  final String? panNumber;
  final String? phone;
  final String? address;
  final String? description;
  @JsonKey(name: 'opening_balance')
  @NullableDoubleConverter()
  final double? openingBalance;
  final bool? status;
  @JsonKey(name: 'created_on')
  final DateTime? createdOn;
  @JsonKey(name: 'updated_on')
  final DateTime? updatedOn;
  @JsonKey(name: 'acc_id')
  @NullableIntConverter()
  final int? accId;

  const PartyData({
    required this.id,
    required this.name,
    this.type,
    this.accType,
    this.panNumber,
    this.phone,
    this.address,
    this.description,
    this.openingBalance,
    this.status,
    this.createdOn,
    this.updatedOn,
    this.accId,
  });

  factory PartyData.fromJson(Map<String, dynamic> json) =>
      _$PartyDataFromJson(json);

  Map<String, dynamic> toJson() => _$PartyDataToJson(this);

  @override
  List<Object?> get props => [
        id,
        name,
        type,
        accType,
        panNumber,
        phone,
        address,
        description,
        openingBalance,
        status,
        createdOn,
        updatedOn,
        accId,
      ];
}
