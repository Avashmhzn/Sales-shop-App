// bill_bloc.dart
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:saleup_app/screen/bill_option/model/bill_settings.dart';
import 'bill_event.dart';
import 'bill_state.dart';

class BillBloc extends Bloc<BillEvent, BillState> {
  final Dio dio;

  BillBloc({required this.dio}) : super(BillInitial()) {
    on<LoadBillSettings>(_onLoadBillSettings);
    on<UpdateBillSettings>(_onUpdateBillSettings);
  }

  Future<void> _onLoadBillSettings(
    LoadBillSettings event,
    Emitter<BillState> emit,
  ) async {
    emit(BillLoading());
    try {
      final response = await dio.get('/bill/get_bill/');

      if (response.statusCode != 200) {
        emit(const BillError('Failed to load bill settings'));
        return;
      }

      final data = response.data;
      if (data['success'] != true) {
        emit(BillError(
            data['message']?.toString() ?? 'Failed to load bill settings'));
        return;
      }

      final billList = data['data'] as List<dynamic>? ?? [];
      if (billList.isEmpty) {
        emit(const BillError('No bill settings found'));
        return;
      }

      final billData = billList.first as Map<String, dynamic>;
      final bill = BillSettings.fromJson(billData);

      emit(BillLoaded(bill));
    } catch (e) {
      emit(BillError('Error loading bill settings: $e'));
    }
  }

  Future<void> _onUpdateBillSettings(
    UpdateBillSettings event,
    Emitter<BillState> emit,
  ) async {
    emit(BillUpdating());
    try {
      final response = await dio.put(
        '/bill/update_bill/',
        queryParameters: {'bill_id': event.billId},
        data: {
          'print_type': event.printType,
          'print_token_on_bill': event.printTokenOnBill,
          'left': event.left,
          'right': event.right,
          'top': event.top,
          'bottom': event.bottom,
        },
      );

      final data = response.data;
      if (data['success'] != true) {
        emit(BillError(
            data['message']?.toString() ?? 'Failed to update bill settings'));
        return;
      }

      emit(BillUpdated());
      // Refresh after update
      add(const LoadBillSettings());
    } catch (e) {
      emit(BillError('Error updating bill settings: $e'));
    }
  }
}
