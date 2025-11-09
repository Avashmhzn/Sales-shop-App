// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trial_balance_report_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TrialBalanceReport _$TrialBalanceReportFromJson(Map<String, dynamic> json) =>
    TrialBalanceReport(
      success: json['success'] as bool,
      message: json['message'] as String,
      data: (json['data'] as List<dynamic>?)
          ?.map((e) => TrialBalanceAccount.fromJson(e as Map<String, dynamic>))
          .toList(),
      isDayOpen: json['is_day_open'] as bool?,
    );

Map<String, dynamic> _$TrialBalanceReportToJson(TrialBalanceReport instance) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
      'data': instance.data,
      'is_day_open': instance.isDayOpen,
    };

TrialBalanceAccount _$TrialBalanceAccountFromJson(Map<String, dynamic> json) =>
    TrialBalanceAccount(
      accountName: json['account_name'] as String?,
      parentAccount: json['main_group'] as String?,
      debit: (json['total_debit'] as num?)?.toDouble(),
      credit: (json['total_credit'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$TrialBalanceAccountToJson(
        TrialBalanceAccount instance) =>
    <String, dynamic>{
      'account_name': instance.accountName,
      'main_group': instance.parentAccount,
      'total_debit': instance.debit,
      'total_credit': instance.credit,
    };
