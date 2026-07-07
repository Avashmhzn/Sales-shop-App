import 'package:flutter_test/flutter_test.dart';
import 'package:saleup_app/utility/trial_balance_request.dart';

void main() {
  group('buildTrialBalanceRequestDateRanges', () {
    test('keeps the original order when it is already chronological', () {
      final ranges =
          buildTrialBalanceRequestDateRanges('2026-03-19', '2027-08-16');

      expect(ranges.length, 1);
      expect(ranges.first.startDate, '2026-03-19');
      expect(ranges.first.endDate, '2027-08-16');
    });

    test(
        'uses a swapped chronological range when the start date is after the end date',
        () {
      final ranges =
          buildTrialBalanceRequestDateRanges('2027-08-16', '2026-03-19');

      expect(ranges.length, 1);
      expect(ranges.first.startDate, '2026-03-19');
      expect(ranges.first.endDate, '2027-08-16');
    });
  });
}
