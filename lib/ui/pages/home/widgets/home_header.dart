// Flutter imports:
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:intl/intl.dart';

// Project imports:
import 'package:sentimento_app/backend/tables/entradas_humor.dart';
import 'package:sentimento_app/core/theme.dart';

class HomeHeader extends StatelessWidget {
  final List<EntradasHumorRow> recentEntries;

  const HomeHeader({super.key, required this.recentEntries});

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Bom dia';
    if (hour < 18) return 'Boa tarde';
    return 'Boa noite';
  }

  String _getEmojiForMood(int mood) {
    switch (mood) {
      case 1:
        return '😢';
      case 2:
        return '😟';
      case 3:
        return '😐';
      case 4:
        return '🙂';
      case 5:
        return '😄';
      default:
        return '😐';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AutoSizeText(
                '${_getGreeting()} 👋',
                style: theme.headlineSmall,
                minFontSize: 16,
                maxLines: 1,
              ),
              const SizedBox(height: 4),
              AutoSizeText(
                DateFormat("EEEE, d 'de' MMMM", 'pt_BR').format(DateTime.now()),
                style: theme.labelMedium.override(color: theme.secondaryText),
                minFontSize: 10,
                maxLines: 1,
              ),
            ],
          ),
        ),
        // Mood indicator
        if (recentEntries.isNotEmpty)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              _getEmojiForMood(recentEntries.first.nota),
              style: const TextStyle(fontSize: 32),
            ),
          ),
      ],
    );
  }
}
