// import 'package:equatable/equatable.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:dio/dio.dart';
// import 'package:saleup_app/screen/purchaseReturn/model/purchase.dart';
// import 'package:saleup_app/screen/purchaseReturn/model/purchase_return.dart';

// part 'purchase_return_event.dart';
// part 'purchase_return_state.dart';

// class PurchaseReturnBloc
//     extends Bloc<PurchaseReturnEvent, PurchaseReturnState> {
//   final Dio dio; // ← this was missing in your last version

//   PurchaseReturnBloc({required this.dio}) : super(PurchaseReturnInitial()) {
//     on<LoadPurchaseReturns>(_onLoadReturns);
//     on<LoadPurchasesForReturn>(_onLoadPurchases);
//     on<CreatePurchaseReturn>(_onCreateReturn);
//   }

//   Future<void> _onLoadReturns(
//     LoadPurchaseReturns event,
//     Emitter<PurchaseReturnState> emit,
//   ) async {
//     emit(PurchaseReturnsLoading());
//     try {
//       final res = await dio.get('/purchase-return/get_purchase_returns/');
//       if (res.data['success'] == true) {
//         final list = (res.data['data'] as List<dynamic>? ?? [])
//             .map((e) => PurchaseReturn.fromJson(e as Map<String, dynamic>))
//             .toList();
//         emit(PurchaseReturnsLoaded(list));
//       } else {
//         emit(PurchaseReturnError(
//             res.data['message'] ?? 'Failed to load returns'));
//       }
//     } catch (e) {
//       emit(PurchaseReturnError(e.toString()));
//     }
//   }

//   Future<void> _onLoadPurchases(
//     LoadPurchasesForReturn event,
//     Emitter<PurchaseReturnState> emit,
//   ) async {
//     emit(PurchasesLoading());
//     try {
//       final res = await dio.get('/purchase/get_purchases/');
//       if (res.data['success'] == true) {
//         final list = (res.data['data'] as List<dynamic>? ?? [])
//             .map((e) => Purchase.fromJson(e as Map<String, dynamic>))
//             .toList();
//         emit(PurchasesLoaded(list));
//       } else {
//         emit(PurchaseReturnError(
//             res.data['message'] ?? 'Failed to load purchases'));
//       }
//     } catch (e) {
//       emit(PurchaseReturnError(e.toString()));
//     }
//   }

//   Future<void> _onCreateReturn(
//     CreatePurchaseReturn event,
//     Emitter<PurchaseReturnState> emit,
//   ) async {
//     emit(PurchaseReturnCreating());
//     try {
//       final res = await dio.post(
//         '/purchase-return/create_purchase_return/',
//         data: {
//           'purchase': event.purchaseId,
//           'return_date': event.returnDate,
//           'reason': event.reason,
//           'items': event.items,
//         },
//       );

//       if (res.data['success'] == true) {
//         final created = PurchaseReturn.fromJson(res.data['data']);
//         emit(PurchaseReturnCreated(created));
//         add(const LoadPurchaseReturns()); // refresh list
//       } else {
//         emit(PurchaseReturnError(res.data['message'] ?? 'Creation failed'));
//       }
//     } catch (e) {
//       emit(PurchaseReturnError(e.toString()));
//     }
//   }
// }
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:saleup_app/screen/purchaseReturn/model/purchase.dart';
import 'package:saleup_app/screen/purchaseReturn/model/purchase_return.dart';

part 'purchase_return_event.dart';
part 'purchase_return_state.dart';

class PurchaseReturnBloc
    extends Bloc<PurchaseReturnEvent, PurchaseReturnState> {
  final Dio dio;

  PurchaseReturnBloc({required this.dio}) : super(PurchaseReturnInitial()) {
    on<LoadPurchaseReturns>(_onLoadReturns);
    on<LoadPurchasesForReturn>(_onLoadPurchases);
    on<CreatePurchaseReturn>(_onCreateReturn);
  }

  Future<void> _onLoadReturns(
    LoadPurchaseReturns event,
    Emitter<PurchaseReturnState> emit,
  ) async {
    emit(PurchaseReturnsLoading());
    try {
      final res = await dio.get('/purchase-return/get_purchase_returns/');
      print('GET returns raw: ${res.data.runtimeType} → $res.data');

      if (res.data is! Map<String, dynamic> || res.data['success'] != true) {
        emit(PurchaseReturnError(
            'Invalid response or failed: ${res.data['message'] ?? 'No data'}'));
        return;
      }

      final rawList = res.data['data'] as List<dynamic>? ?? [];
      final returns = rawList
          .map((e) => PurchaseReturn.fromJson(e as Map<String, dynamic>))
          .toList();

      emit(PurchaseReturnsLoaded(returns));
    } on DioException catch (e) {
      emit(PurchaseReturnError('Network error: ${e.message}'));
    } catch (e) {
      emit(PurchaseReturnError('Unexpected error: $e'));
    }
  }

  Future<void> _onLoadPurchases(
    LoadPurchasesForReturn event,
    Emitter<PurchaseReturnState> emit,
  ) async {
    emit(PurchasesLoading());
    try {
      final res = await dio.get('/purchase/get_purchases/');
      print('GET purchases raw: ${res.data.runtimeType} → $res.data');

      if (res.data is! Map<String, dynamic> || res.data['success'] != true) {
        emit(PurchaseReturnError(
            'Invalid response or failed: ${res.data['message'] ?? 'No data'}'));
        return;
      }

      final rawList = res.data['data'] as List<dynamic>? ?? [];
      final purchases = rawList
          .map((e) => Purchase.fromJson(e as Map<String, dynamic>))
          .toList();

      emit(PurchasesLoaded(purchases));
    } on DioException catch (e) {
      emit(PurchaseReturnError('Network error: ${e.message}'));
    } catch (e) {
      emit(PurchaseReturnError('Unexpected error: $e'));
    }
  }

  Future<void> _onCreateReturn(
    CreatePurchaseReturn event,
    Emitter<PurchaseReturnState> emit,
  ) async {
    emit(PurchaseReturnCreating());
    try {
      print(
          'Creating return → payload: purchaseId=${event.purchaseId}, date=${event.returnDate}, items=${event.items.length}');

      final res = await dio.post(
        '/purchase-return/create_purchase_return/',
        data: {
          'purchase': event.purchaseId,
          'return_date': event.returnDate,
          'reason': event.reason,
          'items': event.items,
        },
      );

      print('POST create raw response: ${res.data.runtimeType} → $res.data');

      if (res.data is! Map<String, dynamic> || res.data['success'] != true) {
        emit(PurchaseReturnError(res.data['message'] ?? 'Creation failed'));
        return;
      }

      final rawData = res.data['data'];
      if (rawData is! Map<String, dynamic>) {
        emit(const PurchaseReturnError('Invalid data format in response'));
        return;
      }

      final created = PurchaseReturn.fromJson(rawData);
      emit(PurchaseReturnCreated(created));

      // Auto-refresh list
      add(const LoadPurchaseReturns());
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ?? e.message ?? 'Network error';
      emit(PurchaseReturnError(msg));
    } catch (e) {
      emit(PurchaseReturnError('Unexpected error during creation: $e'));
    }
  }
}
