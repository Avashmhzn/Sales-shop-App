// lib/screen/dashboard/bloc/dashboard_event.dart

import 'package:equatable/equatable.dart';

sealed class DashboardEvent extends Equatable {
  const DashboardEvent();

  @override
  List<Object?> get props => [];
}

class FetchFiscalYears extends DashboardEvent {
  const FetchFiscalYears();
}

class ChangeFiscalYear extends DashboardEvent {
  final int fiscalYearId;

  const ChangeFiscalYear(this.fiscalYearId);

  @override
  List<Object> get props => [fiscalYearId];
}

class FetchDashboardData extends DashboardEvent {
  const FetchDashboardData();
}

class ResetRefreshFlag extends DashboardEvent {
  const ResetRefreshFlag();
}
