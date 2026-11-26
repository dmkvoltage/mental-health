import '../domain/chat_message.dart';
import '../domain/chat_repository.dart';
import 'chat_api_data_source.dart';

class ChatRepositoryImpl implements ChatRepository {
  const ChatRepositoryImpl(this._dataSource);

  final ChatApiDataSource _dataSource;

  @override
  Future<ChatReply> sendMessage(String message, {String? sessionId}) {
    return _dataSource.sendMessage(message, sessionId: sessionId);
  }
}
