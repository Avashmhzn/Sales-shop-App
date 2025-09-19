import 'package:equatable/equatable.dart';

abstract class SaleEvent extends Equatable {
  const SaleEvent();

  @override
  List<Object?> get props => [];
}

class FetchSales extends SaleEvent {
  const FetchSales();
}

class FetchSaleById extends SaleEvent {
  final int saleId;

  const FetchSaleById(this.saleId);

  @override
  List<Object?> get props => [saleId];
}
