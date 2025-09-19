import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'location_response.g.dart';

@JsonSerializable()
class LocationResponse {
  final bool success;
  final String? message;
  final String? detail;
  @JsonKey(name: 'total')
  final int? total;
  final List<LocationData> data;

  LocationResponse({
    required this.success,
    this.message,
    this.detail,
    this.total,
    required this.data,
  });

  factory LocationResponse.fromJson(Map<String, dynamic> json) =>
      _$LocationResponseFromJson(json);

  Map<String, dynamic> toJson() => _$LocationResponseToJson(this);
}

@JsonSerializable()
class LocationData extends Equatable {
  final int id;
  final String code;
  final String name;

  const LocationData({
    required this.id,
    required this.code,
    required this.name,
  });

  factory LocationData.fromJson(Map<String, dynamic> json) =>
      _$LocationDataFromJson(json);

  Map<String, dynamic> toJson() => _$LocationDataToJson(this);

  @override
  List<Object?> get props => [id, code, name];
}
