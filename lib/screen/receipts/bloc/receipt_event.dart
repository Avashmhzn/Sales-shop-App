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
