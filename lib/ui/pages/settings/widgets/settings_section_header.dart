// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:sentimento_app/core/theme.dart';

class SettingsSectionHeader extends StatelessWidget {
  final String title;
  final Widget? iconWidget;

  const SettingsSectionHeader({
    super.key,
    required this.title,
    this.iconWidget,
  });

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return Row(
      children: [
        if (iconWidget != null) ...[iconWidget!, const SizedBox(width: 8)],
        Text(
          title,
          style: theme.titleMedium.override(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
