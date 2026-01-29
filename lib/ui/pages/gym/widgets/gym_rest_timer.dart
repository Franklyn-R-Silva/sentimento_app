import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sentimento_app/core/theme.dart';

/// A floating rest timer widget for gym workouts
class GymRestTimer extends StatefulWidget {
  const GymRestTimer({super.key, this.defaultSeconds = 60, this.onComplete});

  final int defaultSeconds;
  final VoidCallback? onComplete;

  @override
  State<GymRestTimer> createState() => _GymRestTimerState();
}

class _GymRestTimerState extends State<GymRestTimer>
    with SingleTickerProviderStateMixin {
  Timer? _timer;
  int _secondsRemaining = 0;
  bool _isRunning = false;
  late int _selectedDuration;

  // Preset durations in seconds
  final List<int> _presets = [30, 45, 60, 90, 120, 180];

  @override
  void initState() {
    super.initState();
    _selectedDuration = widget.defaultSeconds;
    _secondsRemaining = _selectedDuration;
  }

  @override
  void didUpdateWidget(GymRestTimer oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reset timer when defaultSeconds changes (e.g., when switching exercises)
    if (oldWidget.defaultSeconds != widget.defaultSeconds) {
      _stopTimer();
      setState(() {
        _selectedDuration = widget.defaultSeconds;
        _secondsRemaining = _selectedDuration;
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    if (_isRunning) return;
    setState(() {
      _isRunning = true;
      if (_secondsRemaining == 0) {
        _secondsRemaining = _selectedDuration;
      }
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() => _secondsRemaining--);
      } else {
        _stopTimer();
        widget.onComplete?.call();
        _showCompletionFeedback();
      }
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    setState(() => _isRunning = false);
  }

  void _resetTimer() {
    _stopTimer();
    setState(() => _secondsRemaining = _selectedDuration);
  }

  void _showCompletionFeedback() {
    if (!mounted) return;
    // Haptic feedback
    HapticFeedback.heavyImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 8),
            Text('Descanso concluído! 💪'),
          ],
        ),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }

  String _formatTime(int seconds) {
    final mins = seconds ~/ 60;
    final secs = seconds % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final progress = _selectedDuration > 0
        ? _secondsRemaining / _selectedDuration
        : 0.0;

    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: theme.secondaryBackground,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.timer, color: theme.primary, size: 24),
                const SizedBox(width: 8),
                Text(
                  'Descanso',
                  style: theme.titleMedium.override(
                    fontFamily: 'Outfit',
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Timer Display with Progress
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 120,
                  height: 120,
                  child: CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 8,
                    backgroundColor: theme.alternate,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _secondsRemaining <= 10 && _isRunning
                          ? Colors.red
                          : theme.primary,
                    ),
                  ),
                ),
                Text(
                  _formatTime(_secondsRemaining),
                  style: theme.displaySmall.override(
                    fontFamily: 'Outfit',
                    fontWeight: FontWeight.bold,
                    color: _secondsRemaining <= 10 && _isRunning
                        ? Colors.red
                        : theme.primaryText,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Control Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: _resetTimer,
                  icon: const Icon(Icons.refresh),
                  color: theme.secondaryText,
                  iconSize: 28,
                ),
                const SizedBox(width: 16),
                FloatingActionButton(
                  heroTag: 'timer_play_pause',
                  onPressed: _isRunning ? _stopTimer : _startTimer,
                  backgroundColor: _isRunning ? Colors.orange : theme.primary,
                  child: Icon(
                    _isRunning ? Icons.pause : Icons.play_arrow,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                IconButton(
                  onPressed: () {
                    setState(() {
                      _secondsRemaining = (_secondsRemaining + 15).clamp(
                        0,
                        600,
                      );
                    });
                  },
                  icon: const Icon(Icons.add),
                  color: theme.secondaryText,
                  iconSize: 28,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Preset Chips
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: _presets.map((seconds) {
                final isSelected = _selectedDuration == seconds;
                return ChoiceChip(
                  label: Text('${seconds}s'),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (!_isRunning && selected) {
                      setState(() {
                        _selectedDuration = seconds;
                        _secondsRemaining = seconds;
                      });
                    }
                  },
                  selectedColor: theme.primary.withOpacity(0.3),
                  labelStyle: TextStyle(
                    color: isSelected ? theme.primary : theme.secondaryText,
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

/// A compact floating button that expands to show the timer
class GymRestTimerFAB extends StatefulWidget {
  const GymRestTimerFAB({super.key});

  @override
  State<GymRestTimerFAB> createState() => _GymRestTimerFABState();
}

class _GymRestTimerFABState extends State<GymRestTimerFAB> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);

    if (_isExpanded) {
      return Stack(
        children: [
          // Dismiss overlay
          Positioned.fill(
            child: GestureDetector(
              onTap: () => setState(() => _isExpanded = false),
              child: Container(color: Colors.black54),
            ),
          ),
          // Timer card
          Positioned(
            bottom: 80,
            right: 16,
            child: GymRestTimer(
              onComplete: () {
                // Optionally collapse after completion
              },
            ),
          ),
          // Close button
          Positioned(
            bottom: 16,
            right: 16,
            child: FloatingActionButton(
              heroTag: 'timer_close',
              onPressed: () => setState(() => _isExpanded = false),
              backgroundColor: Colors.grey,
              child: const Icon(Icons.close, color: Colors.white),
            ),
          ),
        ],
      );
    }

    return FloatingActionButton(
      heroTag: 'timer_fab',
      onPressed: () => setState(() => _isExpanded = true),
      backgroundColor: theme.tertiary,
      child: const Icon(Icons.timer, color: Colors.white),
    );
  }
}
