import 'package:saleup_app/model/trial_balance_report_response.dart';

class TrialBalanceMainGroup {
  final String name;
  final List<TrialBalanceAccount> accounts;
  final double totalDebit;
  final double totalCredit;

  const TrialBalanceMainGroup({
    required this.name,
    required this.accounts,
    required this.totalDebit,
    required this.totalCredit,
  });
}

class TrialBalanceParentGroup {
  final String name;
  final List<TrialBalanceMainGroup> mainGroups;

  const TrialBalanceParentGroup({
    required this.name,
    required this.mainGroups,
  });
}

class TrialBalanceGroupingResult {
  final List<TrialBalanceParentGroup> parentGroups;
  final double totalDebit;
  final double totalCredit;
  final double difference;
  final double differenceDebit;
  final double differenceCredit;

  const TrialBalanceGroupingResult({
    required this.parentGroups,
    required this.totalDebit,
    required this.totalCredit,
    required this.difference,
    required this.differenceDebit,
    required this.differenceCredit,
  });
}

bool _isDebit(String? drCr) =>
    (drCr ?? '').trim().toLowerCase() == 'debit' ||
    (drCr ?? '').trim().toLowerCase() == 'dr';

bool _isCredit(String? drCr) =>
    (drCr ?? '').trim().toLowerCase() == 'credit' ||
    (drCr ?? '').trim().toLowerCase() == 'cr';

String _normalizeParent(String? parent) {
  final value = (parent ?? '').trim();
  return value.isEmpty ? 'UNCATEGORIZED' : value.toUpperCase();
}

String _normalizeMainGroup(String? mainGroup) {
  final value = (mainGroup ?? '').trim();
  return value.isEmpty ? 'OTHERS' : value.toUpperCase();
}

TrialBalanceGroupingResult buildTrialBalanceGrouping(
  List<TrialBalanceAccount>? accounts,
) {
  final groupedByParent = <String, List<TrialBalanceAccount>>{};
  double totalDebit = 0.0;
  double totalCredit = 0.0;

  for (final account in accounts ?? const <TrialBalanceAccount>[]) {
    final parent = _normalizeParent(account.parent);
    groupedByParent.putIfAbsent(parent, () => <TrialBalanceAccount>[]);
    groupedByParent[parent]!.add(account);

    final amount = (account.totalAmount ?? 0.0).abs();
    if (_isDebit(account.drCr)) {
      totalDebit += amount;
    } else if (_isCredit(account.drCr)) {
      totalCredit += amount;
    }
  }

  final parentGroups = groupedByParent.entries.map((entry) {
    final mainGroupMap = <String, List<TrialBalanceAccount>>{};
    for (final account in entry.value) {
      final mainGroup = _normalizeMainGroup(account.mainGroup);
      mainGroupMap.putIfAbsent(mainGroup, () => <TrialBalanceAccount>[]);
      mainGroupMap[mainGroup]!.add(account);
    }

    final mainGroups = mainGroupMap.entries.map((groupEntry) {
      final accounts = groupEntry.value
        ..sort((a, b) => (a.accountName ?? '').compareTo(b.accountName ?? ''));

      double groupDebit = 0.0;
      double groupCredit = 0.0;
      for (final account in accounts) {
        final amount = (account.totalAmount ?? 0.0).abs();
        if (_isDebit(account.drCr)) {
          groupDebit += amount;
        } else if (_isCredit(account.drCr)) {
          groupCredit += amount;
        }
      }

      return TrialBalanceMainGroup(
        name: groupEntry.key,
        accounts: accounts,
        totalDebit: groupDebit,
        totalCredit: groupCredit,
      );
    }).toList()
      ..sort((a, b) => a.name.compareTo(b.name));

    return TrialBalanceParentGroup(
      name: entry.key,
      mainGroups: mainGroups,
    );
  }).toList()
    ..sort((a, b) => a.name.compareTo(b.name));

  final difference = totalDebit - totalCredit;

  return TrialBalanceGroupingResult(
    parentGroups: parentGroups,
    totalDebit: totalDebit,
    totalCredit: totalCredit,
    difference: difference,
    differenceDebit: difference > 0 ? difference : 0.0,
    differenceCredit: difference < 0 ? difference.abs() : 0.0,
  );
}
