import 'package:flutter/material.dart';
import 'package:sentimento_app/core/theme.dart';

class EmergencyContact extends StatelessWidget {
  final String name;
  final String description;
  final Color color;
  final FlutterFlowTheme theme;

  const EmergencyContact({
    super.key,
    required this.name,
    required this.description,
    required this.color,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.phone_rounded, color: color, size: 20),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: theme.bodyMedium.override(fontWeight: FontWeight.w600),
              ),
              Text(
                description,
                style: theme.labelSmall.override(color: theme.secondaryText),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
