import 'package:flutter/material.dart';
import 'package:sentimento_app/core/theme.dart';

class DrawerNavSection extends StatelessWidget {
  final String title;
  final FlutterFlowTheme theme;

  const DrawerNavSection({super.key, required this.title, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8, top: 8),
      child: Text(
        title,
        style: theme.labelSmall.override(
          color: theme.secondaryText,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
