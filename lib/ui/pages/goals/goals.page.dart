import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sentimento_app/core/model.dart';
import 'package:sentimento_app/core/theme.dart';
import 'goals.model.dart';
import 'widgets/goal_card.dart';
import 'widgets/celebration_overlay.dart';

export 'goals.model.dart';

class GoalsPageWidget extends StatefulWidget {
  const GoalsPageWidget({super.key});

  static const String routeName = 'Goals';
  static const String routePath = '/goals';

  @override
  State<GoalsPageWidget> createState() => _GoalsPageWidgetState();
}

class _GoalsPageWidgetState extends State<GoalsPageWidget>
    with TickerProviderStateMixin {
  late GoalsModel _model;
  late AnimationController _fabController;
  late Animation<double> _fabAnimation;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => GoalsModel());
    _model.loadMetas();

    _fabController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _fabAnimation = CurvedAnimation(
      parent: _fabController,
      curve: Curves.elasticOut,
    );

    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) _fabController.forward();
    });
  }

  @override
  void dispose() {
    _model.dispose();
    _fabController.dispose();
    super.dispose();
  }

  void _showAddGoalSheet(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final titleController = TextEditingController();
    final descController = TextEditingController();
    int targetValue = 7;
    String selectedEmoji = '🎯';
    String selectedColor = '#7C4DFF';
    String selectedFrequency = 'diaria';

    final emojis = ['🎯', '💪', '📚', '🏃', '💧', '🧘', '✍️', '🌱', '💤', '🍎'];
    final colors = [
      '#7C4DFF',
      '#FF6B6B',
      '#4ECDC4',
      '#FFD93D',
      '#6BCB77',
      '#4D96FF',
      '#FF8B94',
      '#A66CFF',
    ];

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              decoration: BoxDecoration(
                color: theme.secondaryBackground,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(32),
                ),
              ),
              child: SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Handle
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

                      // Title
                      Text(
                        'Nova Meta',
                        style: theme.headlineSmall.override(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Emoji selector
                      Text('Escolha um ícone', style: theme.labelMedium),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 56,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: emojis.length,
                          itemBuilder: (context, index) {
                            final emoji = emojis[index];
                            final isSelected = emoji == selectedEmoji;
                            return GestureDetector(
                              onTap: () =>
                                  setState(() => selectedEmoji = emoji),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                width: 56,
                                margin: const EdgeInsets.only(right: 8),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? theme.primary.withValues(alpha: 0.2)
                                      : theme.primaryBackground,
                                  borderRadius: BorderRadius.circular(16),
                                  border: isSelected
                                      ? Border.all(
                                          color: theme.primary,
                                          width: 2,
                                        )
                                      : null,
                                ),
                                child: Center(
                                  child: Text(
                                    emoji,
                                    style: const TextStyle(fontSize: 24),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Color selector
                      Text('Escolha uma cor', style: theme.labelMedium),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 44,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: colors.length,
                          itemBuilder: (context, index) {
                            final color = colors[index];
                            final isSelected = color == selectedColor;
                            final parsedColor = Color(
                              int.parse(color.replaceFirst('#', '0xFF')),
                            );
                            return GestureDetector(
                              onTap: () =>
                                  setState(() => selectedColor = color),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                width: 44,
                                margin: const EdgeInsets.only(right: 8),
                                decoration: BoxDecoration(
                                  color: parsedColor,
                                  shape: BoxShape.circle,
                                  border: isSelected
                                      ? Border.all(
                                          color: Colors.white,
                                          width: 3,
                                        )
                                      : null,
                                  boxShadow: isSelected
                                      ? [
                                          BoxShadow(
                                            color: parsedColor.withValues(
                                              alpha: 0.5,
                                            ),
                                            blurRadius: 12,
                                            spreadRadius: 2,
                                          ),
                                        ]
                                      : null,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Title input
                      TextField(
                        controller: titleController,
                        decoration: InputDecoration(
                          labelText: 'Título da meta',
                          hintText: 'Ex: Meditar todos os dias',
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
                      const SizedBox(height: 16),

                      // Description input
                      TextField(
                        controller: descController,
                        maxLines: 2,
                        decoration: InputDecoration(
                          labelText: 'Descrição (opcional)',
                          hintText: 'Descreva sua meta...',
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
                      const SizedBox(height: 20),

                      // Target value
                      Text('Meta de dias', style: theme.labelMedium),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          IconButton(
                            onPressed: () {
                              if (targetValue > 1) {
                                setState(() => targetValue--);
                              }
                            },
                            icon: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: theme.primaryBackground,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.remove, color: theme.primary),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              decoration: BoxDecoration(
                                color: theme.primaryBackground,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Center(
                                child: Text(
                                  '$targetValue dias',
                                  style: theme.titleMedium.override(
                                    color: theme.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () => setState(() => targetValue++),
                            icon: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: theme.primary,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.add, color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Frequency selector
                      Text('Frequência', style: theme.labelMedium),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _FrequencyChip(
                            label: 'Diária',
                            value: 'diaria',
                            selected: selectedFrequency,
                            onTap: () =>
                                setState(() => selectedFrequency = 'diaria'),
                          ),
                          const SizedBox(width: 8),
                          _FrequencyChip(
                            label: 'Semanal',
                            value: 'semanal',
                            selected: selectedFrequency,
                            onTap: () =>
                                setState(() => selectedFrequency = 'semanal'),
                          ),
                          const SizedBox(width: 8),
                          _FrequencyChip(
                            label: 'Mensal',
                            value: 'mensal',
                            selected: selectedFrequency,
                            onTap: () =>
                                setState(() => selectedFrequency = 'mensal'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),

                      // Create button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () async {
                            if (titleController.text.isEmpty) return;
                            await _model.addMeta(
                              titulo: titleController.text,
                              descricao: descController.text.isEmpty
                                  ? null
                                  : descController.text,
                              metaValor: targetValue,
                              icone: selectedEmoji,
                              cor: selectedColor,
                              frequencia: selectedFrequency,
                            );
                            if (context.mounted) Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.primary,
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 8,
                            shadowColor: theme.primary.withValues(alpha: 0.5),
                          ),
                          child: Text(
                            'Criar Meta',
                            style: theme.titleSmall.override(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<GoalsModel>.value(
      value: _model,
      child: Consumer<GoalsModel>(
        builder: (context, model, child) {
          final theme = FlutterFlowTheme.of(context);

          return Scaffold(
            backgroundColor: theme.primaryBackground,
            floatingActionButton: ScaleTransition(
              scale: _fabAnimation,
              child: FloatingActionButton.extended(
                onPressed: () => _showAddGoalSheet(context),
                backgroundColor: theme.primary,
                elevation: 8,
                icon: const Icon(Icons.add_rounded, color: Colors.white),
                label: Text(
                  'Nova Meta',
                  style: theme.labelMedium.override(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            body: Stack(
              children: [
                SafeArea(
                  child: model.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : RefreshIndicator(
                          onRefresh: model.loadMetas,
                          color: theme.primary,
                          child: CustomScrollView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            slivers: [
                              // Header
                              SliverToBoxAdapter(
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Minhas Metas',
                                        style: theme.headlineMedium.override(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Acompanhe seu progresso diário',
                                        style: theme.bodyMedium.override(
                                          color: theme.secondaryText,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              // Stats cards
                              SliverToBoxAdapter(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: _StatsCard(
                                          icon: Icons.track_changes_rounded,
                                          value: '${model.metasAtivas.length}',
                                          label: 'Ativas',
                                          color: theme.primary,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: _StatsCard(
                                          icon: Icons.check_circle_rounded,
                                          value:
                                              '${model.metasConcluidas.length}',
                                          label: 'Concluídas',
                                          color: theme.success,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              const SliverToBoxAdapter(
                                child: SizedBox(height: 24),
                              ),

                              // Active goals section
                              if (model.metasAtivas.isNotEmpty) ...[
                                SliverToBoxAdapter(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                    ),
                                    child: Text(
                                      'Em andamento',
                                      style: theme.titleMedium,
                                    ),
                                  ),
                                ),
                                const SliverToBoxAdapter(
                                  child: SizedBox(height: 12),
                                ),
                                SliverPadding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                  ),
                                  sliver: SliverList(
                                    delegate: SliverChildBuilderDelegate((
                                      context,
                                      index,
                                    ) {
                                      final meta = model.metasAtivas[index];
                                      return GoalCard(
                                        meta: meta,
                                        index: index,
                                        onIncrement: () =>
                                            model.incrementProgress(meta),
                                        onDelete: () =>
                                            model.deleteMeta(meta.id),
                                      );
                                    }, childCount: model.metasAtivas.length),
                                  ),
                                ),
                              ],

                              // Completed goals section
                              if (model.metasConcluidas.isNotEmpty) ...[
                                const SliverToBoxAdapter(
                                  child: SizedBox(height: 16),
                                ),
                                SliverToBoxAdapter(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                    ),
                                    child: Text(
                                      'Concluídas 🎉',
                                      style: theme.titleMedium,
                                    ),
                                  ),
                                ),
                                const SliverToBoxAdapter(
                                  child: SizedBox(height: 12),
                                ),
                                SliverPadding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                  ),
                                  sliver: SliverList(
                                    delegate: SliverChildBuilderDelegate(
                                      (context, index) {
                                        final meta =
                                            model.metasConcluidas[index];
                                        return GoalCard(
                                          meta: meta,
                                          index:
                                              index + model.metasAtivas.length,
                                        );
                                      },
                                      childCount: model.metasConcluidas.length,
                                    ),
                                  ),
                                ),
                              ],

                              // Empty state
                              if (model.metas.isEmpty)
                                SliverFillRemaining(
                                  child: _EmptyState(theme: theme),
                                ),

                              // Bottom padding for FAB
                              const SliverToBoxAdapter(
                                child: SizedBox(height: 100),
                              ),
                            ],
                          ),
                        ),
                ),

                // Celebration overlay
                if (model.showCelebration)
                  CelebrationOverlay(
                    emoji: model.celebrationEmoji ?? '🎯',
                    onComplete: () => model.hideCelebration(),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _FrequencyChip extends StatelessWidget {
  final String label;
  final String value;
  final String selected;
  final VoidCallback onTap;

  const _FrequencyChip({
    required this.label,
    required this.value,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final isSelected = value == selected;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? theme.primary : theme.primaryBackground,
          borderRadius: BorderRadius.circular(12),
          border: isSelected ? null : Border.all(color: theme.alternate),
        ),
        child: Text(
          label,
          style: theme.labelMedium.override(
            color: isSelected ? Colors.white : theme.primaryText,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

class _StatsCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _StatsCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: theme.headlineSmall.override(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                label,
                style: theme.labelSmall.override(color: theme.secondaryText),
              ),
            ],
          ),
        ],
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
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: theme.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Text('🎯', style: const TextStyle(fontSize: 48)),
            ),
            const SizedBox(height: 24),
            Text(
              'Nenhuma meta ainda',
              style: theme.titleMedium.override(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              'Crie sua primeira meta e comece\na acompanhar seu progresso!',
              textAlign: TextAlign.center,
              style: theme.bodyMedium.override(color: theme.secondaryText),
            ),
          ],
        ),
      ),
    );
  }
}
