import 'package:flutter/material.dart';
import 'package:sentimento_app/core/theme.dart';

class JournalFilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const JournalFilterChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? theme.primary : theme.secondaryBackground,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? theme.primary : theme.alternate,
            ),
          ),
          child: Text(
            label,
            style: theme.labelMedium.override(
              color: isSelected ? Colors.white : theme.primaryText,
            ),
          ),
        ),
      ),
    );
  }
}
