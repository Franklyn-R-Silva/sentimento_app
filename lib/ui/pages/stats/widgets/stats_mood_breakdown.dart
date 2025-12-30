// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:sentimento_app/core/theme.dart';
import 'package:sentimento_app/ui/shared/widgets/gradient_card.dart';
import 'package:sentimento_app/ui/shared/widgets/mood_indicator.dart';

class StatsMoodBreakdown extends StatelessWidget {
  final double averageMood;
  final int totalEntries;

  const StatsMoodBreakdown({
    super.key,
    required this.averageMood,
    required this.totalEntries,
  });

  String _getMoodLabel(double mood) {
    if (mood < 1.5) return 'Muito Triste';
    if (mood < 2.5) return 'Triste';
    if (mood < 3.5) return 'Neutro';
    if (mood < 4.5) return 'Feliz';
    return 'Muito Feliz';
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Seu Humor', style: theme.titleMedium),
        const SizedBox(height: 16),
        GradientCard(
          moodLevel: averageMood.round(),
          child: Row(
            children: [
              MoodIndicator(
                value: averageMood / 5,
                size: 100,
                moodLevel: averageMood.round(),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Média Geral', style: theme.titleSmall),
                    const SizedBox(height: 4),
                    Text(
                      _getMoodLabel(averageMood),
                      style: theme.headlineSmall.override(color: theme.primary),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Baseado em $totalEntries registros',
                      style: theme.labelSmall.override(
                        color: theme.secondaryText,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
