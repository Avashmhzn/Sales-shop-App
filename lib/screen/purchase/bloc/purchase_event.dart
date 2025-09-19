import 'package:equatable/equatable.dart';

abstract class PurchaseEvent extends Equatable {
  const PurchaseEvent();

  @override
  List<Object?> get props => [];
}

class FetchPurchases extends PurchaseEvent {
  const FetchPurchases();
}

class FetchPurchaseById extends PurchaseEvent {
  final int purchaseId;

  const FetchPurchaseById(this.purchaseId);

  @override
  List<Object?> get props => [purchaseId];
}
