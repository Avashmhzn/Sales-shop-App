import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:saleup_app/core/network/dio_client.dart';
import 'package:saleup_app/model/voucher_response.dart';
import 'voucher_event.dart';
import 'voucher_state.dart';

class VoucherBloc extends Bloc<VoucherEvent, VoucherState> {
  final DioClient dioClient;

  VoucherBloc({DioClient? dioClient})
      : dioClient = dioClient ?? DioClient(),
        super(VoucherState.initial()) {
    on<FetchVouchers>(_onFetchVouchers);
    on<FetchVoucherById>(_onFetchVoucherById);
    on<CreateVoucher>(_onCreateVoucher); // ← FIXED: added inside constructor
  }

  Future<void> _onFetchVouchers(
      FetchVouchers event, Emitter<VoucherState> emit) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      final response = await dioClient.dio.get('/voucher/get_vouchers/');
      print('FetchVouchers raw response: ${response.data}');
      if (response.data is! Map<String, dynamic>) {
        emit(state.copyWith(
            isLoading: false, errorMessage: 'Invalid API response format'));
        return;
      }
      final voucherResponse = VoucherResponse.fromJson(response.data);
      print('VoucherResponse: success=${voucherResponse.success}, '
          'message=${voucherResponse.message}, data=${voucherResponse.data}');
      if (voucherResponse.success && voucherResponse.data != null) {
        if (voucherResponse.data is! List<dynamic>) {
          emit(state.copyWith(
              isLoading: false, errorMessage: 'Expected a list of vouchers'));
          return;
        }
        final vouchers = (voucherResponse.data as List<dynamic>)
            .map((json) {
              try {
                return VoucherData.fromJson(json as Map<String, dynamic>);
              } catch (e, stackTrace) {
                print(
                    'Error parsing voucher JSON: $json\nError: $e\nStackTrace: $stackTrace');
                return null;
              }
            })
            .where((voucher) => voucher != null)
            .cast<VoucherData>()
            .toList();
        print('Parsed ${vouchers.length} vouchers');
        emit(state.copyWith(
            isLoading: false, vouchers: vouchers, errorMessage: null));
      } else {
        emit(state.copyWith(
            isLoading: false,
            errorMessage:
                voucherResponse.message ?? 'Failed to fetch vouchers'));
      }
    } on DioException catch (e, stackTrace) {
      print('DioException in FetchVouchers: ${e.message}, '
          'Status: ${e.response?.statusCode}, Data: ${e.response?.data}\n'
          'StackTrace: $stackTrace');
      String errorMessage = 'Network error: ${e.message ?? 'Unknown error'}';
      if (e.response?.statusCode == 401) {
        errorMessage = 'Unauthorized: Please log in again';
      }
      emit(state.copyWith(isLoading: false, errorMessage: errorMessage));
    } catch (e, stackTrace) {
      print('Exception in FetchVouchers: $e\nStackTrace: $stackTrace');
      emit(state.copyWith(
          isLoading: false, errorMessage: 'Failed to fetch vouchers: $e'));
    }
  }

  Future<void> _onFetchVoucherById(
      FetchVoucherById event, Emitter<VoucherState> emit) async {
    emit(state.copyWith(
        isLoading: true, errorMessage: null, voucherDetail: null));
    try {
      print('Fetching voucher with ID: ${event.voucherId}');
      final response = await dioClient.dio
          .get('/voucher/get_voucher/?voucher_id=${event.voucherId}');
      print(
          'FetchVoucherById raw response for ID ${event.voucherId}: ${response.data}');

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

      final voucherResponse = VoucherResponse.fromJson(response.data);
      print('VoucherResponse: success=${voucherResponse.success}, '
          'message=${voucherResponse.message}, data=${voucherResponse.data}');
      if (!voucherResponse.success || voucherResponse.data == null) {
        print('Voucher response failure: ${voucherResponse.message}');
        emit(state.copyWith(
            isLoading: false,
            errorMessage:
                voucherResponse.message ?? 'No voucher details found'));
        return;
      }

      if (voucherResponse.data is! Map<String, dynamic>) {
        print('Unexpected data format: ${voucherResponse.data}');
        emit(state.copyWith(
            isLoading: false, errorMessage: 'Unexpected data format'));
        return;
      }

      try {
        final voucherDetail =
            VoucherData.fromJson(voucherResponse.data as Map<String, dynamic>);
        print('Parsed voucherDetail: id=${voucherDetail.id}, '
            'voucherNumber=${voucherDetail.voucherNumber}, '
            'voucherItems=${voucherDetail.voucherItems.map((item) => item.toJson())}');
        emit(state.copyWith(
            isLoading: false,
            voucherDetail: voucherDetail,
            errorMessage: null));
      } catch (e, stackTrace) {
        print(
            'Parsing error in VoucherData.fromJson: $e, StackTrace: $stackTrace');
        emit(state.copyWith(
            isLoading: false,
            errorMessage: 'Failed to parse voucher details: $e'));
      }
    } on DioException catch (e, stackTrace) {
      print('DioException in FetchVoucherById: ${e.message}, '
          'Status: ${e.response?.statusCode}, Data: ${e.response?.data}, '
          'StackTrace: $stackTrace');
      String errorMessage = 'Network error: ${e.message ?? 'Unknown error'}';
      if (e.response?.statusCode == 401) {
        errorMessage = 'Unauthorized: Please log in again';
      }
      emit(state.copyWith(isLoading: false, errorMessage: errorMessage));
    } catch (e, stackTrace) {
      print('Exception in FetchVoucherById: $e, StackTrace: $stackTrace');
      emit(state.copyWith(
          isLoading: false,
          errorMessage: 'Failed to fetch voucher detail: $e'));
    }
  }

  // ── NEW: Create Voucher Handler ────────────────────────────────
  Future<void> _onCreateVoucher(
    CreateVoucher event,
    Emitter<VoucherState> emit,
  ) async {
    emit(state.copyWith(isCreating: true, createError: null));

    try {
      final response = await dioClient.dio.post(
        '/voucher/create_voucher/',
        data: event.payload,
      );

      if (response.data is! Map<String, dynamic>) {
        emit(state.copyWith(
          isCreating: false,
          createError: 'Invalid API response format',
        ));
        return;
      }

      final resp = VoucherResponse.fromJson(response.data);

      if (!resp.success || resp.data == null) {
        emit(state.copyWith(
          isCreating: false,
          createError: resp.message ?? 'Failed to create voucher',
        ));
        return;
      }

      final created = VoucherData.fromJson(resp.data as Map<String, dynamic>);

      // Optional: refresh list after creation
      add(const FetchVouchers());

      emit(state.copyWith(
        isCreating: false,
        newlyCreatedVoucher: created,
        createError: null,
      ));
    } on DioException catch (e) {
      String msg = e.response?.data?['message'] ?? e.message ?? 'Network error';
      emit(state.copyWith(isCreating: false, createError: msg));
    } catch (e) {
      emit(state.copyWith(
        isCreating: false,
        createError: 'Unexpected error: $e',
      ));
    }
  }
}
