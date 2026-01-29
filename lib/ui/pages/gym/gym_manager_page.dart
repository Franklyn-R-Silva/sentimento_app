// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:provider/provider.dart';

// Project imports:
import 'package:sentimento_app/core/theme.dart';
import 'package:sentimento_app/core/util.dart';
import 'package:sentimento_app/ui/pages/gym/gym_manager_model.dart';
import 'package:sentimento_app/ui/pages/gym/widgets/gym_exercise_card.dart';
import 'package:sentimento_app/ui/pages/gym/widgets/gym_empty_state.dart';
import 'package:sentimento_app/ui/pages/gym/gym_register_page.dart'; // import for navigation logic if needed specifically or just usage of routeName

class GymManagerPage extends StatefulWidget {
  const GymManagerPage({super.key});

  static String routeName = 'GymManager';
  static String routePath = '/gym/manager';

  @override
  State<GymManagerPage> createState() => _GymManagerPageState();
}

class _GymManagerPageState extends State<GymManagerPage> {
  late GymManagerModel _model;

  final List<String> days = [
    'Segunda',
    'Terça',
    'Quarta',
    'Quinta',
    'Sexta',
    'Sábado',
    'Domingo',
  ];

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => GymManagerModel());
    _model.loadData();
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isiOS) {
      SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(
          statusBarBrightness: Theme.of(context).brightness,
          systemStatusBarContrastEnforced: true,
        ),
      );
    }
    final theme = FlutterFlowTheme.of(context);

    // Short day names for tabs
    final shortDays = days.map((d) => d.substring(0, 3)).toList();

    return ChangeNotifierProvider.value(
      value: _model,
      child: DefaultTabController(
        length: days.length,
        child: Scaffold(
          backgroundColor: theme.primaryBackground,
          appBar: AppBar(
            backgroundColor: theme.primary,
            automaticallyImplyLeading: true,
            title: Text(
              'Gerenciar Treinos',
              style: theme.headlineMedium.override(
                fontFamily: 'Outfit',
                color: Colors.white,
                fontSize: 22,
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh, color: Colors.white),
                onPressed: () => _model.loadData(),
              ),
            ],
            centerTitle: false,
            elevation: 2,
            bottom: TabBar(
              isScrollable: true,
              labelColor: Colors.white,
              unselectedLabelColor: const Color(0xB3FFFFFF),
              indicatorColor: Colors.white,
              indicatorWeight: 3,
              labelStyle: theme.titleSmall.override(
                fontFamily: 'Outfit',
                fontWeight: FontWeight.w600,
              ),
              tabs: shortDays.map((d) => Tab(text: d)).toList(),
            ),
          ),
          body: Consumer<GymManagerModel>(
            builder: (context, model, child) {
              if (model.isLoading) {
                return Center(
                  child: CircularProgressIndicator(color: theme.primary),
                );
              }

              return TabBarView(
                children: days.map((day) {
                  final exercises = model.exercisesByDay[day] ?? [];

                  if (exercises.isEmpty) {
                    return GymEmptyState(
                      message: 'Sem exercícios para $day',
                      icon: Icons.fitness_center_outlined,
                      actionLabel: 'Adicionar',
                      onAction: () async {
                        await context.pushNamed(
                          GymRegisterPage.routeName,
                          // We could support passing a default day via extra or query params if needed
                        );
                        await model.loadData();
                      },
                    );
                  }

                  return ReorderableListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: exercises.length,
                    onReorder: (oldIndex, newIndex) {
                      model.reorderExercises(day, oldIndex, newIndex);
                    },
                    itemBuilder: (context, index) {
                      final exercise = exercises[index];
                      return Padding(
                        key: ValueKey(exercise.id),
                        padding: const EdgeInsets.only(bottom: 12),
                        child: GymExerciseCard(exercise: exercise),
                      );
                    },
                  );
                }).toList(),
              );
            },
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () async {
              await context.pushNamed(GymRegisterPage.routeName);
              await _model.loadData();
            },
            backgroundColor: theme.primary,
            child: const Icon(Icons.add, color: Colors.white),
          ),
        ),
      ),
    );
  }
}
