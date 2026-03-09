// import 'package:equatable/equatable.dart';

// abstract class PurchaseReturnEvent extends Equatable {
//   const PurchaseReturnEvent();

//   @override
//   List<Object?> get props => [];
// }

// class FetchPurchaseReturns extends PurchaseReturnEvent {
//   const FetchPurchaseReturns();
// }

// class FetchPurchaseReturnById extends PurchaseReturnEvent {
//   final int purchaseReturnId;

//   const FetchPurchaseReturnById(this.purchaseReturnId);

//   @override
//   List<Object?> get props => [purchaseReturnId];
// }

part of 'purchase_return_bloc.dart';

sealed class PurchaseReturnEvent extends Equatable {
  const PurchaseReturnEvent();

  @override
  List<Object?> get props => [];
}

class LoadPurchaseReturns extends PurchaseReturnEvent {
  const LoadPurchaseReturns();
}

class LoadPurchasesForReturn extends PurchaseReturnEvent {
  const LoadPurchasesForReturn();
}

class CreatePurchaseReturn extends PurchaseReturnEvent {
  final int purchaseId;
  final String returnDate; // 'YYYY-MM-DD'
  final String reason;
  final List<Map<String, dynamic>> items;

  const CreatePurchaseReturn({
    required this.purchaseId,
    required this.returnDate,
    required this.reason,
    required this.items,
  });

  @override
  List<Object?> get props => [purchaseId, returnDate, reason, items];
}
