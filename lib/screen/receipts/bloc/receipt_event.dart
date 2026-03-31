import 'package:equatable/equatable.dart';

abstract class ReceiptEvent extends Equatable {
  const ReceiptEvent();

  @override
  List<Object?> get props => [];
}

class FetchReceipts extends ReceiptEvent {
  const FetchReceipts();
}

class FetchReceiptById extends ReceiptEvent {
  final int receiptId;
  const FetchReceiptById(this.receiptId);

  @override
  List<Object?> get props => [receiptId];
}

class FetchRemainingReceipts extends ReceiptEvent {
  final int partyId;
  const FetchRemainingReceipts(this.partyId);

  @override
  List<Object?> get props => [partyId];
}

class FetchParties extends ReceiptEvent {
  const FetchParties();
}

class CreateReceipt extends ReceiptEvent {
  final String refNumber;
  final String customer;
  final double amount;
  final String depositedIn;
  final String signature;
  final String? narration;
  final String? chequeNumber;
  final String? chequeDate;

  const CreateReceipt({
    required this.refNumber,
    required this.customer,
    required this.amount,
    required this.depositedIn,
    required this.signature,
    this.narration,
    this.chequeNumber,
    this.chequeDate,
  });

  @override
  List<Object?> get props => [
        refNumber,
        customer,
        amount,
        depositedIn,
        signature,
        narration,
        chequeNumber,
        chequeDate,
      ];
}

// ==================== NEW EVENT ====================
class CreateParty extends ReceiptEvent {
  final Map<String, dynamic> data;

  const CreateParty(this.data);

  @override
  List<Object?> get props => [data];
}
