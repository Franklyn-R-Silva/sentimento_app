// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:

import 'package:logger/logger.dart';

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
    Logger().t('MoodSelector: build called');
    final theme = FlutterFlowTheme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Como você está se sentindo?',
          style: theme.titleMedium.override(
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(5, (index) {
            final moodLevel = index + 1;
            final isSelected = selectedMood == moodLevel;
            final color = _colors[index];

            return GestureDetector(
              onTap: () => onMoodSelected(moodLevel),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutBack,
                width: isSelected ? 64 : 50,
                height: isSelected ? 64 : 50,
                decoration: BoxDecoration(
                  color: isSelected
                      ? color.withValues(alpha: 0.2)
                      : theme.secondaryBackground,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected
                        ? color
                        : theme.alternate.withValues(alpha: 0.5),
                    width: isSelected ? 2.5 : 1,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: color.withValues(alpha: 0.4),
                            blurRadius: 20,
                            spreadRadius: 2,
                          ),
                        ]
                      : [],
                ),
                child: Center(
                  child: AnimatedScale(
                    scale: isSelected ? 1.0 : 0.9,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOutBack,
                    child: Text(
                      _emojis[index],
                      style: TextStyle(fontSize: isSelected ? 32 : 24),
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 20),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (Widget child, Animation<double> animation) {
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0.0, 0.2),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              ),
            );
          },
          child: Container(
            key: ValueKey<int>(selectedMood),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: _colors[selectedMood - 1].withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: _colors[selectedMood - 1].withValues(alpha: 0.2),
              ),
            ),
            child: Text(
              _labels[selectedMood - 1],
              style: theme.titleMedium.override(
                color: _colors[selectedMood - 1],
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
