// import 'package:json_annotation/json_annotation.dart';

// part 'account_heads_response.g.dart';

// @JsonSerializable()
// class AccountHeadsResponse {
//   final bool? success;
//   final String? message;
//   final List<AccountHeadData> data;
//   final int? total;

//   AccountHeadsResponse({
//     this.success,
//     this.message,
//     required this.data,
//     this.total,
//   });

//   factory AccountHeadsResponse.fromJson(Map<String, dynamic> json) =>
//       _$AccountHeadsResponseFromJson(json);

//   Map<String, dynamic> toJson() => _$AccountHeadsResponseToJson(this);
// }

// @JsonSerializable()
// class AccountHeadData {
//   final int id;
//   final String name;
//   @JsonKey(name: 'main_group')
//   final String? mainGroup;
//   final String? parent;
//   @JsonKey(name: 'dr_cr')
//   final String? drCr;
//   @JsonKey(name: 'account_type')
//   final String? accountType;
//   @JsonKey(name: 'opening_balance', fromJson: _parseOpeningBalance)
//   final double? openingBalance;
//   final String? description;
//   final bool? status;
//   @JsonKey(name: 'created_on')
//   final String? createdOn;
//   @JsonKey(name: 'updated_on')
//   final String? updatedOn;

//   AccountHeadData({
//     required this.id,
//     required this.name,
//     this.mainGroup,
//     this.parent,
//     this.drCr,
//     this.accountType,
//     this.openingBalance,
//     this.description,
//     this.status,
//     this.createdOn,
//     this.updatedOn,
//   });

//   factory AccountHeadData.fromJson(Map<String, dynamic> json) =>
//       _$AccountHeadDataFromJson(json);

//   Map<String, dynamic> toJson() => _$AccountHeadDataToJson(this);

//   static double? _parseOpeningBalance(dynamic value) {
//     if (value == null) return null;
//     if (value is num) return value.toDouble();
//     if (value is String) {
//       try {
//         return double.parse(value);
//       } catch (e) {
//         print('Error parsing opening_balance "$value": $e');
//         return null;
//       }
//     }
//     print('Invalid opening_balance type: ${value.runtimeType}');
//     return null;
//   }
// }
import 'package:json_annotation/json_annotation.dart';

part 'account_heads_response.g.dart';

@JsonSerializable()
class AccountHeadsResponse {
  final bool? success;
  final String? message;
  final List<AccountHeadData> data;
  final int? total;

  AccountHeadsResponse({
    this.success,
    this.message,
    required this.data,
    this.total,
  });

  factory AccountHeadsResponse.fromJson(Map<String, dynamic> json) =>
      _$AccountHeadsResponseFromJson(json);

  Map<String, dynamic> toJson() => _$AccountHeadsResponseToJson(this);
}

@JsonSerializable()
class AccountHeadData {
  final int id;
  final String name;
  @JsonKey(name: 'main_group')
  final String? mainGroup;
  final String? parent;
  @JsonKey(name: 'dr_cr')
  final String? drCr;
  @JsonKey(name: 'account_type')
  final String? accountType;
  @JsonKey(name: 'opening_balance', fromJson: _parseOpeningBalance)
  final double? openingBalance;
  final String? description;
  final bool? status;
  @JsonKey(name: 'created_on')
  final String? createdOn;
  @JsonKey(name: 'updated_on')
  final String? updatedOn;

  AccountHeadData({
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

  factory AccountHeadData.fromJson(Map<String, dynamic> json) =>
      _$AccountHeadDataFromJson(json);

  Map<String, dynamic> toJson() => _$AccountHeadDataToJson(this);

  static double? _parseOpeningBalance(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    if (value is String) {
      try {
        return double.parse(value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  // FIXED: Equality based on ID
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AccountHeadData &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
