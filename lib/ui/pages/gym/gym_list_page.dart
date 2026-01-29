// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:auto_size_text/auto_size_text.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

// Project imports:
import 'package:sentimento_app/core/nav/nav.dart';
import 'package:sentimento_app/core/theme.dart';
import 'package:sentimento_app/core/util.dart';
import 'package:sentimento_app/ui/pages/gym/gym_list_model.dart';

class GymListPage extends StatefulWidget {
  const GymListPage({super.key});

  static String routeName = 'GymList';
  static String routePath = '/gym';

  @override
  State<GymListPage> createState() => _GymListPageState();
}

class _GymListPageState extends State<GymListPage> {
  late GymListModel _model;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => GymListModel());
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

    return Scaffold(
      backgroundColor: theme.primaryBackground,
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await context.pushNamedAuth('GymRegister', mounted);
          await _model.loadData();
        },
        backgroundColor: theme.primary,
        elevation: 8,
        child: Icon(Icons.add_rounded, color: theme.info, size: 24),
      ),
      body: SafeArea(
        top: true,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(24, 24, 24, 0),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  AutoSizeText(
                    'Treino do Dia',
                    style: theme.displaySmall.override(
                      fontFamily: 'Outfit',
                      color: theme.primaryText,
                    ),
                  ),
                  Icon(
                    FontAwesomeIcons.dumbbell,
                    color: theme.primary,
                    size: 24,
                  ),
                ],
              ),
            ),
            Expanded(
              child: Consumer<GymListModel>(
                builder: (context, model, child) {
                  if (model.isLoading) {
                    return Center(
                      child: CircularProgressIndicator(color: theme.primary),
                    );
                  }

                  if (model.todaysExercises.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.fitness_center_rounded,
                            color: theme.secondaryText,
                            size: 64,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Nenhum treino cadastrado\npara hoje',
                            textAlign: TextAlign.center,
                            style: theme.headlineSmall.override(
                              fontFamily: 'Outfit',
                              color: theme.secondaryText,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(24),
                    itemCount: model.todaysExercises.length,
                    itemBuilder: (context, index) {
                      final exercise = model.todaysExercises[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Container(
                          decoration: BoxDecoration(
                            color: theme.secondaryBackground,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                blurRadius: 4,
                                color: const Color(0x33000000),
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        exercise.name,
                                        style: theme.bodyLarge.override(
                                          fontFamily: 'Outfit',
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    if (exercise.machinePhotoUrl != null)
                                      Icon(
                                        Icons.image_rounded,
                                        color: theme.primary,
                                        size: 20,
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                if (exercise.exerciseSeries != null ||
                                    exercise.exerciseQty != null)
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.repeat_rounded,
                                        color: theme.secondaryText,
                                        size: 16,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Execução: ${exercise.exerciseSeries ?? "-"}x ${exercise.exerciseQty ?? "-"}',
                                        style: theme.bodyMedium,
                                      ),
                                    ],
                                  ),
                                if (exercise.stretchingSeries != null ||
                                    exercise.stretchingQty != null)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.accessibility_new_rounded,
                                          color: theme.secondaryText,
                                          size: 16,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          'Alongamento: ${exercise.stretchingSeries ?? "-"}x ${exercise.stretchingQty ?? "-"}',
                                          style: theme.bodyMedium,
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
