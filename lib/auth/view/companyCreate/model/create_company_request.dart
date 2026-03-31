// lib/auth/view/createCompany/model/create_company_request.dart

class CreateCompanyRequest {
  final String companyAddress;
  final String companyContact;
  final String companyName;
  final String domain;
  final String name; // slug — auto-generated from companyName
  final bool onTrial;
  final String paidUntil;
  final String schemaName; // same as name/slug

  const CreateCompanyRequest({
    required this.companyAddress,
    required this.companyContact,
    required this.companyName,
    required this.domain,
    required this.name,
    required this.onTrial,
    required this.paidUntil,
    required this.schemaName,
  });

  Map<String, dynamic> toJson() => {
        'company_address': companyAddress,
        'company_contact': companyContact,
        'company_name': companyName,
        'domain': domain,
        'name': name,
        'on_trial': onTrial,
        'paid_until': paidUntil,
        'schema_name': schemaName,
      };
}
