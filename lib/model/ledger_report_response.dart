import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'ledger_report_response.g.dart'; // Ensure this matches the intended file name

@JsonSerializable()
class LedgerReport {
  final bool success;
  final String message;
  final List<LedgerAccount> data;

  LedgerReport({
    required this.success,
    required this.message,
    required this.data,
  });

  factory LedgerReport.fromJson(Map<String, dynamic> json) =>
      _$LedgerReportFromJson(json);

  Map<String, dynamic> toJson() => _$LedgerReportToJson(this);
}

@JsonSerializable()
class LedgerAccount extends Equatable {
  final int accountId;
  final String accountName;
  final double openingBalance;
  final List<LedgerEntry> ledger;

  LedgerAccount({
    required this.accountId,
    required this.accountName,
    required this.openingBalance,
    required this.ledger,
  });

  factory LedgerAccount.fromJson(Map<String, dynamic> json) =>
      _$LedgerAccountFromJson(json);

  Map<String, dynamic> toJson() => _$LedgerAccountToJson(this);

  @override
  List<Object?> get props => [accountId, accountName, openingBalance, ledger];
}

@JsonSerializable()
class LedgerEntry extends Equatable {
  @JsonKey(name: 'voucher_date')
  final String voucherDate;
  @JsonKey(name: 'voucher_number')
  final String voucherNumber;
  final double debit;
  final double credit;
  @JsonKey(name: 'running_balance')
  final double runningBalance;

  LedgerEntry({
    required this.voucherDate,
    required this.voucherNumber,
    required this.debit,
    required this.credit,
    required this.runningBalance,
  });

  factory LedgerEntry.fromJson(Map<String, dynamic> json) =>
      _$LedgerEntryFromJson(json);

  Map<String, dynamic> toJson() => _$LedgerEntryToJson(this);

  @override
  List<Object?> get props => [voucherDate, voucherNumber, debit, credit, runningBalance];
}