// lib/auth/view/createCompany/bloc/create_company_bloc.dart
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:saleup_app/auth/view/companyCreate/model/create_company_request.dart';
import 'package:saleup_app/auth/view/companySelect/model/company.dart';
import 'package:saleup_app/core/network/dio_client.dart';

import 'create_company_event.dart';
import 'create_company_state.dart';

class CreateCompanyBloc extends Bloc<CreateCompanyEvent, CreateCompanyState> {
  CreateCompanyBloc() : super(const CreateCompanyState()) {
    on<SubmitCreateCompany>(_onSubmitCreateCompany);
    on<ResetCreateCompany>(_onResetCreateCompany);
  }

  // ── Helpers ──────────────────────────────────────────────────────────────

  /// "Himalayan Traders" → "himalayan-traders"
  String _toSlug(String name) =>
      name.trim().toLowerCase().replaceAll(RegExp(r'\s+'), '-');

  // ── Handlers ─────────────────────────────────────────────────────────────

  Future<void> _onSubmitCreateCompany(
    SubmitCreateCompany event,
    Emitter<CreateCompanyState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));

    try {
      final slug = _toSlug(event.companyName);

      final request = CreateCompanyRequest(
        companyName: event.companyName,
        companyAddress: event.companyAddress,
        companyContact: event.companyContact,
        domain: event.domain,
        name: slug,
        schemaName: slug,
        onTrial: event.onTrial,
        paidUntil: event.paidUntil,
      );

      log('CreateCompany → POST /companies/create_user_company/');
      log('Payload: ${request.toJson()}');

      // ✅ UPDATE THIS PATH to match your backend endpoint
      final res = await DioClient()
          .dio
          .post('/company/create_user_company/', data: request.toJson());

      log('CreateCompany response status: ${res.statusCode}');
      log('CreateCompany response data: ${res.data}');

      if (res.statusCode == 200 || res.statusCode == 201) {
        final body = res.data as Map<String, dynamic>?;

        if (body?['success'] == true) {
          final data = body!['data'] as Map<String, dynamic>;

          final company = Company(
            id: data['company_id'] as int,
            name: data['name'] as String? ?? slug,
            companyName: data['company_name'] as String?,
            domain: data['domain'] as String?,
            paidUntil: data['paid_until'] as String? ?? event.paidUntil,
            onTrial: data['on_trial'] as bool? ?? event.onTrial,
            isActive: true,
          );

          log('Company created: ID=${company.id}, name=${company.displayName}');

          emit(state.copyWith(
            isLoading: false,
            isSuccess: true,
            createdCompany: company,
            errorMessage: null,
          ));
        } else {
          final msg = body?['message'] as String? ?? 'Failed to create company';
          log('CreateCompany API error: $msg');
          emit(state.copyWith(isLoading: false, errorMessage: msg));
        }
      } else {
        emit(state.copyWith(
          isLoading: false,
          errorMessage: 'Server error (HTTP ${res.statusCode})',
        ));
      }
    } on DioException catch (e) {
      String message = 'Network error';
      if (e.response?.data is Map<String, dynamic>) {
        message =
            e.response?.data['message'] as String? ?? e.message ?? message;
      }
      log('DioException creating company: $e → $message');
      emit(state.copyWith(isLoading: false, errorMessage: message));
    } catch (e, stack) {
      log('Unexpected error creating company: $e', stackTrace: stack);
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'Something went wrong while creating the company',
      ));
    }
  }

  void _onResetCreateCompany(
    ResetCreateCompany event,
    Emitter<CreateCompanyState> emit,
  ) {
    emit(state.reset);
  }
}
