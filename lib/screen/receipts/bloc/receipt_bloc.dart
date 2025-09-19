import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:saleup_app/core/network/dio_client.dart';
import 'package:saleup_app/model/receipt_response.dart';
import 'receipt_event.dart';
import 'receipt_state.dart';

class ReceiptBloc extends Bloc<ReceiptEvent, ReceiptState> {
  final DioClient dioClient;

  ReceiptBloc({DioClient? dioClient})
      : dioClient = dioClient ?? DioClient(),
        super(ReceiptState.initial()) {
    on<FetchReceipts>(_onFetchReceipts);
    on<FetchReceiptById>(_onFetchReceiptById);
  }

  Future<void> _onFetchReceipts(
      FetchReceipts event, Emitter<ReceiptState> emit) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      final response = await dioClient.dio.get('/receipt/get_receipts/');
      print('FetchReceipts raw response: ${response.data}');
      if (response.data is! Map<String, dynamic>) {
        emit(state.copyWith(
            isLoading: false, errorMessage: 'Invalid API response format'));
        return;
      }
      final receiptResponse = ReceiptResponse.fromJson(response.data);
      print('ReceiptResponse: success=${receiptResponse.success}, '
          'message=${receiptResponse.message}, data=${receiptResponse.data}');
      if (receiptResponse.success && receiptResponse.data != null) {
        if (receiptResponse.data is! List<dynamic>) {
          emit(state.copyWith(
              isLoading: false, errorMessage: 'Expected a list of receipts'));
          return;
        }
        final receipts = (receiptResponse.data as List<dynamic>)
            .map((json) {
              try {
                return ReceiptData.fromJson(json as Map<String, dynamic>);
              } catch (e, stackTrace) {
                print(
                    'Error parsing receipt JSON: $json\nError: $e\nStackTrace: $stackTrace');
                return null;
              }
            })
            .where((receipt) => receipt != null)
            .cast<ReceiptData>()
            .toList();
        print('Parsed ${receipts.length} receipts');
        emit(state.copyWith(
            isLoading: false, receipts: receipts, errorMessage: null));
      } else {
        emit(state.copyWith(
            isLoading: false,
            errorMessage:
                receiptResponse.message ?? 'Failed to fetch receipts'));
      }
    } on DioException catch (e, stackTrace) {
      print('DioException in FetchReceipts: ${e.message}, '
          'Status: ${e.response?.statusCode}, Data: ${e.response?.data}\n'
          'StackTrace: $stackTrace');
      String errorMessage = 'Network error: ${e.message ?? 'Unknown error'}';
      if (e.response?.statusCode == 401) {
        errorMessage = 'Unauthorized: Please log in again';
      }
      emit(state.copyWith(isLoading: false, errorMessage: errorMessage));
    } catch (e, stackTrace) {
      print('Exception in FetchReceipts: $e\nStackTrace: $stackTrace');
      emit(state.copyWith(
          isLoading: false, errorMessage: 'Failed to fetch receipts: $e'));
    }
  }

  Future<void> _onFetchReceiptById(
      FetchReceiptById event, Emitter<ReceiptState> emit) async {
    emit(state.copyWith(
        isLoading: true, errorMessage: null, receiptDetail: null));
    try {
      print('Fetching receipt with ID: ${event.receiptId}');
      final response = await dioClient.dio
          .get('/receipt/get_receipt/?receipt_id=${event.receiptId}');
      print(
          'FetchReceiptById raw response for ID ${event.receiptId}: ${response.data}');

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

      final receiptResponse = ReceiptResponse.fromJson(response.data);
      print('ReceiptResponse: success=${receiptResponse.success}, '
          'message=${receiptResponse.message}, data=${receiptResponse.data}');
      if (!receiptResponse.success || receiptResponse.data == null) {
        print('Receipt response failure: ${receiptResponse.message}');
        emit(state.copyWith(
            isLoading: false,
            errorMessage:
                receiptResponse.message ?? 'No receipt details found'));
        return;
      }

      if (receiptResponse.data is! Map<String, dynamic>) {
        print('Unexpected data format: ${receiptResponse.data}');
        emit(state.copyWith(
            isLoading: false, errorMessage: 'Unexpected data format'));
        return;
      }

      try {
        final receiptDetail =
            ReceiptData.fromJson(receiptResponse.data as Map<String, dynamic>);
        print('Parsed receiptDetail: id=${receiptDetail.id}, '
            'refNumber=${receiptDetail.refNumber}');
        emit(state.copyWith(
            isLoading: false,
            receiptDetail: receiptDetail,
            errorMessage: null));
      } catch (e, stackTrace) {
        print(
            'Parsing error in ReceiptData.fromJson: $e, StackTrace: $stackTrace');
        emit(state.copyWith(
            isLoading: false,
            errorMessage: 'Failed to parse receipt details: $e'));
      }
    } on DioException catch (e, stackTrace) {
      print('DioException in FetchReceiptById: ${e.message}, '
          'Status: ${e.response?.statusCode}, Data: ${e.response?.data}, '
          'StackTrace: $stackTrace');
      String errorMessage = 'Network error: ${e.message ?? 'Unknown error'}';
      if (e.response?.statusCode == 401) {
        errorMessage = 'Unauthorized: Please log in again';
      }
      emit(state.copyWith(isLoading: false, errorMessage: errorMessage));
    } catch (e, stackTrace) {
      print('Exception in FetchReceiptById: $e, StackTrace: $stackTrace');
      emit(state.copyWith(
          isLoading: false,
          errorMessage: 'Failed to fetch receipt detail: $e'));
    }
  }
}
