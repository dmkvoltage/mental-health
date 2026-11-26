enum ChatRole { user, assistant }

class SourceReference {
  const SourceReference({required this.name, this.page});

  final String name;
  final int? page;
}

class ChatMessage {
  const ChatMessage({
    required this.text,
    required this.role,
    this.sources = const [],
    this.safetyNotice = false,
  });

  final String text;
  final ChatRole role;
  final List<SourceReference> sources;
  final bool safetyNotice;

  bool get isUser => role == ChatRole.user;
}

class ChatReply {
  const ChatReply({
    required this.sessionId,
    required this.response,
    required this.sources,
    required this.safetyNotice,
  });

  final String sessionId;
  final String response;
  final List<SourceReference> sources;
  final bool safetyNotice;
}
