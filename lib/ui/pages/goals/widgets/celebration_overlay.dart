import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Overlay de celebração com partículas animadas
class CelebrationOverlay extends StatefulWidget {
  final String emoji;
  final VoidCallback? onComplete;

  const CelebrationOverlay({super.key, required this.emoji, this.onComplete});

  @override
  State<CelebrationOverlay> createState() => _CelebrationOverlayState();
}

class _CelebrationOverlayState extends State<CelebrationOverlay>
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _particleController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _rotationAnimation;
  final List<_Particle> _particles = [];
  final math.Random _random = math.Random();

  @override
  void initState() {
    super.initState();

    // Main emoji animation
    _mainController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 0,
          end: 1.3,
        ).chain(CurveTween(curve: Curves.elasticOut)),
        weight: 60,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.3,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 40,
      ),
    ]).animate(_mainController);

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0, 0.3, curve: Curves.easeIn),
      ),
    );

    _rotationAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(
          begin: -0.1,
          end: 0.1,
        ).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 25,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 0.1,
          end: -0.05,
        ).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 25,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: -0.05,
          end: 0,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 50,
      ),
    ]).animate(_mainController);

    // Particle animation
    _particleController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    // Generate particles
    _generateParticles();

    // Start animations
    _mainController.forward();
    _particleController.forward();

    _mainController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Future.delayed(const Duration(milliseconds: 500), () {
          widget.onComplete?.call();
        });
      }
    });
  }

  void _generateParticles() {
    final colors = [
      const Color(0xFFFFD700), // Gold
      const Color(0xFFFF6B6B), // Red
      const Color(0xFF4ECDC4), // Teal
      const Color(0xFFAB83A1), // Purple
      const Color(0xFFFFE66D), // Yellow
      const Color(0xFF7C4DFF), // Primary purple
      const Color(0xFF00D9FF), // Cyan
    ];

    for (int i = 0; i < 30; i++) {
      _particles.add(
        _Particle(
          x: 0.5,
          y: 0.5,
          vx: (_random.nextDouble() - 0.5) * 2,
          vy: -_random.nextDouble() * 2 - 1,
          color: colors[_random.nextInt(colors.length)],
          size: _random.nextDouble() * 8 + 4,
          rotation: _random.nextDouble() * math.pi * 2,
          rotationSpeed: (_random.nextDouble() - 0.5) * 0.3,
          shape: _ParticleShape
              .values[_random.nextInt(_ParticleShape.values.length)],
        ),
      );
    }
  }

  @override
  void dispose() {
    _mainController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          // Backdrop with blur
          AnimatedBuilder(
            animation: _fadeAnimation,
            builder: (context, child) {
              return Container(
                color: Colors.black.withValues(
                  alpha: 0.3 * _fadeAnimation.value,
                ),
              );
            },
          ),

          // Particles
          AnimatedBuilder(
            animation: _particleController,
            builder: (context, child) {
              return CustomPaint(
                painter: _ParticlePainter(
                  particles: _particles,
                  progress: _particleController.value,
                ),
                size: Size.infinite,
              );
            },
          ),

          // Main emoji
          Center(
            child: AnimatedBuilder(
              animation: _mainController,
              builder: (context, child) {
                return Opacity(
                  opacity: _fadeAnimation.value,
                  child: Transform.scale(
                    scale: _scaleAnimation.value,
                    child: Transform.rotate(
                      angle: _rotationAnimation.value,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Glow behind emoji
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFFFD700).withValues(
                                    alpha: 0.5 * _fadeAnimation.value,
                                  ),
                                  blurRadius: 40,
                                  spreadRadius: 10,
                                ),
                              ],
                            ),
                            child: Text(
                              widget.emoji,
                              style: const TextStyle(fontSize: 80),
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Congratulations text with shimmer
                          ShaderMask(
                            shaderCallback: (bounds) {
                              return LinearGradient(
                                colors: const [
                                  Color(0xFFFFD700),
                                  Color(0xFFFFFFFF),
                                  Color(0xFFFFD700),
                                ],
                                stops: [
                                  (_mainController.value - 0.3).clamp(0.0, 1.0),
                                  _mainController.value.clamp(0.0, 1.0),
                                  (_mainController.value + 0.3).clamp(0.0, 1.0),
                                ],
                              ).createShader(bounds);
                            },
                            child: const Text(
                              'META CONCLUÍDA!',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 2,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
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

enum _ParticleShape { circle, square, star, confetti }

class _Particle {
  double x, y;
  double vx, vy;
  final Color color;
  final double size;
  double rotation;
  final double rotationSpeed;
  final _ParticleShape shape;

  _Particle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.color,
    required this.size,
    required this.rotation,
    required this.rotationSpeed,
    required this.shape,
  });
}

class _ParticlePainter extends CustomPainter {
  final List<_Particle> particles;
  final double progress;

  _ParticlePainter({required this.particles, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    for (var particle in particles) {
      const gravity = 0.05;

      // Update position based on progress
      final t = progress;
      final x = size.width * particle.x + particle.vx * t * size.width * 0.5;
      final y =
          size.height * particle.y +
          particle.vy * t * size.height * 0.3 +
          gravity * t * t * size.height * 0.5;

      // Fade out
      final alpha = (1 - t).clamp(0.0, 1.0);

      if (alpha <= 0) continue;

      final paint = Paint()
        ..color = particle.color.withValues(alpha: alpha)
        ..style = PaintingStyle.fill;

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(particle.rotation + particle.rotationSpeed * t * 10);

      switch (particle.shape) {
        case _ParticleShape.circle:
          canvas.drawCircle(Offset.zero, particle.size / 2, paint);
          break;
        case _ParticleShape.square:
          canvas.drawRect(
            Rect.fromCenter(
              center: Offset.zero,
              width: particle.size,
              height: particle.size,
            ),
            paint,
          );
          break;
        case _ParticleShape.star:
          _drawStar(canvas, particle.size / 2, paint);
          break;
        case _ParticleShape.confetti:
          canvas.drawRect(
            Rect.fromCenter(
              center: Offset.zero,
              width: particle.size,
              height: particle.size / 3,
            ),
            paint,
          );
          break;
      }

      canvas.restore();
    }
  }

  void _drawStar(Canvas canvas, double radius, Paint paint) {
    final path = Path();
    const angle = math.pi / 5;

    for (int i = 0; i < 10; i++) {
      final r = i.isEven ? radius : radius * 0.5;
      final x = r * math.cos(i * angle - math.pi / 2);
      final y = r * math.sin(i * angle - math.pi / 2);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_ParticlePainter oldDelegate) =>
      oldDelegate.progress != progress;
}
