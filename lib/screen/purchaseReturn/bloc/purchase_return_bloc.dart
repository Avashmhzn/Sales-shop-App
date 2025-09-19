import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:saleup_app/core/network/dio_client.dart';
import 'package:saleup_app/model/purchase_return_response.dart';
import 'purchase_return_event.dart';
import 'purchase_return_state.dart';

class PurchaseReturnBloc
    extends Bloc<PurchaseReturnEvent, PurchaseReturnState> {
  final DioClient dioClient;

  PurchaseReturnBloc({DioClient? dioClient})
      : dioClient = dioClient ?? DioClient(),
        super(PurchaseReturnState.initial()) {
    on<FetchPurchaseReturns>(_onFetchPurchaseReturns);
    on<FetchPurchaseReturnById>(_onFetchPurchaseReturnById);
  }

  Future<void> _onFetchPurchaseReturns(
      FetchPurchaseReturns event, Emitter<PurchaseReturnState> emit) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      final response =
          await dioClient.dio.get('/purchase-return/get_purchase_returns/');
      print('FetchPurchaseReturns raw response: ${response.data}');
      if (response.data is! Map<String, dynamic>) {
        emit(state.copyWith(
            isLoading: false, errorMessage: 'Invalid API response format'));
        return;
      }
      final purchaseReturnResponse =
          PurchaseReturnResponse.fromJson(response.data);
      if (purchaseReturnResponse.success &&
          purchaseReturnResponse.data != null) {
        if (purchaseReturnResponse.data is! List<dynamic>) {
          emit(state.copyWith(
              isLoading: false,
              errorMessage: 'Expected a list of purchase returns'));
          return;
        }
        final purchaseReturns = (purchaseReturnResponse.data as List<dynamic>)
            .map((json) =>
                PurchaseReturnData.fromJson(json as Map<String, dynamic>))
            .toList();
        emit(state.copyWith(
            isLoading: false,
            purchaseReturns: purchaseReturns,
            errorMessage: null));
      } else {
        emit(state.copyWith(
            isLoading: false,
            errorMessage: purchaseReturnResponse.message ??
                'Failed to fetch purchase returns'));
      }
    } on DioException catch (e, stackTrace) {
      print(
          'DioException in FetchPurchaseReturns: ${e.message}, Status: ${e.response?.statusCode}, Data: ${e.response?.data}\nStackTrace: $stackTrace');
      emit(state.copyWith(
          isLoading: false, errorMessage: 'Network error: ${e.message}'));
    } catch (e, stackTrace) {
      print('Exception in FetchPurchaseReturns: $e\nStackTrace: $stackTrace');
      emit(state.copyWith(
          isLoading: false,
          errorMessage: 'Failed to fetch purchase returns: $e'));
    }
  }

  Future<void> _onFetchPurchaseReturnById(
      FetchPurchaseReturnById event, Emitter<PurchaseReturnState> emit) async {
    emit(state.copyWith(
        isLoading: true, errorMessage: null, purchaseReturnDetail: null));
    try {
      print('Fetching purchase return with ID: ${event.purchaseReturnId}');
      final response = await dioClient.dio.get(
          '/purchase-return/get_purchase_return/?purchase_return_id=${event.purchaseReturnId}');
      print(
          'FetchPurchaseReturnById raw response for ID ${event.purchaseReturnId}: ${response.data}');

      if (response.data == null) {
        print('Null response data');
        emit(state.copyWith(
            isLoading: false, errorMessage: 'No data returned from API'));
        return;
      }

      if (response.data is! Map<String, dynamic>) {
        print('Invalid response format: ${response.data}');
        emit(state.copyWith(
            isLoading: false, errorMessage: 'Invalid API response format'));
        return;
      }

      final purchaseReturnResponse =
          PurchaseReturnResponse.fromJson(response.data);
      print(
          'PurchaseReturnResponse: success=${purchaseReturnResponse.success}, message=${purchaseReturnResponse.message}, data=${purchaseReturnResponse.data}');
      if (purchaseReturnResponse.success &&
          purchaseReturnResponse.data != null) {
        if (purchaseReturnResponse.data is! Map<String, dynamic>) {
          print('Unexpected data format: ${purchaseReturnResponse.data}');
          emit(state.copyWith(
              isLoading: false, errorMessage: 'Unexpected data format'));
          return;
        }

        try {
          final purchaseReturnDetail = PurchaseReturnData.fromJson(
              purchaseReturnResponse.data as Map<String, dynamic>);
          print('Parsed purchaseReturnDetail: $purchaseReturnDetail');
          emit(state.copyWith(
              isLoading: false,
              purchaseReturnDetail: purchaseReturnDetail,
              errorMessage: null));
        } catch (e, stackTrace) {
          print(
              'Parsing error in PurchaseReturnData.fromJson: $e, StackTrace: $stackTrace');
          emit(state.copyWith(
              isLoading: false,
              errorMessage: 'Failed to parse purchase return details: $e'));
        }
      } else {
        print(
            'Purchase return response failure: ${purchaseReturnResponse.message}');
        emit(state.copyWith(
            isLoading: false,
            errorMessage: purchaseReturnResponse.message ??
                'No purchase return details found'));
      }
    } on DioException catch (e, stackTrace) {
      print(
          'DioException in FetchPurchaseReturnById: ${e.message}, Status: ${e.response?.statusCode}, Data: ${e.response?.data}, StackTrace: $stackTrace');
      String errorMessage = 'Network error: ${e.message}';
      if (e.response?.statusCode == 401) {
        errorMessage = 'Unauthorized: Please log in again';
      }
      emit(state.copyWith(isLoading: false, errorMessage: errorMessage));
    } catch (e, stackTrace) {
      print(
          'Exception in FetchPurchaseReturnById: $e, StackTrace: $stackTrace');
      emit(state.copyWith(
          isLoading: false,
          errorMessage: 'Failed to fetch purchase return detail: $e'));
    }
  }
}
