// import 'package:equatable/equatable.dart';
// import 'package:saleup_app/model/purchase_response.dart';

// class PurchaseFormState extends Equatable {
//   final bool isLoading;
//   final bool isSubmitting;
//   final String? error;
//   final bool success;

//   final List<String> parties;
//   final List<String> products;

//   final String invoiceNumber;
//   final String? selectedParty;
//   final String billType;
//   final double discount;
//   final String date; // 'yyyy-MM-dd'
//   final List<PurchaseItem> items;

//   // ── Cash balance from /account-heads/get_cash_balance/ ──
//   final double cashBalance;

//   const PurchaseFormState({
//     this.isLoading = false,
//     this.isSubmitting = false,
//     this.error,
//     this.success = false,
//     this.parties = const [],
//     this.products = const [],
//     this.invoiceNumber = '',
//     this.selectedParty,
//     this.billType = 'Credit',
//     this.discount = 0.0,
//     this.date = '',
//     this.items = const [],
//     this.cashBalance = 0.0,
//   });

//   double get subTotal => items.fold<double>(
//         0.0,
//         (sum, item) => sum + (item.total ?? 0),
//       );

//   double get taxableAmount => subTotal - discount;
//   double get vat => taxableAmount * 0.13;
//   double get grandTotal => taxableAmount + vat;

//   PurchaseFormState copyWith({
//     bool? isLoading,
//     bool? isSubmitting,
//     String? error,
//     bool? success,
//     List<String>? parties,
//     List<String>? products,
//     String? invoiceNumber,
//     String? selectedParty,
//     String? billType,
//     double? discount,
//     String? date,
//     List<PurchaseItem>? items,
//     double? cashBalance,
//   }) {
//     return PurchaseFormState(
//       isLoading: isLoading ?? this.isLoading,
//       isSubmitting: isSubmitting ?? this.isSubmitting,
//       error: error ?? this.error,
//       success: success ?? this.success,
//       parties: parties ?? this.parties,
//       products: products ?? this.products,
//       invoiceNumber: invoiceNumber ?? this.invoiceNumber,
//       selectedParty: selectedParty ?? this.selectedParty,
//       billType: billType ?? this.billType,
//       discount: discount ?? this.discount,
//       date: date ?? this.date,
//       items: items ?? this.items,
//       cashBalance: cashBalance ?? this.cashBalance,
//     );
//   }

//   @override
//   List<Object?> get props => [
//         isLoading,
//         isSubmitting,
//         error,
//         success,
//         parties,
//         products,
//         invoiceNumber,
//         selectedParty,
//         billType,
//         discount,
//         date,
//         items,
//         cashBalance,
//       ];
// }

import 'package:equatable/equatable.dart';
import 'package:saleup_app/model/purchase_response.dart';
import 'package:saleup_app/screen/addPurchase/model/unit.dart';

class PurchaseFormState extends Equatable {
  final bool isLoading;
  final bool isSubmitting;
  final String? error;
  final bool success;

  final List<String> parties;
  final List<String> products;
  final List<Unit> units; // ← NEW
  final bool isLoadingUnits; // ← NEW (optional but improves UX)

  final String invoiceNumber;
  final String? selectedParty;
  final String billType;
  final double discount;
  final String date; // 'yyyy-MM-dd'
  final List<PurchaseItem> items;

  final double cashBalance;

  const PurchaseFormState({
    this.isLoading = false,
    this.isSubmitting = false,
    this.error,
    this.success = false,
    this.parties = const [],
    this.products = const [],
    this.units = const [], // ← NEW
    this.isLoadingUnits = false, // ← NEW
    this.invoiceNumber = '',
    this.selectedParty,
    this.billType = 'Credit',
    this.discount = 0.0,
    this.date = '',
    this.items = const [],
    this.cashBalance = 0.0,
  });

  double get subTotal => items.fold<double>(
        0.0,
        (sum, item) => sum + (item.total ?? 0),
      );

  double get taxableAmount => subTotal - discount;
  double get vat => taxableAmount * 0.13;
  double get grandTotal => taxableAmount + vat;

  PurchaseFormState copyWith({
    bool? isLoading,
    bool? isSubmitting,
    String? error,
    bool? success,
    List<String>? parties,
    List<String>? products,
    List<Unit>? units, // ← NEW
    bool? isLoadingUnits, // ← NEW
    String? invoiceNumber,
    String? selectedParty,
    String? billType,
    double? discount,
    String? date,
    List<PurchaseItem>? items,
    double? cashBalance,
  }) {
    return PurchaseFormState(
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      error: error ?? this.error,
      success: success ?? this.success,
      parties: parties ?? this.parties,
      products: products ?? this.products,
      units: units ?? this.units, // ← NEW
      isLoadingUnits: isLoadingUnits ?? this.isLoadingUnits, // ← NEW
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      selectedParty: selectedParty ?? this.selectedParty,
      billType: billType ?? this.billType,
      discount: discount ?? this.discount,
      date: date ?? this.date,
      items: items ?? this.items,
      cashBalance: cashBalance ?? this.cashBalance,
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        isSubmitting,
        error,
        success,
        parties,
        products,
        units, // ← NEW
        isLoadingUnits, // ← NEW
        invoiceNumber,
        selectedParty,
        billType,
        discount,
        date,
        items,
        cashBalance,
      ];
}
