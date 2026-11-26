import 'package:flutter/material.dart';

import '../../../app/app_theme.dart';

class GroundingScreen extends StatelessWidget {
  const GroundingScreen({super.key});

  static const steps = [
    ('5', 'things you can see', Icons.visibility_outlined),
    ('4', 'things you can feel', Icons.back_hand_outlined),
    ('3', 'things you can hear', Icons.hearing_outlined),
    ('2', 'things you can smell', Icons.air_outlined),
    ('1', 'thing you can taste', Icons.restaurant_outlined),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Grounding exercise')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 620),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
            children: [
              Text(
                'Notice what’s around you.',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                'If it feels comfortable, take your time with each prompt. You '
                'can skip any step.',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 22),
              for (final step in steps) ...[
                Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 17,
                    vertical: 15,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: const Color(0xFFE8ECE9)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE9F2ED),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(step.$3, color: AppTheme.forest, size: 21),
                      ),
                      const SizedBox(width: 13),
                      Text(
                        step.$1,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppTheme.forest,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          step.$2,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 10),
              const Text(
                'This is a simple reflection exercise, not medical treatment. '
                'Stop if it doesn’t feel right for you.',
                style: TextStyle(
                  color: AppTheme.mutedInk,
                  fontSize: 13,
                  height: 1.45,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
