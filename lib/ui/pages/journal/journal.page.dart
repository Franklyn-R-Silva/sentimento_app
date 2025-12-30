// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

// Project imports:
import 'package:sentimento_app/backend/services/data_refresh_service.dart';
import 'package:sentimento_app/backend/tables/entradas_humor.dart';
import 'package:sentimento_app/core/model.dart';
import 'package:sentimento_app/core/theme.dart';
import 'package:sentimento_app/ui/pages/home/widgets/mood_card.dart';
import 'package:sentimento_app/ui/pages/journal/widgets/journal_calendar_view.dart';
import 'package:sentimento_app/ui/pages/journal/widgets/journal_empty_state.dart';
import 'package:sentimento_app/ui/pages/journal/widgets/journal_entry_detail_sheet.dart';
import 'package:sentimento_app/ui/pages/journal/widgets/journal_filter_chip.dart';
import 'package:sentimento_app/ui/pages/journal/widgets/journal_search_bar.dart';
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
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => JournalEntryDetailSheet(
        entry: entry,
        onDelete: () async {
          debugPrint('Usuário confirmou exclusão. Iniciando...');
          try {
            await _model.deleteEntry(entry.id);
            if (context.mounted) Navigator.pop(context);
            // Notify other pages to refresh
            DataRefreshService.instance.triggerRefresh();
          } catch (e) {
            debugPrint('Exceção capturada na UI ao excluir: $e');
            if (context.mounted) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('Erro ao excluir: $e')));
            }
          }
        },
        onUpdate: (newText) async {
          try {
            await _model.updateEntry(entry, newText);
            if (context.mounted) Navigator.pop(context); // Close sheet
            // Notify other pages to refresh
            DataRefreshService.instance.triggerRefresh();
          } catch (e) {
            if (context.mounted) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('Erro ao atualizar: $e')));
            }
          }
        },
      ),
    );
  }

  bool _isCalendarView = false;

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
                IconButton(
                  onPressed: () {
                    setState(() {
                      _isCalendarView = !_isCalendarView;
                    });
                  },
                  icon: Icon(
                    _isCalendarView
                        ? Icons.format_list_bulleted_rounded
                        : Icons.calendar_month_rounded,
                    color: theme.primary,
                  ),
                  tooltip: _isCalendarView ? 'Ver Lista' : 'Ver Calendário',
                ),
                if ((model.filterMood != null ||
                        model.searchQuery.isNotEmpty) &&
                    !_isCalendarView)
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
            body: _isCalendarView
                ? JournalCalendarView(model: model)
                : Column(
                    children: [
                      // Search bar
                      JournalSearchBar(
                        controller: _searchController,
                        onChanged: (value) => model.searchQuery = value,
                      ).animate().fade().slideY(begin: -0.5, end: 0),

                      // Mood filter chips
                      SizedBox(
                        height: 48,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          children: [
                            JournalFilterChip(
                              label: 'Todos',
                              isSelected: model.filterMood == null,
                              onTap: () => model.filterMood = null,
                            ),
                            ...List.generate(5, (index) {
                              final mood = index + 1;
                              final emojis = ['😢', '😟', '😐', '🙂', '😄'];
                              return JournalFilterChip(
                                label: emojis[index],
                                isSelected: model.filterMood == mood,
                                onTap: () => model.filterMood = mood,
                              );
                            }),
                          ],
                        ),
                      ).animate().fade().slideX(
                        begin: -0.2,
                        end: 0,
                        delay: 100.ms,
                      ),

                      const SizedBox(height: 8),

                      // Entries list
                      Expanded(
                        child: model.isLoading
                            ? const Center(child: CircularProgressIndicator())
                            : model.filteredEntries.isEmpty
                            ? const JournalEmptyState()
                            : ListView.builder(
                                padding: const EdgeInsets.only(bottom: 100),
                                itemCount: model.filteredEntries.length,
                                itemBuilder: (context, index) {
                                  final entry = model.filteredEntries[index];
                                  return MoodCard(
                                        entry: entry,
                                        onTap: () =>
                                            _showEntryDetail(context, entry),
                                      )
                                      .animate(delay: (50 * index).ms)
                                      .fade()
                                      .slideX(begin: 0.2, end: 0);
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
