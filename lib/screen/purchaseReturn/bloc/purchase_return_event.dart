import 'package:equatable/equatable.dart';

abstract class PurchaseReturnEvent extends Equatable {
  const PurchaseReturnEvent();

  @override
  List<Object?> get props => [];
}

class FetchPurchaseReturns extends PurchaseReturnEvent {
  const FetchPurchaseReturns();
}

class FetchPurchaseReturnById extends PurchaseReturnEvent {
  final int purchaseReturnId;

  const FetchPurchaseReturnById(this.purchaseReturnId);

  @override
  List<Object?> get props => [purchaseReturnId];
}
