// // lib/bloc/company/company_bloc.dart

// import 'dart:convert';
// import 'dart:developer';

// import 'package:dio/dio.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:go_router/go_router.dart';

// import 'package:saleup_app/auth/view/companySelect/model/company.dart';
// import 'package:saleup_app/core/network/api_endpoints.dart';
// import 'package:saleup_app/core/network/dio_client.dart';
// import 'package:saleup_app/services/auth_service.dart';

// import 'company_event.dart';
// import 'company_state.dart';

// class CompanyBloc extends Bloc<CompanyEvent, CompanyState> {
//   CompanyBloc() : super(const CompanyState()) {
//     on<LoadUserCompanies>(_onLoadCompanies);
//     on<SelectCompany>(_onSelectCompany);
//   }

//   Future<void> _onLoadCompanies(
//     LoadUserCompanies event,
//     Emitter<CompanyState> emit,
//   ) async {
//     emit(state.copyWith(isLoading: true, errorMessage: null));

//     try {
//       // Give secure storage time to settle + log token presence
//       await Future.delayed(const Duration(milliseconds: 600));

//       final tokenNow = await AuthService().getAccessToken();
//       log('Token right before company fetch: ${tokenNow != null ? "YES (len ${tokenNow.length})" : "MISSING!!!"}');

//       final res = await DioClient().dio.get('/company/get_user_companies/');

//       log('Company API Response status: ${res.statusCode}');
//       log('Company API Response type: ${res.data.runtimeType}');
//       log('Company API Raw data:\n${const JsonEncoder.withIndent("  ").convert(res.data)}');

//       if (res.statusCode == 200) {
//         final rawData = res.data as Map<String, dynamic>?;

//         List<dynamic> companyListData = [];

//         if (rawData != null) {
//           // Main expected path: { "data": { "companies": [...] } }
//           final innerData = rawData['data'] as Map<String, dynamic>?;
//           if (innerData != null) {
//             final companiesFromInner = innerData['companies'] as List<dynamic>?;
//             if (companiesFromInner != null) {
//               companyListData = companiesFromInner;
//               log('Success: Found companies at response["data"]["companies"]');
//             }
//           }

//           // Fallbacks in case format changes
//           if (companyListData.isEmpty) {
//             if (rawData['companies'] is List<dynamic>) {
//               companyListData = rawData['companies'];
//               log('Found companies at response["companies"]');
//             } else if (rawData['data'] is List<dynamic>) {
//               companyListData = rawData['data'];
//               log('Found companies at response["data"] (direct list)');
//             } else if (rawData['results'] is List<dynamic>) {
//               companyListData = rawData['results'];
//               log('Found companies at response["results"]');
//             }
//           }
//         }

//         if (companyListData.isEmpty) {
//           log('Warning: No company list could be extracted from response');
//         }

//         // Parse companies safely
//         final companies = companyListData
//             .whereType<Map<String, dynamic>>()
//             .map((json) {
//               try {
//                 final company = Company.fromJson(json);
//                 log('Parsed company: ID=${company.id}, Name=${company.displayName}');
//                 return company;
//               } catch (e, stack) {
//                 log('Failed to parse one company → $e\nItem: $json',
//                     stackTrace: stack);
//                 return null;
//               }
//             })
//             .whereType<Company>()
//             .toList();

//         log('Parsed ${companies.length} valid companies');

//         // Auto-select first company if available
//         final selected = companies.isNotEmpty ? companies.first : null;

//         emit(state.copyWith(
//           isLoading: false,
//           companies: companies,
//           selectedCompany: selected,
//           errorMessage:
//               companies.isEmpty ? 'No companies found for this user' : null,
//         ));
//       } else {
//         emit(state.copyWith(
//           isLoading: false,
//           errorMessage: 'Failed to load companies (HTTP ${res.statusCode})',
//         ));
//       }
//     } on DioException catch (e) {
//       // ====================== FIXED: Handle token_not_valid ======================
//       if (e.response?.statusCode == 401) {
//         final data = e.response?.data;
//         bool isTokenInvalid = false;

//         if (data is Map<String, dynamic>) {
//           final code = data['code']?.toString();
//           final detail = data['detail']?.toString().toLowerCase() ?? '';

//           if (code == 'token_not_valid' ||
//               detail.contains('token not valid') ||
//               detail.contains('token is invalid') ||
//               detail.contains('expired')) {
//             isTokenInvalid = true;
//             log('🚨 TOKEN NOT VALID DETECTED - Forcing logout');
//           }
//         }

//         if (isTokenInvalid) {
//           log('Clearing tokens and navigating to login screen');
//           await AuthService().clearTokens();
//           try {
//             await DioClient().cookieJar.deleteAll();
//           } catch (_) {}
//           Api.resetToPublic();

//           // Navigate to login
//           final context = DioClient.navigatorKey.currentContext;
//           if (context != null && context.mounted) {
//             context.go('/login');
//           }

//           emit(state.copyWith(
//             isLoading: false,
//             errorMessage: 'Session expired. Please login again.',
//           ));
//           return;
//         }
//       }
//       // ========================================================================

//       String message = 'Network error';
//       if (e.response?.data is Map<String, dynamic>) {
//         message = e.response?.data['message'] ?? e.message ?? message;
//       }
//       log('DioException loading companies: $e → message: $message');
//       emit(state.copyWith(
//         isLoading: false,
//         errorMessage: message,
//       ));
//     } catch (e, stack) {
//       log('Unexpected company load error: $e', stackTrace: stack);
//       emit(state.copyWith(
//         isLoading: false,
//         errorMessage: 'Something went wrong while loading companies',
//       ));
//     }
//   }

//   Future<void> _onSelectCompany(
//     SelectCompany event,
//     Emitter<CompanyState> emit,
//   ) async {
//     emit(state.copyWith(isLoading: true, errorMessage: null));

//     try {
//       final selectedCompany = state.companies.firstWhere(
//         (c) => c.id == event.companyId,
//         orElse: () =>
//             Company(id: event.companyId, name: 'Company ${event.companyId}'),
//       );

//       log('Selecting company: ${selectedCompany.name} (domain: ${selectedCompany.domain})');

//       Api.switchToPrivate(selectedCompany.domain);

//       // Give Dio time to apply new base URL
//       await Future.delayed(const Duration(milliseconds: 150));
//       log('Dio baseUrl after switch: ${DioClient().dio.options.baseUrl}');

//       // Update UI state
//       final updatedCompanies = state.companies.map((c) {
//         return c.copyWith(isActive: c.id == event.companyId);
//       }).toList();

//       emit(state.copyWith(
//         isLoading: false,
//         companies: updatedCompanies,
//         selectedCompany: selectedCompany.copyWith(isActive: true),
//         errorMessage: null,
//       ));

//       // NO context.go() here — UI will handle it
//     } catch (e, stack) {
//       log('Error selecting company: $e', stackTrace: stack);
//       emit(state.copyWith(
//         isLoading: false,
//         errorMessage: 'Failed to select company',
//       ));
//     }
//   }
// }

// lib/bloc/company/company_bloc.dart

import 'dart:convert';
import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:saleup_app/auth/view/companySelect/model/company.dart';
import 'package:saleup_app/core/network/api_endpoints.dart';
import 'package:saleup_app/core/network/dio_client.dart';
import 'package:saleup_app/services/auth_service.dart';

import 'company_event.dart';
import 'company_state.dart';

class CompanyBloc extends Bloc<CompanyEvent, CompanyState> {
  CompanyBloc() : super(const CompanyState()) {
    on<LoadUserCompanies>(_onLoadCompanies);
    on<SelectCompany>(_onSelectCompany);
  }

  Future<void> _onLoadCompanies(
    LoadUserCompanies event,
    Emitter<CompanyState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));

    try {
      await Future.delayed(const Duration(milliseconds: 600));

      final tokenNow = await AuthService().getAccessToken();
      log('Token right before company fetch: ${tokenNow != null ? "YES (len ${tokenNow.length})" : "MISSING!!!"}');

      final res = await DioClient().dio.get('/company/get_user_companies/');

      log('Company API Response status: ${res.statusCode}');
      log('Company API Response type: ${res.data.runtimeType}');
      log('Company API Raw data:\n${const JsonEncoder.withIndent("  ").convert(res.data)}');

      if (res.statusCode == 200) {
        final rawData = res.data as Map<String, dynamic>?;
        List<dynamic> companyListData = [];

        if (rawData != null) {
          final innerData = rawData['data'] as Map<String, dynamic>?;
          if (innerData != null) {
            final companiesFromInner = innerData['companies'] as List<dynamic>?;
            if (companiesFromInner != null) {
              companyListData = companiesFromInner;
            }
          }

          if (companyListData.isEmpty) {
            if (rawData['companies'] is List) {
              companyListData = rawData['companies'];
            } else if (rawData['data'] is List)
              companyListData = rawData['data'];
          }
        }

        final companies = companyListData
            .whereType<Map<String, dynamic>>()
            .map((json) => Company.fromJson(json))
            .toList();

        final selected = companies.isNotEmpty ? companies.first : null;

        emit(state.copyWith(
          isLoading: false,
          companies: companies,
          selectedCompany: selected,
          errorMessage:
              companies.isEmpty ? 'No companies found for this user' : null,
        ));
      } else {
        emit(state.copyWith(
          isLoading: false,
          errorMessage: 'Failed to load companies (HTTP ${res.statusCode})',
        ));
      }
    } on DioException catch (e) {
      final isTimeout = e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.connectionError;

      if (isTimeout || e.response?.statusCode == 401) {
        log('DioException loading companies: $e → logging out');
        await AuthService().clearTokens();
        await DioClient().clearCookies();
        Api.resetToPublic();
        DioClient().goRouter?.go('/login');
        return;
      }

      final message = e.response?.data is Map
          ? (e.response!.data['message'] ?? e.message ?? 'Network error')
          : (e.message ?? 'Network error');
      log('DioException loading companies: $e → message: $message');
      emit(state.copyWith(isLoading: false, errorMessage: message));
    } catch (e, stack) {
      log('Unexpected company load error: $e', stackTrace: stack);
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'Something went wrong while loading companies',
      ));
    }
  }

  Future<void> _onSelectCompany(
      SelectCompany event, Emitter<CompanyState> emit) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));

    try {
      final selectedCompany = state.companies.firstWhere(
        (c) => c.id == event.companyId,
        orElse: () =>
            Company(id: event.companyId, name: 'Company ${event.companyId}'),
      );

      Api.switchToPrivate(selectedCompany.domain);
      await Future.delayed(const Duration(milliseconds: 150));

      final updatedCompanies = state.companies
          .map((c) => c.copyWith(isActive: c.id == event.companyId))
          .toList();

      emit(state.copyWith(
        isLoading: false,
        companies: updatedCompanies,
        selectedCompany: selectedCompany.copyWith(isActive: true),
        errorMessage: null,
      ));
    } catch (e, stack) {
      log('Error selecting company: $e', stackTrace: stack);
      emit(state.copyWith(
          isLoading: false, errorMessage: 'Failed to select company'));
    }
  }
}
