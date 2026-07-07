// lib/screen/trial_balance/view/trial_balance_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:nepali_utils/nepali_utils.dart';
import 'package:saleup_app/core/network/dio_client.dart';
import 'package:saleup_app/model/trial_balance_report_response.dart';
import 'package:saleup_app/screen/trialBalance/bloc/trial_balance_bloc.dart';
import 'package:saleup_app/screen/trialBalance/bloc/trial_balance_event.dart';
import 'package:saleup_app/screen/trialBalance/bloc/trial_balance_state.dart';
import 'package:saleup_app/services/report_service.dart';
import 'package:saleup_app/utility/datepiker.dart';
import 'package:saleup_app/utility/trial_balance_grouping.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class TrialBalanceScreen extends StatefulWidget {
  const TrialBalanceScreen({super.key});

  @override
  State<TrialBalanceScreen> createState() => _TrialBalanceScreenState();
}

class _TrialBalanceScreenState extends State<TrialBalanceScreen> {
  late final TrialBalanceBloc _bloc;
  DateTime? _start;
  DateTime? _end;
  bool _isLoadingInitialDates = true;
  bool _downloadInProgress = false;
  String _balanceType = 'closing';
  final Set<String> _expandedParents = <String>{};
  final Set<String> _expandedMainGroups = <String>{};

  bool get _showOpening => _balanceType == 'opening';

  void _toggleParent(String parentName) {
    setState(() {
      if (_expandedParents.contains(parentName)) {
        _expandedParents.remove(parentName);
      } else {
        _expandedParents.add(parentName);
      }
    });
  }

  void _toggleMainGroup(String parentName, String mainGroupName) {
    final key = '${parentName}__${mainGroupName}';
    setState(() {
      if (_expandedMainGroups.contains(key)) {
        _expandedMainGroups.remove(key);
      } else {
        _expandedMainGroups.add(key);
      }
    });
  }

  bool _isParentExpanded(String parentName) =>
      _expandedParents.contains(parentName);

  bool _isMainGroupExpanded(String parentName, String mainGroupName) =>
      _expandedMainGroups.contains('${parentName}__${mainGroupName}');

  @override
  void initState() {
    super.initState();
    _bloc = TrialBalanceBloc(dioClient: DioClient());
    _loadInitialDates();
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  Future<void> _loadInitialDates() async {
    try {
      final service = ReportService();
      final results = await Future.wait([
        service.getFiscalYearStartDate(),
        service.getDayOpenDate(),
      ]);
      final fiscalStartStr = results[0];
      final openDayStr = results[1];
      debugPrint(
          'TrialBalanceScreen: Loaded dates: fiscalStartStr = $fiscalStartStr, openDayStr = $openDayStr');

      if (mounted) {
        setState(() {
          if (fiscalStartStr != null) {
            _start = DateTime.tryParse(fiscalStartStr);
          }
          // Fallback start date to Jan 1st of current year if null
          _start ??= DateTime(DateTime.now().year, 1, 1);

          if (openDayStr != null) {
            _end = DateTime.tryParse(openDayStr);
          }
          // Fallback end date to today if null
          _end ??= DateTime.now();

          _isLoadingInitialDates = false;
        });

        debugPrint(
            'TrialBalanceScreen: Triggering API fetch with start = $_start, end = $_end');
        _apply();
      }
    } catch (e) {
      debugPrint('Error loading initial dates: $e');
      if (mounted) {
        setState(() {
          _start ??= DateTime(DateTime.now().year, 1, 1);
          _end ??= DateTime.now();
          _isLoadingInitialDates = false;
        });
        _apply();
      }
    }
  }

  void _pickDate(bool isStart) async {
    final current = isStart ? _start : _end;
    final initialDate =
        current != null ? current.toNepaliDateTime() : NepaliDateTime.now();

    await showDialog(
      context: context,
      builder: (_) => NepaliDatePickerDialog(
        initialDate: initialDate,
        firstDate: NepaliDateTime(2075),
        lastDate: NepaliDateTime(2090),
        onDateSelected: (picked) {
          setState(() {
            if (isStart) {
              _start = picked.toDateTime();
            } else {
              _end = picked.toDateTime();
            }
          });
          if (context.canPop()) context.pop();
        },
      ),
    );
  }

  void _apply() {
    if (_start == null || _end == null) return;
    _bloc.add(FetchTrialBalance(
      DateFormat('yyyy-MM-dd').format(_start!),
      DateFormat('yyyy-MM-dd').format(_end!),
    ));
  }

  void _clear() {
    setState(() {
      _start = null;
      _end = null;
      _expandedParents.clear();
      _expandedMainGroups.clear();
    });
    _bloc.add(ClearTrialBalanceFilter());
    _loadInitialDates();
  }

  Future<void> _exportExcel() async {
    if (_start == null || _end == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select date range first'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final sStr = DateFormat('yyyy-MM-dd').format(_start!);
    final eStr = DateFormat('yyyy-MM-dd').format(_end!);

    setState(() => _downloadInProgress = true);
    try {
      final path = await ReportService().exportReport(
        reportType: 'trial_balance',
        startDate: sStr,
        endDate: eStr,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Excel exported successfully to: $path'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _downloadInProgress = false);
      }
    }
  }

  Future<void> _printReport() async {
    final state = _bloc.state;
    if (state is! TrialBalanceLoaded) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No data loaded to print'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      final pdf = await _generatePdf(state.report);
      await Printing.layoutPdf(
        onLayout: (format) async => pdf.save(),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to print: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<pw.Document> _generatePdf(TrialBalanceReport report) async {
    final pdf = pw.Document();
    final accounts = report.data ?? [];
    final startStr =
        _start != null ? DateFormat('yyyy-MM-dd').format(_start!) : '';
    final endStr = _end != null ? DateFormat('yyyy-MM-dd').format(_end!) : '';

    double totalDebit = 0;
    double totalCredit = 0;
    for (final acc in accounts) {
      final amount = acc.totalAmount ?? 0.0;
      if (acc.drCr == 'Debit') {
        totalDebit += amount;
      } else if (acc.drCr == 'Credit') {
        totalCredit += amount;
      }
    }

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Center(
                child: pw.Text(
                  'Trial Balance',
                  style: pw.TextStyle(
                    fontSize: 22,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.SizedBox(height: 8),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Start Date: $startStr'),
                  pw.Text('End Date: $endStr'),
                ],
              ),
              pw.SizedBox(height: 16),
              pw.Table(
                border:
                    pw.TableBorder.all(color: PdfColors.grey400, width: 0.5),
                columnWidths: {
                  0: const pw.FlexColumnWidth(4),
                  1: const pw.FlexColumnWidth(2),
                  2: const pw.FlexColumnWidth(2),
                },
                children: [
                  // Table Header
                  pw.TableRow(
                    decoration:
                        const pw.BoxDecoration(color: PdfColors.grey200),
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(6),
                        child: pw.Text('Accounts',
                            style:
                                pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(6),
                        child: pw.Text('Debit',
                            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                            textAlign: pw.TextAlign.right),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(6),
                        child: pw.Text('Credit',
                            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                            textAlign: pw.TextAlign.right),
                      ),
                    ],
                  ),
                  // Table Body
                  ...accounts.map((acc) {
                    final amount = acc.totalAmount ?? 0.0;
                    final isDebit = acc.drCr == 'Debit';
                    return pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(6),
                          child: pw.Text(acc.accountName ?? ''),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(6),
                          child: pw.Text(
                            isDebit ? '${formatNepaliNumber(amount)} Dr' : '-',
                            textAlign: pw.TextAlign.right,
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(6),
                          child: pw.Text(
                            !isDebit ? '${formatNepaliNumber(amount)} Cr' : '-',
                            textAlign: pw.TextAlign.right,
                          ),
                        ),
                      ],
                    );
                  }),
                  // Grand Total
                  pw.TableRow(
                    decoration:
                        const pw.BoxDecoration(color: PdfColors.grey100),
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(6),
                        child: pw.Text('GRAND TOTAL',
                            style:
                                pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(6),
                        child: pw.Text(
                          totalDebit > 0
                              ? '${formatNepaliNumber(totalDebit)} Dr'
                              : '- Dr',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                          textAlign: pw.TextAlign.right,
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(6),
                        child: pw.Text(
                          totalCredit > 0
                              ? '${formatNepaliNumber(totalCredit)} Cr'
                              : '- Dr',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                          textAlign: pw.TextAlign.right,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );

    return pdf;
  }

  String formatCombinedDate(DateTime date) {
    final nepaliDate = date.toNepaliDateTime();
    final bsPart =
        '${nepaliDate.year}-${nepaliDate.month.toString().padLeft(2, '0')}-${nepaliDate.day.toString().padLeft(2, '0')}';
    final adPart = '${date.day} ${DateFormat('MMM').format(date)}';
    return '$bsPart ($adPart)';
  }

  String formatNepaliNumber(double amount) {
    final isNegative = amount < 0;
    final absAmount = amount.abs();
    final parts = absAmount.toStringAsFixed(2).split('.');
    final wholePart = parts[0];
    final decimalPart = parts[1];

    String formattedWhole;
    if (wholePart.length <= 3) {
      formattedWhole = wholePart;
    } else {
      final lastThree = wholePart.substring(wholePart.length - 3);
      var remaining = wholePart.substring(0, wholePart.length - 3);
      final chunks = <String>[];
      while (remaining.isNotEmpty) {
        if (remaining.length > 2) {
          chunks.insert(0, remaining.substring(remaining.length - 2));
          remaining = remaining.substring(0, remaining.length - 2);
        } else {
          chunks.insert(0, remaining);
          remaining = '';
        }
      }
      chunks.add(lastThree);
      formattedWhole = chunks.join(',');
    }
    return '${isNegative ? '-' : ''}$formattedWhole.$decimalPart';
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isWide = width > 750;

    return BlocProvider(
      create: (_) => _bloc,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBar(
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF1E293B),
          elevation: 0.5,
          title: const Text(
            'Trial Balance',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go('/home'),
          ),
        ),
        body: _isLoadingInitialDates
            ? const Center(child: CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Top Controls Card
                    Card(
                      color: Colors.white,
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (isWide)
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Expanded(child: _buildDatePicker(true)),
                                  const SizedBox(width: 16),
                                  Expanded(child: _buildDatePicker(false)),
                                  const SizedBox(width: 16),
                                  _buildFilterButton(),
                                ],
                              )
                            else
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(child: _buildDatePicker(true)),
                                      const SizedBox(width: 12),
                                      Expanded(child: _buildDatePicker(false)),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  _buildFilterButton(fullWidth: true),
                                ],
                              ),
                            const SizedBox(height: 16),
                            // Action buttons (Reset, Print, Export Excel)
                            Row(
                              children: [
                                ElevatedButton(
                                  onPressed: _clear,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFF1F3F4),
                                    foregroundColor: const Color(0xFF1E293B),
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 12),
                                  ),
                                  child: const Text('Reset',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                ),
                                const SizedBox(width: 12),
                                ElevatedButton(
                                  onPressed: _printReport,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFF1F3F4),
                                    foregroundColor: const Color(0xFF1E293B),
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 12),
                                  ),
                                  child: const Text('Print',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                ),
                                const SizedBox(width: 12),
                                ElevatedButton.icon(
                                  onPressed:
                                      _downloadInProgress ? null : _exportExcel,
                                  icon: _downloadInProgress
                                      ? const SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Colors.white),
                                        )
                                      : const Icon(Icons.table_chart_outlined,
                                          size: 16, color: Colors.white),
                                  label: const Text('Export Excel',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF0F7C3E),
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 12),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildBalanceTypeToggle(),
                    const SizedBox(height: 12),
                    // Table Header Column Labels
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      decoration: const BoxDecoration(
                        color: Color(0xFFF1F5F9),
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(8)),
                      ),
                      child: Row(
                        children: [
                          const Expanded(
                            flex: 4,
                            child: Text(
                              'ACCOUNTS',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF475569),
                                fontSize: 13,
                              ),
                            ),
                          ),
                          if (_showOpening)
                            const Expanded(
                              flex: 2,
                              child: Text(
                                'OPENING',
                                textAlign: TextAlign.right,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF475569),
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          const Expanded(
                            flex: 2,
                            child: Text(
                              'DEBIT',
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF475569),
                                fontSize: 13,
                              ),
                            ),
                          ),
                          const Expanded(
                            flex: 2,
                            child: Text(
                              'CREDIT',
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF475569),
                                fontSize: 13,
                              ),
                            ),
                          ),
                          if (_showOpening)
                            const Expanded(
                              flex: 2,
                              child: Text(
                                'CLOSING',
                                textAlign: TextAlign.right,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF475569),
                                  fontSize: 13,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    // Trial Balance content list
                    Expanded(
                      child: BlocBuilder<TrialBalanceBloc, TrialBalanceState>(
                        builder: (context, state) {
                          if (state is TrialBalanceLoading) {
                            return const Center(
                                child: CircularProgressIndicator());
                          }
                          if (state is TrialBalanceLoaded) {
                            return _buildReportContent(state.report);
                          }
                          if (state is TrialBalanceError) {
                            return Center(
                              child: Text(
                                state.message,
                                style: const TextStyle(color: Colors.red),
                              ),
                            );
                          }
                          return const Center(
                              child:
                                  Text('Select date range and apply filter'));
                        },
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildDatePicker(bool isStart) {
    final date = isStart ? _start : _end;
    final label = isStart ? 'START DATE' : 'END DATE';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w800,
            color: Color(0xFF64748B),
          ),
        ),
        const SizedBox(height: 6),
        InkWell(
          onTap: () => _pickDate(isStart),
          child: Container(
            height: 42,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: const Color(0xFFCBD5E1)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    date == null ? 'Select' : formatCombinedDate(date),
                    style:
                        const TextStyle(fontSize: 13, color: Color(0xFF1E293B)),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const Icon(Icons.calendar_today_outlined,
                    size: 16, color: Color(0xFF64748B)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterButton({bool fullWidth = false}) {
    final button = ElevatedButton(
      onPressed: (_start != null && _end != null) ? _apply : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFF59422),
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
      child:
          const Text('Filter', style: TextStyle(fontWeight: FontWeight.bold)),
    );

    if (fullWidth) {
      return SizedBox(height: 42, child: button);
    }

    return Container(
      height: 42,
      margin: const EdgeInsets.only(bottom: 0),
      child: button,
    );
  }

  String _formatSignedValue(double amount) {
    final absAmount = amount.abs();
    return amount >= 0
        ? '${formatNepaliNumber(absAmount)} Dr'
        : '${formatNepaliNumber(absAmount)} Cr';
  }

  Widget _buildBalanceTypeToggle() {
    return ToggleButtons(
      isSelected: [_balanceType == 'closing', _balanceType == 'opening'],
      onPressed: (index) {
        setState(() {
          _balanceType = index == 0 ? 'closing' : 'opening';
        });
      },
      borderRadius: BorderRadius.circular(8),
      selectedColor: Colors.white,
      fillColor: const Color(0xFFF59422),
      color: const Color(0xFF475569),
      textStyle: const TextStyle(fontWeight: FontWeight.w600),
      children: const [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text('Closing'),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text('Opening'),
        ),
      ],
    );
  }

  Widget _buildAccountRow(TrialBalanceAccount acc) {
    final isDebit = (acc.drCr ?? '').trim().toLowerCase() == 'debit' ||
        (acc.drCr ?? '').trim().toLowerCase() == 'dr';
    final amount = acc.totalAmount ?? 0.0;
    final openingAmount = acc.openingBalance ?? 0.0;
    final debitText = isDebit ? formatNepaliNumber(amount) : '-';
    final creditText = !isDebit ? formatNepaliNumber(amount) : '-';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9))),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Text(
              acc.accountName ?? '',
              style: const TextStyle(color: Color(0xFF334155), fontSize: 13),
            ),
          ),
          if (_showOpening)
            Expanded(
              flex: 2,
              child: Text(
                openingAmount == 0 ? '-' : _formatSignedValue(openingAmount),
                textAlign: TextAlign.right,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF1E293B),
                ),
              ),
            ),
          Expanded(
            flex: 2,
            child: Text(
              _showOpening
                  ? ((acc.totalDebit ?? 0) == 0
                      ? '-'
                      : formatNepaliNumber(acc.totalDebit ?? 0))
                  : debitText,
              textAlign: TextAlign.right,
              style: TextStyle(
                color:
                    isDebit ? const Color(0xFF1E293B) : const Color(0xFF94A3B8),
                fontWeight: isDebit ? FontWeight.w600 : FontWeight.normal,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              _showOpening
                  ? ((acc.totalCredit ?? 0) == 0
                      ? '-'
                      : formatNepaliNumber(acc.totalCredit ?? 0))
                  : creditText,
              textAlign: TextAlign.right,
              style: TextStyle(
                color: !isDebit
                    ? const Color(0xFF1E293B)
                    : const Color(0xFF94A3B8),
                fontWeight: !isDebit ? FontWeight.w600 : FontWeight.normal,
                fontSize: 13,
              ),
            ),
          ),
          if (_showOpening)
            Expanded(
              flex: 2,
              child: Text(
                amount == 0 ? '-' : _formatSignedValue(amount),
                textAlign: TextAlign.right,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF1E293B),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildGroupTotalRow(TrialBalanceMainGroup group) {
    return Container(
      color: const Color(0xFFF8FAFC),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          const Expanded(
            flex: 4,
            child: Text(
              'GROUP TOTAL',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF475569),
                fontSize: 12,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              group.totalDebit > 0 ? formatNepaliNumber(group.totalDebit) : '-',
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Color(0xFF1E293B),
                fontSize: 12,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              group.totalCredit > 0
                  ? formatNepaliNumber(group.totalCredit)
                  : '-',
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Color(0xFF1E293B),
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportContent(TrialBalanceReport report) {
    final accounts = report.data ?? [];
    if (accounts.isEmpty) {
      return const Center(
        child: Text('No records found for the selected period'),
      );
    }

    final grouping = buildTrialBalanceGrouping(accounts);
    final diff = grouping.difference;
    final diffDebit = grouping.differenceDebit;
    final diffCredit = grouping.differenceCredit;

    return ListView(
      children: [
        ...grouping.parentGroups.map((parentGroup) {
          final isExpanded = _isParentExpanded(parentGroup.name);
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InkWell(
                onTap: () => _toggleParent(parentGroup.name),
                child: Container(
                  width: double.infinity,
                  color: const Color(0xFFE2E8F0),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          parentGroup.name.toUpperCase(),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E293B),
                            fontSize: 13,
                          ),
                        ),
                      ),
                      Icon(
                        isExpanded
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                        size: 20,
                        color: const Color(0xFF475569),
                      ),
                    ],
                  ),
                ),
              ),
              if (isExpanded)
                ...parentGroup.mainGroups.map((mainGroup) {
                  final isMainExpanded = _isMainGroupExpanded(
                    parentGroup.name,
                    mainGroup.name,
                  );
                  return Column(
                    children: [
                      InkWell(
                        onTap: () => _toggleMainGroup(
                          parentGroup.name,
                          mainGroup.name,
                        ),
                        child: Container(
                          width: double.infinity,
                          color: const Color(0xFFF1F5F9),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  mainGroup.name.toUpperCase(),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF475569),
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              Icon(
                                isMainExpanded
                                    ? Icons.keyboard_arrow_up
                                    : Icons.keyboard_arrow_down,
                                size: 18,
                                color: const Color(0xFF64748B),
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (isMainExpanded)
                        ...mainGroup.accounts.map(_buildAccountRow),
                      if (isMainExpanded) _buildGroupTotalRow(mainGroup),
                    ],
                  );
                }),
            ],
          );
        }),
        Container(
          color: const Color(0xFFE2E8F0),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              const Expanded(
                flex: 4,
                child: Text(
                  'GRAND TOTAL',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                    fontSize: 13,
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  grouping.totalDebit > 0
                      ? formatNepaliNumber(grouping.totalDebit)
                      : '-',
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                    fontSize: 13,
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  grouping.totalCredit > 0
                      ? formatNepaliNumber(grouping.totalCredit)
                      : '-',
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (!_showOpening && diff.abs() > 0.01)
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  flex: 4,
                  child: Text(
                    diff >= 0 ? 'DIFFERENCE (DEBIT)' : 'DIFFERENCE (CREDIT)',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF64748B),
                      fontSize: 13,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    diffDebit > 0 ? formatNepaliNumber(diffDebit) : '-',
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                      fontSize: 13,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    diffCredit > 0 ? formatNepaliNumber(diffCredit) : '-',
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
