import 'package:equatable/equatable.dart';
import 'package:saleup_app/model/voucher_response.dart';

class VoucherState extends Equatable {
  final bool isLoading;
  final List<VoucherData> vouchers;
  final VoucherData? voucherDetail;
  final String? errorMessage;

  const VoucherState({
    this.isLoading = false,
    this.vouchers = const [],
    this.voucherDetail,
    this.errorMessage,
  });

  VoucherState copyWith({
    bool? isLoading,
    List<VoucherData>? vouchers,
    VoucherData? voucherDetail,
    String? errorMessage,
  }) {
    return VoucherState(
      isLoading: isLoading ?? this.isLoading,
      vouchers: vouchers ?? this.vouchers,
      voucherDetail: voucherDetail,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [isLoading, vouchers, voucherDetail, errorMessage];

  static VoucherState initial() => const VoucherState();
}
