import 'package:flutter/material.dart';
import 'package:sentimento_app/core/theme.dart';

class DailyMessage extends StatelessWidget {
  final FlutterFlowTheme theme;

  const DailyMessage({super.key, required this.theme});

  String _getMessage() {
    final messages = [
      'Cada dia é uma nova oportunidade 🌅',
      'Você está fazendo um ótimo trabalho 🌟',
      'Pequenos passos fazem grandes jornadas 🚶',
      'Respire fundo. Você está bem 🌸',
      'Sua presença ilumina o mundo 🌻',
      'Seja gentil consigo mesmo hoje 💜',
      'Você é mais resiliente do que pensa 💪',
    ];
    return messages[DateTime.now().weekday % messages.length];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.primary.withValues(alpha: 0.1),
            theme.tertiary.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.primary.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          const Text('💫', style: TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _getMessage(),
              style: theme.bodySmall.override(
                fontStyle: FontStyle.italic,
                color: theme.primaryText,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
