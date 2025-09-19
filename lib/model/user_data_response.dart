// lib/models/user_data_response.dart
import 'package:json_annotation/json_annotation.dart';

part 'user_data_response.g.dart';

@JsonSerializable()
class UserDataResponse {
  final bool success;
  final String? message;
  final String? detail;
  final UserData? data;

  UserDataResponse({
    required this.success,
    this.message,
    this.detail,
    this.data,
  });

  factory UserDataResponse.fromJson(Map<String, dynamic> json) =>
      _$UserDataResponseFromJson(json);
  Map<String, dynamic> toJson() => _$UserDataResponseToJson(this);
}

@JsonSerializable()
class UserData {
  final String? first_name;
  final String? last_name;
  final String? email;
  final String? username;
  final String? phone;

  UserData({
    this.first_name,
    this.last_name,
    this.email,
    this.username,
    this.phone,
  });

  factory UserData.fromJson(Map<String, dynamic> json) =>
      _$UserDataFromJson(json);
  Map<String, dynamic> toJson() => _$UserDataToJson(this);
}
