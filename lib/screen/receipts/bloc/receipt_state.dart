import 'package:equatable/equatable.dart';
import 'package:saleup_app/model/party_response.dart';
import 'package:saleup_app/model/receipt_response.dart';

class ReceiptState extends Equatable {
  final bool isLoading;
  final List<ReceiptData> receipts;
  final ReceiptData? receiptDetail;
  final String? errorMessage;
  final List<RemainingReceiptData> remainingReceipts;
  final bool isCreating;
  final bool createSuccess;
  final List<PartyData> parties;
  final bool isLoadingParties;

  const ReceiptState({
    this.isLoading = false,
    this.receipts = const [],
    this.receiptDetail,
    this.errorMessage,
    this.remainingReceipts = const [],
    this.isCreating = false,
    this.createSuccess = false,
    this.parties = const [],
    this.isLoadingParties = false,
  });

  ReceiptState copyWith({
    bool? isLoading,
    List<ReceiptData>? receipts,
    ReceiptData? receiptDetail,
    String? errorMessage,
    List<RemainingReceiptData>? remainingReceipts,
    bool? isCreating,
    bool? createSuccess,
    List<PartyData>? parties,
    bool? isLoadingParties,
  }) {
    return ReceiptState(
      isLoading: isLoading ?? this.isLoading,
      receipts: receipts ?? this.receipts,
      receiptDetail: receiptDetail,
      errorMessage: errorMessage,
      remainingReceipts: remainingReceipts ?? this.remainingReceipts,
      isCreating: isCreating ?? this.isCreating,
      createSuccess: createSuccess ?? this.createSuccess,
      parties: parties ?? this.parties,
      isLoadingParties: isLoadingParties ?? this.isLoadingParties,
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        receipts,
        receiptDetail,
        errorMessage,
        remainingReceipts,
        isCreating,
        createSuccess,
        parties,
        isLoadingParties,
      ];

  static ReceiptState initial() => const ReceiptState();
}
