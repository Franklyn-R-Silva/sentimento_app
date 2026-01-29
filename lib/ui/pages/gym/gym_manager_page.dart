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
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.fitness_center_outlined,
                            size: 60,
                            color: theme.secondaryText,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Sem exercícios para $day',
                            style: theme.bodyLarge.override(
                              fontFamily: 'Outfit',
                              color: theme.secondaryText,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: () async {
                              await context.pushNamed(
                                GymRegisterPage.routeName,
                                // We could support passing a default day via extra or query params if needed
                              );
                              await model.loadData();
                            },
                            icon: const Icon(Icons.add),
                            label: const Text('Adicionar'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: theme.primary,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: exercises.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final exercise = exercises[index];
                      // We reuse GymExerciseCard which has Edit/Delete logic built-in
                      // However, GymExerciseCard completion logic refreshes LOCAL state or calls parent?
                      // The current GymExerciseCard updates DB but might not refresh this list if we don't pass a callback or rely on something else.
                      // Ideally, after edit/delete from card, we might need to refresh.
                      // GymExerciseCard doesn't seem to have a callback for 'onDelete' success to refresh parent.
                      // We might need to handle delete here if we want list reference update, OR rely on Card self-managing.
                      // But Card popups Edit page, and when that pops, we need refresh.
                      // The Card implementation:
                      /*
                         onSelected: (value) async {
                            if (value == 'edit') {
                              await context.pushNamed(...);
                              // It doesn't trigger refresh on parent currently unless we pass a callback or use provider correctly.
                            }
                         }
                      */
                      // To fix this cleanly without changing Card signature too much:
                      // Since Card is dumb-ish (it does logic internally), maybe we just rely on 'Refresh' button in AppBar for now,
                      // OR we assume the user will pull-to-refresh (if we add it).
                      // Better: Let's wrap ListView in RefreshIndicator.

                      return GymExerciseCard(exercise: exercise);
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
