import 'package:equatable/equatable.dart';

abstract class SaleReturnEvent extends Equatable {
  const SaleReturnEvent();

  @override
  List<Object?> get props => [];
}

class FetchSaleReturns extends SaleReturnEvent {
  const FetchSaleReturns();
}

class FetchSaleReturnById extends SaleReturnEvent {
  final int saleReturnId;

  const FetchSaleReturnById(this.saleReturnId);

  @override
  List<Object?> get props => [saleReturnId];
}
