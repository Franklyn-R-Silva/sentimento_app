import 'package:flutter/material.dart';
import 'package:sentimento_app/core/theme.dart';

class ProfileSectionTitle extends StatelessWidget {
  final String title;

  const ProfileSectionTitle({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);

    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: theme.titleSmall.override(color: theme.secondaryText),
      ),
    );
  }
}
