// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:sentimento_app/core/theme.dart';
import 'package:sentimento_app/ui/shared/widgets/gradient_card.dart';
import '../fotos_anuais.model.dart';

class MoodSelectorWidget extends StatelessWidget {
  final FotosAnuaisModel model;

  const MoodSelectorWidget({super.key, required this.model});

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);

    return GradientCard(
      moodLevel: model.moodLevel ?? 3,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Como você está se sentindo?',
              style: theme.typography.titleMedium.copyWith(color: Colors.white),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _moodOption(1, '😢'),
                _moodOption(2, '😕'),
                _moodOption(3, '😐'),
                _moodOption(4, '🙂'),
                _moodOption(5, '🤩'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _moodOption(int level, String emoji) {
    final isSelected = model.moodLevel == level;
    return GestureDetector(
      onTap: () => model.moodLevel = level,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          shape: BoxShape.circle,
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Text(emoji, style: TextStyle(fontSize: isSelected ? 32 : 24)),
      ),
    );
  }
}
