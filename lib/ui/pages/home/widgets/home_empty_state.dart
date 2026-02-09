// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:logger/logger.dart';

// Project imports:
import 'package:sentimento_app/core/theme.dart';

class HomeEmptyState extends StatelessWidget {
  const HomeEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    Logger().t('HomeEmptyState: build called');
    final theme = FlutterFlowTheme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: theme.secondaryBackground.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.alternate.withValues(alpha: 0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.sentiment_satisfied_rounded,
              size: 48,
              color: theme.primary,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Comece sua jornada',
            style: theme.titleMedium.override(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'Registre como você está se sentindo hoje para começar a acompanhar seu progresso.',
            textAlign: TextAlign.center,
            style: theme.bodyMedium.override(
              color: theme.secondaryText,
              lineHeight: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
