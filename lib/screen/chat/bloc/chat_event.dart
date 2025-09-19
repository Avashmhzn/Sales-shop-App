abstract class ChatEvent {}

class SendChatMessage extends ChatEvent {
  final String message;

  SendChatMessage(this.message);
}
