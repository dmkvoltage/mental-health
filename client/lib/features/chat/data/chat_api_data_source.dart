import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../core/network/api_exception.dart';
import '../domain/chat_message.dart';

class ChatApiDataSource {
  const ChatApiDataSource({required this.client, required this.baseUri});

  final http.Client client;
  final Uri baseUri;

  Future<ChatReply> sendMessage(String message, {String? sessionId}) async {
    final requestBody = <String, Object>{
      'message': message,
      'session_id': ?sessionId,
    };

    try {
      final response = await client
          .post(
            baseUri.resolve('/api/chat'),
            headers: const {'content-type': 'application/json'},
            body: jsonEncode(requestBody),
          )
          .timeout(const Duration(seconds: 45));

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw ApiException(_messageForStatus(response.statusCode));
      }

      return _parseReply(response.body);
    } on TimeoutException {
      throw const ApiException(
        'The support service is taking too long to respond. Please try again.',
      );
    } on http.ClientException {
      throw const ApiException(
        'Could not connect to MindCare. Check that the server is running.',
      );
    } on FormatException {
      throw const ApiException(
        'The server returned a response that could not be read.',
      );
    }
  }

  ChatReply _parseReply(String body) {
    final decoded = jsonDecode(body);
    if (decoded is! Map<String, dynamic>) {
      throw const ApiException(
        'The server returned a response in an unexpected format.',
      );
    }

    final sessionId = decoded['session_id'];
    final answer = decoded['response'];
    final rawSources = decoded['sources'];
    final safetyNotice = decoded['safety_notice'];

    if (sessionId is! String ||
        answer is! String ||
        rawSources is! List ||
        safetyNotice is! bool) {
      throw const ApiException(
        'The server returned a response in an unexpected format.',
      );
    }

    final sources = <SourceReference>[];
    for (final rawSource in rawSources) {
      if (rawSource is! Map<String, dynamic>) {
        throw const ApiException(
          'The server returned a response in an unexpected format.',
        );
      }

      final sourceName = rawSource['source'];
      final page = rawSource['page'];
      if (sourceName is! String || (page != null && page is! int)) {
        throw const ApiException(
          'The server returned a response in an unexpected format.',
        );
      }

      sources.add(
        SourceReference(
          name: sourceName,
          page: page == null ? null : page as int,
        ),
      );
    }

    return ChatReply(
      sessionId: sessionId,
      response: answer,
      sources: List.unmodifiable(sources),
      safetyNotice: safetyNotice,
    );
  }

  String _messageForStatus(int statusCode) {
    return switch (statusCode) {
      404 => 'This conversation is no longer available. Start a new one.',
      422 => 'Please check your message and try again.',
      _ => 'MindCare could not reply right now. Please try again.',
    };
  }
}
