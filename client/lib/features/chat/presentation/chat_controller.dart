import 'package:flutter/foundation.dart';

import '../../../core/network/api_exception.dart';
import '../domain/chat_message.dart';
import '../domain/chat_repository.dart';

class ChatController extends ChangeNotifier {
  ChatController(this._repository);

  final ChatRepository _repository;

  final List<ChatMessage> _messages = [
    const ChatMessage(
      text: "Hi, I'm here to listen. What's on your mind today?",
      role: ChatRole.assistant,
    ),
  ];
  String? _sessionId;
  String? _pendingMessage;
  String? _error;
  bool _isSending = false;

  List<ChatMessage> get messages => List.unmodifiable(_messages);
  bool get isSending => _isSending;
  String? get error => _error;

  Future<void> sendMessage(String input) async {
    final message = input.trim();
    if (message.isEmpty || _isSending) {
      return;
    }

    _pendingMessage = message;
    _messages.add(ChatMessage(text: message, role: ChatRole.user));
    await _submitPendingMessage();
  }

  Future<void> retryLastMessage() async {
    if (_pendingMessage == null || _isSending) {
      return;
    }
    await _submitPendingMessage();
  }

  void startNewConversation() {
    _sessionId = null;
    _pendingMessage = null;
    _error = null;
    _messages
      ..clear()
      ..add(
        const ChatMessage(
          text: "Hi, I'm here to listen. What's on your mind today?",
          role: ChatRole.assistant,
        ),
      );
    notifyListeners();
  }

  Future<void> _submitPendingMessage() async {
    final message = _pendingMessage;
    if (message == null) {
      return;
    }

    _isSending = true;
    _error = null;
    notifyListeners();

    try {
      final reply = await _repository.sendMessage(
        message,
        sessionId: _sessionId,
      );
      _sessionId = reply.sessionId;
      _messages.add(
        ChatMessage(
          text: reply.response,
          role: ChatRole.assistant,
          sources: reply.sources,
          safetyNotice: reply.safetyNotice,
        ),
      );
      _pendingMessage = null;
    } on ApiException catch (exception) {
      _error = exception.message;
    } finally {
      _isSending = false;
      notifyListeners();
    }
  }
}
