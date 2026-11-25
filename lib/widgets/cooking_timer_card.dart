import 'dart:async';
import 'package:flutter/material.dart';

import '../services/language_service.dart';

class CookingTimerCard extends StatefulWidget {
  final int cookTimeMinutes;

  const CookingTimerCard({super.key, required this.cookTimeMinutes});

  @override
  State<CookingTimerCard> createState() => _CookingTimerCardState();
}

class _CookingTimerCardState extends State<CookingTimerCard> {
  Timer? _timer;
  late int _totalSeconds;
  late int _remainingSeconds;
  bool _isRunning = false;

  @override
  void initState() {
    super.initState();
    final minutes = widget.cookTimeMinutes > 0 ? widget.cookTimeMinutes : 5;
    _totalSeconds = minutes * 60;
    _remainingSeconds = _totalSeconds;
  }

  void _toggleTimer() {
    if (_isRunning) {
      _timer?.cancel();
      setState(() => _isRunning = false);
    } else {
      if (_remainingSeconds == 0) _resetTimer();
      setState(() => _isRunning = true);
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (_remainingSeconds > 0) {
          setState(() => _remainingSeconds--);
        } else {
          timer.cancel();
          setState(() => _isRunning = false);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  LanguageService.tr(
                    'Waktu memasak selesai! Cek hidanganmu.',
                    "Time's up! Check your dish.",
                  ),
                ),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        }
      });
    }
  }

  void _resetTimer() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      _remainingSeconds = _totalSeconds;
    });
  }

  void _addOneMinute() {
    setState(() {
      _totalSeconds += 60;
      _remainingSeconds += 60;
    });
  }

  String _formatTime(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final progress =
    _totalSeconds > 0 ? _remainingSeconds / _totalSeconds : 0.0;

    return Card(
      elevation: 0,
      color: colors.surfaceContainerHighest.withValues(alpha: 0.5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.timer_outlined, color: colors.primary),
                    const SizedBox(width: 8),
                    Text(
                      context.tr('Timer Memasak', 'Cooking Timer'),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Text(
                  _formatTime(_remainingSeconds),
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(value: progress, minHeight: 6),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                FilledButton.icon(
                  onPressed: _toggleTimer,
                  icon: Icon(_isRunning ? Icons.pause : Icons.play_arrow),
                  label: Text(
                    _isRunning
                        ? context.tr('Jeda', 'Pause')
                        : context.tr('Mulai', 'Start'),
                  ),
                ),
                const SizedBox(width: 8),
                OutlinedButton(
                  onPressed: _resetTimer,
                  child: Text(context.tr('Reset', 'Reset')),
                ),
                const Spacer(),
                TextButton(
                  onPressed: _addOneMinute,
                  child: Text(context.tr('+1 Mnt', '+1 Min')),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}