import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:saleup_app/core/network/dio_client.dart';
import 'package:saleup_app/screen/dayClosing/model/day_closing_model.dart';
import 'day_closing_event.dart';
import 'day_closing_state.dart';

class DayClosingBloc extends Bloc<DayClosingEvent, DayClosingState> {
  final DioClient dioClient;

  DayClosingBloc({DioClient? dioClient})
      : dioClient = dioClient ?? DioClient(),
        super(DayClosingInitial()) {
    on<FetchDayData>(_onFetchDayData);
    on<CloseDay>(_onCloseDay);
    on<OpenDay>(_onOpenDay);
  }

  Future<void> _onFetchDayData(
    FetchDayData event,
    Emitter<DayClosingState> emit,
  ) async {
    emit(DayClosingLoading());
    try {
      final response = await dioClient.dio.get('/day-closing/get_day_data/');

      if (kDebugMode) {
        debugPrint('FetchDayData response: ${response.data}');
      }

      if (response.statusCode == 200) {
        final body = response.data as Map<String, dynamic>;

        if (body['success'] == true) {
          if (body['data'] == null) {
            // Server says success but no data → no open day
            emit(DayClosingNoDayOpen(
              message: body['message'] as String? ?? 'No day data',
            ));
            return;
          }

          final dayResponse = DayClosingResponse.fromJson(body);

          if (dayResponse.data != null) {
            emit(DayClosingLoaded(dayData: dayResponse.data!));
          } else {
            emit(DayClosingNoDayOpen(
              message: dayResponse.message,
            ));
          }
        } else {
          // success == false → check message
          final message = body['message'] as String? ?? 'Unknown error';
          if (message.toLowerCase().contains('no open day') ||
              message.toLowerCase().contains('no day data')) {
            emit(DayClosingNoDayOpen(message: message));
          } else {
            emit(DayClosingError(message));
          }
        }
      } else {
        emit(DayClosingError('Server error: ${response.statusCode}'));
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('FetchDayData error: $e');
      }
      emit(DayClosingError('Failed to fetch day data: $e'));
    }
  }

  Future<void> _onCloseDay(
    CloseDay event,
    Emitter<DayClosingState> emit,
  ) async {
    emit(DayClosingLoading());
    try {
      final response = await dioClient.dio.put(
        '/day-closing/close_day/',
        data: {},
      );

      if (response.statusCode == 200) {
        final body = response.data as Map<String, dynamic>;
        if (body['success'] == true) {
          emit(DayCloseSuccess(
            body['message'] as String? ?? 'Day closed successfully',
          ));
          // Re-fetch day data after closing
          add(const FetchDayData());
        } else {
          emit(DayClosingError(
            body['message'] as String? ?? 'Failed to close day',
          ));
        }
      } else {
        emit(DayClosingError('Server error: ${response.statusCode}'));
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('CloseDay error: $e');
      }
      emit(DayClosingError('Failed to close day: $e'));
    }
  }

  Future<void> _onOpenDay(
    OpenDay event,
    Emitter<DayClosingState> emit,
  ) async {
    emit(DayClosingLoading());
    try {
      final response = await dioClient.dio.post(
        '/day-closing/open_day/',
        data: {},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final body = response.data as Map<String, dynamic>;
        if (body['success'] == true) {
          emit(DayOpenSuccess(
            body['message'] as String? ?? 'Day opened successfully',
          ));
          // Re-fetch day data after opening
          add(const FetchDayData());
        } else {
          emit(DayClosingError(
            body['message'] as String? ?? 'Failed to open day',
          ));
        }
      } else {
        emit(DayClosingError('Server error: ${response.statusCode}'));
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('OpenDay error: $e');
      }
      emit(DayClosingError('Failed to open day: $e'));
    }
  }
}
