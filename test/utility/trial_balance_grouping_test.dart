import 'package:flutter_test/flutter_test.dart';
import 'package:saleup_app/model/trial_balance_report_response.dart';
import 'package:saleup_app/utility/trial_balance_grouping.dart';

void main() {
  group('buildTrialBalanceGrouping', () {
    test('groups accounts by parent and main group and computes totals', () {
      final accounts = <TrialBalanceAccount>[
        const TrialBalanceAccount(
          accountName: 'Cash',
          mainGroup: 'Assets',
          parent: 'Current Assets',
          drCr: 'Debit',
          totalAmount: 1200,
        ),
        const TrialBalanceAccount(
          accountName: 'Bank',
          mainGroup: 'Assets',
          parent: 'Current Assets',
          drCr: 'Debit',
          totalAmount: 300,
        ),
        const TrialBalanceAccount(
          accountName: 'Sales',
          mainGroup: 'Income',
          parent: 'Revenue',
          drCr: 'Credit',
          totalAmount: 900,
        ),
        const TrialBalanceAccount(
          accountName: 'Rent',
          mainGroup: 'Assets',
          parent: 'Current Assets',
          drCr: 'Credit',
          totalAmount: 100,
        ),
        const TrialBalanceAccount(
          accountName: 'Utilities',
          mainGroup: '',
          parent: '',
          drCr: 'Debit',
          totalAmount: 250,
        ),
      ];

      final result = buildTrialBalanceGrouping(accounts);

      expect(result.parentGroups.length, 3);

      final currentAssetsParent = result.parentGroups.firstWhere(
        (parent) => parent.name == 'CURRENT ASSETS',
      );
      expect(currentAssetsParent.mainGroups.length, 1);

      final assetsMainGroup = currentAssetsParent.mainGroups.firstWhere(
        (group) => group.name == 'ASSETS',
      );
      expect(assetsMainGroup.totalDebit, 1500);
      expect(assetsMainGroup.totalCredit, 100);

      final uncategorizedParent = result.parentGroups.firstWhere(
        (parent) => parent.name == 'UNCATEGORIZED',
      );
      expect(uncategorizedParent.mainGroups.length, 1);
      final othersMainGroup = uncategorizedParent.mainGroups.firstWhere(
        (group) => group.name == 'OTHERS',
      );
      expect(othersMainGroup.totalDebit, 250);
      expect(othersMainGroup.totalCredit, 0);

      expect(result.totalDebit, 1750);
      expect(result.totalCredit, 1000);
      expect(result.difference, 750);
      expect(result.differenceDebit, 750);
      expect(result.differenceCredit, 0);
    });
  });
}
