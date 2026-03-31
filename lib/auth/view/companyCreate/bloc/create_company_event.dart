// lib/auth/view/createCompany/bloc/create_company_event.dart
import 'package:equatable/equatable.dart';

sealed class CreateCompanyEvent extends Equatable {
  const CreateCompanyEvent();

  @override
  List<Object?> get props => [];
}

class SubmitCreateCompany extends CreateCompanyEvent {
  final String companyName;
  final String companyAddress;
  final String companyContact;
  final String domain;
  final String paidUntil;
  final bool onTrial;

  const SubmitCreateCompany({
    required this.companyName,
    required this.companyAddress,
    required this.companyContact,
    required this.domain,
    required this.paidUntil,
    required this.onTrial,
  });

  @override
  List<Object?> get props => [
        companyName,
        companyAddress,
        companyContact,
        domain,
        paidUntil,
        onTrial,
      ];
}

class ResetCreateCompany extends CreateCompanyEvent {
  const ResetCreateCompany();
}
