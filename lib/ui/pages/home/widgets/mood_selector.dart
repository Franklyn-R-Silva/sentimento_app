// Flutter imports:
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

// Project imports:
import 'package:sentimento_app/core/theme.dart';

/// MoodSelector - Seletor de humor com emojis animados
class MoodSelector extends StatelessWidget {
  final int selectedMood;
  final ValueChanged<int> onMoodSelected;

  const MoodSelector({
    super.key,
    required this.selectedMood,
    required this.onMoodSelected,
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
    final theme = FlutterFlowTheme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AutoSizeText(
          'Como você está se sentindo?',
          style: theme.titleMedium,
          minFontSize: 12,
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(5, (index) {
            final moodLevel = index + 1;
            final isSelected = selectedMood == moodLevel;

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
        const SizedBox(height: 16),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: AutoSizeText(
            _labels[selectedMood - 1],
            key: ValueKey(selectedMood),
            style: theme.labelLarge.override(
              color: _colors[selectedMood - 1],
              fontWeight: FontWeight.w600,
            ),
            minFontSize: 10,
          ),
        ),
      ],
    );
  }
}
