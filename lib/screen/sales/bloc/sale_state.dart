import 'package:equatable/equatable.dart';
import 'package:saleup_app/model/sale_response.dart';

class SaleState extends Equatable {
  final bool isLoading;
  final List<SaleData> sales;
  final SaleData? saleDetail;
  final String? errorMessage;

  const SaleState({
    this.isLoading = false,
    this.sales = const [],
    this.saleDetail,
    this.errorMessage,
  });

  SaleState copyWith({
    bool? isLoading,
    List<SaleData>? sales,
    SaleData? saleDetail,
    String? errorMessage,
  }) {
    return SaleState(
      isLoading: isLoading ?? this.isLoading,
      sales: sales ?? this.sales,
      saleDetail: saleDetail,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [isLoading, sales, saleDetail, errorMessage];

  static SaleState initial() => const SaleState();
}
