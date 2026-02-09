// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// Project imports:
import 'package:sentimento_app/core/theme.dart';

class GymEmptyState extends StatelessWidget {
  const GymEmptyState({
    super.key,
    required this.message,
    this.icon = FontAwesomeIcons.dumbbell,
    this.onAction,
    this.actionLabel,
  });

  final String message;
  final IconData icon;
  final VoidCallback? onAction;
  final String? actionLabel;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: theme.secondaryBackground,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: theme.primary.withValues(alpha: 0.1),
                    blurRadius: 32,
                    offset: const Offset(0, 16),
                  ),
                ],
                border: Border.all(
                  color: theme.primary.withValues(alpha: 0.1),
                  width: 1,
                ),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: theme.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                  ),
                  Icon(icon, size: 48, color: theme.primary),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.headlineSmall.override(
                fontFamily: 'Outfit',
                color: theme.primaryText,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Toque no botão abaixo para começar',
              textAlign: TextAlign.center,
              style: theme.bodyMedium.override(
                fontFamily: 'Outfit',
                color: theme.secondaryText,
              ),
            ),
            if (onAction != null && actionLabel != null) ...[
              const SizedBox(height: 32),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: theme.primary.withValues(alpha: 0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: ElevatedButton.icon(
                  onPressed: onAction,
                  icon: const Icon(Icons.add_rounded, size: 24),
                  label: Text(
                    actionLabel!,
                    style: theme.titleSmall.override(
                      fontFamily: 'Outfit',
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
