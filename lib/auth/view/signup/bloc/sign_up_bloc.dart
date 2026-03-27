import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'package:saleup_app/auth/view/signup/bloc/sign_in_up_event.dart';
import 'package:saleup_app/auth/view/signup/bloc/sign_up_state.dart';
import 'dart:developer';
import 'package:saleup_app/core/network/dio_client.dart';

class SignUpBloc extends Bloc<SignUpEvent, SignUpState> {
  SignUpBloc() : super(const SignUpState()) {
    on<UpdateFirstName>((event, emit) =>
        emit(state.copyWith(firstName: event.firstName.trim())));
    on<UpdateLastName>(
        (event, emit) => emit(state.copyWith(lastName: event.lastName.trim())));
    on<UpdateUsername>(
        (event, emit) => emit(state.copyWith(username: event.username.trim())));
    on<UpdateEmail>(
        (event, emit) => emit(state.copyWith(email: event.email.trim())));
    on<UpdatePhone>(
        (event, emit) => emit(state.copyWith(phone: event.phone.trim())));
    on<UpdatePassword>(
        (event, emit) => emit(state.copyWith(password: event.password)));
    on<UpdateConfirmPassword>((event, emit) =>
        emit(state.copyWith(confirmPassword: event.confirmPassword)));
    on<ToggleTerms>(
        (event, emit) => emit(state.copyWith(termsAgreed: event.agreed)));

    on<SubmitRegistration>(_onSubmitRegistration);
  }

  Future<void> _onSubmitRegistration(
    SubmitRegistration event,
    Emitter<SignUpState> emit,
  ) async {
    if (!state.canSubmit) {
      emit(state.copyWith(
        status: SignUpStatus.failure,
        errorMessage: 'Please fill all fields correctly and agree to terms',
      ));
      return;
    }

    emit(state.copyWith(
      status: SignUpStatus.loading,
      errorMessage: null,
      fieldErrors: null,
    ));

    try {
      final request = {
        "email": state.email,
        "username": state.username,
        "password": state.password,
        "first_name": state.firstName,
        "last_name": state.lastName,
        "mobile": state.phone,
        "is_active": state.isActive ?? true,
        "is_staff": state.isStaff ?? true,
        "is_superuser": state.isSuperuser ?? false,
        "domains": [],
        "groups": state.groups ?? ["Admin"],
        "user_permissions": []
      };

      log('Register Payload → $request');

      final response = await DioClient().dio.post(
            '/auth/register/',
            data: request,
          );

      log('Response Status: ${response.statusCode}');
      log('Response Body: ${response.data}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;

        if (data['success'] == true) {
          emit(state.copyWith(
            status: SignUpStatus.success,
            errorMessage: data['message'] ?? 'User created successfully.',
          ));
        } else {
          emit(state.copyWith(
            status: SignUpStatus.failure,
            errorMessage: data['message'] ?? 'Registration failed',
          ));
        }
      }
    } on DioException catch (e) {
      String msg = 'Registration failed';
      Map<String, String>? fieldErrs = {};

      log('Error Response: ${e.response?.data}');

      if (e.response?.data is Map) {
        final err = e.response!.data as Map<dynamic, dynamic>;

        msg = err['message']?.toString() ??
            err['detail']?.toString() ??
            (err['password']?.toString() ?? 'Invalid input');

        if (err.containsKey('password')) {
          fieldErrs['password'] = err['password'].toString();
        }
        if (err.containsKey('email')) {
          fieldErrs['email'] = err['email'].toString();
        }
        if (err.containsKey('username')) {
          fieldErrs['username'] = err['username'].toString();
        }
        if (err.containsKey('mobile')) {
          fieldErrs['phone'] = err['mobile'].toString();
        }
      }

      emit(state.copyWith(
        status: SignUpStatus.failure,
        errorMessage: msg,
        fieldErrors: fieldErrs.isNotEmpty ? fieldErrs : null,
      ));
    } catch (e) {
      log('Unexpected error: $e');
      emit(state.copyWith(
        status: SignUpStatus.failure,
        errorMessage: 'Something went wrong. Please try again.',
      ));
    }
  }
}
