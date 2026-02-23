class Company {
  final int id;
  final String? companyName;
  final String? companyAddress;
  final String? companyContact;
  final String name;
  final String? domain;
  final String? paidUntil;
  final bool onTrial;
  final String? createdOn;
  final bool isActive;

  Company({
    required this.id,
    this.companyName,
    this.companyAddress,
    this.companyContact,
    required this.name,
    this.domain,
    this.paidUntil,
    this.onTrial = false,
    this.createdOn,
    this.isActive = false,
  });

  factory Company.fromJson(Map<String, dynamic> json) {
    return Company(
      id: json['company_id'] as int? ?? 0,
      companyName: json['company_name'] as String?,
      companyAddress: json['company_address'] as String?,
      companyContact: json['company_contact'] as String?,
      name: json['name'] as String? ?? 'Unnamed Company',
      domain: json['domain'] as String?,
      paidUntil: json['paid_until'] as String?,
      onTrial: json['on_trial'] as bool? ?? false,
      createdOn: json['created_on'] as String?,
      isActive: json['is_active'] as bool? ?? false,
    );
  }

  // ────────────────────────────────────────────────────────────────
  //   ADD THIS METHOD — this is what was missing
  // ────────────────────────────────────────────────────────────────
  Company copyWith({
    int? id,
    String? companyName,
    String? companyAddress,
    String? companyContact,
    String? name,
    String? domain,
    String? paidUntil,
    bool? onTrial,
    String? createdOn,
    bool? isActive,
  }) {
    return Company(
      id: id ?? this.id,
      companyName: companyName ?? this.companyName,
      companyAddress: companyAddress ?? this.companyAddress,
      companyContact: companyContact ?? this.companyContact,
      name: name ?? this.name,
      domain: domain ?? this.domain,
      paidUntil: paidUntil ?? this.paidUntil,
      onTrial: onTrial ?? this.onTrial,
      createdOn: createdOn ?? this.createdOn,
      isActive: isActive ?? this.isActive,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'company_id': id,
      'company_name': companyName,
      'company_address': companyAddress,
      'company_contact': companyContact,
      'name': name,
      'domain': domain,
      'paid_until': paidUntil,
      'on_trial': onTrial,
      'created_on': createdOn,
      'is_active': isActive,
    };
  }

  String get displayName => companyName ?? name;
}
