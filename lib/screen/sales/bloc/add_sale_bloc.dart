import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:saleup_app/core/network/dio_client.dart';
import 'add_sale_event.dart';
import 'add_sale_state.dart';

class AddSaleBloc extends Bloc<AddSaleEvent, AddSaleState> {
  final DioClient dioClient;

  AddSaleBloc({DioClient? dioClient})
      : dioClient = dioClient ?? DioClient(),
        super(AddSaleInitial()) {
    on<SubmitSale>(_onSubmitSale);
    on<GenerateBill>(_onGenerateBill);
  }

  Future<void> _onSubmitSale(
      SubmitSale event, Emitter<AddSaleState> emit) async {
    emit(AddSaleLoading());

    try {
      final response = await dioClient.dio.post('/sale/create_sale/', data: {
        "bill_type": event.billType,
        "customer": event.customer,
        "payment_mode": event.paymentMethod,
        "items": event.items,
        "narration": event.narration,
        "total": event.total,
        // Add other fields you need
      });

      if (response.data['success'] == true) {
        final saleId = response.data['data']['id'];
        emit(AddSaleSuccess(response.data['message'], saleId));
      } else {
        emit(AddSaleFailure(
            response.data['message'] ?? 'Failed to create sale'));
      }
    } catch (e) {
      emit(AddSaleFailure(e.toString()));
    }
  }

  Future<void> _onGenerateBill(
      GenerateBill event, Emitter<AddSaleState> emit) async {
    try {
      final response = await dioClient.dio.get(
        '/sale/generate_sales_bill/?sales_id=${event.saleId}&action=download',
      );
      // Handle bill download (e.g., save file or open in browser)
      print('Bill generated: ${response.data}');
    } catch (e) {
      print('Failed to generate bill: $e');
    }
  }
}
