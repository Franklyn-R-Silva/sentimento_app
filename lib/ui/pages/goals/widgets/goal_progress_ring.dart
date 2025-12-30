// Dart imports:
import 'dart:math' as math;

// Flutter imports:
import 'package:flutter/material.dart';

/// Widget de ring de progresso animado com gradiente
class GoalProgressRing extends StatefulWidget {
  final double progress;
  final double size;
  final double strokeWidth;
  final Color primaryColor;
  final Color? secondaryColor;
  final Widget? child;
  final Duration animationDuration;

  const GoalProgressRing({
    super.key,
    required this.progress,
    this.size = 80,
    this.strokeWidth = 8,
    required this.primaryColor,
    this.secondaryColor,
    this.child,
    this.animationDuration = const Duration(milliseconds: 1200),
  });

  @override
  State<GoalProgressRing> createState() => _GoalProgressRingState();
}

class _GoalProgressRingState extends State<GoalProgressRing>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  double _previousProgress = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    );
    _animation = Tween<double>(
      begin: 0,
      end: widget.progress,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _controller.forward();
  }

  @override
  void didUpdateWidget(GoalProgressRing oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.progress != widget.progress) {
      _previousProgress = _animation.value;
      _animation = Tween<double>(begin: _previousProgress, end: widget.progress)
          .animate(
            CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
          );
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return SizedBox(
          width: widget.size,
          height: widget.size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Background ring
              CustomPaint(
                size: Size(widget.size, widget.size),
                painter: _RingPainter(
                  progress: 1.0,
                  strokeWidth: widget.strokeWidth,
                  color: widget.primaryColor.withValues(alpha: 0.2),
                ),
              ),
              // Foreground animated ring with gradient
              CustomPaint(
                size: Size(widget.size, widget.size),
                painter: _GradientRingPainter(
                  progress: _animation.value,
                  strokeWidth: widget.strokeWidth,
                  primaryColor: widget.primaryColor,
                  secondaryColor:
                      widget.secondaryColor ??
                      widget.primaryColor.withValues(alpha: 0.5),
                ),
              ),
              // Glow effect at the end
              if (_animation.value > 0.1)
                CustomPaint(
                  size: Size(widget.size, widget.size),
                  painter: _GlowPainter(
                    progress: _animation.value,
                    strokeWidth: widget.strokeWidth,
                    color: widget.primaryColor,
                    size: widget.size,
                  ),
                ),
              // Child widget (usually emoji or percentage)
              if (widget.child != null) widget.child!,
            ],
          ),
        );
      },
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  final double strokeWidth;
  final Color color;

  _RingPainter({
    required this.progress,
    required this.strokeWidth,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(_RingPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.color != color;
}

class _GradientRingPainter extends CustomPainter {
  final double progress;
  final double strokeWidth;
  final Color primaryColor;
  final Color secondaryColor;

  _GradientRingPainter({
    required this.progress,
    required this.strokeWidth,
    required this.primaryColor,
    required this.secondaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    final gradient = SweepGradient(
      startAngle: -math.pi / 2,
      endAngle: 3 * math.pi / 2,
      colors: [primaryColor, secondaryColor, primaryColor],
      stops: const [0.0, 0.5, 1.0],
    );

    final rect = Rect.fromCircle(center: center, radius: radius);

    final paint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(rect, -math.pi / 2, 2 * math.pi * progress, false, paint);
  }

  @override
  bool shouldRepaint(_GradientRingPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.primaryColor != primaryColor;
}

class _GlowPainter extends CustomPainter {
  final double progress;
  final double strokeWidth;
  final Color color;
  final double size;

  _GlowPainter({
    required this.progress,
    required this.strokeWidth,
    required this.color,
    required this.size,
  });

  @override
  void paint(Canvas canvas, Size canvasSize) {
    if (progress <= 0) return;

    final center = Offset(canvasSize.width / 2, canvasSize.height / 2);
    final radius = (canvasSize.width - strokeWidth) / 2;

    // Calculate the end point of the arc
    final angle = -math.pi / 2 + 2 * math.pi * progress;
    final endPoint = Offset(
      center.dx + radius * math.cos(angle),
      center.dy + radius * math.sin(angle),
    );

    // Draw glow
    final glowPaint = Paint()
      ..color = color.withValues(alpha: 0.6)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    canvas.drawCircle(endPoint, strokeWidth / 2 + 4, glowPaint);

    // Draw bright dot
    final dotPaint = Paint()..color = Colors.white;
    canvas.drawCircle(endPoint, strokeWidth / 3, dotPaint);
  }

  @override
  bool shouldRepaint(_GlowPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
