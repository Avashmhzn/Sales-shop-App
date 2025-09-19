import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:saleup_app/core/network/dio_client.dart';
import 'package:saleup_app/model/payment_response.dart';
import 'payment_event.dart';
import 'payment_state.dart';

class PaymentBloc extends Bloc<PaymentEvent, PaymentState> {
  final DioClient dioClient;

  PaymentBloc({DioClient? dioClient})
      : dioClient = dioClient ?? DioClient(),
        super(PaymentState.initial()) {
    on<FetchPayments>(_onFetchPayments);
    on<FetchPaymentById>(_onFetchPaymentById);
  }

  Future<void> _onFetchPayments(
      FetchPayments event, Emitter<PaymentState> emit) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      final response = await dioClient.dio.get('/payment/get_payments/');
      print('FetchPayments raw response: ${response.data}');
      if (response.data is! Map<String, dynamic>) {
        emit(state.copyWith(
            isLoading: false, errorMessage: 'Invalid API response format'));
        return;
      }
      final paymentResponse = PaymentResponse.fromJson(response.data);
      print('PaymentResponse: success=${paymentResponse.success}, '
          'message=${paymentResponse.message}, data=${paymentResponse.data}');
      if (paymentResponse.success && paymentResponse.data != null) {
        if (paymentResponse.data is! List<dynamic>) {
          emit(state.copyWith(
              isLoading: false, errorMessage: 'Expected a list of payments'));
          return;
        }
        final payments = (paymentResponse.data as List<dynamic>)
            .map((json) {
              try {
                return PaymentData.fromJson(json as Map<String, dynamic>);
              } catch (e, stackTrace) {
                print(
                    'Error parsing payment JSON: $json\nError: $e\nStackTrace: $stackTrace');
                return null;
              }
            })
            .where((payment) => payment != null)
            .cast<PaymentData>()
            .toList();
        print('Parsed ${payments.length} payments');
        emit(state.copyWith(
            isLoading: false, payments: payments, errorMessage: null));
      } else {
        emit(state.copyWith(
            isLoading: false,
            errorMessage:
                paymentResponse.message ?? 'Failed to fetch payments'));
      }
    } on DioException catch (e, stackTrace) {
      print('DioException in FetchPayments: ${e.message}, '
          'Status: ${e.response?.statusCode}, Data: ${e.response?.data}\n'
          'StackTrace: $stackTrace');
      String errorMessage = 'Network error: ${e.message ?? 'Unknown error'}';
      if (e.response?.statusCode == 401) {
        errorMessage = 'Unauthorized: Please log in again';
      }
      emit(state.copyWith(isLoading: false, errorMessage: errorMessage));
    } catch (e, stackTrace) {
      print('Exception in FetchPayments: $e\nStackTrace: $stackTrace');
      emit(state.copyWith(
          isLoading: false, errorMessage: 'Failed to fetch payments: $e'));
    }
  }

  Future<void> _onFetchPaymentById(
      FetchPaymentById event, Emitter<PaymentState> emit) async {
    emit(state.copyWith(
        isLoading: true, errorMessage: null, paymentDetail: null));
    try {
      print('Fetching payment with ID: ${event.paymentId}');
      final response = await dioClient.dio
          .get('/payment/get_payment/?payment_id=${event.paymentId}');
      print(
          'FetchPaymentById raw response for ID ${event.paymentId}: ${response.data}');

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

      final paymentResponse = PaymentResponse.fromJson(response.data);
      print('PaymentResponse: success=${paymentResponse.success}, '
          'message=${paymentResponse.message}, data=${paymentResponse.data}');
      if (!paymentResponse.success || paymentResponse.data == null) {
        print('Payment response failure: ${paymentResponse.message}');
        emit(state.copyWith(
            isLoading: false,
            errorMessage:
                paymentResponse.message ?? 'No payment details found'));
        return;
      }

      if (paymentResponse.data is! Map<String, dynamic>) {
        print('Unexpected data format: ${paymentResponse.data}');
        emit(state.copyWith(
            isLoading: false, errorMessage: 'Unexpected data format'));
        return;
      }

      try {
        final paymentDetail =
            PaymentData.fromJson(paymentResponse.data as Map<String, dynamic>);
        print('Parsed paymentDetail: id=${paymentDetail.id}, '
            'refNumber=${paymentDetail.refNumber}');
        emit(state.copyWith(
            isLoading: false,
            paymentDetail: paymentDetail,
            errorMessage: null));
      } catch (e, stackTrace) {
        print(
            'Parsing error in PaymentData.fromJson: $e, StackTrace: $stackTrace');
        emit(state.copyWith(
            isLoading: false,
            errorMessage: 'Failed to parse payment details: $e'));
      }
    } on DioException catch (e, stackTrace) {
      print('DioException in FetchPaymentById: ${e.message}, '
          'Status: ${e.response?.statusCode}, Data: ${e.response?.data}, '
          'StackTrace: $stackTrace');
      String errorMessage = 'Network error: ${e.message ?? 'Unknown error'}';
      if (e.response?.statusCode == 401) {
        errorMessage = 'Unauthorized: Please log in again';
      }
      emit(state.copyWith(isLoading: false, errorMessage: errorMessage));
    } catch (e, stackTrace) {
      print('Exception in FetchPaymentById: $e, StackTrace: $stackTrace');
      emit(state.copyWith(
          isLoading: false,
          errorMessage: 'Failed to fetch payment detail: $e'));
    }
  }
}
