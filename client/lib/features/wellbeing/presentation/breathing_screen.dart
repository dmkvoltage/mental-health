import 'dart:async';

import 'package:flutter/material.dart';

import '../../../app/app_theme.dart';

class BreathingScreen extends StatefulWidget {
  const BreathingScreen({super.key});

  @override
  State<BreathingScreen> createState() => _BreathingScreenState();
}

class _BreathingScreenState extends State<BreathingScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _breathController = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 4),
  );

  Timer? _timer;
  int _secondsRemaining = 60;
  bool _isRunning = false;

  void _start() {
    setState(() {
      _isRunning = true;
      _secondsRemaining = 60;
    });
    _breathController.repeat(reverse: true);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining <= 1) {
        timer.cancel();
        _breathController.stop();
        setState(() {
          _secondsRemaining = 0;
          _isRunning = false;
        });
        return;
      }
      setState(() => _secondsRemaining -= 1);
    });
  }

  void _stop() {
    _timer?.cancel();
    _breathController.stop();
    setState(() => _isRunning = false);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _breathController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isComplete = _secondsRemaining == 0;

    return Scaffold(
      appBar: AppBar(title: const Text('Breathing space')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  isComplete
                      ? 'Well done for taking a moment.'
                      : 'There’s no rush. Just breathe at a pace that feels easy.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 42),
                AnimatedBuilder(
                  animation: _breathController,
                  builder: (context, child) {
                    final scale = _isRunning
                        ? 0.88 + (_breathController.value * 0.12)
                        : 1.0;
                    final instruction = !_isRunning
                        ? 'Ready when you are'
                        : _breathController.value < 0.5
                        ? 'Breathe in'
                        : 'Breathe out';
                    return Transform.scale(
                      scale: scale,
                      child: Container(
                        width: 220,
                        height: 220,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFFE8F0EB),
                          border: Border.all(
                            color: AppTheme.sage.withValues(alpha: 0.6),
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.sage.withValues(alpha: 0.2),
                              blurRadius: 28,
                              spreadRadius: 8,
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            instruction,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 34),
                Text(
                  _isRunning
                      ? '${_secondsRemaining ~/ 60}:${(_secondsRemaining % 60).toString().padLeft(2, '0')} remaining'
                      : isComplete
                      ? 'Take this calm with you.'
                      : 'A gentle one-minute reset',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 22),
                FilledButton(
                  onPressed: _isRunning ? _stop : _start,
                  child: Text(
                    _isRunning
                        ? 'Pause exercise'
                        : isComplete
                        ? 'Try again'
                        : 'Start exercise',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
