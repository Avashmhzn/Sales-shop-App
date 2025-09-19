import 'package:equatable/equatable.dart';
import 'package:saleup_app/model/sale_return_response.dart';

class SaleReturnState extends Equatable {
  final bool isLoading;
  final List<SaleReturnData> saleReturns;
  final SaleReturnData? saleReturnDetail;
  final String? errorMessage;

  const SaleReturnState({
    this.isLoading = false,
    this.saleReturns = const [],
    this.saleReturnDetail,
    this.errorMessage,
  });

  SaleReturnState copyWith({
    bool? isLoading,
    List<SaleReturnData>? saleReturns,
    SaleReturnData? saleReturnDetail,
    String? errorMessage,
  }) {
    return SaleReturnState(
      isLoading: isLoading ?? this.isLoading,
      saleReturns: saleReturns ?? this.saleReturns,
      saleReturnDetail: saleReturnDetail,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props =>
      [isLoading, saleReturns, saleReturnDetail, errorMessage];

  static SaleReturnState initial() => const SaleReturnState();
}
