import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:saleup_app/core/network/dio_client.dart';
import 'package:saleup_app/model/purchase_response.dart';
import 'purchase_form_event.dart';
import 'purchase_form_state.dart';

class PurchaseFormBloc extends Bloc<PurchaseFormEvent, PurchaseFormState> {
  final DioClient dioClient;
  final PurchaseData? initialPurchase;

  PurchaseFormBloc({
    required this.dioClient,
    this.initialPurchase,
  }) : super(const PurchaseFormState()) {
    on<InitializePurchaseForm>(_onInitialize);
    on<LoadPartiesAndProducts>(_onLoadData);
    on<ChangeInvoiceNumber>(_onChangeInvoice);
    on<ChangeParty>(_onChangeParty);
    on<ChangeBillType>(_onChangeBillType);
    on<ChangeDiscount>(_onChangeDiscount);
    on<ChangeDate>(_onChangeDate);
    on<AddItem>(_onAddItem);
    on<RemoveItem>(_onRemoveItem);
    on<SubmitForm>(_onSubmit);
    on<FetchCashBalance>(_onFetchCashBalance); // ← new
  }

  Future<void> _onInitialize(
      InitializePurchaseForm event, Emitter<PurchaseFormState> emit) async {
    emit(state.copyWith(isLoading: true));
    add(LoadPartiesAndProducts());

    if (event.existingPurchase != null) {
      final p = event.existingPurchase!;
      final billType = p.billType ?? 'Credit';
      emit(state.copyWith(
        invoiceNumber: p.invoiceNumber ?? '',
        selectedParty: p.party,
        billType: billType,
        discount: p.discount ?? 0.0,
        date: p.createdOn != null
            ? DateFormat('yyyy-MM-dd').format(p.createdOn!)
            : DateFormat('yyyy-MM-dd').format(DateTime.now()),
        items: p.purchaseItems ?? [],
      ));
      // Fetch cash balance if starting on Cash
      if (billType == 'Cash') add(FetchCashBalance());
    } else {
      emit(state.copyWith(
        invoiceNumber: '',
        billType: 'Credit',
        date: DateFormat('yyyy-MM-dd').format(DateTime.now()),
        discount: 0.0,
        items: [],
      ));
    }
  }

  Future<void> _onLoadData(
      LoadPartiesAndProducts event, Emitter<PurchaseFormState> emit) async {
    try {
      final partiesRes = await dioClient.dio.get('/party/get_parties/');
      final partiesData = PurchaseResponse.fromJson(partiesRes.data);
      // debugPrint('Parties raw: ${partiesData.data}');
      final partyNames = (partiesData.data as List<dynamic>?)
              ?.where((e) {
                final t = (e['type'] as String?)?.toLowerCase() ?? '';
                return t == 'supplier' || t == 'both';
              })
              .map((e) => e['name'] as String)
              .toList() ??
          [];

      final productsRes = await dioClient.dio.get(
        '/product/get_products/?limit=3000&offset=0&search=',
      );
      final productsData = PurchaseResponse.fromJson(productsRes.data);
      final productNames = (productsData.data?['results'] as List<dynamic>?)
              ?.map((e) => e['name'] as String)
              .toList() ??
          [];

      emit(state.copyWith(
        parties: partyNames,
        products: productNames,
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  void _onChangeInvoice(ChangeInvoiceNumber event, Emitter emit) =>
      emit(state.copyWith(invoiceNumber: event.value));

  void _onChangeParty(ChangeParty event, Emitter emit) =>
      emit(state.copyWith(selectedParty: event.value));

  void _onChangeBillType(ChangeBillType event, Emitter emit) {
    emit(state.copyWith(billType: event.value));
    // Fetch real cash balance whenever user switches to Cash
    if (event.value == 'Cash') add(FetchCashBalance());
  }

  void _onChangeDiscount(ChangeDiscount event, Emitter emit) =>
      emit(state.copyWith(discount: event.value.clamp(0.0, double.infinity)));

  void _onChangeDate(ChangeDate event, Emitter emit) =>
      emit(state.copyWith(date: event.date));

  void _onAddItem(AddItem event, Emitter emit) {
    emit(state.copyWith(items: [...state.items, event.item]));
  }

  void _onRemoveItem(RemoveItem event, Emitter emit) {
    final updated = List<PurchaseItem>.from(state.items)..removeAt(event.index);
    emit(state.copyWith(items: updated));
  }

  Future<void> _onSubmit(
      SubmitForm event, Emitter<PurchaseFormState> emit) async {
    emit(state.copyWith(isSubmitting: true, error: null));

    if (state.selectedParty == null || state.invoiceNumber.trim().isEmpty) {
      emit(state.copyWith(
          isSubmitting: false, error: 'Party and Invoice are required'));
      return;
    }
    if (state.items.isEmpty) {
      emit(state.copyWith(isSubmitting: false, error: 'Add at least one item'));
      return;
    }

    final payload = {
      'invoice_number': state.invoiceNumber.trim(),
      'bill_type': state.billType,
      'party': state.selectedParty,
      'discount': state.discount.toStringAsFixed(2),
      'sub_total': state.subTotal.toStringAsFixed(2),
      'vat': state.vat.toStringAsFixed(2),
      'total': state.grandTotal.toStringAsFixed(2),
      'items': state.items.map((item) {
        return {
          'product': item.product,
          'quantity': item.quantity,
          'unit': item.unit ?? 'PCS',
          'cost_price': item.costPrice?.toStringAsFixed(2) ?? '0.00',
          'selling_price': item.sellingPrice?.toStringAsFixed(2) ?? '0.00',
          'total': item.total?.toStringAsFixed(2) ?? '0.00',
          'batch_number': item.batchNumber ?? '',
          if (item.expiryDate != null)
            'expiry_date': DateFormat('yyyy-MM-dd').format(item.expiryDate!),
          'is_complementary': item.isComplementary,
        };
      }).toList(),
    };

    try {
      final isEdit = initialPurchase != null;
      final response = await dioClient.dio.post(
        isEdit ? '/purchase/update_purchase/' : '/purchase/create_purchase/',
        data: payload,
      );

      final resp = PurchaseResponse.fromJson(response.data);
      if (resp.success) {
        emit(state.copyWith(isSubmitting: false, success: true));
      } else {
        emit(state.copyWith(
            isSubmitting: false, error: resp.message ?? 'Failed'));
      }
    } catch (e) {
      emit(state.copyWith(isSubmitting: false, error: e.toString()));
    }
  }

  /// Fetches real cash balance from /account-heads/get_cash_balance/
  Future<void> _onFetchCashBalance(
      FetchCashBalance event, Emitter<PurchaseFormState> emit) async {
    try {
      final response =
          await dioClient.dio.get('/account-heads/get_cash_balance/');
      final balance = (response.data['data']['balance'] as num).toDouble();
      emit(state.copyWith(cashBalance: balance));
    } catch (_) {
      // Silently fail — balance stays at previous value
    }
  }
}
