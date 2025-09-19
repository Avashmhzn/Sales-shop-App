import 'package:equatable/equatable.dart';
import 'package:saleup_app/model/payment_response.dart';

class PaymentState extends Equatable {
  final bool isLoading;
  final List<PaymentData> payments;
  final PaymentData? paymentDetail;
  final String? errorMessage;

  const PaymentState({
    this.isLoading = false,
    this.payments = const [],
    this.paymentDetail,
    this.errorMessage,
  });

  PaymentState copyWith({
    bool? isLoading,
    List<PaymentData>? payments,
    PaymentData? paymentDetail,
    String? errorMessage,
  }) {
    return PaymentState(
      isLoading: isLoading ?? this.isLoading,
      payments: payments ?? this.payments,
      paymentDetail: paymentDetail,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [isLoading, payments, paymentDetail, errorMessage];

  static PaymentState initial() => const PaymentState();
}
