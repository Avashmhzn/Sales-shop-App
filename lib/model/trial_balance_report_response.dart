// lib/model/trial_balance_report_response.dart
import 'package:equatable/equatable.dart';

class TrialBalanceReport {
  final bool success;
  final String message;
  final List<TrialBalanceAccount>? data;
  final bool? isDayOpen;

  TrialBalanceReport({
    required this.success,
    required this.message,
    this.data,
    this.isDayOpen,
  });

  factory TrialBalanceReport.fromJson(Map<String, dynamic> json) {
    return TrialBalanceReport(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      data: (json['data'] as List<dynamic>?)
          ?.map((e) => TrialBalanceAccount.fromJson(e as Map<String, dynamic>))
          .toList(),
      isDayOpen: json['is_day_open'] as bool?,
    );
  }

  Map<String, dynamic> toJson() => {
        'success': success,
        'message': message,
        'data': data?.map((e) => e.toJson()).toList(),
        'is_day_open': isDayOpen,
      };
}

class TrialBalanceAccount extends Equatable {
  final int? accountId;
  final String? accountName;
  final String? mainGroup;
  final String? drCr;
  final String? parent;
  final double? openingBalance;
  final double? totalDebit;
  final double? totalCredit;
  final double? totalAmount;

  const TrialBalanceAccount({
    this.accountId,
    this.accountName,
    this.mainGroup,
    this.drCr,
    this.parent,
    this.openingBalance,
    this.totalDebit,
    this.totalCredit,
    this.totalAmount,
  });

  // Compatibility getters for other parts of the app
  double? get debit => totalDebit;
  double? get credit => totalCredit;
  String? get parentAccount => mainGroup;

  factory TrialBalanceAccount.fromJson(Map<String, dynamic> json) {
    return TrialBalanceAccount(
      accountId: json['account_id'] as int?,
      accountName: json['account_name'] as String?,
      mainGroup: json['main_group'] as String?,
      drCr: json['dr_cr'] as String?,
      parent: json['parent'] as String?,
      openingBalance: (json['opening_balance'] as num?)?.toDouble(),
      totalDebit: (json['total_debit'] as num?)?.toDouble(),
      totalCredit: (json['total_credit'] as num?)?.toDouble(),
      totalAmount: (json['total_amount'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
        'account_id': accountId,
        'account_name': accountName,
        'main_group': mainGroup,
        'dr_cr': drCr,
        'parent': parent,
        'opening_balance': openingBalance,
        'total_debit': totalDebit,
        'total_credit': totalCredit,
        'total_amount': totalAmount,
      };

  @override
  List<Object?> get props => [
        accountId,
        accountName,
        mainGroup,
        drCr,
        parent,
        openingBalance,
        totalDebit,
        totalCredit,
        totalAmount,
      ];
}
