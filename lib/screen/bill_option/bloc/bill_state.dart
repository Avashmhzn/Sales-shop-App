// bill_state.dart
import 'package:equatable/equatable.dart';
import '../model/bill_settings.dart';

abstract class BillState extends Equatable {
  const BillState();

  @override
  List<Object?> get props => [];
}

class BillInitial extends BillState {}

class BillLoading extends BillState {}

class BillLoaded extends BillState {
  final BillSettings bill;

  const BillLoaded(this.bill);

  @override
  List<Object?> get props => [bill];
}

class BillUpdating extends BillState {}

class BillUpdated extends BillState {}

class BillError extends BillState {
  final String message;

  const BillError(this.message);

  @override
  List<Object?> get props => [message];
}
