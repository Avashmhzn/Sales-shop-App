import 'package:json_annotation/json_annotation.dart';

part 'profile.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class Profile {
  final int? id;
  final String? manager;
  final String? companyName;
  final String? tagline;
  final String? address;
  final String? contactNumber;
  final String? panNumber;
  final String? fiscalYearStart;
  final String? fiscalYearEnd;
  final String? openingHour;
  final String? establishedYear;
  @JsonKey(fromJson: _parseDouble)
  final double? taxPercent;

  Profile({
    this.id,
    this.manager,
    this.companyName,
    this.tagline,
    this.address,
    this.contactNumber,
    this.panNumber,
    this.fiscalYearStart,
    this.fiscalYearEnd,
    this.openingHour,
    this.establishedYear,
    this.taxPercent,
  });

  factory Profile.fromJson(Map<String, dynamic> json) =>
      _$ProfileFromJson(json);
  Map<String, dynamic> toJson() => _$ProfileToJson(this);
}

// Helper for tax_percent
double? _parseDouble(dynamic value) {
  if (value == null) return null;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is String) return double.tryParse(value);
  return null;
}
