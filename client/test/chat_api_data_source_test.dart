import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mindcare_client/features/chat/data/chat_api_data_source.dart';

void main() {
  group('ChatApiDataSource', () {
    test('posts the message and parses the chat response', () async {
      final client = MockClient((request) async {
        expect(request.method, 'POST');
        expect(request.url, Uri.parse('http://localhost:8000/api/chat'));
        expect(request.headers['content-type'], 'application/json');
        expect(jsonDecode(request.body), {
          'message': 'I feel overwhelmed',
          'session_id': 'session-123',
        });
        return http.Response(
          jsonEncode({
            'session_id': 'session-123',
            'response': 'I hear you. Would you like to share more?',
            'sources': [
              {'source': 'wellbeing.pdf', 'page': 4},
            ],
            'safety_notice': false,
          }),
          200,
        );
      });
      final dataSource = ChatApiDataSource(
        client: client,
        baseUri: Uri.parse('http://localhost:8000'),
      );

      final reply = await dataSource.sendMessage(
        'I feel overwhelmed',
        sessionId: 'session-123',
      );

      expect(reply.sessionId, 'session-123');
      expect(reply.response, contains('I hear you'));
      expect(reply.sources.single.name, 'wellbeing.pdf');
      expect(reply.sources.single.page, 4);
      expect(reply.safetyNotice, isFalse);
      client.close();
    });

    test('does not send a session id when starting a conversation', () async {
      final client = MockClient((request) async {
        expect(jsonDecode(request.body), {'message': 'Hello'});
        return http.Response(
          jsonEncode({
            'session_id': 'new-session',
            'response': 'Hello.',
            'sources': [],
            'safety_notice': false,
          }),
          200,
        );
      });
      final dataSource = ChatApiDataSource(
        client: client,
        baseUri: Uri.parse('http://localhost:8000'),
      );

      final reply = await dataSource.sendMessage('Hello');

      expect(reply.sessionId, 'new-session');
      client.close();
    });

    test('reports an actionable error for a failed request', () async {
      final client = MockClient(
        (_) async => http.Response('{"detail":"Chat session not found."}', 404),
      );
      final dataSource = ChatApiDataSource(
        client: client,
        baseUri: Uri.parse('http://localhost:8000'),
      );

      await expectLater(
        dataSource.sendMessage('Hello', sessionId: 'missing'),
        throwsA(
          isA<Exception>().having(
            (error) => error.toString(),
            'message',
            contains('Start a new one'),
          ),
        ),
      );
      client.close();
    });
  });
}
