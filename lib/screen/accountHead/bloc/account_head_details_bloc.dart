import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:saleup_app/core/network/dio_client.dart';
import 'package:saleup_app/model/account_head_details_response.dart';
import 'package:saleup_app/services/auth_service.dart';
import 'account_head_details_event.dart';
import 'account_head_details_state.dart';
import 'package:dio/dio.dart' as dio;

class AccountHeadDetailsBloc
    extends Bloc<AccountHeadDetailsEvent, AccountHeadDetailsState> {
  AccountHeadDetailsBloc() : super(const AccountHeadDetailsState()) {
    on<FetchAccountHeadDetails>(_onFetchAccountHeadDetails);
  }

  Future<void> _onFetchAccountHeadDetails(FetchAccountHeadDetails event,
      Emitter<AccountHeadDetailsState> emit) async {
    emit(state.copyWith(isLoading: true));
    try {
      final token = await AuthService().getAccessToken();
      if (token == null) {
        emit(state.copyWith(
          isLoading: false,
          errorMessage: 'No access token available',
        ));
        return;
      }

      final response = await DioClient().dio.get(
            '/account-heads/get_account_head/?account_head_id=${event.accountHeadId}',
            options: dio.Options(headers: {'Authorization': 'Bearer $token'}),
          );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final accountHeadResponse =
            AccountHeadDetailsResponse.fromJson(response.data);
        emit(state.copyWith(
          isLoading: false,
          accountHeadDetails: accountHeadResponse.data,
          errorMessage: null,
        ));
      } else {
        emit(state.copyWith(
          isLoading: false,
          errorMessage: 'Failed to load details: ${response.data['message']}',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: e is dio.DioException
            ? 'Network error: ${e.message}'
            : 'Unexpected error',
      ));
    }
  }
}
