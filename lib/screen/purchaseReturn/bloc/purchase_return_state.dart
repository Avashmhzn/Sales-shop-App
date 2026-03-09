// import 'package:equatable/equatable.dart';
// import 'package:saleup_app/model/purchase_return_response.dart';

// class PurchaseReturnState extends Equatable {
//   final bool isLoading;
//   final List<PurchaseReturnData> purchaseReturns;
//   final PurchaseReturnData? purchaseReturnDetail;
//   final String? errorMessage;

//   const PurchaseReturnState({
//     this.isLoading = false,
//     this.purchaseReturns = const [],
//     this.purchaseReturnDetail,
//     this.errorMessage,
//   });

//   PurchaseReturnState copyWith({
//     bool? isLoading,
//     List<PurchaseReturnData>? purchaseReturns,
//     PurchaseReturnData? purchaseReturnDetail,
//     String? errorMessage,
//   }) {
//     return PurchaseReturnState(
//       isLoading: isLoading ?? this.isLoading,
//       purchaseReturns: purchaseReturns ?? this.purchaseReturns,
//       purchaseReturnDetail: purchaseReturnDetail,
//       errorMessage: errorMessage ?? this.errorMessage,
//     );
//   }

//   @override
//   List<Object?> get props =>
//       [isLoading, purchaseReturns, purchaseReturnDetail, errorMessage];

//   static PurchaseReturnState initial() => const PurchaseReturnState();
// }

part of 'purchase_return_bloc.dart';

sealed class PurchaseReturnState extends Equatable {
  const PurchaseReturnState();

  @override
  List<Object?> get props => [];
}

class PurchaseReturnInitial extends PurchaseReturnState {}

class PurchaseReturnsLoading extends PurchaseReturnState {}

class PurchasesLoading extends PurchaseReturnState {}

class PurchaseReturnsLoaded extends PurchaseReturnState {
  final List<PurchaseReturn> returns;

  const PurchaseReturnsLoaded(this.returns);

  @override
  List<Object?> get props => [returns];
}

class PurchasesLoaded extends PurchaseReturnState {
  final List<Purchase> purchases;

  const PurchasesLoaded(this.purchases);

  @override
  List<Object?> get props => [purchases];
}

class PurchaseReturnCreating extends PurchaseReturnState {}

class PurchaseReturnCreated extends PurchaseReturnState {
  final PurchaseReturn purchaseReturn;

  const PurchaseReturnCreated(this.purchaseReturn);

  @override
  List<Object?> get props => [purchaseReturn];
}

class PurchaseReturnError extends PurchaseReturnState {
  final String message;

  const PurchaseReturnError(this.message);

  @override
  List<Object?> get props => [message];
}
