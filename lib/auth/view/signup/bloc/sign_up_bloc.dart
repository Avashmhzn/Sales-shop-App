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
        status: SignUpStatus.loading, errorMessage: null, fieldErrors: null));

    try {
      final request = {
        "email": state.email,
        "username": state.username,
        "mobile": state.phone,
        "password": state.password,
        "first_name": state.firstName,
        "last_name": state.lastName,
        "is_active": true,
        "is_staff": false,
        "is_superuser": false,
      };

      log('Register → $request');

      final response = await DioClient().dio.post(
            '/auth/register/',
            data: request,
          );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;

        if (data['success'] == true) {
          // Optional: if backend returns tokens here → save them
          // await AuthService().saveTokens(...);

          emit(state.copyWith(
            status: SignUpStatus.success,
            errorMessage: data['message'] ?? 'Account created successfully!',
          ));
        } else {
          emit(state.copyWith(
            status: SignUpStatus.failure,
            errorMessage: data['message'] ?? 'Registration failed',
          ));
        }
      } else {
        emit(state.copyWith(
          status: SignUpStatus.failure,
          errorMessage: 'Unexpected status: ${response.statusCode}',
        ));
      }
    } on DioException catch (e) {
      String msg = 'Registration failed';
      Map<String, String>? fieldErrs;

      if (e.response?.data is Map) {
        final err = e.response!.data as Map;
        msg = err['message'] ?? 'Invalid input';

        // Parse field-specific errors if backend sends them (common in Django REST)
        if (err.containsKey('email')) fieldErrs = {'email': err['email'][0]};
        if (err.containsKey('username')) {
          fieldErrs ??= {'username': err['username'][0]};
        }
        if (err.containsKey('mobile')) {
          fieldErrs ??= {'phone': err['mobile'][0]};
        }
        // ... add more fields
      }

      emit(state.copyWith(
        status: SignUpStatus.failure,
        errorMessage: msg,
        fieldErrors: fieldErrs,
      ));
    } catch (e) {
      log('Unexpected: $e');
      emit(state.copyWith(
        status: SignUpStatus.failure,
        errorMessage: 'Something went wrong. Try again.',
      ));
    }
  }
}
