// lib/bloc/company_event.dart
import 'package:equatable/equatable.dart';

sealed class CompanyEvent extends Equatable {
  const CompanyEvent();
  @override
  List<Object?> get props => [];
}

class LoadUserCompanies extends CompanyEvent {
  const LoadUserCompanies();
}

class SelectCompany extends CompanyEvent {
  final int companyId;
  const SelectCompany(this.companyId);

  @override
  List<Object?> get props => [companyId];
}
