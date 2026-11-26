import 'package:flutter/material.dart';

import '../../../app/app_theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    required this.onOpenChat,
    required this.onOpenTools,
    super.key,
  });

  final VoidCallback onOpenChat;
  final VoidCallback onOpenTools;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? _selectedMood;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 26),
                sliver: SliverList.list(
                  children: [
                    const _HomeHeader(),
                    const SizedBox(height: 24),
                    _WelcomeCard(onOpenChat: widget.onOpenChat),
                    const SizedBox(height: 25),
                    _SectionHeading(
                      title: 'A moment for you',
                      subtitle:
                          'A small check-in can help you notice how you feel.',
                    ),
                    const SizedBox(height: 12),
                    _MoodCheckIn(
                      selectedMood: _selectedMood,
                      onSelected: (mood) {
                        setState(() => _selectedMood = mood);
                      },
                    ),
                    const SizedBox(height: 24),
                    _SectionHeading(
                      title: 'Gentle ways to reset',
                      actionLabel: 'See all',
                      onAction: widget.onOpenTools,
                    ),
                    const SizedBox(height: 12),
                    _BreathingCard(onTap: widget.onOpenTools),
                    const SizedBox(height: 22),
                    const _CareNote(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: AppTheme.forest,
            borderRadius: BorderRadius.circular(15),
          ),
          child: const Icon(Icons.spa_rounded, color: Colors.white, size: 23),
        ),
        const SizedBox(width: 11),
        Text('MindCare', style: Theme.of(context).textTheme.titleLarge),
        const Spacer(),
        const CircleAvatar(
          radius: 20,
          backgroundColor: Color(0xFFE8EFEB),
          child: Icon(Icons.favorite_border_rounded, color: AppTheme.forest),
        ),
      ],
    );
  }
}

class _WelcomeCard extends StatelessWidget {
  const _WelcomeCard({required this.onOpenChat});

  final VoidCallback onOpenChat;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF315D56), Color(0xFF547C6D)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(26),
      ),
      child: Stack(
        children: [
          const Positioned(
            right: -14,
            top: -18,
            child: Icon(
              Icons.spa_outlined,
              size: 128,
              color: Color(0x22FFFFFF),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 11,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Text(
                  'YOUR WELLBEING MATTERS',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.1,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'A little space for\nhow you feel.',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  fontSize: 30,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Take a breath, reflect, or talk things through at your own pace.',
                style: TextStyle(
                  color: Color(0xFFE8F0EC),
                  fontSize: 15,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: onOpenChat,
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppTheme.forest,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 17,
                    vertical: 13,
                  ),
                ),
                icon: const Icon(Icons.chat_bubble_outline_rounded, size: 19),
                label: const Text('Start a conversation'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleLarge),
              if (subtitle != null) ...[
                const SizedBox(height: 4),
                Text(subtitle!, style: Theme.of(context).textTheme.bodyMedium),
              ],
            ],
          ),
        ),
        if (actionLabel != null)
          TextButton(onPressed: onAction, child: Text(actionLabel!)),
      ],
    );
  }
}

class _MoodCheckIn extends StatelessWidget {
  const _MoodCheckIn({required this.selectedMood, required this.onSelected});

  final String? selectedMood;
  final ValueChanged<String> onSelected;

  static const moods = [
    ('Low', Icons.sentiment_dissatisfied_outlined),
    ('Okay', Icons.sentiment_neutral_outlined),
    ('Good', Icons.sentiment_satisfied_outlined),
    ('Great', Icons.sentiment_very_satisfied_outlined),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE8ECE9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'How are you feeling right now?',
            style: TextStyle(
              color: AppTheme.ink,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 9,
            runSpacing: 9,
            children: moods.map((mood) {
              final isSelected = selectedMood == mood.$1;
              return ChoiceChip(
                avatar: Icon(
                  mood.$2,
                  size: 19,
                  color: isSelected ? Colors.white : AppTheme.forest,
                ),
                label: Text(mood.$1),
                selected: isSelected,
                onSelected: (_) => onSelected(mood.$1),
                selectedColor: AppTheme.forest,
                backgroundColor: AppTheme.paper,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : AppTheme.ink,
                  fontWeight: FontWeight.w600,
                ),
                side: BorderSide(
                  color: isSelected ? AppTheme.forest : const Color(0xFFE3E9E5),
                ),
              );
            }).toList(),
          ),
          if (selectedMood != null) ...[
            const SizedBox(height: 12),
            Text(
              'Thank you for checking in. There’s no right or wrong way to feel.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ],
      ),
    );
  }
}

class _BreathingCard extends StatelessWidget {
  const _BreathingCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFF0EFF8),
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Padding(
          padding: const EdgeInsets.all(17),
          child: Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(
                  Icons.air_rounded,
                  color: Color(0xFF5E5B8C),
                  size: 28,
                ),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'One-minute breathing space',
                      style: TextStyle(
                        color: AppTheme.ink,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'A gentle pause, whenever you need one.',
                      style: TextStyle(
                        color: AppTheme.mutedInk,
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _CareNote extends StatelessWidget {
  const _CareNote();

  @override
  Widget build(BuildContext context) {
    return const Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.info_outline_rounded, size: 18, color: AppTheme.mutedInk),
        SizedBox(width: 9),
        Expanded(
          child: Text(
            'MindCare offers supportive conversation and general wellbeing '
            'information. It does not diagnose or replace professional care.',
            style: TextStyle(
              color: AppTheme.mutedInk,
              fontSize: 12,
              height: 1.45,
            ),
          ),
        ),
      ],
    );
  }
}
