import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
                              onTap: () {
                                // TODO: Open entry detail
                              },
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
            color: theme.secondaryText.withOpacity(0.5),
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
              color: theme.secondaryText.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }
}
