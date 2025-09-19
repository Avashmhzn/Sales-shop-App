import 'package:equatable/equatable.dart';

abstract class VoucherEvent extends Equatable {
  const VoucherEvent();

  @override
  List<Object?> get props => [];
}

class FetchVouchers extends VoucherEvent {
  const FetchVouchers();
}

class FetchVoucherById extends VoucherEvent {
  final int voucherId;

  const FetchVoucherById(this.voucherId);

  @override
  List<Object?> get props => [voucherId];
}
