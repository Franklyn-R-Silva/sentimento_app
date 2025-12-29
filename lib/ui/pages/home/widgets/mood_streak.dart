import 'package:flutter/material.dart';
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
    final theme = FlutterFlowTheme.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.primary.withOpacity(0.2),
            theme.secondary.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.primary.withOpacity(0.3), width: 1),
      ),
      child: Row(
        children: [
          // Fire icon with streak count
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [const Color(0xFFFF6B35), const Color(0xFFFF9800)],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFF6B35).withOpacity(0.4),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('🔥', style: TextStyle(fontSize: 24)),
                Text(
                  '$streakDays',
                  style: theme.titleLarge.override(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Text content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  streakDays == 1
                      ? '1 dia de sequência'
                      : '$streakDays dias de sequência',
                  style: theme.titleMedium.override(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _getMotivationalMessage(),
                  style: theme.bodySmall.override(color: theme.secondaryText),
                ),
                if (longestStreak != null && longestStreak! > streakDays) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.emoji_events_rounded,
                        size: 16,
                        color: theme.tertiary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Recorde: $longestStreak dias',
                        style: theme.labelSmall.override(
                          color: theme.tertiary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
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
