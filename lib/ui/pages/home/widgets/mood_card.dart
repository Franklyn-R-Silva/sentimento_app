// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:auto_size_text/auto_size_text.dart';
import 'package:intl/intl.dart';

// Project imports:
import 'package:sentimento_app/backend/tables/entradas_humor.dart';
import 'package:sentimento_app/core/theme.dart';

/// MoodCard - Card para exibir uma entrada de humor
class MoodCard extends StatelessWidget {
  final EntradasHumorRow entry;
  final VoidCallback? onTap;

  const MoodCard({super.key, required this.entry, this.onTap});

  static const List<String> _emojis = ['😢', '😟', '😐', '🙂', '😄'];
  static const List<Color> _colors = [
    Color(0xFFE53935),
    Color(0xFFFF9800),
    Color(0xFF2196F3),
    Color(0xFF4CAF50),
    Color(0xFF7C4DFF),
  ];

  String get _emoji => _emojis[(entry.nota - 1).clamp(0, 4)];
  Color get _color => _colors[(entry.nota - 1).clamp(0, 4)];

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _color.withValues(alpha: 0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: theme.primaryText.withValues(alpha: 0.05),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
        border: Border.all(color: _color.withValues(alpha: 0.2), width: 1),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Emoji avatar
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        _color.withValues(alpha: 0.2),
                        _color.withValues(alpha: 0.1),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: _color.withValues(alpha: 0.2),
                      width: 1.5,
                    ),
                  ),
                  child: Center(
                    child: Text(_emoji, style: const TextStyle(fontSize: 28)),
                  ),
                ),
                const SizedBox(width: 16),
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: AutoSizeText(
                              DateFormat(
                                'EEEE, d MMM',
                                'pt_BR',
                              ).format(entry.criadoEm),
                              style: theme.titleSmall.override(
                                fontWeight: FontWeight.w600,
                              ),
                              minFontSize: 10,
                              maxLines: 1,
                            ),
                          ),
                          AutoSizeText(
                            DateFormat('HH:mm').format(entry.criadoEm),
                            style: theme.labelSmall.override(
                              color: theme.secondaryText,
                            ),
                            minFontSize: 9,
                          ),
                        ],
                      ),

                      // Note with Icon
                      if (entry.notaTexto != null &&
                          entry.notaTexto!.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.notes,
                              size: 14,
                              color: theme.secondaryText,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: AutoSizeText(
                                entry.notaTexto!,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: theme.bodySmall.override(
                                  color: theme.secondaryText,
                                  fontStyle: FontStyle.italic,
                                ),
                                minFontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ],

                      // Tags
                      if (entry.tags.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 4, // Tighter spacing
                          runSpacing: 4,
                          children: entry.tags
                              .take(4) // Show 4 tags
                              .map(
                                (tag) => Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: theme.alternate.withOpacity(0.5),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: theme.alternate,
                                      width: 0.5,
                                    ),
                                  ),
                                  child: Text(
                                    '#$tag',
                                    style: theme.labelSmall.override(
                                      color: theme.secondaryText,
                                      fontSize: 10,
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// TODO: Implement PDF Report generation (Feature Module #2)
// TODO: Implement Breathing Exercises Module (Feature Module #3)
