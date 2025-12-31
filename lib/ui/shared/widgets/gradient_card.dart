// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:sentimento_app/core/theme.dart';

/// GradientCard - Card com gradiente baseado no nível de humor
class GradientCard extends StatelessWidget {
  final Widget child;
  final int? moodLevel; // 1-5, null para gradiente padrão
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final VoidCallback? onTap;

  const GradientCard({
    super.key,
    required this.child,
    this.moodLevel,
    this.padding,
    this.margin,
    this.borderRadius = 16,
    this.onTap,
  });

  List<Color> _getGradientColors(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);

    if (moodLevel == null) {
      return [
        theme.primary.withValues(alpha: 0.8),
        theme.secondary.withValues(alpha: 0.8),
      ];
    }

    switch (moodLevel) {
      case 1: // Muito triste - Error Color
        return [
          theme.error.withValues(alpha: 0.9),
          theme.error.withValues(alpha: 0.7),
        ];
      case 2: // Triste - Warning/Alternate
        return [
          theme.warning.withValues(alpha: 0.9),
          theme.warning.withValues(alpha: 0.7),
        ];
      case 3: // Neutro - Secondary/Accent
        return [
          theme.secondary.withValues(alpha: 0.9),
          theme.secondary.withValues(alpha: 0.7),
        ];
      case 4: // Feliz - Primary
        return [
          theme.primary.withValues(alpha: 0.9),
          theme.primary.withValues(alpha: 0.7),
        ];
      case 5: // Muito feliz - Success/Tertiary
        return [
          theme.success.withValues(alpha: 0.9),
          theme.success.withValues(alpha: 0.7),
        ];
      default:
        return [
          theme.primary.withValues(alpha: 0.8),
          theme.secondary.withValues(alpha: 0.8),
        ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);

    return Container(
      margin: margin ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: _getGradientColors(context),
        ),
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: theme.alternate.withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.primary.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(borderRadius),
          child: Padding(
            padding: padding ?? const EdgeInsets.all(16),
            child: child,
          ),
        ),
      ),
    );
  }
}
