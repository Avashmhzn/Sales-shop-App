// lib/bloc/company/company_state.dart
import 'package:equatable/equatable.dart';
import 'package:saleup_app/auth/view/companySelect/model/company.dart';

class CompanyState extends Equatable {
  final bool isLoading;
  final List<Company> companies;
  final Company? selectedCompany;
  final String? errorMessage;

  const CompanyState({
    this.isLoading = false,
    this.companies = const [],
    this.selectedCompany,
    this.errorMessage,
  });

  CompanyState copyWith({
    bool? isLoading,
    List<Company>? companies,
    Company? selectedCompany,
    String? errorMessage,
  }) {
    return CompanyState(
      isLoading: isLoading ?? this.isLoading,
      companies: companies ?? this.companies,
      selectedCompany: selectedCompany ?? this.selectedCompany,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props =>
      [isLoading, companies, selectedCompany, errorMessage];
}
