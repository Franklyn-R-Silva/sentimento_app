import 'package:flutter/material.dart';
import 'package:sentimento_app/core/theme.dart';

class ProfileHeader extends StatelessWidget {
  final String? userName;
  final String? userEmail;

  const ProfileHeader({super.key, this.userName, this.userEmail});

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.primary.withValues(alpha: 0.2),
            theme.secondary.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          // Avatar
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [theme.primary, theme.secondary],
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: theme.primary.withValues(alpha: 0.4),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Center(
              child: Text(
                (userName?.isNotEmpty ?? false)
                    ? userName![0].toUpperCase()
                    : 'U',
                style: theme.displaySmall.override(color: Colors.white),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(userName ?? 'Usuário', style: theme.titleLarge),
          const SizedBox(height: 4),
          Text(
            userEmail ?? '',
            style: theme.labelMedium.override(color: theme.secondaryText),
          ),
        ],
      ),
    );
  }
}
