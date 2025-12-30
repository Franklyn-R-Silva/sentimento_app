// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:sentimento_app/core/theme.dart';

/// MoodIndicator - Indicador circular de humor com porcentagem
class MoodIndicator extends StatelessWidget {
  final double value; // 0.0 to 1.0
  final double size;
  final double strokeWidth;
  final String? label;
  final int? moodLevel; // 1-5

  const MoodIndicator({
    super.key,
    required this.value,
    this.size = 80,
    this.strokeWidth = 8,
    this.label,
    this.moodLevel,
  });

  Color _getMoodColor(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);

    if (moodLevel == null) return theme.primary;

    switch (moodLevel) {
      case 1:
        return const Color(0xFFE53935);
      case 2:
        return const Color(0xFFFF9800);
      case 3:
        return const Color(0xFF2196F3);
      case 4:
        return const Color(0xFF4CAF50);
      case 5:
        return theme.primary;
      default:
        return theme.primary;
    }
  }

  String _getEmoji() {
    switch (moodLevel) {
      case 1:
        return '😢';
      case 2:
        return '😟';
      case 3:
        return '😐';
      case 4:
        return '🙂';
      case 5:
        return '😄';
      default:
        return '😐';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final color = _getMoodColor(context);

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background circle
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: 1,
              strokeWidth: strokeWidth,
              valueColor: AlwaysStoppedAnimation<Color>(
                theme.alternate.withValues(alpha: 0.3),
              ),
            ),
          ),
          // Progress circle
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: value,
              strokeWidth: strokeWidth,
              valueColor: AlwaysStoppedAnimation<Color>(color),
              strokeCap: StrokeCap.round,
            ),
          ),
          // Center content
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (moodLevel != null)
                Text(_getEmoji(), style: TextStyle(fontSize: size * 0.3)),
              if (label != null)
                Text(
                  label!,
                  style: theme.labelSmall.override(
                    color: theme.primaryText,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
