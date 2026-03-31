// bill_event.dart
import 'package:equatable/equatable.dart';

abstract class BillEvent extends Equatable {
  const BillEvent();

  @override
  List<Object?> get props => [];
}

class LoadBillSettings extends BillEvent {
  const LoadBillSettings();
}

class UpdateBillSettings extends BillEvent {
  final int billId;
  final String printType;
  final bool printTokenOnBill;
  final int left;
  final int right;
  final int top;
  final int bottom;

  const UpdateBillSettings({
    required this.billId,
    required this.printType,
    required this.printTokenOnBill,
    required this.left,
    required this.right,
    required this.top,
    required this.bottom,
  });

  @override
  List<Object?> get props =>
      [billId, printType, printTokenOnBill, left, right, top, bottom];
}
