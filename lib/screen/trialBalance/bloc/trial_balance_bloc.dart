// lib/screen/trial_balance/bloc/trial_balance_bloc.dart
import 'dart:developer';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:saleup_app/core/network/dio_client.dart';
import 'package:saleup_app/model/trial_balance_report_response.dart';
import 'trial_balance_event.dart';
import 'trial_balance_state.dart';

class TrialBalanceBloc extends Bloc<TrialBalanceEvent, TrialBalanceState> {
  final DioClient dioClient;

  TrialBalanceBloc({required this.dioClient}) : super(TrialBalanceInitial()) {
    on<FetchTrialBalance>(_onFetch);
    on<ClearTrialBalanceFilter>(_onClear);
  }

  Future<void> _onFetch(FetchTrialBalance event, Emitter emit) async {
    emit(TrialBalanceLoading());
    try {
      final report =
          await dioClient.fetchTrialBalance(event.startDate, event.endDate);
      if (report.success && (report.data?.isNotEmpty ?? false)) {
        emit(TrialBalanceLoaded(report));
      } else {
        emit(const TrialBalanceError('No data found for the selected period'));
      }
    } catch (e) {
      log('TrialBalance fetch error: $e');
      emit(TrialBalanceError(e.toString()));
    }
  }

  void _onClear(ClearTrialBalanceFilter event, Emitter emit) {
    emit(TrialBalanceInitial());
  }
}
