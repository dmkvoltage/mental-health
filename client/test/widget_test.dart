import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mindcare_client/features/home/presentation/home_screen.dart';

void main() {
  testWidgets('home screen opens the chat from its primary action', (
    tester,
  ) async {
    var openedChat = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: HomeScreen(
            onOpenChat: () => openedChat = true,
            onOpenTools: () {},
          ),
        ),
      ),
    );

    expect(find.textContaining('A little space for'), findsOneWidget);
    await tester.tap(find.text('Start a conversation'));
    expect(openedChat, isTrue);
  });
}
