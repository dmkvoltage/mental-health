import 'chat_message.dart';

abstract interface class ChatRepository {
  Future<ChatReply> sendMessage(String message, {String? sessionId});
}
