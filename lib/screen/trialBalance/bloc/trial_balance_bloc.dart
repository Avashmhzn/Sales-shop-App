import 'dart:developer';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:saleup_app/model/trial_balance_report_response.dart';
import 'package:saleup_app/services/report_service.dart';
import 'package:saleup_app/utility/trial_balance_grouping.dart';
import 'trial_balance_event.dart';
import 'trial_balance_state.dart';

class TrialBalanceBloc extends Bloc<TrialBalanceEvent, TrialBalanceState> {
  final ReportService reportService;

  DateTime _defaultStart = DateTime.now();
  DateTime _defaultEnd = DateTime.now();

  TrialBalanceBloc({required this.reportService})
      : super(TrialBalanceInitial()) {
    on<InitializeTrialBalance>(_onInitialize);
    on<FetchTrialBalance>(_onFetch);
    on<ResetTrialBalance>(_onReset);
  }

  Future<void> _onInitialize(
    InitializeTrialBalance event,
    Emitter<TrialBalanceState> emit,
  ) async {
    emit(TrialBalanceLoading());
    try {
      // Get day open date first
      final dayOpenDate = await reportService.getDayOpenDate();
      log('📅 [TrialBalance] Day open date: $dayOpenDate', name: 'TrialBalance');

      // Find the fiscal year that contains the day open date
      final dayOpen = dayOpenDate != null ? DateTime.tryParse(dayOpenDate) : null;
      final fiscalYear = dayOpen != null
          ? await reportService.getFiscalYearContaining(dayOpen)
          : await reportService.getActiveFiscalYear();
      log('📅 [TrialBalance] Fiscal year: start=${fiscalYear?.startDate}, end=${fiscalYear?.endDate}', name: 'TrialBalance');

      if (fiscalYear != null && fiscalYear.startDate.isNotEmpty) {
        _defaultStart = DateTime.tryParse(fiscalYear.startDate) ?? _defaultStart;
      }

      // End = day open date (guaranteed within fiscal year now)
      _defaultEnd = dayOpen ?? 
          (fiscalYear?.endDate != null ? DateTime.tryParse(fiscalYear!.endDate!) ?? _defaultEnd : _defaultEnd);

      log('📅 [TrialBalance] Using dates → start: ${_fmt(_defaultStart)}, end: ${_fmt(_defaultEnd)}', name: 'TrialBalance');

      emit(TrialBalanceDatesLoaded(
          startDate: _defaultStart, endDate: _defaultEnd));

      add(FetchTrialBalance(
        startDate: _fmt(_defaultStart),
        endDate: _fmt(_defaultEnd),
      ));
    } catch (e) {
      log('❌ [TrialBalance] Init error: $e', name: 'TrialBalance');
      emit(TrialBalanceFailure('Initialization failed: $e'));
    }
  }

  Future<void> _onFetch(
    FetchTrialBalance event,
    Emitter<TrialBalanceState> emit,
  ) async {
    emit(TrialBalanceLoading());
    try {
      log('🌐 [TrialBalance] GET /ledger/get_trial_balance/?start_date=${event.startDate}&end_date=${event.endDate}', name: 'TrialBalance');
      final raw = await reportService.fetchReport(
        '/ledger/get_trial_balance/',
        {
          'start_date': event.startDate,
          'end_date': event.endDate,
          'balance_type': event.balanceType,
        },
      );
      log('✅ [TrialBalance] Response: $raw', name: 'TrialBalance');
      final report = TrialBalanceReport.fromJson(raw);
      log('📊 [TrialBalance] Parsed ${report.data?.length ?? 0} accounts, success=${report.success}', name: 'TrialBalance');
      if (report.success) {
        final accounts = report.data ?? [];
        for (final a in accounts) {
          log('  → ${a.parent} / ${a.mainGroup} / ${a.accountName} | dr_cr=${a.drCr} | total_amount=${a.totalAmount}', name: 'TrialBalance');
        }
        final grouping = buildTrialBalanceGrouping(accounts);
        log('📊 [TrialBalance] Grouping → totalDebit=${grouping.totalDebit}, totalCredit=${grouping.totalCredit}', name: 'TrialBalance');
        emit(TrialBalanceSuccess(
          accounts: accounts,
          grouping: grouping,
          startDate: DateTime.tryParse(event.startDate) ?? _defaultStart,
          endDate: DateTime.tryParse(event.endDate) ?? _defaultEnd,
          balanceType: event.balanceType,
        ));
      } else {
        log('❌ [TrialBalance] API returned success=false: ${report.message}', name: 'TrialBalance');
        emit(TrialBalanceFailure(report.message));
      }
    } catch (e, st) {
      log('❌ [TrialBalance] Fetch error: $e', name: 'TrialBalance', stackTrace: st);
      emit(TrialBalanceFailure('Error: $e'));
    }
  }

  void _onReset(ResetTrialBalance event, Emitter<TrialBalanceState> emit) {
    emit(TrialBalanceDatesLoaded(
        startDate: _defaultStart, endDate: _defaultEnd));
    add(FetchTrialBalance(
      startDate: _fmt(_defaultStart),
      endDate: _fmt(_defaultEnd),
    ));
  }

  String _fmt(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}
