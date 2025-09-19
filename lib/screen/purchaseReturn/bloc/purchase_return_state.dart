import 'package:equatable/equatable.dart';
import 'package:saleup_app/model/purchase_return_response.dart';

class PurchaseReturnState extends Equatable {
  final bool isLoading;
  final List<PurchaseReturnData> purchaseReturns;
  final PurchaseReturnData? purchaseReturnDetail;
  final String? errorMessage;

  const PurchaseReturnState({
    this.isLoading = false,
    this.purchaseReturns = const [],
    this.purchaseReturnDetail,
    this.errorMessage,
  });

  PurchaseReturnState copyWith({
    bool? isLoading,
    List<PurchaseReturnData>? purchaseReturns,
    PurchaseReturnData? purchaseReturnDetail,
    String? errorMessage,
  }) {
    return PurchaseReturnState(
      isLoading: isLoading ?? this.isLoading,
      purchaseReturns: purchaseReturns ?? this.purchaseReturns,
      purchaseReturnDetail: purchaseReturnDetail,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props =>
      [isLoading, purchaseReturns, purchaseReturnDetail, errorMessage];

  static PurchaseReturnState initial() => const PurchaseReturnState();
}
