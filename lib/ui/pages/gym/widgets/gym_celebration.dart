// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:sentimento_app/core/theme.dart';

/// A progress bar that shows workout completion with smooth animation
class GymProgressBar extends StatelessWidget {
  const GymProgressBar({
    super.key,
    required this.completed,
    required this.total,
  });

  final int completed;
  final int total;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final progress = total > 0 ? completed / total : 0.0;
    final isComplete = completed >= total && total > 0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Text(
                  isComplete ? '🎉 Treino Completo!' : 'Progresso',
                  key: ValueKey(isComplete),
                  style: theme.labelMedium.override(
                    fontFamily: 'Outfit',
                    color: isComplete ? Colors.green : theme.secondaryText,
                    fontWeight: isComplete
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              ),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Text(
                  '$completed / $total',
                  key: ValueKey('$completed/$total'),
                  style: theme.labelMedium.override(
                    fontFamily: 'Outfit',
                    fontWeight: FontWeight.bold,
                    color: isComplete ? Colors.green : theme.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeOutCubic,
              tween: Tween<double>(begin: 0, end: progress),
              builder: (context, value, child) {
                return LinearProgressIndicator(
                  value: value,
                  minHeight: 8,
                  backgroundColor: theme.alternate,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isComplete ? Colors.green : theme.primary,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// An animated celebration widget that shows when workout is complete
class GymCelebration extends StatefulWidget {
  const GymCelebration({
    super.key,
    required this.isComplete,
    required this.child,
  });

  final bool isComplete;
  final Widget child;

  @override
  State<GymCelebration> createState() => _GymCelebrationState();
}

class _GymCelebrationState extends State<GymCelebration>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _hasShownCelebration = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(GymCelebration oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isComplete && !_hasShownCelebration) {
      _controller.forward().then((_) => _controller.reverse());
      _hasShownCelebration = true;
      _showCelebrationSnackbar();
    } else if (!widget.isComplete) {
      _hasShownCelebration = false;
    }
  }

  void _showCelebrationSnackbar() {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Text('🎉', style: TextStyle(fontSize: 24)),
            SizedBox(width: 12),
            Text(
              'Parabéns! Treino concluído!',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(scale: _scaleAnimation, child: widget.child);
  }
}
