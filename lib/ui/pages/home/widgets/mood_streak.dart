// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:auto_size_text/auto_size_text.dart';
import 'package:logger/logger.dart';

// Project imports:
import 'package:sentimento_app/core/theme.dart';

/// MoodStreak - Widget de gamificação mostrando dias consecutivos
class MoodStreak extends StatelessWidget {
  final int streakDays;
  final int? longestStreak;

  const MoodStreak({super.key, required this.streakDays, this.longestStreak});

  String _getMotivationalMessage() {
    if (streakDays == 0) {
      return 'Comece sua jornada hoje! 🌱';
    } else if (streakDays < 3) {
      return 'Bom começo! Continue assim! 💪';
    } else if (streakDays < 7) {
      return 'Incrível! Você está criando um hábito! 🌟';
    } else if (streakDays < 14) {
      return 'Uma semana completa! Você é demais! 🔥';
    } else if (streakDays < 30) {
      return 'Impressionante! Você é imparável! 🚀';
    } else {
      return 'Lendário! Continue sua jornada! 👑';
    }
  }

  @override
  Widget build(BuildContext context) {
    Logger().t('MoodStreak: build called with $streakDays days');
    final theme = FlutterFlowTheme.of(context);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.primary.withValues(alpha: 0.15),
            theme.secondary.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: theme.primary.withValues(alpha: 0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.primary.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          // Fire icon with streak count
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFFF8A65), Color(0xFFFF5722)],
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFF5722).withValues(alpha: 0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
                BoxShadow(
                  color: const Color(0xFFFF5722).withValues(alpha: 0.2),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('🔥', style: TextStyle(fontSize: 28)),
                const SizedBox(height: 2),
                AutoSizeText(
                  '$streakDays',
                  style: theme.displaySmall.override(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                  ),
                  minFontSize: 16,
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          // Text content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AutoSizeText(
                  streakDays == 1 ? 'Dia de sequência' : 'Dias de sequência',
                  style: theme.labelMedium.override(
                    color: theme.secondaryText,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                  minFontSize: 10,
                  maxLines: 1,
                ),
                const SizedBox(height: 4),
                AutoSizeText(
                  _getMotivationalMessage(),
                  style: theme.titleMedium.override(
                    fontWeight: FontWeight.bold,
                    lineHeight: 1.2,
                  ),
                  minFontSize: 14,
                  maxLines: 3,
                ),
                if (longestStreak != null && longestStreak! > streakDays) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: theme.tertiary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.emoji_events_rounded,
                          size: 14,
                          color: theme.tertiary,
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: AutoSizeText(
                            'Recorde: $longestStreak dias',
                            style: theme.labelSmall.override(
                              color: theme.tertiary,
                              fontWeight: FontWeight.bold,
                            ),
                            minFontSize: 9,
                            maxLines: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
