import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:saleup_app/core/network/dio_client.dart';
import 'package:saleup_app/model/chat_response.dart';
import 'package:saleup_app/screen/chat/bloc/chat_event.dart';
import 'package:saleup_app/screen/chat/bloc/chat_state.dart';
import 'dart:developer';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final DioClient _dioClient;

  ChatBloc({DioClient? dioClient})
      : _dioClient = dioClient ?? DioClient(),
        super(ChatInitial()) {
    on<SendChatMessage>(_onSendChatMessage);
  }

  Future<void> _onSendChatMessage(
      SendChatMessage event, Emitter<ChatState> emit) async {
    emit(ChatLoading());
    try {
      final response = await _dioClient.dio.post(
        '/chat/',
        data: {'message': event.message},
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final chatResponse = ChatResponse.fromJson(response.data);
        emit(ChatSuccess(
          message: chatResponse.data.answer,
          timestamp: DateTime.now(),
        ));
      } else {
        emit(ChatError(
            errorMessage:
                response.data['message'] ?? 'Failed to get response'));
      }
    } catch (e) {
      log('Chat error: $e');
      emit(ChatError(errorMessage: 'An error occurred: $e'));
    }
  }
}
