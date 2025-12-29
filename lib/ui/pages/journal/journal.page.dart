import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sentimento_app/backend/tables/entradas_humor.dart';
import 'package:sentimento_app/core/model.dart';
import 'package:sentimento_app/core/theme.dart';
import 'package:sentimento_app/ui/pages/home/widgets/mood_card.dart';
import 'journal.model.dart';

export 'journal.model.dart';

class JournalPageWidget extends StatefulWidget {
  const JournalPageWidget({super.key});

  static const String routeName = 'Journal';
  static const String routePath = '/journal';

  @override
  State<JournalPageWidget> createState() => _JournalPageWidgetState();
}

class _JournalPageWidgetState extends State<JournalPageWidget> {
  late JournalModel _model;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => JournalModel());
    _model.loadEntries();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _model.dispose();
    super.dispose();
  }

  void _showEntryDetail(BuildContext context, EntradasHumorRow entry) {
    final theme = FlutterFlowTheme.of(context);
    final emojis = ['😢', '😟', '😐', '🙂', '😄'];
    final mood = entry.nota - 1;
    final emoji = emojis[mood.clamp(0, 4)];

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
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
                      Text('Humor: ${entry.nota}/5', style: theme.titleMedium),
                      const SizedBox(height: 4),
                      Text(
                        '${entry.criadoEm.day}/${entry.criadoEm.month}/${entry.criadoEm.year} às ${entry.criadoEm.hour}:${entry.criadoEm.minute.toString().padLeft(2, '0')}',
                        style: theme.labelMedium.override(
                          color: theme.secondaryText,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            if (entry.notaTexto != null && entry.notaTexto!.isNotEmpty) ...[
              const SizedBox(height: 24),
              Text(
                'Nota:',
                style: theme.labelMedium.override(color: theme.secondaryText),
              ),
              const SizedBox(height: 8),
              Text(entry.notaTexto!, style: theme.bodyMedium),
            ],

            if (entry.tags.isNotEmpty) ...[
              const SizedBox(height: 24),
              Text(
                'Tags:',
                style: theme.labelMedium.override(color: theme.secondaryText),
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
                        child: Text(
                          tag.toString(),
                          style: theme.labelMedium.override(
                            color: theme.primary,
                          ),
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
                          content: const Text(
                            'Esta ação não pode ser desfeita.',
                          ),
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

                      if (confirm == true && context.mounted) {
                        debugPrint('Usuário confirmou exclusão. Iniciando...');
                        try {
                          await Provider.of<JournalModel>(
                            context,
                            listen: false,
                          ).deleteEntry(entry.id);
                          if (context.mounted) Navigator.pop(context);
                        } catch (e) {
                          debugPrint('Exceção capturada na UI ao excluir: $e');
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Erro ao excluir: $e')),
                            );
                          }
                        }
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
                    label: Text(
                      'Excluir',
                      style: TextStyle(color: theme.error),
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

                      if (newText != null && context.mounted) {
                        try {
                          await Provider.of<JournalModel>(
                            context,
                            listen: false,
                          ).updateEntry(entry, newText);
                          if (context.mounted)
                            Navigator.pop(context); // Close sheet
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Erro ao atualizar: $e')),
                            );
                          }
                        }
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
                    label: const Text(
                      'Editar',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<JournalModel>.value(
      value: _model,
      child: Consumer<JournalModel>(
        builder: (context, model, child) {
          final theme = FlutterFlowTheme.of(context);

          return Scaffold(
            backgroundColor: theme.primaryBackground,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              title: Text(
                'Meu Diário',
                style: theme.headlineMedium.override(color: theme.primaryText),
              ),
              centerTitle: false,
              actions: [
                if (model.filterMood != null || model.searchQuery.isNotEmpty)
                  TextButton(
                    onPressed: () {
                      _searchController.clear();
                      model.clearFilters();
                    },
                    child: Text(
                      'Limpar',
                      style: theme.labelMedium.override(color: theme.primary),
                    ),
                  ),
              ],
            ),
            body: Column(
              children: [
                // Search bar
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) => model.searchQuery = value,
                    decoration: InputDecoration(
                      hintText: 'Buscar no diário...',
                      hintStyle: theme.bodyMedium.override(
                        color: theme.secondaryText,
                      ),
                      prefixIcon: Icon(
                        Icons.search_rounded,
                        color: theme.secondaryText,
                      ),
                      filled: true,
                      fillColor: theme.secondaryBackground,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    style: theme.bodyMedium,
                  ),
                ),

                // Mood filter chips
                SizedBox(
                  height: 48,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      _FilterChip(
                        label: 'Todos',
                        isSelected: model.filterMood == null,
                        onTap: () => model.filterMood = null,
                      ),
                      ...List.generate(5, (index) {
                        final mood = index + 1;
                        final emojis = ['😢', '😟', '😐', '🙂', '😄'];
                        return _FilterChip(
                          label: emojis[index],
                          isSelected: model.filterMood == mood,
                          onTap: () => model.filterMood = mood,
                        );
                      }),
                    ],
                  ),
                ),

                const SizedBox(height: 8),

                // Entries list
                Expanded(
                  child: model.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : model.filteredEntries.isEmpty
                      ? _EmptyState(theme: theme)
                      : ListView.builder(
                          padding: const EdgeInsets.only(bottom: 100),
                          itemCount: model.filteredEntries.length,
                          itemBuilder: (context, index) {
                            final entry = model.filteredEntries[index];
                            return MoodCard(
                              entry: entry,
                              onTap: () => _showEntryDetail(context, entry),
                            );
                          },
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? theme.primary : theme.secondaryBackground,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? theme.primary : theme.alternate,
            ),
          ),
          child: Text(
            label,
            style: theme.labelMedium.override(
              color: isSelected ? Colors.white : theme.primaryText,
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final FlutterFlowTheme theme;

  const _EmptyState({required this.theme});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.book_outlined,
            size: 64,
            color: theme.secondaryText.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Nenhuma entrada encontrada',
            style: theme.titleMedium.override(color: theme.secondaryText),
          ),
          const SizedBox(height: 8),
          Text(
            'Comece a registrar seu humor!',
            style: theme.bodySmall.override(
              color: theme.secondaryText.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
}
