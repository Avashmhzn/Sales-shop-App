// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bill_settings.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BillSettings _$BillSettingsFromJson(Map<String, dynamic> json) => BillSettings(
      id: (json['id'] as num).toInt(),
      left: (json['left'] as num).toInt(),
      right: (json['right'] as num).toInt(),
      top: (json['top'] as num).toInt(),
      bottom: (json['bottom'] as num).toInt(),
      printTokenOnBill: json['printTokenOnBill'] as bool? ?? false,
      printType: json['printType'] as String? ?? 'A4',
    );

Map<String, dynamic> _$BillSettingsToJson(BillSettings instance) =>
    <String, dynamic>{
      'id': instance.id,
      'left': instance.left,
      'right': instance.right,
      'top': instance.top,
      'bottom': instance.bottom,
      'printTokenOnBill': instance.printTokenOnBill,
      'printType': instance.printType,
    };
