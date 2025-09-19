import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:saleup_app/core/network/dio_client.dart';
import 'package:saleup_app/model/sale_return_response.dart';
import 'sale_return_event.dart';
import 'sale_return_state.dart';

class SaleReturnBloc extends Bloc<SaleReturnEvent, SaleReturnState> {
  final DioClient dioClient;

  SaleReturnBloc({DioClient? dioClient})
      : dioClient = dioClient ?? DioClient(),
        super(SaleReturnState.initial()) {
    on<FetchSaleReturns>(_onFetchSaleReturns);
    on<FetchSaleReturnById>(_onFetchSaleReturnById);
  }

  Future<void> _onFetchSaleReturns(
      FetchSaleReturns event, Emitter<SaleReturnState> emit) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      final response =
          await dioClient.dio.get('/sale-return/get_sale_returns/');
      print('FetchSaleReturns raw response: ${response.data}');
      if (response.data is! Map<String, dynamic>) {
        emit(state.copyWith(
            isLoading: false, errorMessage: 'Invalid API response format'));
        return;
      }
      final saleReturnResponse = SaleReturnResponse.fromJson(response.data);
      if (saleReturnResponse.success && saleReturnResponse.data != null) {
        if (saleReturnResponse.data is! List<dynamic>) {
          emit(state.copyWith(
              isLoading: false,
              errorMessage: 'Expected a list of sale returns'));
          return;
        }
        final saleReturns = (saleReturnResponse.data as List<dynamic>)
            .map(
                (json) => SaleReturnData.fromJson(json as Map<String, dynamic>))
            .toList();
        emit(state.copyWith(
            isLoading: false, saleReturns: saleReturns, errorMessage: null));
      } else {
        emit(state.copyWith(
            isLoading: false,
            errorMessage:
                saleReturnResponse.message ?? 'Failed to fetch sale returns'));
      }
    } on DioException catch (e, stackTrace) {
      print(
          'DioException in FetchSaleReturns: ${e.message}, Status: ${e.response?.statusCode}, Data: ${e.response?.data}\nStackTrace: $stackTrace');
      emit(state.copyWith(
          isLoading: false, errorMessage: 'Network error: ${e.message}'));
    } catch (e, stackTrace) {
      print('Exception in FetchSaleReturns: $e\nStackTrace: $stackTrace');
      emit(state.copyWith(
          isLoading: false, errorMessage: 'Failed to fetch sale returns: $e'));
    }
  }

  Future<void> _onFetchSaleReturnById(
      FetchSaleReturnById event, Emitter<SaleReturnState> emit) async {
    emit(state.copyWith(
        isLoading: true, errorMessage: null, saleReturnDetail: null));
    try {
      print('Fetching sale return with ID: ${event.saleReturnId}');
      final response = await dioClient.dio.get(
          '/sale-return/get_sale_return/?sale_return_id=${event.saleReturnId}');
      print(
          'FetchSaleReturnById raw response for ID ${event.saleReturnId}: ${response.data}');

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

      final saleReturnResponse = SaleReturnResponse.fromJson(response.data);
      print(
          'SaleReturnResponse: success=${saleReturnResponse.success}, message=${saleReturnResponse.message}, data=${saleReturnResponse.data}');
      if (saleReturnResponse.success && saleReturnResponse.data != null) {
        if (saleReturnResponse.data is! Map<String, dynamic>) {
          print('Unexpected data format: ${saleReturnResponse.data}');
          emit(state.copyWith(
              isLoading: false, errorMessage: 'Unexpected data format'));
          return;
        }

        try {
          final saleReturnDetail = SaleReturnData.fromJson(
              saleReturnResponse.data as Map<String, dynamic>);
          print('Parsed saleReturnDetail: $saleReturnDetail');
          emit(state.copyWith(
              isLoading: false,
              saleReturnDetail: saleReturnDetail,
              errorMessage: null));
        } catch (e, stackTrace) {
          print(
              'Parsing error in SaleReturnData.fromJson: $e, StackTrace: $stackTrace');
          emit(state.copyWith(
              isLoading: false,
              errorMessage: 'Failed to parse sale return details: $e'));
        }
      } else {
        print('Sale return response failure: ${saleReturnResponse.message}');
        emit(state.copyWith(
            isLoading: false,
            errorMessage:
                saleReturnResponse.message ?? 'No sale return details found'));
      }
    } on DioException catch (e, stackTrace) {
      print(
          'DioException in FetchSaleReturnById: ${e.message}, Status: ${e.response?.statusCode}, Data: ${e.response?.data}, StackTrace: $stackTrace');
      String errorMessage = 'Network error: ${e.message}';
      if (e.response?.statusCode == 401) {
        errorMessage = 'Unauthorized: Please log in again';
      }
      emit(state.copyWith(isLoading: false, errorMessage: errorMessage));
    } catch (e, stackTrace) {
      print('Exception in FetchSaleReturnById: $e, StackTrace: $stackTrace');
      emit(state.copyWith(
          isLoading: false,
          errorMessage: 'Failed to fetch sale return detail: $e'));
    }
  }
}
