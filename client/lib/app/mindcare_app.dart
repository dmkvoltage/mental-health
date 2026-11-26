import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../features/chat/domain/chat_repository.dart';
import 'app_theme.dart';
import 'home_shell.dart';

class MindCareApp extends StatelessWidget {
  const MindCareApp({required this.chatRepository, super.key});

  final ChatRepository chatRepository;

  @override
  Widget build(BuildContext context) {
    return Provider<ChatRepository>.value(
      value: chatRepository,
      child: MaterialApp(
        title: 'MindCare',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        home: const HomeShell(),
      ),
    );
  }
}
