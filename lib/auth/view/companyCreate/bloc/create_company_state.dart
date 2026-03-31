// lib/auth/view/createCompany/bloc/create_company_state.dart
import 'package:equatable/equatable.dart';
import 'package:saleup_app/auth/view/companySelect/model/company.dart';

class CreateCompanyState extends Equatable {
  final bool isLoading;
  final bool isSuccess;
  final Company? createdCompany;
  final String? errorMessage;

  const CreateCompanyState({
    this.isLoading = false,
    this.isSuccess = false,
    this.createdCompany,
    this.errorMessage,
  });

  CreateCompanyState copyWith({
    bool? isLoading,
    bool? isSuccess,
    Company? createdCompany,
    String? errorMessage,
  }) {
    return CreateCompanyState(
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? this.isSuccess,
      createdCompany: createdCompany ?? this.createdCompany,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  /// Fully reset back to initial — used by [ResetCreateCompany]
  CreateCompanyState get reset => const CreateCompanyState();

  @override
  List<Object?> get props => [
        isLoading,
        isSuccess,
        createdCompany,
        errorMessage,
      ];
}
