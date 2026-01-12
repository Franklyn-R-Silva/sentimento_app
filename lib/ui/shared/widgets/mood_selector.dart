// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:auto_size_text/auto_size_text.dart';
import 'package:logger/logger.dart';

// Project imports:
import 'package:sentimento_app/core/theme.dart';

/// MoodSelector - Seletor de humor com emojis animados
class MoodSelector extends StatelessWidget {
  final int selectedMood;
  final ValueChanged<int> onMoodSelected;
  final bool showLabels;

  const MoodSelector({
    super.key,
    required this.selectedMood,
    required this.onMoodSelected,
    this.showLabels = true,
  });

  static const List<String> _emojis = ['😢', '😟', '😐', '🙂', '😄'];
  static const List<String> _labels = [
    'Muito Triste',
    'Triste',
    'Neutro',
    'Feliz',
    'Muito Feliz',
  ];
  static const List<Color> _colors = [
    Color(0xFFE53935),
    Color(0xFFFF9800),
    Color(0xFF2196F3),
    Color(0xFF4CAF50),
    Color(0xFF7C4DFF),
  ];

  @override
  Widget build(BuildContext context) {
    Logger().t('MoodSelector: build called');
    final theme = FlutterFlowTheme.of(context);

    // Validate mood range (1-5)
    final safeMood = selectedMood.clamp(1, 5);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showLabels) ...[
          AutoSizeText(
            'Como você está se sentindo?',
            style: theme.titleMedium,
            minFontSize: 12,
          ),
          const SizedBox(height: 24),
        ],
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(5, (index) {
            final moodLevel = index + 1;
            final isSelected = safeMood == moodLevel;

            return GestureDetector(
              onTap: () => onMoodSelected(moodLevel),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isSelected
                      ? _colors[index].withValues(alpha: 0.2)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected
                        ? _colors[index]
                        : theme.alternate.withValues(alpha: 0.3),
                    width: 2,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: _colors[index].withValues(alpha: 0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : null,
                ),
                child: AnimatedScale(
                  scale: isSelected ? 1.2 : 1.0,
                  duration: const Duration(milliseconds: 200),
                  child: Text(
                    _emojis[index],
                    style: const TextStyle(fontSize: 32),
                  ),
                ),
              ),
            );
          }),
        ),
        if (showLabels) ...[
          const SizedBox(height: 16),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: AutoSizeText(
              _labels[safeMood - 1],
              key: ValueKey(safeMood),
              style: theme.labelLarge.override(
                color: _colors[safeMood - 1],
                fontWeight: FontWeight.w600,
              ),
              minFontSize: 10,
            ),
          ),
        ],
      ],
    );
  }
}
