import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:saleup_app/core/network/dio_client.dart';
import 'package:saleup_app/model/purchase_response.dart';
import 'purchase_event.dart';
import 'purchase_state.dart';

class PurchaseBloc extends Bloc<PurchaseEvent, PurchaseState> {
  final DioClient dioClient;

  PurchaseBloc({DioClient? dioClient})
      : dioClient = dioClient ?? DioClient(),
        super(PurchaseState.initial()) {
    on<FetchPurchases>(_onFetchPurchases);
    on<FetchPurchaseById>(_onFetchPurchaseById);
  }

  Future<void> _onFetchPurchases(
      FetchPurchases event, Emitter<PurchaseState> emit) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      final response = await dioClient.dio.get('/purchase/get_purchases/');
      print('FetchPurchases raw response: ${response.data}');
      if (response.data is! Map<String, dynamic>) {
        emit(state.copyWith(
            isLoading: false, errorMessage: 'Invalid API response format'));
        return;
      }
      final purchaseResponse = PurchaseResponse.fromJson(response.data);
      if (purchaseResponse.success && purchaseResponse.data != null) {
        if (purchaseResponse.data is! List<dynamic>) {
          emit(state.copyWith(
              isLoading: false, errorMessage: 'Expected a list of purchases'));
          return;
        }
        final purchases = (purchaseResponse.data as List<dynamic>)
            .map((json) => PurchaseData.fromJson(json as Map<String, dynamic>))
            .toList();
        emit(state.copyWith(
            isLoading: false, purchases: purchases, errorMessage: null));
      } else {
        emit(state.copyWith(
            isLoading: false,
            errorMessage:
                purchaseResponse.message ?? 'Failed to fetch purchases'));
      }
    } on DioException catch (e, stackTrace) {
      print(
          'DioException in FetchPurchases: ${e.message}, Status: ${e.response?.statusCode}, Data: ${e.response?.data}\nStackTrace: $stackTrace');
      emit(state.copyWith(
          isLoading: false, errorMessage: 'Network error: ${e.message}'));
    } catch (e, stackTrace) {
      print('Exception in FetchPurchases: $e\nStackTrace: $stackTrace');
      emit(state.copyWith(
          isLoading: false, errorMessage: 'Failed to fetch purchases: $e'));
    }
  }

  Future<void> _onFetchPurchaseById(
      FetchPurchaseById event, Emitter<PurchaseState> emit) async {
    emit(state.copyWith(
        isLoading: true, errorMessage: null, purchaseDetail: null));
    try {
      print('Fetching purchase with ID: ${event.purchaseId}');
      final response = await dioClient.dio
          .get('/purchase/get_purchase/?purchase_id=${event.purchaseId}');
      print(
          'FetchPurchaseById raw response for ID ${event.purchaseId}: ${response.data}');

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

      final purchaseResponse = PurchaseResponse.fromJson(response.data);
      print(
          'PurchaseResponse: success=${purchaseResponse.success}, message=${purchaseResponse.message}, data=${purchaseResponse.data}');
      if (purchaseResponse.success && purchaseResponse.data != null) {
        Map<String, dynamic>? rawData;
        if (purchaseResponse.data is Map<String, dynamic>) {
          rawData = purchaseResponse.data as Map<String, dynamic>;
        } else if (purchaseResponse.data is List<dynamic> &&
            (purchaseResponse.data as List<dynamic>).isNotEmpty) {
          rawData = (purchaseResponse.data as List<dynamic>).first
              as Map<String, dynamic>?;
        } else {
          print('Unexpected data format: ${purchaseResponse.data}');
          emit(state.copyWith(
              isLoading: false, errorMessage: 'Unexpected data format'));
          return;
        }

        if (rawData == null) {
          print('No valid data in response');
          emit(state.copyWith(
              isLoading: false, errorMessage: 'No data in response'));
          return;
        }

        try {
          final purchaseDetail = PurchaseData.fromJson(rawData);
          print('Parsed purchaseDetail: $purchaseDetail');
          emit(state.copyWith(
              isLoading: false,
              purchaseDetail: purchaseDetail,
              errorMessage: null));
        } catch (e, stackTrace) {
          print(
              'Parsing error in PurchaseData.fromJson: $e, StackTrace: $stackTrace');
          emit(state.copyWith(
              isLoading: false,
              errorMessage: 'Failed to parse purchase details: $e'));
        }
      } else {
        print('Purchase response failure: ${purchaseResponse.message}');
        emit(state.copyWith(
            isLoading: false,
            errorMessage:
                purchaseResponse.message ?? 'No purchase details found'));
      }
    } on DioException catch (e, stackTrace) {
      print(
          'DioException in FetchPurchaseById: ${e.message}, Status: ${e.response?.statusCode}, Data: ${e.response?.data}, StackTrace: $stackTrace');
      String errorMessage = 'Network error: ${e.message}';
      if (e.response?.statusCode == 401) {
        errorMessage = 'Unauthorized: Please log in again';
      }
      emit(state.copyWith(isLoading: false, errorMessage: errorMessage));
    } catch (e, stackTrace) {
      print('Exception in FetchPurchaseById: $e, StackTrace: $stackTrace');
      emit(state.copyWith(
          isLoading: false,
          errorMessage: 'Failed to fetch purchase detail: $e'));
    }
  }
}
