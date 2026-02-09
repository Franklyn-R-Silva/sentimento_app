// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:auto_size_text/auto_size_text.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';

// Project imports:
import 'package:sentimento_app/backend/tables/entradas_humor.dart';
import 'package:sentimento_app/core/theme.dart';
import 'package:sentimento_app/services/pdf_service.dart';

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
    Logger().t('MoodCard: build called for entry ${entry.id}');
    final theme = FlutterFlowTheme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: _color.withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(
          color: theme.alternate.withValues(alpha: 0.4),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Emoji avatar with glow
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: _color.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: _color.withValues(alpha: 0.3),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: _color.withValues(alpha: 0.2),
                        blurRadius: 12,
                        spreadRadius: 2,
                      ),
                    ],
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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                AutoSizeText(
                                  DateFormat(
                                    'EEEE, d MMM',
                                    'pt_BR',
                                  ).format(entry.criadoEm),
                                  style: theme.titleMedium.override(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                  minFontSize: 12,
                                  maxLines: 1,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  DateFormat('HH:mm').format(entry.criadoEm),
                                  style: theme.labelSmall.override(
                                    color: theme.secondaryText,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.share_rounded,
                              color: theme.secondaryText,
                              size: 20,
                            ),
                            onPressed: () async {
                              await PdfService().generateAndShareEntryPdf(
                                entry,
                              );
                            },
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            style: IconButton.styleFrom(
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                          ),
                        ],
                      ),

                      if (entry.notaTexto != null &&
                          entry.notaTexto!.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: theme.primaryBackground,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.sticky_note_2_rounded,
                                size: 16,
                                color: _color.withValues(alpha: 0.7),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: AutoSizeText(
                                  entry.notaTexto!,
                                  style: theme.bodyMedium.override(
                                    color: theme.primaryText,
                                    lineHeight: 1.5,
                                  ),
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                  minFontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      if (entry.tags.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: entry.tags.take(4).map((tag) {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: theme.accent1.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: theme.accent1.withValues(alpha: 0.2),
                                ),
                              ),
                              child: Text(
                                '#$tag',
                                style: theme.labelSmall.override(
                                  color: theme.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            );
                          }).toList(),
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
