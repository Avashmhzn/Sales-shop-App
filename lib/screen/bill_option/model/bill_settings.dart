import 'package:json_annotation/json_annotation.dart';

part 'bill_settings.g.dart';

@JsonSerializable()
class BillSettings {
  final int id;
  final int left;
  final int right;
  final int top;
  final int bottom;

  @JsonKey(defaultValue: false) // ← Fixed
  final bool printTokenOnBill;

  @JsonKey(defaultValue: 'A4') // ← Fixed
  final String? printType;

  BillSettings({
    required this.id,
    required this.left,
    required this.right,
    required this.top,
    required this.bottom,
    required this.printTokenOnBill,
    this.printType,
  });

  factory BillSettings.fromJson(Map<String, dynamic> json) =>
      _$BillSettingsFromJson(json);

  Map<String, dynamic> toJson() => _$BillSettingsToJson(this);
}
