// lib/models/verify_otp_response.dart
import 'package:json_annotation/json_annotation.dart';

part 'verify_otp_response.g.dart';

@JsonSerializable()
class VerifyOtpResponse {
  final bool success;
  final String? message;
  final String? detail;
  final String? data;

  VerifyOtpResponse({
    required this.success,
    this.message,
    this.detail,
    this.data,
  });

  factory VerifyOtpResponse.fromJson(Map<String, dynamic> json) =>
      _$VerifyOtpResponseFromJson(json);
  Map<String, dynamic> toJson() => _$VerifyOtpResponseToJson(this);
}
