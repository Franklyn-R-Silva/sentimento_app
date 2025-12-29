import 'package:flutter/material.dart';
import 'package:sentimento_app/core/theme.dart';

class DrawerNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;
  final String? badge;
  final bool isEmergency;

  const DrawerNavItem({
    super.key,
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.onTap,
    this.badge,
    this.isEmergency = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isEmergency
            ? color.withValues(alpha: 0.1)
            : theme.secondaryBackground,
        borderRadius: BorderRadius.circular(16),
        border: isEmergency
            ? Border.all(color: color.withValues(alpha: 0.4))
            : null,
      ),
      child: ListTile(
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        title: Row(
          children: [
            Flexible(
              child: Text(
                label,
                style: theme.bodyMedium,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (badge != null) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: theme.primary,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  badge!,
                  style: theme.labelSmall.override(
                    color: Colors.white,
                    fontSize: 9,
                  ),
                ),
              ),
            ],
          ],
        ),
        subtitle: Text(
          subtitle,
          style: theme.labelSmall.override(color: theme.secondaryText),
        ),
        trailing: Icon(
          Icons.chevron_right_rounded,
          color: theme.secondaryText,
          size: 20,
        ),
      ),
    );
  }
}
