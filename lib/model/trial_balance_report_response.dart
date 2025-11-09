// lib/model/trial_balance_report_response.dart
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'trial_balance_report_response.g.dart';

@JsonSerializable()
class TrialBalanceReport {
  final bool success;
  final String message;
  final List<TrialBalanceAccount>? data;
  @JsonKey(name: 'is_day_open')
  final bool? isDayOpen;

  TrialBalanceReport({
    required this.success,
    required this.message,
    this.data,
    this.isDayOpen,
  });

  factory TrialBalanceReport.fromJson(Map<String, dynamic> json) =>
      _$TrialBalanceReportFromJson(json);
  Map<String, dynamic> toJson() => _$TrialBalanceReportToJson(this);
}

@JsonSerializable()
class TrialBalanceAccount extends Equatable {
  @JsonKey(name: 'account_name')
  final String? accountName;

  @JsonKey(name: 'main_group') // ← MATCH API
  final String? parentAccount;

  @JsonKey(name: 'total_debit') // ← MATCH API
  final double? debit;

  @JsonKey(name: 'total_credit') // ← MATCH API
  final double? credit;

  const TrialBalanceAccount({
    this.accountName,
    this.parentAccount,
    this.debit,
    this.credit,
  });

  factory TrialBalanceAccount.fromJson(Map<String, dynamic> json) =>
      _$TrialBalanceAccountFromJson(json);
  Map<String, dynamic> toJson() => _$TrialBalanceAccountToJson(this);

  @override
  List<Object?> get props => [accountName, parentAccount, debit, credit];
}
