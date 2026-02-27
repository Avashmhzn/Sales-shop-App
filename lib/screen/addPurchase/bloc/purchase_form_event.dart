import 'package:equatable/equatable.dart';
import 'package:saleup_app/model/purchase_response.dart';

abstract class PurchaseFormEvent extends Equatable {
  const PurchaseFormEvent();
  @override
  List<Object?> get props => [];
}

class InitializePurchaseForm extends PurchaseFormEvent {
  final PurchaseData? existingPurchase;
  const InitializePurchaseForm({this.existingPurchase});
  @override
  List<Object?> get props => [existingPurchase];
}

class LoadPartiesAndProducts extends PurchaseFormEvent {}

class ChangeInvoiceNumber extends PurchaseFormEvent {
  final String value;
  const ChangeInvoiceNumber(this.value);
  @override
  List<Object?> get props => [value];
}

class ChangeParty extends PurchaseFormEvent {
  final String? value;
  const ChangeParty(this.value);
  @override
  List<Object?> get props => [value];
}

class ChangeBillType extends PurchaseFormEvent {
  final String value;
  const ChangeBillType(this.value);
  @override
  List<Object?> get props => [value];
}

class ChangeDiscount extends PurchaseFormEvent {
  final double value;
  const ChangeDiscount(this.value);
  @override
  List<Object?> get props => [value];
}

class ChangeDate extends PurchaseFormEvent {
  final String date;
  const ChangeDate(this.date);
  @override
  List<Object?> get props => [date];
}

class AddItem extends PurchaseFormEvent {
  final PurchaseItem item;
  const AddItem(this.item);
  @override
  List<Object?> get props => [item];
}

class RemoveItem extends PurchaseFormEvent {
  final int index;
  const RemoveItem(this.index);
  @override
  List<Object?> get props => [index];
}

class SubmitForm extends PurchaseFormEvent {}

// ── New: fetch real cash balance from API ──
class FetchCashBalance extends PurchaseFormEvent {}
