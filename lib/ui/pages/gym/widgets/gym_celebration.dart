// Dart imports:
import 'dart:math';

// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:sentimento_app/core/theme.dart';

/// A premium progress bar with gradient and animation
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
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.primaryText.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Text(
                  isComplete ? '🎉 Treino Concluído!' : 'Seu Progresso',
                  key: ValueKey(isComplete),
                  style: theme.titleSmall.override(
                    fontFamily: 'Outfit',
                    color: isComplete ? Colors.green : theme.secondaryText,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: isComplete
                      ? Colors.green.withValues(alpha: 0.1)
                      : theme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$completed / $total',
                  style: theme.labelMedium.override(
                    fontFamily: 'Outfit',
                    fontWeight: FontWeight.bold,
                    color: isComplete ? Colors.green : theme.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            height: 12,
            decoration: BoxDecoration(
              color: theme.alternate,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Stack(
              children: [
                LayoutBuilder(
                  builder: (context, constraints) {
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 800),
                      curve: Curves.fastOutSlowIn,
                      width: constraints.maxWidth * progress,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6),
                        gradient: LinearGradient(
                          colors: isComplete
                              ? [Colors.greenAccent, Colors.green]
                              : [theme.primary, theme.tertiary],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: isComplete
                                ? Colors.green.withValues(alpha: 0.4)
                                : theme.primary.withValues(alpha: 0.4),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// An animated celebration widget that overlays confetti
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
  final List<_ConfettiParticle> _particles = [];
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _controller.addListener(() {
      setState(() {
        for (final particle in _particles) {
          particle.update();
        }
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(GymCelebration oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isComplete && !oldWidget.isComplete) {
      _startCelebration();
    }
  }

  void _startCelebration() {
    setState(() {
      _isPlaying = true;
      _particles.clear();
      for (int i = 0; i < 50; i++) {
        _particles.add(_ConfettiParticle());
      }
    });
    _controller.forward(from: 0).then((_) {
      setState(() => _isPlaying = false);
    });

    // Also show snackbar
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Text('🏆', style: TextStyle(fontSize: 24)),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Parabéns!',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text('Você concluiu seu treino.'),
                  ],
                ),
              ),
            ],
          ),
          backgroundColor: Colors.green.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (_isPlaying)
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(painter: _ConfettiPainter(_particles)),
            ),
          ),
      ],
    );
  }
}

class _ConfettiParticle {
  _ConfettiParticle() {
    final random = Random();
    x = random.nextDouble();
    y = -0.1; // Start above screen
    size = random.nextDouble() * 8 + 4;
    color = Colors.primaries[random.nextInt(Colors.primaries.length)];
    speed = random.nextDouble() * 0.02 + 0.01;
    angle = random.nextDouble() * pi;
    rotationSpeed = (random.nextDouble() - 0.5) * 0.2;
  }

  late double x;
  late double y;
  late double size;
  late Color color;
  late double speed;
  late double angle;
  late double rotationSpeed;

  void update() {
    y += speed;
    angle += rotationSpeed;
    x += sin(angle) * 0.002;
  }
}

class _ConfettiPainter extends CustomPainter {
  _ConfettiPainter(this.particles);

  final List<_ConfettiParticle> particles;

  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in particles) {
      final paint = Paint()..color = particle.color;
      final dx = particle.x * size.width;
      final dy = particle.y * size.height;

      canvas.save();
      canvas.translate(dx, dy);
      canvas.rotate(particle.angle);

      // Draw a simple rectangle (confetti piece)
      canvas.drawRect(
        Rect.fromCenter(
          center: Offset.zero,
          width: particle.size,
          height: particle.size / 2,
        ),
        paint,
      );

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
