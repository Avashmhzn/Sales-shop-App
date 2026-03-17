abstract class AddSaleState {}

class AddSaleInitial extends AddSaleState {}

class AddSaleLoading extends AddSaleState {}

class AddSaleSuccess extends AddSaleState {
  final String message;
  final int saleId;

  AddSaleSuccess(this.message, this.saleId);
}

class AddSaleFailure extends AddSaleState {
  final String error;

  AddSaleFailure(this.error);
}
