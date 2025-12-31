// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:auto_size_text/auto_size_text.dart';
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

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      _getGreeting(),
                      style: theme.headlineMedium.override(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Greeting Hand Animation could go here
                    const Text('👋', style: TextStyle(fontSize: 24)),
                  ],
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: theme.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    DateFormat(
                      "EEEE, d 'de' MMMM",
                      'pt_BR',
                    ).format(DateTime.now()).toUpperCase(),
                    style: theme.labelSmall.override(
                      color: theme.primary,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // User Avatar / Profile Button
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: theme.secondaryBackground,
              boxShadow: [
                BoxShadow(
                  color: theme.primaryText.withValues(alpha: 0.1),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
              border: Border.all(color: theme.primaryBackground, width: 2),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    // Navigate to profile or settings
                    // Navigator.pushNamed(context, '/settings');
                    // For now, simple feedback
                  },
                  child: Center(
                    child: Icon(
                      Icons.person_outline_rounded,
                      color: theme.primaryText,
                      size: 24,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
