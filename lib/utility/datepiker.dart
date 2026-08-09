import 'package:flutter/material.dart';
import 'package:nepali_utils/nepali_utils.dart'; // pubspec: nepali_utils: ^4.x

class NepaliDatePickerDialog extends StatefulWidget {
  final NepaliDateTime? initialDate;
  final NepaliDateTime firstDate;
  final NepaliDateTime lastDate;
  final ValueChanged<NepaliDateTime> onDateSelected;

  const NepaliDatePickerDialog({
    super.key,
    this.initialDate,
    required this.firstDate,
    required this.lastDate,
    required this.onDateSelected,
  });

  @override
  State<NepaliDatePickerDialog> createState() => _NepaliDatePickerDialogState();
}

class _NepaliDatePickerDialogState extends State<NepaliDatePickerDialog> {
  late NepaliDateTime _focusedMonth;
  NepaliDateTime? _selectedDate;
  late NepaliDateTime _today;

  static const _weekdays = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

  // Nepali month names
  static const _nepaliMonths = [
    'Baisakh',
    'Jestha',
    'Ashadh',
    'Shrawan',
    'Bhadra',
    'Ashwin',
    'Kartik',
    'Mangsir',
    'Poush',
    'Magh',
    'Falgun',
    'Chaitra',
  ];

  // AD month ranges for subtitle (approx)
  static const _adMonthRanges = [
    'Apr - May',
    'May - Jun',
    'Jun - Jul',
    'Jul - Aug',
    'Aug - Sep',
    'Sep - Oct',
    'Oct - Nov',
    'Nov - Dec',
    'Dec - Jan',
    'Jan - Feb',
    'Feb - Mar',
    'Mar - Apr',
  ];

  @override
  void initState() {
    super.initState();
    _today = NepaliDateTime.now();
    _selectedDate = widget.initialDate;
    _focusedMonth = widget.initialDate ?? _today;
  }

  void _previousMonth() {
    setState(() {
      if (_focusedMonth.month == 1) {
        _focusedMonth = NepaliDateTime(_focusedMonth.year - 1, 12);
      } else {
        _focusedMonth =
            NepaliDateTime(_focusedMonth.year, _focusedMonth.month - 1);
      }
    });
  }

  void _nextMonth() {
    setState(() {
      if (_focusedMonth.month == 12) {
        _focusedMonth = NepaliDateTime(_focusedMonth.year + 1, 1);
      } else {
        _focusedMonth =
            NepaliDateTime(_focusedMonth.year, _focusedMonth.month + 1);
      }
    });
  }

  bool _isSameDay(NepaliDateTime a, NepaliDateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  bool _isSameMonth(NepaliDateTime a, NepaliDateTime b) =>
      a.year == b.year && a.month == b.month;

  int _daysInMonth(int year, int month) =>
      NepaliDateTime(year, month).totalDays;

  int _firstWeekdayOfMonth(int year, int month) {
    // 0=Sun ... 6=Sat
    return NepaliDateTime(year, month, 1).toDateTime().weekday % 7;
  }

  // Convert Nepali day to AD day number for subtitle
  String _toAdDay(int nepYear, int nepMonth, int nepDay) {
    try {
      final ad = NepaliDateTime(nepYear, nepMonth, nepDay).toDateTime();
      return '${ad.day}';
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final year = _focusedMonth.year;
    final month = _focusedMonth.month;
    final daysInMonth = _daysInMonth(year, month);
    final firstWeekday = _firstWeekdayOfMonth(year, month);
    final monthName = _nepaliMonths[month - 1];
    final adRange = _adMonthRanges[month - 1];

    // Build AD year for subtitle
    final adYear1 = NepaliDateTime(year, month, 1).toDateTime().year;
    final adYear2 = NepaliDateTime(year, month, daysInMonth).toDateTime().year;
    final adYearStr = adYear1 == adYear2 ? '$adYear1' : '$adYear1 - $adYear2';

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Header ──────────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: _previousMonth,
                ),
                Column(
                  children: [
                    Text(
                      '$monthName $year',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '$adRange $adYearStr (AD)',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: _nextMonth,
                ),
              ],
            ),
            const SizedBox(height: 8),

            // ── Weekday Labels ───────────────────────────────────
            Row(
              children: _weekdays
                  .map((d) => Expanded(
                        child: Center(
                          child: Text(
                            d,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 4),

            // ── Day Grid ─────────────────────────────────────────
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                childAspectRatio: 0.85,
              ),
              itemCount: firstWeekday + daysInMonth,
              itemBuilder: (context, index) {
                if (index < firstWeekday) return const SizedBox.shrink();

                final day = index - firstWeekday + 1;
                final cellDate = NepaliDateTime(year, month, day);
                final isSelected = _selectedDate != null &&
                    _isSameDay(cellDate, _selectedDate!);
                final isToday = _isSameDay(cellDate, _today);
                final adDay = _toAdDay(year, month, day);

                Color? bgColor;
                Color textColor = Colors.black87;
                Color subColor = Colors.grey;

                if (isSelected) {
                  bgColor = const Color(0xFFF59422);
                  textColor = Colors.white;
                  subColor = Colors.white70;
                } else if (isToday) {
                  bgColor = const Color(0xFFF59422).withValues(alpha: 0.18);
                  textColor = Colors.black87;
                  subColor = Colors.grey;
                }

                return GestureDetector(
                  onTap: () {
                    setState(() => _selectedDate = cellDate);
                    widget.onDateSelected.call(cellDate); // optional
                    Navigator.pop(context, cellDate); // ← ADD THIS LINE
                  },
                  child: Container(
                    margin: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: bgColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '$day',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: textColor,
                          ),
                        ),
                        Text(
                          adDay,
                          style: TextStyle(
                            fontSize: 10,
                            color: subColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 8),

            // ── Go to Today ──────────────────────────────────────
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: () {
                  setState(() {
                    _focusedMonth = _today;
                    _selectedDate = _today;
                  });
                  widget.onDateSelected(_today);
                },
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFFF59422),
                  padding: EdgeInsets.zero,
                ),
                child: const Text(
                  'Go to Today',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
