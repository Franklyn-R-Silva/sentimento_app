// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:auto_size_text/auto_size_text.dart';

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
          AutoSizeText(
            'Nenhuma entrada encontrada',
            style: theme.titleMedium.override(color: theme.secondaryText),
            minFontSize: 12,
          ),
          const SizedBox(height: 8),
          AutoSizeText(
            'Comece a registrar seu humor!',
            style: theme.bodySmall.override(
              color: theme.secondaryText.withValues(alpha: 0.7),
            ),
            minFontSize: 10,
          ),
        ],
      ),
    );
  }
}
