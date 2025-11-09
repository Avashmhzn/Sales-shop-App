// lib/screen/trial_balance/trial_balance_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:saleup_app/core/network/dio_client.dart';
import 'package:saleup_app/model/trial_balance_report_response.dart';
import 'package:saleup_app/routes/router.dart';
import 'package:saleup_app/screen/trialBalance/bloc/trial_balance_bloc.dart';
import 'package:saleup_app/screen/trialBalance/bloc/trial_balance_event.dart';
import 'package:saleup_app/screen/trialBalance/bloc/trial_balance_state.dart';

class TrialBalanceScreen extends StatefulWidget {
  const TrialBalanceScreen({super.key});
  @override
  State<TrialBalanceScreen> createState() => _TrialBalanceScreenState();
}

class _TrialBalanceScreenState extends State<TrialBalanceScreen> {
  late final TrialBalanceBloc _bloc;
  DateTime? _start;
  DateTime? _end;
  bool _dialogShown = false;
  bool _downloadInProgress = false;

  @override
  void initState() {
    super.initState();
    _bloc = TrialBalanceBloc(dioClient: DioClient());
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  void _pickDate(bool isStart) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() => isStart ? _start = picked : _end = picked);
    }
  }

  void _apply() {
    if (_start == null || _end == null) return;
    _bloc.add(FetchTrialBalance(
      DateFormat('yyyy-MM-dd').format(_start!),
      DateFormat('yyyy-MM-dd').format(_end!),
    ));
  }

  void _clear() {
    setState(() => _start = _end = null);
    _bloc.add(ClearTrialBalanceFilter());
  }

  Future<void> _download(String type, Future<void> Function() fn) async {
    if (_downloadInProgress) return;
    _downloadInProgress = true;

    try {
      await fn();
      final filename =
          'trial_balance_${DateTime.now().millisecondsSinceEpoch}.${type == 'PDF' ? 'pdf' : 'csv'}';
      Future.microtask(() {
        final ctx = rootNavigatorKey.currentContext;
        if (ctx != null && ctx.mounted) {
          ScaffoldMessenger.of(ctx).showSnackBar(
            SnackBar(
                content: Text('$type saved: $filename'),
                backgroundColor: Colors.green),
          );
        }
      });
    } catch (e) {
      Future.microtask(() {
        final ctx = rootNavigatorKey.currentContext;
        if (ctx != null && ctx.mounted) {
          ScaffoldMessenger.of(ctx).showSnackBar(
            SnackBar(
                content: Text('Failed to download $type'),
                backgroundColor: Colors.red),
          );
        }
      });
    } finally {
      _downloadInProgress = false;
      if (mounted) setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => _bloc,
      child: Scaffold(
        appBar: AppBar(title: const Text('Trial Balance'), actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _clear)
        ]),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Date Range',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () => _pickDate(true),
                              child: Text(_start == null
                                  ? 'Start Date'
                                  : DateFormat('yyyy-MM-dd').format(_start!)),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () => _pickDate(false),
                              child: Text(_end == null
                                  ? 'End Date'
                                  : DateFormat('yyyy-MM-dd').format(_end!)),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ElevatedButton(
                              onPressed: (_start != null && _end != null)
                                  ? _apply
                                  : null,
                              child: const Text('Apply')),
                          ElevatedButton(
                              onPressed: _clear, child: const Text('Clear')),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: BlocConsumer<TrialBalanceBloc, TrialBalanceState>(
                  listenWhen: (p, c) =>
                      c is TrialBalanceLoaded && !_dialogShown,
                  listener: (context, state) {
                    if (state is TrialBalanceLoaded && !_dialogShown) {
                      _dialogShown = true;
                      Future.microtask(() {
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (_) => _downloadDialog(state.report),
                        ).then((_) => _dialogShown = false);
                      });
                    }
                  },
                  builder: (context, state) {
                    if (state is TrialBalanceLoading)
                      return const Center(child: CircularProgressIndicator());
                    if (state is TrialBalanceLoaded)
                      return _buildReport(state.report);
                    if (state is TrialBalanceError)
                      return Center(
                          child: Text(state.message,
                              style: const TextStyle(color: Colors.red)));
                    return const Center(
                        child: Text('Select dates and apply filter'));
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _downloadDialog(TrialBalanceReport report) {
    final hasData = (report.data ?? []).isNotEmpty;
    final s = DateFormat('yyyy-MM-dd').format(_start!);
    final e = DateFormat('yyyy-MM-dd').format(_end!);

    return PopScope(
      canPop: true,
      onPopInvoked: (didPop) => !didPop ? context.pop() : null,
      child: AlertDialog(
        title: const Text('Export Trial Balance'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: hasData
              ? [
                  ElevatedButton.icon(
                    icon: const Icon(Icons.picture_as_pdf),
                    label: const Text('Download PDF + PNG Preview'),
                    onPressed: () async {
                      await _download(
                          'PDF',
                          () => DioClient()
                              .downloadTrialBalanceAsPdf(report, s, e));
                      if (mounted) context.pop();
                    },
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.table_chart),
                    label: const Text('Download Excel (CSV)'),
                    onPressed: () async {
                      await _download(
                          'CSV',
                          () => DioClient()
                              .downloadTrialBalanceAsExcel(report, s, e));
                      if (mounted) context.pop();
                    },
                  ),
                ]
              : [const Text('No data to export.')],
        ),
      ),
    );
  }

  Widget _buildReport(TrialBalanceReport report) {
    final accounts = report.data ?? [];
    final groups = <String, List<TrialBalanceAccount>>{};

    for (final acc in accounts) {
      final group = acc.parentAccount?.trim().isNotEmpty == true
          ? acc.parentAccount!
          : 'OTHERS';
      groups.putIfAbsent(group, () => []).add(acc);
    }

    double totalDebit = 0, totalCredit = 0;

    return Column(
      children: [
        Card(
          color: Colors.grey[200],
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('GRAND TOTAL',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Text(totalDebit.toStringAsFixed(2),
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(totalCredit.toStringAsFixed(2),
                    style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: ListView.builder(
            itemCount: groups.length,
            itemBuilder: (context, i) {
              final groupName = groups.keys.elementAt(i);
              final groupAccounts = groups[groupName]!;
              double groupDebit = 0, groupCredit = 0;

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 4),
                color: Colors.grey[100],
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      color: Colors.orange[100],
                      padding: const EdgeInsets.all(8),
                      child: Text(groupName,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.deepOrange)),
                    ),
                    ...groupAccounts.map((acc) {
                      final d = acc.debit ?? 0;
                      final c = acc.credit ?? 0;
                      groupDebit += d;
                      groupCredit += c;
                      totalDebit += d;
                      totalCredit += c;

                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        child: Row(
                          children: [
                            Expanded(
                                flex: 3, child: Text(acc.accountName ?? '')),
                            Expanded(
                                child: Text(d.toStringAsFixed(2),
                                    textAlign: TextAlign.right)),
                            Expanded(
                                child: Text(c.toStringAsFixed(2),
                                    textAlign: TextAlign.right)),
                          ],
                        ),
                      );
                    }),
                    if (groupAccounts.length > 1)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        child: Row(
                          children: [
                            const Expanded(
                                flex: 3,
                                child: Text('TOTAL',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold))),
                            Expanded(
                                child: Text(groupDebit.toStringAsFixed(2),
                                    textAlign: TextAlign.right,
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold))),
                            Expanded(
                                child: Text(groupCredit.toStringAsFixed(2),
                                    textAlign: TextAlign.right,
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold))),
                          ],
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        Card(
          color: Colors.grey[200],
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('DIFFERENCE (CREDIT)',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Text((totalCredit - totalDebit).abs().toStringAsFixed(2),
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                const Text('0.00',
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
