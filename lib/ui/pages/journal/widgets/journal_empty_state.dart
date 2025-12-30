// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:sentimento_app/core/theme.dart';

class JournalEmptyState extends StatelessWidget {
  const JournalEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.book_outlined,
            size: 64,
            color: theme.secondaryText.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Nenhuma entrada encontrada',
            style: theme.titleMedium.override(color: theme.secondaryText),
          ),
          const SizedBox(height: 8),
          Text(
            'Comece a registrar seu humor!',
            style: theme.bodySmall.override(
              color: theme.secondaryText.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
}
