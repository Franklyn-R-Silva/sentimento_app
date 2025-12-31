// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:auto_size_text/auto_size_text.dart';

// Project imports:
import 'package:sentimento_app/backend/tables/entradas_humor.dart';
import 'package:sentimento_app/core/theme.dart';

class JournalEntryDetailSheet extends StatelessWidget {
  final EntradasHumorRow entry;
  final Future<void> Function() onDelete;
  final Future<void> Function(String newText) onUpdate;

  const JournalEntryDetailSheet({
    super.key,
    required this.entry,
    required this.onDelete,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final emojis = ['😢', '😟', '😐', '🙂', '😄'];
    final mood = entry.nota - 1;
    final emoji = emojis[mood.clamp(0, 4)];

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.alternate,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Mood emoji and date
          Row(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: theme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Text(emoji, style: const TextStyle(fontSize: 32)),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AutoSizeText(
                      'Humor: ${entry.nota}/5',
                      style: theme.titleMedium,
                      minFontSize: 12,
                    ),
                    const SizedBox(height: 4),
                    AutoSizeText(
                      '${entry.criadoEm.day}/${entry.criadoEm.month}/${entry.criadoEm.year} às ${entry.criadoEm.hour}:${entry.criadoEm.minute.toString().padLeft(2, '0')}',
                      style: theme.labelMedium.override(
                        color: theme.secondaryText,
                      ),
                      minFontSize: 10,
                      maxLines: 1,
                    ),
                  ],
                ),
              ),
            ],
          ),

          if (entry.notaTexto != null && entry.notaTexto!.isNotEmpty) ...[
            const SizedBox(height: 24),
            AutoSizeText(
              'Nota:',
              style: theme.labelMedium.override(color: theme.secondaryText),
              minFontSize: 10,
            ),
            const SizedBox(height: 8),
            AutoSizeText(
              entry.notaTexto!,
              style: theme.bodyMedium,
              minFontSize: 10,
            ),
          ],

          if (entry.tags.isNotEmpty) ...[
            const SizedBox(height: 24),
            AutoSizeText(
              'Tags:',
              style: theme.labelMedium.override(color: theme.secondaryText),
              minFontSize: 10,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: entry.tags
                  .map<Widget>(
                    (tag) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: theme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: AutoSizeText(
                        tag.toString(),
                        style: theme.labelMedium.override(color: theme.primary),
                        minFontSize: 9,
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],

          const SizedBox(height: 32),

          // Actions
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () async {
                    // Confirm delete
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Excluir entrada?'),
                        content: const Text('Esta ação não pode ser desfeita.'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Cancelar'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            style: TextButton.styleFrom(
                              foregroundColor: theme.error,
                            ),
                            child: const Text('Excluir'),
                          ),
                        ],
                      ),
                    );

                    if (confirm == true) {
                      await onDelete();
                    }
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: BorderSide(color: theme.error),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: Icon(Icons.delete_outline, color: theme.error),
                  label: AutoSizeText(
                    'Excluir',
                    style: TextStyle(color: theme.error),
                    minFontSize: 10,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final textController = TextEditingController(
                      text: entry.notaTexto,
                    );
                    final newText = await showDialog<String>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Editar Nota'),
                        content: TextField(
                          controller: textController,
                          maxLines: 3,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancelar'),
                          ),
                          TextButton(
                            onPressed: () =>
                                Navigator.pop(context, textController.text),
                            child: const Text('Salvar'),
                          ),
                        ],
                      ),
                    );

                    if (newText != null) {
                      await onUpdate(newText);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.edit, color: Colors.white),
                  label: const AutoSizeText(
                    'Editar',
                    style: TextStyle(color: Colors.white),
                    minFontSize: 10,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
