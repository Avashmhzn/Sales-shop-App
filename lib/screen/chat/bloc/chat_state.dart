abstract class ChatState {}

class ChatInitial extends ChatState {}

class ChatLoading extends ChatState {}

class ChatSuccess extends ChatState {
  final String message;
  final DateTime timestamp;

  ChatSuccess({required this.message, required this.timestamp});
}

class ChatError extends ChatState {
  final String errorMessage;

  ChatError({required this.errorMessage});
}
