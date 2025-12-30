// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:sentimento_app/core/theme.dart';

class BreathingExerciseSheet extends StatefulWidget {
  final FlutterFlowTheme theme;

  const BreathingExerciseSheet({super.key, required this.theme});

  @override
  State<BreathingExerciseSheet> createState() => _BreathingExerciseSheetState();
}

class _BreathingExerciseSheetState extends State<BreathingExerciseSheet>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  String _instruction = 'Inspire';
  bool _isRunning = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );
    _animation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() => _instruction = 'Expire');
        _controller.reverse();
      } else if (status == AnimationStatus.dismissed) {
        setState(() => _instruction = 'Inspire');
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleExercise() {
    setState(() {
      _isRunning = !_isRunning;
      if (_isRunning) {
        _controller.forward();
      } else {
        _controller.stop();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme;

    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: theme.primaryBackground,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: theme.alternate,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          Text('Exercício de Respiração', style: theme.headlineSmall),
          const SizedBox(height: 8),
          Text(
            'Relaxe e siga o ritmo',
            style: theme.bodyMedium.override(color: theme.secondaryText),
          ),
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedBuilder(
                    animation: _animation,
                    builder: (context, child) {
                      return Container(
                        width: 200 * _animation.value,
                        height: 200 * _animation.value,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              theme.primary.withValues(alpha: 0.6),
                              theme.secondary.withValues(alpha: 0.4),
                              theme.tertiary.withValues(alpha: 0.2),
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: theme.primary.withValues(alpha: 0.3),
                              blurRadius: 30,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            _isRunning ? _instruction : 'Toque para iniciar',
                            textAlign: TextAlign.center,
                            style: theme.titleMedium.override(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _toggleExercise,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isRunning ? theme.error : theme.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                icon: Icon(
                  _isRunning ? Icons.stop_rounded : Icons.play_arrow_rounded,
                  color: Colors.white,
                ),
                label: Text(
                  _isRunning ? 'Parar' : 'Começar',
                  style: theme.titleSmall.override(color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
