// part of 'purchase_return_bloc.dart';

// sealed class PurchaseReturnState extends Equatable {
//   const PurchaseReturnState();

//   @override
//   List<Object?> get props => [];
// }

// class PurchaseReturnInitial extends PurchaseReturnState {}

// class PurchaseReturnsLoading extends PurchaseReturnState {}

// class PurchasesLoading extends PurchaseReturnState {}

// class PurchaseReturnsLoaded extends PurchaseReturnState {
//   final List<PurchaseReturn> returns;

//   const PurchaseReturnsLoaded(this.returns);

//   @override
//   List<Object?> get props => [returns];
// }

// class PurchasesLoaded extends PurchaseReturnState {
//   final List<Purchase> purchases;

//   const PurchasesLoaded(this.purchases);

//   @override
//   List<Object?> get props => [purchases];
// }

// class PurchaseReturnCreating extends PurchaseReturnState {}

// class PurchaseReturnCreated extends PurchaseReturnState {
//   final PurchaseReturn purchaseReturn;

//   const PurchaseReturnCreated(this.purchaseReturn);

//   @override
//   List<Object?> get props => [purchaseReturn];
// }

// class PurchaseReturnError extends PurchaseReturnState {
//   final String message;

//   const PurchaseReturnError(this.message);

//   @override
//   List<Object?> get props => [message];
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
