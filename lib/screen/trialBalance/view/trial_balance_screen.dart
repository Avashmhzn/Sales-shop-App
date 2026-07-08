import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:nepali_utils/nepali_utils.dart';
import 'package:saleup_app/model/trial_balance_report_response.dart';
import 'package:saleup_app/screen/trialBalance/bloc/trial_balance_bloc.dart';
import 'package:saleup_app/screen/trialBalance/bloc/trial_balance_event.dart';
import 'package:saleup_app/screen/trialBalance/bloc/trial_balance_state.dart';
import 'package:saleup_app/services/report_service.dart';
import 'package:saleup_app/utility/trial_balance_grouping.dart';
import 'package:saleup_app/core/network/dio_client.dart';

class TrialBalanceScreen extends StatelessWidget {
  const TrialBalanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          TrialBalanceBloc(reportService: ReportService(dioClient: DioClient()))
            ..add(InitializeTrialBalance()),
      child: const _TrialBalanceView(),
    );
  }
}

class _TrialBalanceView extends StatefulWidget {
  const _TrialBalanceView();

  @override
  State<_TrialBalanceView> createState() => _TrialBalanceViewState();
}

class _TrialBalanceViewState extends State<_TrialBalanceView> {
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isExporting = false;
  String _balanceType = 'with_closing';

  final Map<String, bool> _parentExpanded = {};
  final Map<String, bool> _mainGroupExpanded = {};

  static const _orange = Color(0xFFE8A020);
  static const _lightOrange = Color(0xFFFFF3E0);

  final _numFmt = NumberFormat('#,##,##0.00');

  /// Formats a DateTime as "2082-04-31 (16 Aug)" — BS date + English day/month
  String _fmtDate(DateTime d) {
    final bs = d.toNepaliDateTime();
    final bsStr = NepaliDateFormat('yyyy-MM-dd').format(bs);
    final engStr = DateFormat('d MMM').format(d);
    return '$bsStr ($engStr)';
  }

  // Column flex ratios: accounts=3, debit=2, credit=2
  static const int _accFlex = 3;
  static const int _valFlex = 2;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          'Trial Balance',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: Colors.grey.shade200, height: 1),
        ),
        actions: [
          BlocBuilder<TrialBalanceBloc, TrialBalanceState>(
            builder: (context, state) {
              if (state is TrialBalanceLoading) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                );
              }
              return IconButton(
                icon: const Icon(Icons.filter_list_rounded),
                tooltip: 'Filter',
                onPressed: () => _showFilterSheet(context),
              );
            },
          ),
        ],
      ),
      body: BlocConsumer<TrialBalanceBloc, TrialBalanceState>(
        listener: (context, state) {
          if (state is TrialBalanceDatesLoaded) {
            setState(() {
              _startDate = state.startDate;
              _endDate = state.endDate;
            });
          }
          if (state is TrialBalanceSuccess) {
            setState(() {
              _startDate = state.startDate;
              _endDate = state.endDate;
              _balanceType = state.balanceType;
            });
          }
          if (state is TrialBalanceFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red.shade600,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        builder: (context, state) {
          return Column(
            children: [
              _buildDateBar(),
              // Export Excel button
              if (state is TrialBalanceSuccess)
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                  child: Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: _isExporting ? null : _exportExcel,
                        icon: _isExporting
                            ? const SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.white))
                            : const Icon(Icons.download_rounded, size: 16),
                        label: Text(
                            _isExporting ? 'Exporting...' : 'Export Excel'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1E7E34),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                          elevation: 0,
                        ),
                      ),
                    ],
                  ),
                ),
              Expanded(child: _buildBody(context, state)),
            ],
          );
        },
      ),
    );
  }

  Future<void> _exportExcel() async {
    if (_startDate == null || _endDate == null) return;
    setState(() => _isExporting = true);
    try {
      final path = await context.read<TrialBalanceBloc>().reportService.exportReport(
        reportType: 'trial_balance',
        startDate: DateFormat('yyyy-MM-dd').format(_startDate!),
        endDate: DateFormat('yyyy-MM-dd').format(_endDate!),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Exported: $path'),
            backgroundColor: Colors.green.shade600,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export failed: $e'),
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  Widget _buildDateBar() {
    const balanceLabels = {
      'with_closing': 'With Closing',
      'without_closing': 'Without Closing',
      'opening': 'Opening Balance',
    };
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          const Icon(Icons.calendar_today_rounded, size: 15, color: _orange),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  balanceLabels[_balanceType] ?? 'Trial Balance',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: _orange,
                  ),
                ),
                Text(
                  _startDate != null && _endDate != null
                      ? '${_fmtDate(_startDate!)}  →  ${_fmtDate(_endDate!)}'
                      : 'Loading dates...',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade700,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => _showFilterSheet(context),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _lightOrange,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.tune_rounded, size: 14, color: _orange),
                  SizedBox(width: 4),
                  Text('Filter',
                      style: TextStyle(
                          fontSize: 12,
                          color: _orange,
                          fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Body ───────────────────────────────────────────────────────────────────
  Widget _buildBody(BuildContext context, TrialBalanceState state) {
    if (state is TrialBalanceInitial ||
        state is TrialBalanceDatesLoaded ||
        state is TrialBalanceLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state is TrialBalanceFailure) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline_rounded,
                size: 48, color: Colors.red.shade300),
            const SizedBox(height: 12),
            Text(state.message,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade600)),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => context
                  .read<TrialBalanceBloc>()
                  .add(InitializeTrialBalance()),
              icon: const Icon(Icons.refresh, size: 16),
              label: const Text('Retry'),
            ),
          ],
        ),
      );
    }
    if (state is TrialBalanceSuccess) {
      if (state.accounts.isEmpty) {
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.receipt_long_outlined,
                  size: 56, color: Colors.grey.shade300),
              const SizedBox(height: 12),
              Text('No data found for selected period',
                  style:
                      TextStyle(color: Colors.grey.shade500, fontSize: 14)),
            ],
          ),
        );
      }
      return _buildTable(state.grouping);
    }
    return const SizedBox.shrink();
  }

  // ─── Table ──────────────────────────────────────────────────────────────────
  Widget _buildTable(TrialBalanceGroupingResult grouping) {
    return SingleChildScrollView(
      child: Column(
        children: [
          _tableHeader(),
          for (final parent in grouping.parentGroups) ...[
            _parentRow(parent),
            if (_parentExpanded[parent.name] != false) ...[
              for (final mg in parent.mainGroups) ...[
                _mainGroupRow(parent.name, mg),
                if (_mainGroupExpanded[
                        '${parent.name}__${mg.name}'] !=
                    false) ...[
                  for (final acc in mg.accounts) _accountRow(acc),
                ],
              ],
            ],
          ],
          _grandTotalRow(grouping),
          _differenceRow(grouping),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // ─── Table header ────────────────────────────────────────────────────────────
  Widget _tableHeader() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Expanded(
            flex: _accFlex,
            child: Text('ACCOUNTS',
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Colors.grey.shade500,
                    letterSpacing: 0.8)),
          ),
          Expanded(
            flex: _valFlex,
            child: Text('DEBIT',
                textAlign: TextAlign.right,
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Colors.grey.shade500,
                    letterSpacing: 0.8)),
          ),
          Expanded(
            flex: _valFlex,
            child: Text('CREDIT',
                textAlign: TextAlign.right,
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Colors.grey.shade500,
                    letterSpacing: 0.8)),
          ),
        ],
      ),
    );
  }

  // ─── Parent row (e.g. ASSETS) ────────────────────────────────────────────────
  Widget _parentRow(TrialBalanceParentGroup parent) {
    final isExpanded = _parentExpanded[parent.name] != false;
    return GestureDetector(
      onTap: () =>
          setState(() => _parentExpanded[parent.name] = !isExpanded),
      child: Container(
        color: const Color(0xFFEEEEEE),
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
        child: Row(
          children: [
            Icon(
              isExpanded
                  ? Icons.keyboard_arrow_down_rounded
                  : Icons.keyboard_arrow_right_rounded,
              size: 18,
              color: _orange,
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                parent.name,
                style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: _orange),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Main group row (e.g. CURRENT ASSETS) ────────────────────────────────────
  Widget _mainGroupRow(String parentName, TrialBalanceMainGroup mg) {
    final key = '${parentName}__${mg.name}';
    final isExpanded = _mainGroupExpanded[key] != false;
    return GestureDetector(
      onTap: () =>
          setState(() => _mainGroupExpanded[key] = !isExpanded),
      child: Container(
        color: const Color(0xFFF5F5F5),
        padding: const EdgeInsets.only(
            left: 32, right: 16, top: 9, bottom: 9),
        child: Row(
          children: [
            Icon(
              isExpanded
                  ? Icons.keyboard_arrow_down_rounded
                  : Icons.keyboard_arrow_right_rounded,
              size: 15,
              color: _orange,
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                mg.name,
                style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                    color: _orange),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Account row ─────────────────────────────────────────────────────────────
  Widget _accountRow(TrialBalanceAccount account) {
    final isDebit =
        (account.drCr ?? '').trim().toLowerCase().contains('debit');
    final amount = (account.totalAmount ?? 0.0).abs();
    final formatted =
        '${_numFmt.format(amount)} ${isDebit ? 'Dr' : 'Cr'}';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border:
            Border(bottom: BorderSide(color: Colors.grey.shade100)),
      ),
      padding: const EdgeInsets.only(
          left: 48, right: 16, top: 10, bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: _accFlex,
            child: Text(
              account.accountName ?? '',
              style: const TextStyle(fontSize: 13, color: Colors.black87),
            ),
          ),
          Expanded(
            flex: _valFlex,
            child: Text(
              isDebit ? formatted : '-',
              textAlign: TextAlign.right,
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87),
            ),
          ),
          Expanded(
            flex: _valFlex,
            child: Text(
              !isDebit ? formatted : '-',
              textAlign: TextAlign.right,
              style:
                  TextStyle(fontSize: 13, color: Colors.grey.shade700),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Grand total row ─────────────────────────────────────────────────────────
  Widget _grandTotalRow(TrialBalanceGroupingResult g) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.grey.shade400, width: 1.5),
          bottom: BorderSide(color: Colors.grey.shade400, width: 1.5),
        ),
      ),
      padding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          const Expanded(
            flex: _accFlex,
            child: Text('GRAND TOTAL',
                style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                    color: Colors.black87)),
          ),
          Expanded(
            flex: _valFlex,
            child: Text(
              '${_numFmt.format(g.totalDebit)} Dr',
              textAlign: TextAlign.right,
              style: const TextStyle(
                  fontWeight: FontWeight.w800, fontSize: 13),
            ),
          ),
          Expanded(
            flex: _valFlex,
            child: Text(
              g.totalCredit > 0
                  ? '${_numFmt.format(g.totalCredit)} Cr'
                  : '- Dr',
              textAlign: TextAlign.right,
              style: const TextStyle(
                  fontWeight: FontWeight.w800, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Difference row ──────────────────────────────────────────────────────────
  Widget _differenceRow(TrialBalanceGroupingResult g) {
    final diff = g.totalDebit - g.totalCredit;
    final label =
        diff >= 0 ? 'DIFFERENCE\n(DEBIT)' : 'DIFFERENCE\n(CREDIT)';

    return Container(
      color: const Color(0xFFF5F5F5),
      padding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: _accFlex,
            child: Text(label,
                style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: Colors.black87)),
          ),
          Expanded(
            flex: _valFlex,
            child: Text(
              _numFmt.format(g.totalDebit),
              textAlign: TextAlign.right,
              style: const TextStyle(
                  fontWeight: FontWeight.w700, fontSize: 13),
            ),
          ),
          Expanded(
            flex: _valFlex,
            child: Text(
              _numFmt.format(diff < 0 ? diff.abs() : 0.0),
              textAlign: TextAlign.right,
              style: const TextStyle(
                  fontWeight: FontWeight.w700, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Filter bottom sheet ─────────────────────────────────────────────────────
  void _showFilterSheet(BuildContext context) {
    DateTime? tempStart = _startDate;
    DateTime? tempEnd = _endDate;
    String tempBalanceType = _balanceType;

    const balanceTypes = [
      ('with_closing', 'Trial Balance with Closing'),
      ('without_closing', 'Trial Balance without Closing'),
      ('opening', 'Opening Balance'),
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheet) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(4)),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text('Filter Report',
                      style: TextStyle(
                          fontSize: 17, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  // Balance Type dropdown
                  DropdownButtonFormField<String>(
                    value: tempBalanceType,
                    decoration: InputDecoration(
                      labelText: 'Balance Type',
                      labelStyle: TextStyle(
                          fontSize: 12, color: Colors.grey.shade600),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide:
                              BorderSide(color: Colors.grey.shade300)),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide:
                              BorderSide(color: Colors.grey.shade300)),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                    ),
                    items: balanceTypes
                        .map((t) => DropdownMenuItem(
                            value: t.$1, child: Text(t.$2, style: const TextStyle(fontSize: 13))))
                        .toList(),
                    onChanged: (v) =>
                        setSheet(() => tempBalanceType = v ?? tempBalanceType),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _sheetDateField(
                          ctx: ctx,
                          label: 'Start Date',
                          date: tempStart,
                          onPicked: (d) =>
                              setSheet(() => tempStart = d),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _sheetDateField(
                          ctx: ctx,
                          label: 'End Date',
                          date: tempEnd,
                          onPicked: (d) =>
                              setSheet(() => tempEnd = d),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.pop(ctx);
                            context
                                .read<TrialBalanceBloc>()
                                .add(ResetTrialBalance());
                          },
                          icon: const Icon(Icons.refresh_rounded,
                              size: 16),
                          label: const Text('Reset'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                vertical: 14),
                            side: BorderSide(
                                color: Colors.grey.shade300),
                            shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(10)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed:
                              (tempStart != null && tempEnd != null)
                                  ? () {
                                      Navigator.pop(ctx);
                                      setState(() {
                                        _startDate = tempStart;
                                        _endDate = tempEnd;
                                        _balanceType = tempBalanceType;
                                      });
                                      context
                                          .read<TrialBalanceBloc>()
                                          .add(FetchTrialBalance(
                                            startDate:
                                                DateFormat('yyyy-MM-dd')
                                                    .format(tempStart!),
                                            endDate:
                                                DateFormat('yyyy-MM-dd')
                                                    .format(tempEnd!),
                                            balanceType: tempBalanceType,
                                          ));
                                    }
                                  : null,
                          icon: const Icon(Icons.check_rounded,
                              size: 16),
                          label: const Text('Apply'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _orange,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                vertical: 14),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(10)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _sheetDateField({
    required BuildContext ctx,
    required String label,
    required DateTime? date,
    required ValueChanged<DateTime> onPicked,
  }) {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: ctx,
          initialDate: date ?? DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
        );
        if (picked != null) onPicked(picked);
      },
      borderRadius: BorderRadius.circular(10),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          labelStyle:
              TextStyle(fontSize: 12, color: Colors.grey.shade600),
          prefixIcon: const Icon(Icons.calendar_today_rounded,
              size: 16, color: _orange),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide:
                  BorderSide(color: Colors.grey.shade300)),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide:
                  BorderSide(color: Colors.grey.shade300)),
          contentPadding: const EdgeInsets.symmetric(
              horizontal: 12, vertical: 8),
        ),
        child: Text(
          date != null
              ? _fmtDate(date)
              : 'Select',
          style: TextStyle(
              fontSize: 13,
              color: date != null
                  ? Colors.black87
                  : Colors.grey.shade400),
        ),
      ),
    );
  }
}
