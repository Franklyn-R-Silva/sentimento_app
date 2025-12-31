// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:auto_size_text/auto_size_text.dart';

// Project imports:
import 'package:sentimento_app/core/theme.dart';

class HomeEmptyState extends StatelessWidget {
  const HomeEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);

    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(
            Icons.sentiment_satisfied_alt_rounded,
            size: 64,
            color: theme.primary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          AutoSizeText(
            'Nenhum registro ainda',
            style: theme.titleMedium,
            minFontSize: 12,
          ),
          const SizedBox(height: 8),
          AutoSizeText(
            'Toque no botão "Registrar" para adicionar seu primeiro registro de humor!',
            textAlign: TextAlign.center,
            style: theme.bodySmall.override(color: theme.secondaryText),
            minFontSize: 10,
          ),
        ],
      ),
    );
  }
}
