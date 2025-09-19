// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ledger_report_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LedgerReport _$LedgerReportFromJson(Map<String, dynamic> json) => LedgerReport(
      success: json['success'] as bool,
      message: json['message'] as String,
      data: (json['data'] as List<dynamic>)
          .map((e) => LedgerAccount.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$LedgerReportToJson(LedgerReport instance) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
      'data': instance.data,
    };

LedgerAccount _$LedgerAccountFromJson(Map<String, dynamic> json) =>
    LedgerAccount(
      accountId: (json['accountId'] as num).toInt(),
      accountName: json['accountName'] as String,
      openingBalance: (json['openingBalance'] as num).toDouble(),
      ledger: (json['ledger'] as List<dynamic>)
          .map((e) => LedgerEntry.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$LedgerAccountToJson(LedgerAccount instance) =>
    <String, dynamic>{
      'accountId': instance.accountId,
      'accountName': instance.accountName,
      'openingBalance': instance.openingBalance,
      'ledger': instance.ledger,
    };

LedgerEntry _$LedgerEntryFromJson(Map<String, dynamic> json) => LedgerEntry(
      voucherDate: json['voucher_date'] as String,
      voucherNumber: json['voucher_number'] as String,
      debit: (json['debit'] as num).toDouble(),
      credit: (json['credit'] as num).toDouble(),
      runningBalance: (json['running_balance'] as num).toDouble(),
    );

Map<String, dynamic> _$LedgerEntryToJson(LedgerEntry instance) =>
    <String, dynamic>{
      'voucher_date': instance.voucherDate,
      'voucher_number': instance.voucherNumber,
      'debit': instance.debit,
      'credit': instance.credit,
      'running_balance': instance.runningBalance,
    };
