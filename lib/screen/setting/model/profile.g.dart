// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Profile _$ProfileFromJson(Map<String, dynamic> json) => Profile(
      id: (json['id'] as num?)?.toInt(),
      manager: json['manager'] as String?,
      companyName: json['company_name'] as String?,
      tagline: json['tagline'] as String?,
      address: json['address'] as String?,
      contactNumber: json['contact_number'] as String?,
      panNumber: json['pan_number'] as String?,
      fiscalYearStart: json['fiscal_year_start'] as String?,
      fiscalYearEnd: json['fiscal_year_end'] as String?,
      openingHour: json['opening_hour'] as String?,
      establishedYear: json['established_year'] as String?,
      taxPercent: _parseDouble(json['tax_percent']),
    );

Map<String, dynamic> _$ProfileToJson(Profile instance) => <String, dynamic>{
      'id': instance.id,
      'manager': instance.manager,
      'company_name': instance.companyName,
      'tagline': instance.tagline,
      'address': instance.address,
      'contact_number': instance.contactNumber,
      'pan_number': instance.panNumber,
      'fiscal_year_start': instance.fiscalYearStart,
      'fiscal_year_end': instance.fiscalYearEnd,
      'opening_hour': instance.openingHour,
      'established_year': instance.establishedYear,
      'tax_percent': instance.taxPercent,
    };
