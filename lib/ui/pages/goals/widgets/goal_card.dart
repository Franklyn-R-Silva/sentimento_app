// Dart imports:
import 'dart:ui';

// Flutter imports:
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

// Project imports:
import 'package:sentimento_app/backend/tables/metas.dart';
import 'package:sentimento_app/core/theme.dart';
import 'goal_progress_ring.dart';

/// Card de meta com glassmorphism e animações
class GoalCard extends StatefulWidget {
  final MetasRow meta;
  final VoidCallback? onTap;
  final VoidCallback? onIncrement;
  final VoidCallback? onDelete;
  final int index;
  final bool hasCheckedInToday;
  final int currentStreak;

  const GoalCard({
    super.key,
    required this.meta,
    this.onTap,
    this.onIncrement,
    this.onDelete,
    this.index = 0,
    this.hasCheckedInToday = false,
    this.currentStreak = 0,
  });

  @override
  State<GoalCard> createState() => _GoalCardState();
}

class _GoalCardState extends State<GoalCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  late Animation<Offset> _slideAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.8, curve: Curves.easeOutBack),
      ),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _controller,
            curve: const Interval(0.0, 0.8, curve: Curves.easeOutCubic),
          ),
        );

    // Staggered animation based on index
    Future.delayed(Duration(milliseconds: widget.index * 100), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _parseColor(String hexColor) {
    try {
      return Color(int.parse(hexColor.replaceFirst('#', '0xFF')));
    } catch (e) {
      return const Color(0xFF7C4DFF);
    }
  }

  String _getFrequencyLabel(String frequencia) {
    switch (frequencia) {
      case 'diaria':
        return 'Diária';
      case 'semanal':
        return 'Semanal';
      case 'mensal':
        return 'Mensal';
      default:
        return frequencia;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final color = _parseColor(widget.meta.cor);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _opacityAnimation.value,
          child: SlideTransition(
            position: _slideAnimation,
            child: ScaleTransition(scale: _scaleAnimation, child: child),
          ),
        );
      },
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: _isPressed ? 0.98 : 1.0,
          duration: const Duration(milliseconds: 100),
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        isDark
                            ? color.withValues(alpha: 0.15)
                            : color.withValues(alpha: 0.1),
                        isDark
                            ? theme.secondaryBackground.withValues(alpha: 0.8)
                            : Colors.white.withValues(alpha: 0.9),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: color.withValues(alpha: 0.3),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: color.withValues(alpha: 0.2),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Progress Ring
                      GoalProgressRing(
                        progress: widget.meta.progresso,
                        size: 72,
                        strokeWidth: 6,
                        primaryColor: color,
                        secondaryColor: color.withValues(alpha: 0.5),
                        child: Text(
                          widget.meta.icone,
                          style: const TextStyle(fontSize: 28),
                        ),
                      ),

                      const SizedBox(width: 16),

                      // Content
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.meta.titulo,
                              style: theme.titleMedium.override(
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            if (widget.meta.descricao != null &&
                                widget.meta.descricao!.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Text(
                                  widget.meta.descricao!,
                                  style: theme.bodySmall.override(
                                    color: theme.secondaryText,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            Row(
                              children: [
                                // Progress text
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: color.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: AutoSizeText(
                                    '${widget.meta.valorAtual}/${widget.meta.metaValor}',
                                    style: theme.labelSmall.override(
                                      color: color,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    minFontSize: 8,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                // Streak badge
                                if (widget.currentStreak > 0)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: theme.warning.withValues(
                                        alpha: 0.2,
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Text(
                                          '🔥',
                                          style: TextStyle(fontSize: 10),
                                        ),
                                        const SizedBox(width: 4),
                                        AutoSizeText(
                                          '${widget.currentStreak}',
                                          style: theme.labelSmall.override(
                                            color: theme.warning,
                                            fontWeight: FontWeight.w600,
                                          ),
                                          minFontSize: 8,
                                        ),
                                      ],
                                    ),
                                  ),
                                if (widget.currentStreak > 0)
                                  const SizedBox(width: 8),
                                // Frequency badge
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: theme.alternate.withValues(
                                      alpha: 0.5,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: AutoSizeText(
                                    _getFrequencyLabel(widget.meta.frequencia),
                                    style: theme.labelSmall.override(
                                      color: theme.secondaryText,
                                    ),
                                    minFontSize: 8,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Increment button (disabled if already checked in today)
                      if (!widget.meta.concluido && widget.onIncrement != null)
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: widget.hasCheckedInToday
                                ? null
                                : widget.onIncrement,
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                gradient: widget.hasCheckedInToday
                                    ? null
                                    : LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          color,
                                          color.withValues(alpha: 0.8),
                                        ],
                                      ),
                                color: widget.hasCheckedInToday
                                    ? theme.success.withValues(alpha: 0.2)
                                    : null,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: widget.hasCheckedInToday
                                    ? null
                                    : [
                                        BoxShadow(
                                          color: color.withValues(alpha: 0.4),
                                          blurRadius: 12,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                              ),
                              child: Icon(
                                widget.hasCheckedInToday
                                    ? Icons.check_rounded
                                    : Icons.add_rounded,
                                color: widget.hasCheckedInToday
                                    ? theme.success
                                    : Colors.white,
                                size: 24,
                              ),
                            ),
                          ),
                        ),

                      // Completed badge
                      if (widget.meta.concluido)
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: theme.success.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(
                            Icons.check_rounded,
                            color: theme.success,
                            size: 24,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
