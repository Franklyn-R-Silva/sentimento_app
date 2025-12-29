import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:sentimento_app/core/theme.dart';
import 'package:sentimento_app/core/model.dart';
import 'package:sentimento_app/ui/pages/home/widgets/mood_card.dart';
import 'package:sentimento_app/ui/pages/home/widgets/mood_selector.dart';
import 'package:sentimento_app/ui/pages/home/widgets/mood_streak.dart';
import 'package:sentimento_app/ui/pages/home/widgets/weekly_chart.dart';
import 'package:sentimento_app/ui/shared/widgets/gradient_card.dart';
import 'home.model.dart';

export 'home.model.dart';

class HomePageWidget extends StatefulWidget {
  const HomePageWidget({super.key});

  static const String routeName = 'HomePage';
  static const String routePath = '/home';

  @override
  State<HomePageWidget> createState() => _HomePageWidgetState();
}

class _HomePageWidgetState extends State<HomePageWidget> {
  late HomeModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => HomeModel());
    _loadData();
  }

  Future<void> _loadData() async {
    await _model.loadData();
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Bom dia';
    if (hour < 18) return 'Boa tarde';
    return 'Boa noite';
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<HomeModel>.value(
      value: _model,
      child: Consumer<HomeModel>(
        builder: (context, model, child) {
          final theme = FlutterFlowTheme.of(context);

          return Scaffold(
            key: scaffoldKey,
            backgroundColor: theme.primaryBackground,
            floatingActionButton: FloatingActionButton.extended(
              onPressed: () => _showAddMoodSheet(context),
              backgroundColor: theme.primary,
              elevation: 8,
              icon: const Icon(Icons.add_rounded, color: Colors.white),
              label: Text(
                'Registrar',
                style: theme.labelMedium.override(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            body: SafeArea(
              child: model.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : RefreshIndicator(
                      onRefresh: _loadData,
                      color: theme.primary,
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Header with greeting
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${_getGreeting()} 👋',
                                        style: theme.headlineSmall,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        DateFormat(
                                          "EEEE, d 'de' MMMM",
                                          'pt_BR',
                                        ).format(DateTime.now()),
                                        style: theme.labelMedium.override(
                                          color: theme.secondaryText,
                                        ),
                                      ),
                                    ],
                                  ),
                                  // Mood indicator
                                  if (model.recentEntries.isNotEmpty)
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: theme.primary.withValues(
                                          alpha: 0.1,
                                        ),
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Text(
                                        _getEmojiForMood(
                                          model.recentEntries.first.nota,
                                        ),
                                        style: const TextStyle(fontSize: 32),
                                      ),
                                    ),
                                ],
                              ),

                              const SizedBox(height: 24),

                              // Streak widget
                              MoodStreak(
                                streakDays: _calculateStreak(model),
                                longestStreak: model.longestStreak,
                              ),

                              const SizedBox(height: 24),

                              // Weekly chart section
                              Text('Sua Semana', style: theme.titleMedium),
                              const SizedBox(height: 12),
                              GradientCard(
                                margin: EdgeInsets.zero,
                                child: WeeklyChart(
                                  entries: model.weeklyEntries,
                                ),
                              ),

                              const SizedBox(height: 24),

                              // Recent entries
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Entradas Recentes',
                                    style: theme.titleMedium,
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      // Navigate to journal - handled by bottom nav
                                    },
                                    child: Text(
                                      'Ver todas',
                                      style: theme.labelMedium.override(
                                        color: theme.primary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),

                              if (model.recentEntries.isEmpty)
                                _EmptyEntriesState(theme: theme)
                              else
                                ...model.recentEntries
                                    .take(5)
                                    .map(
                                      (entry) =>
                                          MoodCard(entry: entry, onTap: () {}),
                                    ),

                              const SizedBox(height: 100), // Space for FAB
                            ],
                          ),
                        ),
                      ),
                    ),
            ),
          );
        },
      ),
    );
  }

  int _calculateStreak(HomeModel model) {
    if (model.recentEntries.isEmpty) return 0;

    int streak = 0;
    DateTime? lastDate;

    for (var entry in model.recentEntries) {
      final entryDate = DateTime(
        entry.criadoEm.year,
        entry.criadoEm.month,
        entry.criadoEm.day,
      );

      if (lastDate == null) {
        final today = DateTime.now();
        final todayDate = DateTime(today.year, today.month, today.day);
        if (entryDate == todayDate ||
            entryDate == todayDate.subtract(const Duration(days: 1))) {
          streak = 1;
          lastDate = entryDate;
        } else {
          break;
        }
      } else {
        final diff = lastDate.difference(entryDate).inDays;
        if (diff == 1) {
          streak++;
          lastDate = entryDate;
        } else if (diff > 1) {
          break;
        }
      }
    }

    return streak;
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

  void _showAddMoodSheet(BuildContext context) {
    int selectedMood = 3;
    final textController = TextEditingController();
    final theme = FlutterFlowTheme.of(context);

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return Container(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            decoration: BoxDecoration(
              color: theme.secondaryBackground,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Handle
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: theme.alternate,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Mood selector
                    MoodSelector(
                      selectedMood: selectedMood,
                      onMoodSelected: (mood) =>
                          setState(() => selectedMood = mood),
                    ),

                    const SizedBox(height: 24),

                    // Note input
                    TextField(
                      controller: textController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: 'Como foi seu dia? (opcional)',
                        hintStyle: theme.bodyMedium.override(
                          color: theme.secondaryText,
                        ),
                        filled: true,
                        fillColor: theme.primaryBackground,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.all(16),
                      ),
                      style: theme.bodyMedium,
                    ),

                    const SizedBox(height: 24),

                    // Save button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          await _model.addEntry(
                            context,
                            selectedMood,
                            textController.text.isEmpty
                                ? null
                                : textController.text,
                            [],
                          );
                          if (context.mounted) {
                            Navigator.pop(context);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.primary,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(
                          'Salvar Registro',
                          style: theme.titleSmall.override(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _EmptyEntriesState extends StatelessWidget {
  final FlutterFlowTheme theme;

  const _EmptyEntriesState({required this.theme});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(
            Icons.sentiment_satisfied_alt_rounded,
            size: 64,
            color: theme.primary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text('Nenhum registro ainda', style: theme.titleMedium),
          const SizedBox(height: 8),
          Text(
            'Toque no botão "Registrar" para adicionar seu primeiro registro de humor!',
            textAlign: TextAlign.center,
            style: theme.bodySmall.override(color: theme.secondaryText),
          ),
        ],
      ),
    );
  }
}
