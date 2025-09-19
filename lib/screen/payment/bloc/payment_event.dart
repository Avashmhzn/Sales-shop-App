import 'package:equatable/equatable.dart';

abstract class PaymentEvent extends Equatable {
  const PaymentEvent();

  @override
  List<Object?> get props => [];
}

class FetchPayments extends PaymentEvent {
  const FetchPayments();
}

class FetchPaymentById extends PaymentEvent {
  final int paymentId;

  const FetchPaymentById(this.paymentId);

  @override
  List<Object?> get props => [paymentId];
}
