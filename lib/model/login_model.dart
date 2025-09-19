// lib/models/login_response.dart
import 'package:json_annotation/json_annotation.dart';

part 'login_model.g.dart';

@JsonSerializable()
class LoginResponse {
  final bool success;
  final String? message;
  final LoginData? data;

  LoginResponse({
    required this.success,
    this.message,
    this.data,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) =>
      _$LoginResponseFromJson(json);
  Map<String, dynamic> toJson() => _$LoginResponseToJson(this);
}

@JsonSerializable()
class LoginData {
  final String? access_token;
  final String? refresh_token;
  final int? user_id;
  final String? email;
  final String? username;
  final String? first_name;
  final String? last_name;
  final String? phone;

  LoginData({
    this.access_token,
    this.refresh_token,
    this.user_id,
    this.email,
    this.username,
    this.first_name,
    this.last_name,
    this.phone,
  });

  factory LoginData.fromJson(Map<String, dynamic> json) =>
      _$LoginDataFromJson(json);
  Map<String, dynamic> toJson() => _$LoginDataToJson(this);
}
