import 'package:equatable/equatable.dart';

enum SignUpStatus { initial, loading, success, failure }

class SignUpState extends Equatable {
  final String firstName;
  final String lastName;
  final String username;
  final String email;
  final String phone;
  final String password;
  final String confirmPassword;
  final bool termsAgreed;

  final bool? isActive;
  final bool? isStaff;
  final bool? isSuperuser;
  final List<String>? groups;

  final SignUpStatus status;
  final String? errorMessage;
  final Map<String, String>? fieldErrors;

  const SignUpState({
    this.firstName = '',
    this.lastName = '',
    this.username = '',
    this.email = '',
    this.phone = '',
    this.password = '',
    this.confirmPassword = '',
    this.termsAgreed = false,
    this.isActive,
    this.isStaff,
    this.isSuperuser,
    this.groups,
    this.status = SignUpStatus.initial,
    this.errorMessage,
    this.fieldErrors,
  });

  SignUpState copyWith({
    String? firstName,
    String? lastName,
    String? username,
    String? email,
    String? phone,
    String? password,
    String? confirmPassword,
    bool? termsAgreed,
    bool? isActive,
    bool? isStaff,
    bool? isSuperuser,
    List<String>? groups,
    SignUpStatus? status,
    String? errorMessage,
    Map<String, String>? fieldErrors,
  }) {
    return SignUpState(
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      username: username ?? this.username,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      password: password ?? this.password,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      termsAgreed: termsAgreed ?? this.termsAgreed,
      isActive: isActive ?? this.isActive,
      isStaff: isStaff ?? this.isStaff,
      isSuperuser: isSuperuser ?? this.isSuperuser,
      groups: groups ?? this.groups,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      fieldErrors: fieldErrors ?? this.fieldErrors,
    );
  }

  bool get canSubmit =>
      firstName.trim().isNotEmpty &&
      lastName.trim().isNotEmpty &&
      username.trim().isNotEmpty &&
      email.trim().isNotEmpty &&
      phone.trim().isNotEmpty &&
      password.trim().isNotEmpty &&
      password == confirmPassword &&
      termsAgreed;

  @override
  List<Object?> get props => [
        firstName,
        lastName,
        username,
        email,
        phone,
        password,
        confirmPassword,
        termsAgreed,
        isActive,
        isStaff,
        isSuperuser,
        groups,
        status,
        errorMessage,
        fieldErrors,
      ];
}
