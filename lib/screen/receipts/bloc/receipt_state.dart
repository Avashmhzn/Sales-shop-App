import 'package:equatable/equatable.dart';
import 'package:saleup_app/model/receipt_response.dart';

class ReceiptState extends Equatable {
  final bool isLoading;
  final List<ReceiptData> receipts;
  final ReceiptData? receiptDetail;
  final String? errorMessage;

  const ReceiptState({
    this.isLoading = false,
    this.receipts = const [],
    this.receiptDetail,
    this.errorMessage,
  });

  ReceiptState copyWith({
    bool? isLoading,
    List<ReceiptData>? receipts,
    ReceiptData? receiptDetail,
    String? errorMessage,
  }) {
    return ReceiptState(
      isLoading: isLoading ?? this.isLoading,
      receipts: receipts ?? this.receipts,
      receiptDetail: receiptDetail,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [isLoading, receipts, receiptDetail, errorMessage];

  static ReceiptState initial() => const ReceiptState();
}
