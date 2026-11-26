import 'package:flutter/material.dart';

import '../../../../app/app_theme.dart';
import '../../domain/chat_message.dart';

class ChatMessageBubble extends StatelessWidget {
  const ChatMessageBubble({required this.message, super.key});

  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Row(
        mainAxisAlignment: isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            const CircleAvatar(
              radius: 17,
              backgroundColor: AppTheme.lavender,
              child: Icon(Icons.spa_rounded, size: 18, color: AppTheme.forest),
            ),
            const SizedBox(width: 9),
          ],
          Flexible(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Column(
                crossAxisAlignment: isUser
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 13,
                    ),
                    decoration: BoxDecoration(
                      color: isUser ? AppTheme.forest : Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(20),
                        topRight: const Radius.circular(20),
                        bottomLeft: Radius.circular(isUser ? 20 : 5),
                        bottomRight: Radius.circular(isUser ? 5 : 20),
                      ),
                      border: isUser
                          ? null
                          : Border.all(color: const Color(0xFFE8ECE9)),
                    ),
                    child: Text(
                      message.text,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: isUser ? Colors.white : AppTheme.ink,
                      ),
                    ),
                  ),
                  if (message.sources.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: message.sources.map((source) {
                        final label = source.page == null
                            ? source.name
                            : '${source.name}, p. ${source.page}';
                        return Chip(
                          avatar: const Icon(
                            Icons.menu_book_outlined,
                            size: 16,
                          ),
                          label: Text(label),
                          visualDensity: VisualDensity.compact,
                          backgroundColor: Colors.white,
                          side: BorderSide(color: colorScheme.outlineVariant),
                          labelStyle: Theme.of(context).textTheme.labelSmall,
                        );
                      }).toList(),
                    ),
                  ],
                  if (message.safetyNotice) ...[
                    const SizedBox(height: 10),
                    _SafetyNotice(),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SafetyNotice extends StatelessWidget {
  const _SafetyNotice();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3E8),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFEAC9A8)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.health_and_safety_outlined,
            color: Color(0xFF81521E),
            size: 20,
          ),
          SizedBox(width: 9),
          Expanded(
            child: Text(
              'If you may be in immediate danger, contact your local emergency '
              'services or go to the nearest emergency department. MindCare '
              'is not an emergency service.',
              style: TextStyle(
                color: Color(0xFF62451F),
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
