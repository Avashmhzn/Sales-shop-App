import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:saleup_app/core/network/dio_client.dart';
import 'package:saleup_app/model/party_response.dart';
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
    on<FetchRemainingReceipts>(_onFetchRemainingReceipts);
    on<FetchParties>(_onFetchParties);
    on<CreateReceipt>(_onCreateReceipt);
    on<CreateParty>(_onCreateParty); // ← Fixed
  }

  // ── Fetch all receipts ───────────────────────────────────────────────────
  Future<void> _onFetchReceipts(
      FetchReceipts event, Emitter<ReceiptState> emit) async {
    emit(state.copyWith(
        isLoading: true, errorMessage: null, createSuccess: false));
    try {
      final response = await dioClient.dio.get('/receipt/get_receipts/');
      if (response.data is! Map<String, dynamic>) {
        emit(state.copyWith(
            isLoading: false, errorMessage: 'Invalid API response format'));
        return;
      }
      final receiptResponse = ReceiptResponse.fromJson(response.data);
      if (receiptResponse.success) {
        if (receiptResponse.data == null) {
          emit(state.copyWith(isLoading: false, receipts: []));
          return;
        }
        if (receiptResponse.data is! List<dynamic>) {
          emit(state.copyWith(
              isLoading: false, errorMessage: 'Expected a list of receipts'));
          return;
        }
        final receipts = (receiptResponse.data as List<dynamic>)
            .map((json) {
              try {
                return ReceiptData.fromJson(json as Map<String, dynamic>);
              } catch (e, st) {
                print('Error parsing receipt: $e\n$st');
                return null;
              }
            })
            .where((r) => r != null)
            .cast<ReceiptData>()
            .toList();
        emit(state.copyWith(isLoading: false, receipts: receipts));
      } else {
        emit(state.copyWith(
            isLoading: false,
            errorMessage:
                receiptResponse.message ?? 'Failed to fetch receipts'));
      }
    } on DioException catch (e) {
      emit(state.copyWith(
          isLoading: false,
          errorMessage: e.response?.statusCode == 401
              ? 'Unauthorized: Please log in again'
              : 'Network error: ${e.message ?? 'Unknown error'}'));
    } catch (e) {
      emit(state.copyWith(
          isLoading: false, errorMessage: 'Failed to fetch receipts: $e'));
    }
  }

  // ── Fetch single receipt by ID ───────────────────────────────────────────
  Future<void> _onFetchReceiptById(
      FetchReceiptById event, Emitter<ReceiptState> emit) async {
    emit(state.copyWith(
        isLoading: true,
        errorMessage: null,
        receiptDetail: null,
        createSuccess: false));
    try {
      final response = await dioClient.dio
          .get('/receipt/get_receipt/?receipt_id=${event.receiptId}');
      if (response.data == null || response.data is! Map<String, dynamic>) {
        emit(state.copyWith(
            isLoading: false, errorMessage: 'Invalid API response format'));
        return;
      }
      final receiptResponse = ReceiptResponse.fromJson(response.data);
      if (!receiptResponse.success || receiptResponse.data == null) {
        emit(state.copyWith(
            isLoading: false,
            errorMessage:
                receiptResponse.message ?? 'No receipt details found'));
        return;
      }
      if (receiptResponse.data is! Map<String, dynamic>) {
        emit(state.copyWith(
            isLoading: false, errorMessage: 'Unexpected data format'));
        return;
      }
      final receiptDetail =
          ReceiptData.fromJson(receiptResponse.data as Map<String, dynamic>);
      emit(state.copyWith(isLoading: false, receiptDetail: receiptDetail));
    } on DioException catch (e) {
      emit(state.copyWith(
          isLoading: false,
          errorMessage: e.response?.statusCode == 401
              ? 'Unauthorized: Please log in again'
              : 'Network error: ${e.message ?? 'Unknown error'}'));
    } catch (e) {
      emit(state.copyWith(
          isLoading: false,
          errorMessage: 'Failed to fetch receipt detail: $e'));
    }
  }

  // ── Fetch remaining invoices for a party ─────────────────────────────────
  Future<void> _onFetchRemainingReceipts(
      FetchRemainingReceipts event, Emitter<ReceiptState> emit) async {
    emit(state.copyWith(
        isLoading: true,
        errorMessage: null,
        remainingReceipts: [],
        createSuccess: false));
    try {
      final response = await dioClient.dio
          .get('/receipt/get_remaining_receipts/?party_id=${event.partyId}');
      if (response.data is! Map<String, dynamic>) {
        emit(state.copyWith(
            isLoading: false, errorMessage: 'Invalid API response format'));
        return;
      }
      final receiptResponse = ReceiptResponse.fromJson(response.data);
      if (receiptResponse.success && receiptResponse.data != null) {
        if (receiptResponse.data is! List<dynamic>) {
          emit(state.copyWith(
              isLoading: false, errorMessage: 'Expected a list of invoices'));
          return;
        }
        final list = (receiptResponse.data as List<dynamic>)
            .map((json) {
              try {
                return RemainingReceiptData.fromJson(
                    json as Map<String, dynamic>);
              } catch (e, st) {
                print('Error parsing remaining receipt: $e\n$st');
                return null;
              }
            })
            .where((r) => r != null)
            .cast<RemainingReceiptData>()
            .toList();
        emit(state.copyWith(isLoading: false, remainingReceipts: list));
      } else {
        emit(state.copyWith(
            isLoading: false,
            errorMessage:
                receiptResponse.message ?? 'Failed to fetch invoices'));
      }
    } on DioException catch (e) {
      emit(state.copyWith(
          isLoading: false,
          errorMessage: e.response?.statusCode == 401
              ? 'Unauthorized: Please log in again'
              : 'Network error: ${e.message ?? 'Unknown error'}'));
    } catch (e) {
      emit(state.copyWith(
          isLoading: false, errorMessage: 'Failed to fetch invoices: $e'));
    }
  }

  // ── Fetch parties (customer list) ────────────────────────────────────────
  Future<void> _onFetchParties(
      FetchParties event, Emitter<ReceiptState> emit) async {
    emit(state.copyWith(
        isLoadingParties: true, errorMessage: null, createSuccess: false));
    try {
      final response = await dioClient.dio.get('/party/get_parties/');
      print('FetchParties raw response: ${response.data}');
      if (response.data is! Map<String, dynamic>) {
        emit(state.copyWith(
            isLoadingParties: false,
            errorMessage: 'Invalid API response format'));
        return;
      }
      final partyResponse = PartyResponse.fromJson(response.data);
      if (partyResponse.success) {
        final parties = partyResponse.data;
        print('Parsed ${parties.length} parties');
        emit(state.copyWith(isLoadingParties: false, parties: parties));
      } else {
        emit(state.copyWith(
            isLoadingParties: false,
            errorMessage:
                partyResponse.message ?? 'Failed to fetch customers'));
      }
    } on DioException catch (e) {
      emit(state.copyWith(
          isLoadingParties: false,
          errorMessage: e.response?.statusCode == 401
              ? 'Unauthorized: Please log in again'
              : 'Network error: ${e.message ?? 'Unknown error'}'));
    } catch (e) {
      emit(state.copyWith(
          isLoadingParties: false,
          errorMessage: 'Failed to fetch customers: $e'));
    }
  }

  // ── Create receipt ────────────────────────────────────────────────────────
  Future<void> _onCreateReceipt(
      CreateReceipt event, Emitter<ReceiptState> emit) async {
    emit(state.copyWith(
        isCreating: true, errorMessage: null, createSuccess: false));
    try {
      final payload = <String, dynamic>{
        'ref_number': event.refNumber,
        'customer': event.customer,
        'amount': event.amount,
        'deposited_in': event.depositedIn,
        'signature': event.signature,
        if (event.narration != null && event.narration!.isNotEmpty)
          'narration': event.narration,
        if (event.chequeNumber != null && event.chequeNumber!.isNotEmpty)
          'cheque_number': event.chequeNumber,
        if (event.chequeDate != null && event.chequeDate!.isNotEmpty)
          'cheque_date': event.chequeDate,
      };
      print('CreateReceipt payload: $payload');
      final response =
          await dioClient.dio.post('/receipt/create_receipt/', data: payload);
      if (response.data is! Map<String, dynamic>) {
        emit(state.copyWith(
            isCreating: false, errorMessage: 'Invalid API response format'));
        return;
      }
      final receiptResponse = ReceiptResponse.fromJson(response.data);
      if (receiptResponse.success) {
        emit(state.copyWith(isCreating: false, createSuccess: true));
      } else {
        emit(state.copyWith(
            isCreating: false,
            errorMessage:
                receiptResponse.message ?? 'Failed to create receipt'));
      }
    } on DioException catch (e) {
      emit(state.copyWith(
          isCreating: false,
          errorMessage: e.response?.statusCode == 401
              ? 'Unauthorized: Please log in again'
              : 'Network error: ${e.message ?? 'Unknown error'}'));
    } catch (e) {
      emit(state.copyWith(
          isCreating: false, errorMessage: 'Failed to create receipt: $e'));
    }
  }

  // ====================== FIXED CREATE PARTY ======================
  Future<void> _onCreateParty(
    CreateParty event,
    Emitter<ReceiptState> emit,
  ) async {
    emit(state.copyWith(
      isCreating: true,
      errorMessage: null,
      createSuccess: false,
    ));

    try {
      print('CreateParty payload: ${event.data}');

      final response = await dioClient.dio.post(
        '/party/create_party/',
        data: event.data,
      );

      print('CreateParty raw response: ${response.data}');

      if (response.data is! Map<String, dynamic>) {
        emit(state.copyWith(
          isCreating: false,
          errorMessage: 'Invalid API response format',
        ));
        return;
      }

      final Map<String, dynamic> jsonResponse =
          response.data as Map<String, dynamic>;

      if (jsonResponse['success'] == true) {
        emit(state.copyWith(
          isCreating: false,
          createSuccess: true,
          errorMessage: null,
        ));

        // Refresh parties list after successful creation
        add(const FetchParties());

        // Reset success flag
        await Future.delayed(const Duration(milliseconds: 800));
        emit(state.copyWith(createSuccess: false));
      } else {
        emit(state.copyWith(
          isCreating: false,
          createSuccess: false,
          errorMessage:
              jsonResponse['message']?.toString() ?? 'Failed to create party',
        ));
      }
    } on DioException catch (e) {
      emit(state.copyWith(
        isCreating: false,
        errorMessage: e.response?.statusCode == 401
            ? 'Unauthorized: Please log in again'
            : 'Network error: ${e.message ?? 'Unknown error'}',
      ));
    } catch (e) {
      emit(state.copyWith(
        isCreating: false,
        errorMessage: 'Failed to create party: $e',
      ));
    }
  }
}
