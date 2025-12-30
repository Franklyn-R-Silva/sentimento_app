// Flutter imports:
import 'package:flutter/material.dart';

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
          Text(
            'Minhas Metas',
            style: theme.headlineMedium.override(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            'Acompanhe seu progresso diário',
            style: theme.bodyMedium.override(color: theme.secondaryText),
          ),
        ],
      ),
    );
  }
}
