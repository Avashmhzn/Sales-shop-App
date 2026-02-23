import 'package:equatable/equatable.dart';

abstract class SignUpEvent extends Equatable {
  const SignUpEvent();

  @override
  List<Object> get props => [];
}

class UpdateFirstName extends SignUpEvent {
  final String firstName;
  const UpdateFirstName(this.firstName);
}

class UpdateLastName extends SignUpEvent {
  final String lastName;
  const UpdateLastName(this.lastName);
}

class UpdateUsername extends SignUpEvent {
  final String username;
  const UpdateUsername(this.username);
}

class UpdateEmail extends SignUpEvent {
  final String email;
  const UpdateEmail(this.email);
}

class UpdatePhone extends SignUpEvent {
  final String phone;
  const UpdatePhone(this.phone);
}

class UpdatePassword extends SignUpEvent {
  final String password;
  const UpdatePassword(this.password);
}

class UpdateConfirmPassword extends SignUpEvent {
  final String confirmPassword;
  const UpdateConfirmPassword(this.confirmPassword);
}

class ToggleTerms extends SignUpEvent {
  final bool agreed;
  const ToggleTerms(this.agreed);
}

class SubmitRegistration extends SignUpEvent {}
