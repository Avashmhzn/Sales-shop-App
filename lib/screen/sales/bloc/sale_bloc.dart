// import 'package:dio/dio.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:saleup_app/core/network/dio_client.dart';
// import 'package:saleup_app/model/sale_response.dart';
// import 'sale_event.dart';
// import 'sale_state.dart';

// class SaleBloc extends Bloc<SaleEvent, SaleState> {
//   final DioClient dioClient;

//   SaleBloc({DioClient? dioClient})
//       : dioClient = dioClient ?? DioClient(),
//         super(SaleState.initial()) {
//     on<FetchSales>(_onFetchSales);
//     on<FetchSaleById>(_onFetchSaleById);
//   }

//   Future<void> _onFetchSales(FetchSales event, Emitter<SaleState> emit) async {
//     emit(state.copyWith(isLoading: true, errorMessage: null));
//     try {
//       final response = await dioClient.dio.get('/sale/get_sales/');
//       print('FetchSales raw response: ${response.data}');
//       if (response.data is! Map<String, dynamic>) {
//         emit(state.copyWith(
//             isLoading: false, errorMessage: 'Invalid API response format'));
//         return;
//       }
//       final saleResponse = SaleResponse.fromJson(response.data);
//       if (saleResponse.success && saleResponse.data != null) {
//         if (saleResponse.data is! List<dynamic>) {
//           emit(state.copyWith(
//               isLoading: false, errorMessage: 'Expected a list of sales'));
//           return;
//         }
//         final sales = (saleResponse.data as List<dynamic>)
//             .map((json) => SaleData.fromJson(json as Map<String, dynamic>))
//             .toList();
//         emit(
//             state.copyWith(isLoading: false, sales: sales, errorMessage: null));
//       } else {
//         emit(state.copyWith(
//             isLoading: false,
//             errorMessage: saleResponse.message ?? 'Failed to fetch sales'));
//       }
//     } on DioException catch (e, stackTrace) {
//       print(
//           'DioException in FetchSales: ${e.message}, Status: ${e.response?.statusCode}, Data: ${e.response?.data}\nStackTrace: $stackTrace');
//       emit(state.copyWith(
//           isLoading: false, errorMessage: 'Network error: ${e.message}'));
//     } catch (e, stackTrace) {
//       print('Exception in FetchSales: $e\nStackTrace: $stackTrace');
//       emit(state.copyWith(
//           isLoading: false, errorMessage: 'Failed to fetch sales: $e'));
//     }
//   }

//   Future<void> _onFetchSaleById(
//       FetchSaleById event, Emitter<SaleState> emit) async {
//     emit(state.copyWith(isLoading: true, errorMessage: null, saleDetail: null));
//     try {
//       print('Fetching sale with ID: ${event.saleId}');
//       final response =
//           await dioClient.dio.get('/sale/get_sale/?sale_id=${event.saleId}');
//       print(
//           'FetchSaleById raw response for ID ${event.saleId}: ${response.data}');

//       if (response.data == null) {
//         print('Null response data');
//         emit(state.copyWith(
//             isLoading: false, errorMessage: 'No data returned from API'));
//         return;
//       }

//       if (response.data is! Map<String, dynamic>) {
//         print('Invalid response format: ${response.data}');
//         emit(state.copyWith(
//             isLoading: false, errorMessage: 'Invalid API response format'));
//         return;
//       }

//       final saleResponse = SaleResponse.fromJson(response.data);
//       print(
//           'SaleResponse: success=${saleResponse.success}, message=${saleResponse.message}, data=${saleResponse.data}');
//       if (saleResponse.success && saleResponse.data != null) {
//         if (saleResponse.data is! Map<String, dynamic>) {
//           print('Unexpected data format: ${saleResponse.data}');
//           emit(state.copyWith(
//               isLoading: false, errorMessage: 'Unexpected data format'));
//           return;
//         }

//         try {
//           final saleDetail =
//               SaleData.fromJson(saleResponse.data as Map<String, dynamic>);
//           print('Parsed saleDetail: $saleDetail');
//           emit(state.copyWith(
//               isLoading: false, saleDetail: saleDetail, errorMessage: null));
//         } catch (e, stackTrace) {
//           print(
//               'Parsing error in SaleData.fromJson: $e, StackTrace: $stackTrace');
//           emit(state.copyWith(
//               isLoading: false,
//               errorMessage: 'Failed to parse sale details: $e'));
//         }
//       } else {
//         print('Sale response failure: ${saleResponse.message}');
//         emit(state.copyWith(
//             isLoading: false,
//             errorMessage: saleResponse.message ?? 'No sale details found'));
//       }
//     } on DioException catch (e, stackTrace) {
//       print(
//           'DioException in FetchSaleById: ${e.message}, Status: ${e.response?.statusCode}, Data: ${e.response?.data}, StackTrace: $stackTrace');
//       String errorMessage = 'Network error: ${e.message}';
//       if (e.response?.statusCode == 401) {
//         errorMessage = 'Unauthorized: Please log in again';
//       }
//       emit(state.copyWith(isLoading: false, errorMessage: errorMessage));
//     } catch (e, stackTrace) {
//       print('Exception in FetchSaleById: $e, StackTrace: $stackTrace');
//       emit(state.copyWith(
//           isLoading: false, errorMessage: 'Failed to fetch sale detail: $e'));
//     }
//   }
// }
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:saleup_app/core/network/dio_client.dart';
import 'package:saleup_app/model/sale_response.dart';
import 'sale_event.dart';
import 'sale_state.dart';
import 'package:flutter/foundation.dart';

class SaleBloc extends Bloc<SaleEvent, SaleState> {
  final DioClient dioClient;

  SaleBloc({DioClient? dioClient})
      : dioClient = dioClient ?? DioClient(),
        super(SaleState.initial()) {
    on<FetchSales>(_onFetchSales);
    on<FetchSaleById>(_onFetchSaleById);
  }

  Future<void> _onFetchSales(FetchSales event, Emitter<SaleState> emit) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    Response? response;
    try {
      response = await dioClient.dio.get('/sale/get_sales/');
      if (kDebugMode) {
        print('FetchSales raw response: ${response.data}');
      }
      if (response.data is! Map<String, dynamic>) {
        emit(state.copyWith(
            isLoading: false, errorMessage: 'Invalid API response format'));
        return;
      }
      final saleResponse = SaleResponse.fromJson(response.data);
      if (kDebugMode) {
        print(
            'SaleResponse: success=${saleResponse.success}, message=${saleResponse.message}, data length=${(saleResponse.data as List<dynamic>?)?.length ?? 0}');
      }
      if (saleResponse.success && saleResponse.data != null) {
        if (saleResponse.data is! List<dynamic>) {
          emit(state.copyWith(
              isLoading: false, errorMessage: 'Expected a list of sales'));
          return;
        }
        final sales = <SaleData>[];
        final saleDataList = saleResponse.data as List<dynamic>;
        if (kDebugMode) {
          print('Processing ${saleDataList.length} sales entries');
        }
        for (var json in saleDataList) {
          if (json is! Map<String, dynamic>) {
            if (kDebugMode) {
              print('Invalid sale data format: $json');
            }
            continue;
          }
          try {
            final sale = SaleData.fromJson(json);
            sales.add(sale);
            if (kDebugMode) {
              print(
                  'Successfully parsed sale: ID=${sale.id}, Invoice=${sale.invoiceNumber}');
            }
          } catch (e, stackTrace) {
            if (kDebugMode) {
              print('Error parsing sale data: $json');
              print('Deserialization error: $e\nStackTrace: $stackTrace');
              // Log SaleData fields
              print(
                  'SaleData fields: id=${json['id']}, type=${json['id'].runtimeType}');
              print(
                  'SaleData fields: invoice_number=${json['invoice_number']}, type=${json['invoice_number'].runtimeType}');
              print(
                  'SaleData fields: sub_total=${json['sub_total']}, type=${json['sub_total'].runtimeType}');
              print(
                  'SaleData fields: vatable_amount=${json['vatable_amount']}, type=${json['vatable_amount'].runtimeType}');
              print(
                  'SaleData fields: vat=${json['vat']}, type=${json['vat'].runtimeType}');
              print(
                  'SaleData fields: discount=${json['discount']}, type=${json['discount'].runtimeType}');
              print(
                  'SaleData fields: total=${json['total']}, type=${json['total'].runtimeType}');
              print(
                  'SaleData fields: tender_amount=${json['tender_amount']}, type=${json['tender_amount'].runtimeType}');
              // Log SaleItem fields from items array
              if (json['items'] is List<dynamic>) {
                for (var item in json['items'] as List<dynamic>) {
                  if (item is Map<String, dynamic>) {
                    print(
                        'SaleItem fields: id=${item['id']}, type=${item['id'].runtimeType}');
                    print(
                        'SaleItem fields: product=${item['product']}, type=${item['product'].runtimeType}');
                    print(
                        'SaleItem fields: quantity=${item['quantity']}, type=${item['quantity'].runtimeType}');
                    print(
                        'SaleItem fields: rate=${item['rate']}, type=${item['rate'].runtimeType}');
                    print(
                        'SaleItem fields: total=${item['total']}, type=${item['total'].runtimeType}');
                    print(
                        'SaleItem fields: product_name=${item['product_name']}, type=${item['product_name'].runtimeType}');
                  }
                }
              }
            }
            continue;
          }
        }
        if (sales.isEmpty && saleDataList.isNotEmpty) {
          emit(state.copyWith(
              isLoading: false,
              errorMessage:
                  'No valid sales data could be parsed from the response'));
          return;
        }
        emit(
            state.copyWith(isLoading: false, sales: sales, errorMessage: null));
        if (kDebugMode) {
          print('Emitted state with ${sales.length} sales');
        }
      } else {
        emit(state.copyWith(
            isLoading: false,
            errorMessage: saleResponse.message ?? 'Failed to fetch sales'));
      }
    } on DioException catch (e, stackTrace) {
      if (kDebugMode) {
        print(
            'DioException in FetchSales: ${e.message}, Status: ${e.response?.statusCode}, Data: ${e.response?.data}\nStackTrace: $stackTrace');
      }
      emit(state.copyWith(
          isLoading: false, errorMessage: 'Network error: ${e.message}'));
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('Exception in FetchSales: $e\nStackTrace: $stackTrace');
        print(
            'Failed JSON data: ${response?.data ?? "No response data available"}');
      }
      emit(state.copyWith(
          isLoading: false, errorMessage: 'Failed to fetch sales: $e'));
    }
  }

  Future<void> _onFetchSaleById(
      FetchSaleById event, Emitter<SaleState> emit) async {
    emit(state.copyWith(isLoading: true, errorMessage: null, saleDetail: null));
    try {
      if (kDebugMode) {
        print('Fetching sale with ID: ${event.saleId}');
      }
      final response =
          await dioClient.dio.get('/sale/get_sale/?sale_id=${event.saleId}');
      if (kDebugMode) {
        print(
            'FetchSaleById raw response for ID ${event.saleId}: ${response.data}');
      }

      if (response.data == null) {
        if (kDebugMode) {
          print('Null response data');
        }
        emit(state.copyWith(
            isLoading: false, errorMessage: 'No data returned from API'));
        return;
      }

      if (response.data is! Map<String, dynamic>) {
        if (kDebugMode) {
          print('Invalid response format: ${response.data}');
        }
        emit(state.copyWith(
            isLoading: false, errorMessage: 'Invalid API response format'));
        return;
      }

      final saleResponse = SaleResponse.fromJson(response.data);
      if (kDebugMode) {
        print(
            'SaleResponse: success=${saleResponse.success}, message=${saleResponse.message}, data=${saleResponse.data}');
      }
      if (saleResponse.success && saleResponse.data != null) {
        if (saleResponse.data is! Map<String, dynamic>) {
          if (kDebugMode) {
            print('Unexpected data format: ${saleResponse.data}');
          }
          emit(state.copyWith(
              isLoading: false, errorMessage: 'Unexpected data format'));
          return;
        }

        try {
          final saleDetail =
              SaleData.fromJson(saleResponse.data as Map<String, dynamic>);
          if (kDebugMode) {
            print('Parsed saleDetail: $saleDetail');
          }
          emit(state.copyWith(
              isLoading: false, saleDetail: saleDetail, errorMessage: null));
        } catch (e, stackTrace) {
          if (kDebugMode) {
            print(
                'Parsing error in SaleData.fromJson: $e, StackTrace: $stackTrace');
          }
          emit(state.copyWith(
              isLoading: false,
              errorMessage: 'Failed to parse sale details: $e'));
        }
      } else {
        if (kDebugMode) {
          print('Sale response failure: ${saleResponse.message}');
        }
        emit(state.copyWith(
            isLoading: false,
            errorMessage: saleResponse.message ?? 'No sale details found'));
      }
    } on DioException catch (e, stackTrace) {
      if (kDebugMode) {
        print(
            'DioException in FetchSaleById: ${e.message}, Status: ${e.response?.statusCode}, Data: ${e.response?.data}, StackTrace: $stackTrace');
      }
      String errorMessage = 'Network error: ${e.message}';
      if (e.response?.statusCode == 401) {
        errorMessage = 'Unauthorized: Please log in again';
      }
      emit(state.copyWith(isLoading: false, errorMessage: errorMessage));
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('Exception in FetchSaleById: $e, StackTrace: $stackTrace');
      }
      emit(state.copyWith(
          isLoading: false, errorMessage: 'Failed to fetch sale detail: $e'));
    }
  }
}
