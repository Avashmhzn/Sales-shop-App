// import 'package:equatable/equatable.dart';
// import 'package:saleup_app/model/voucher_response.dart';

// class VoucherState extends Equatable {
//   final bool isLoading;
//   final List<VoucherData> vouchers;
//   final VoucherData? voucherDetail;
//   final String? errorMessage;

//   const VoucherState({
//     this.isLoading = false,
//     this.vouchers = const [],
//     this.voucherDetail,
//     this.errorMessage,
//   });

//   VoucherState copyWith({
//     bool? isLoading,
//     List<VoucherData>? vouchers,
//     VoucherData? voucherDetail,
//     String? errorMessage,
//   }) {
//     return VoucherState(
//       isLoading: isLoading ?? this.isLoading,
//       vouchers: vouchers ?? this.vouchers,
//       voucherDetail: voucherDetail,
//       errorMessage: errorMessage ?? this.errorMessage,
//     );
//   }

//   @override
//   List<Object?> get props => [isLoading, vouchers, voucherDetail, errorMessage];

//   static VoucherState initial() => const VoucherState();
// }

import 'package:equatable/equatable.dart';
import 'package:saleup_app/model/voucher_response.dart';

class VoucherState extends Equatable {
  final bool isLoading;
  final List<VoucherData> vouchers;
  final VoucherData? voucherDetail;
  final String? errorMessage;

  // ── Added for create voucher ────────────────────────────────
  final bool isCreating;
  final VoucherData? newlyCreatedVoucher;
  final String? createError;

  const VoucherState({
    this.isLoading = false,
    this.vouchers = const [],
    this.voucherDetail,
    this.errorMessage,
    this.isCreating = false,
    this.newlyCreatedVoucher,
    this.createError,
  });

  VoucherState copyWith({
    bool? isLoading,
    List<VoucherData>? vouchers,
    VoucherData? voucherDetail,
    String? errorMessage,
    bool? isCreating,
    VoucherData? newlyCreatedVoucher,
    String? createError,
  }) {
    return VoucherState(
      isLoading: isLoading ?? this.isLoading,
      vouchers: vouchers ?? this.vouchers,
      voucherDetail: voucherDetail ?? this.voucherDetail,
      errorMessage: errorMessage ?? this.errorMessage,
      isCreating: isCreating ?? this.isCreating,
      newlyCreatedVoucher: newlyCreatedVoucher ?? this.newlyCreatedVoucher,
      createError: createError ?? this.createError,
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        vouchers,
        voucherDetail,
        errorMessage,
        isCreating,
        newlyCreatedVoucher,
        createError,
      ];

  static VoucherState initial() => const VoucherState();
}
