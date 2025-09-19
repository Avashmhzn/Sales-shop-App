import 'package:equatable/equatable.dart';
import 'package:saleup_app/model/purchase_response.dart';

class PurchaseState extends Equatable {
  final bool isLoading;
  final List<PurchaseData> purchases;
  final PurchaseData? purchaseDetail;
  final String? errorMessage;

  const PurchaseState({
    this.isLoading = false,
    this.purchases = const [],
    this.purchaseDetail,
    this.errorMessage,
  });

  PurchaseState copyWith({
    bool? isLoading,
    List<PurchaseData>? purchases,
    PurchaseData? purchaseDetail,
    String? errorMessage,
  }) {
    return PurchaseState(
      isLoading: isLoading ?? this.isLoading,
      purchases: purchases ?? this.purchases,
      purchaseDetail: purchaseDetail,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props =>
      [isLoading, purchases, purchaseDetail, errorMessage];

  static PurchaseState initial() => const PurchaseState();
}
