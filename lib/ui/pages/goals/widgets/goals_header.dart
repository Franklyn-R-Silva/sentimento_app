// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:auto_size_text/auto_size_text.dart';

// Project imports:
import 'package:sentimento_app/core/theme.dart';

class GoalsHeader extends StatelessWidget {
  const GoalsHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AutoSizeText(
            'Minhas Metas',
            style: theme.headlineMedium.override(fontWeight: FontWeight.bold),
            minFontSize: 18,
          ),
          const SizedBox(height: 4),
          AutoSizeText(
            'Acompanhe seu progresso diário',
            style: theme.bodyMedium.override(color: theme.secondaryText),
            minFontSize: 10,
          ),
        ],
      ),
    );
  }
}
