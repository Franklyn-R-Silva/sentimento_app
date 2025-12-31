// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:

// Project imports:
import 'package:sentimento_app/core/theme.dart';

class GoalsEmptyState extends StatelessWidget {
  const GoalsEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: theme.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Text('🎯', style: TextStyle(fontSize: 48)),
            ),
            const SizedBox(height: 24),
            Text(
              'Nenhuma meta ainda',
              style: theme.titleMedium.override(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              'Crie sua primeira meta e comece\na acompanhar seu progresso!',
              textAlign: TextAlign.center,
              style: theme.bodyMedium.override(color: theme.secondaryText),
            ),
          ],
        ),
      ),
    );
  }
}
