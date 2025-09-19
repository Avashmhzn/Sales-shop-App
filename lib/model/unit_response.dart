import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'unit_response.g.dart';

@JsonSerializable()
class UnitResponse {
  final bool success;
  final String? message;
  final List<UnitData> data;

  UnitResponse({
    required this.success,
    this.message,
    required this.data,
  });

  factory UnitResponse.fromJson(Map<String, dynamic> json) =>
      _$UnitResponseFromJson(json);

  Map<String, dynamic> toJson() => _$UnitResponseToJson(this);
}

@JsonSerializable()
class UnitData extends Equatable {
  final int id;
  final String name;
  final String? description;

  const UnitData({
    required this.id,
    required this.name,
    this.description,
  });

  factory UnitData.fromJson(Map<String, dynamic> json) =>
      _$UnitDataFromJson(json);

  Map<String, dynamic> toJson() => _$UnitDataToJson(this);

  @override
  List<Object?> get props => [id, name, description];
}
