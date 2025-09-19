import 'package:json_annotation/json_annotation.dart';

part 'account_head_details_response.g.dart';

@JsonSerializable()
class AccountHeadDetailsResponse {
  final bool success;
  final String? message;
  final AccountHeadDetailData data;

  AccountHeadDetailsResponse({
    required this.success,
    this.message,
    required this.data,
  });

  factory AccountHeadDetailsResponse.fromJson(Map<String, dynamic> json) =>
      _$AccountHeadDetailsResponseFromJson(json);
  Map<String, dynamic> toJson() => _$AccountHeadDetailsResponseToJson(this);
}

@JsonSerializable()
class AccountHeadDetailData {
  final int id;
  final String name;
  @JsonKey(name: 'main_group')
  final String? mainGroup;
  final String? parent;
  @JsonKey(name: 'dr_cr')
  final String? drCr;
  @JsonKey(name: 'account_type')
  final String? accountType;
  @JsonKey(name: 'opening_balance')
  final String? openingBalance;
  final String? description;
  final bool? status;
  @JsonKey(name: 'created_on')
  final String? createdOn;
  @JsonKey(name: 'updated_on')
  final String? updatedOn;

  AccountHeadDetailData({
    required this.id,
    required this.name,
    this.mainGroup,
    this.parent,
    this.drCr,
    this.accountType,
    this.openingBalance,
    this.description,
    this.status,
    this.createdOn,
    this.updatedOn,
  });

  factory AccountHeadDetailData.fromJson(Map<String, dynamic> json) =>
      _$AccountHeadDetailDataFromJson(json);
  Map<String, dynamic> toJson() => _$AccountHeadDetailDataToJson(this);
}
