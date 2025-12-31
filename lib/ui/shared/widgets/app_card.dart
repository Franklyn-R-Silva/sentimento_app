// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:sentimento_app/core/theme.dart';

class AppCard extends StatelessWidget {
  final Widget child;

  const AppCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);

    return Container(
      padding: const EdgeInsets.all(20), // Default premium padding
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(24), // Softer corners
        boxShadow: [
          BoxShadow(
            color: theme.primaryText.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(
          color: theme.alternate.withValues(alpha: 0.05),
          width: 1,
        ),
      ),
      child: child,
    );
  }
}
