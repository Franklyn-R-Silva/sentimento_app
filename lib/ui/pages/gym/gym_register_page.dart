// Dart imports:

// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/cupertino.dart';

// Package imports:
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Project imports:
import 'package:sentimento_app/backend/tables/gym_exercises.dart';
import 'package:sentimento_app/backend/tables/gym_workouts.dart';
import 'package:sentimento_app/core/theme.dart';
import 'package:sentimento_app/core/util.dart';
import 'package:sentimento_app/ui/pages/gym/gym_register_model.dart';
import 'package:sentimento_app/ui/pages/gym/widgets/gym_photo_picker.dart';

class GymRegisterPage extends StatefulWidget {
  const GymRegisterPage({super.key, this.exercise, this.isDuplication = false});

  final GymExercisesRow? exercise;
  final bool isDuplication;

  static String routeName = 'GymRegister';
  static String routePath = '/gym/register';

  @override
  State<GymRegisterPage> createState() => _GymRegisterPageState();
}

class _GymRegisterPageState extends State<GymRegisterPage> {
  late GymRegisterModel _model;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => GymRegisterModel());
    if (widget.exercise != null) {
      _model.initFromExercise(
        widget.exercise!,
        isDuplication: widget.isDuplication,
      );
    }
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
    final isEditing = widget.exercise != null;

    return ChangeNotifierProvider.value(
      value: _model,
      child: Scaffold(
        backgroundColor: theme.primaryBackground,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_rounded,
              color: theme.primaryText,
              size: 30,
            ),
            onPressed: () => context.safePop(),
          ),
          title: Text(
            isEditing ? 'Editar Exercício' : 'Novo Exercício',
            style: theme.headlineMedium.override(
              fontFamily: 'Outfit',
              color: theme.primaryText,
              fontSize: 22,
            ),
          ),
          centerTitle: false,
        ),
        body: SafeArea(
          child: Consumer<GymRegisterModel>(
            builder: (context, model, child) {
              return SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: model.formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Detalhes do Exercício',
                        style: theme.headlineSmall.override(
                          fontFamily: 'Outfit',
                          color: theme.primaryText,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Nome
                      TextFormField(
                        controller: model.nameController,
                        textCapitalization: TextCapitalization.sentences,
                        decoration: InputDecoration(
                          labelText: 'Nome do Exercício',
                          labelStyle: theme.labelMedium,
                          hintText: 'Ex: Supino Reto',
                          hintStyle: theme.labelMedium,
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: theme.alternate,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: theme.primary,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          filled: true,
                          fillColor: theme.secondaryBackground,
                        ),
                        style: theme.bodyMedium,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor, insira o nome do exercício';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Category Dropdown
                      DropdownButtonFormField<String>(
                        value: model.selectedCategory,
                        items: model.categories.map((cat) {
                          return DropdownMenuItem(value: cat, child: Text(cat));
                        }).toList(),
                        onChanged: (val) => model.selectedCategory = val,
                        decoration: InputDecoration(
                          labelText: 'Categoria',
                          labelStyle: theme.labelMedium,
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: theme.alternate,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: theme.primary,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          filled: true,
                          fillColor: theme.secondaryBackground,
                        ),
                        style: theme.bodyMedium.override(
                          color: theme.primaryText,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Muscle Group Dropdown
                      DropdownButtonFormField<String>(
                        value: model.selectedMuscleGroup,
                        items: model.muscleGroups.map((group) {
                          return DropdownMenuItem(
                            value: group,
                            child: Text(group),
                          );
                        }).toList(),
                        onChanged: (val) => model.selectedMuscleGroup = val,
                        decoration: InputDecoration(
                          labelText: 'Grupo Muscular',
                          labelStyle: theme.labelMedium,
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: theme.alternate,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: theme.primary,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          filled: true,
                          fillColor: theme.secondaryBackground,
                        ),
                        style: theme.bodyMedium.override(
                          color: theme.primaryText,
                        ),
                      ),
                      const SizedBox(height: 16),

                      DropdownButtonFormField<String>(
                        value: model.selectedDay,
                        items: model.daysOfWeek.map((day) {
                          return DropdownMenuItem(value: day, child: Text(day));
                        }).toList(),
                        onChanged: (val) => model.selectedDay = val,
                        decoration: InputDecoration(
                          labelText: 'Dia da Semana',
                          labelStyle: theme.labelMedium,
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: theme.alternate,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: theme.primary,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          filled: true,
                          fillColor: theme.secondaryBackground,
                        ),
                        style: theme.bodyMedium.override(
                          color: theme.primaryText,
                        ),
                        icon: Icon(
                          Icons.calendar_today_rounded,
                          color: theme.secondaryText,
                          size: 20,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Workout Group
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value:
                                  (model.workouts.any(
                                    (w) => w.id == model.selectedWorkoutId,
                                  ))
                                  ? model.selectedWorkoutId
                                  : null,
                              items: [
                                const DropdownMenuItem(
                                  value: null,
                                  child: Text('Nenhum Grupo'),
                                ),
                                ...model.workouts.map((w) {
                                  return DropdownMenuItem(
                                    value: w.id,
                                    child: Text(w.name),
                                  );
                                }),
                              ],
                              onChanged: (val) => model.selectedWorkoutId = val,
                              decoration: InputDecoration(
                                labelText: 'Grupo de Treino',
                                labelStyle: theme.labelMedium,
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: theme.alternate,
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: theme.primary,
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                filled: true,
                                fillColor: theme.secondaryBackground,
                              ),
                              style: theme.bodyMedium.override(
                                color: theme.primaryText,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: Icon(
                              Icons.add_box_rounded,
                              color: theme.primary,
                            ),
                            onPressed: () =>
                                _showAddWorkoutDialog(context, model),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Execução
                      Text(
                        'Execução (Obrigatório)',
                        style: theme.titleMedium.override(
                          fontFamily: 'Outfit',
                          color: theme.primaryText,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: model.setsController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: 'Séries',
                                hintText: 'Ex: 3',
                                filled: true,
                                fillColor: theme.secondaryBackground,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                              style: theme.bodyMedium,
                              validator: (val) {
                                if (val == null || val.isEmpty) {
                                  return 'Obrigatório';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller:
                                  model.repsController, // Text input for range
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: 'Repetições',
                                hintText: 'Ex: 12-15',
                                filled: true,
                                fillColor: theme.secondaryBackground,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                              style: theme.bodyMedium,
                              validator: (val) {
                                // Reps required unless valid time is set?
                                // For simplicity, make it required or check time in Model.
                                // But usually simple approach is better.
                                if (val == null || val.isEmpty) {
                                  final hasTime =
                                      model.minutesController.text.isNotEmpty ||
                                      model.secondsController.text.isNotEmpty;
                                  if (!hasTime) return 'Obrigatório';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () async {
                                final currentMin =
                                    int.tryParse(
                                      model.minutesController.text,
                                    ) ??
                                    0;
                                final currentSec =
                                    int.tryParse(
                                      model.secondsController.text,
                                    ) ??
                                    0;

                                await showModalBottomSheet<void>(
                                  context: context,
                                  builder: (context) => Container(
                                    height: 300,
                                    color: theme.secondaryBackground,
                                    child: Column(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 8,
                                          ),
                                          decoration: BoxDecoration(
                                            border: Border(
                                              bottom: BorderSide(
                                                color: theme.alternate,
                                              ),
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              TextButton(
                                                onPressed: () =>
                                                    Navigator.pop(context),
                                                child: Text(
                                                  'Cancelar',
                                                  style: TextStyle(
                                                    color: theme.secondaryText,
                                                  ),
                                                ),
                                              ),
                                              Text(
                                                'Selecionar Tempo',
                                                style: theme.bodyLarge.override(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              TextButton(
                                                onPressed: () =>
                                                    Navigator.pop(context),
                                                child: Text(
                                                  'OK',
                                                  style: TextStyle(
                                                    color: theme.primary,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Expanded(
                                          child: CupertinoTimerPicker(
                                            mode: CupertinoTimerPickerMode.ms,
                                            initialTimerDuration: Duration(
                                              minutes: currentMin,
                                              seconds: currentSec,
                                            ),
                                            onTimerDurationChanged:
                                                (Duration newDuration) {
                                                  model.minutesController.text =
                                                      newDuration.inMinutes
                                                          .toString();
                                                  model.secondsController.text =
                                                      (newDuration.inSeconds %
                                                              60)
                                                          .toString();
                                                  setState(() {});
                                                },
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                              child: IgnorePointer(
                                child: TextFormField(
                                  controller: TextEditingController(
                                    text:
                                        (model.minutesController.text.isEmpty &&
                                            model
                                                .secondsController
                                                .text
                                                .isEmpty)
                                        ? ''
                                        : '${model.minutesController.text.isEmpty ? '0' : model.minutesController.text}m ${model.secondsController.text.isEmpty ? '0' : model.secondsController.text}s',
                                  ),
                                  decoration: InputDecoration(
                                    labelText: 'Tempo de Exercício',
                                    hintText: 'Selecionar tempo',
                                    prefixIcon: Icon(
                                      Icons.timer_outlined,
                                      color: theme.secondaryText,
                                    ),
                                    filled: true,
                                    fillColor: theme.secondaryBackground,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide.none,
                                    ),
                                  ),
                                  style: theme.bodyMedium,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: model.weightController,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                              decoration: InputDecoration(
                                labelText: 'Carga (kg)',
                                hintText: 'Ex: 20.5',
                                filled: true,
                                fillColor: theme.secondaryBackground,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                              style: theme.bodyMedium,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: model.restTimeController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: 'Descanso (s)',
                                hintText: 'Ex: 60',
                                filled: true,
                                fillColor: theme.secondaryBackground,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                              style: theme.bodyMedium,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: model.elevationController,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                              decoration: InputDecoration(
                                labelText: 'Elevação (%)',
                                hintText: 'Ex: 5.0',
                                prefixIcon: Icon(
                                  Icons.trending_up_rounded,
                                  color: theme.secondaryText,
                                ),
                                filled: true,
                                fillColor: theme.secondaryBackground,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                              style: theme.bodyMedium,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: model.speedController,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                              decoration: InputDecoration(
                                labelText: 'Velocidade',
                                hintText: 'Ex: 10.0',
                                prefixIcon: Icon(
                                  Icons.speed_rounded,
                                  color: theme.secondaryText,
                                ),
                                filled: true,
                                fillColor: theme.secondaryBackground,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                              style: theme.bodyMedium,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Alongamento (Opcional)
                      Text(
                        'Alongamento (Opcional)',
                        style: theme.titleMedium.override(
                          fontFamily: 'Outfit',
                          color: theme.secondaryText,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: model.stretchingNameController,
                        textCapitalization: TextCapitalization.sentences,
                        decoration: InputDecoration(
                          labelText: 'Nome do Alongamento',
                          filled: true,
                          fillColor: theme.secondaryBackground,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        style: theme.bodyMedium,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: model.stretchingSeriesController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: 'Séries',
                                filled: true,
                                fillColor: theme.secondaryBackground,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                              style: theme.bodyMedium,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: model.stretchingQtyController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: 'Repetições',
                                filled: true,
                                fillColor: theme.secondaryBackground,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                              style: theme.bodyMedium,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: model.stretchingTimeController,
                        decoration: InputDecoration(
                          labelText: 'Tempo (Opcional)',
                          hintText: 'Ex: 30s',
                          filled: true,
                          fillColor: theme.secondaryBackground,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        style: theme.bodyMedium,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Fotos do Alongamento (Opcional)',
                        style: theme.bodyMedium.override(
                          fontFamily: 'Outfit',
                          color: theme.secondaryText,
                        ),
                      ),
                      const SizedBox(height: 8),
                      GymPhotoPicker(
                        images: model.selectedStretchingImages,
                        existingImages: model.existingStretchingImages,
                        onPickImages: () => model.pickStretchingImages(),
                        onRemoveImage: (index) =>
                            model.removeStretchingImage(index),
                        onRemoveExistingImage: (index) =>
                            model.removeExistingStretchingImage(index),
                      ),
                      const SizedBox(height: 24),

                      // Fotos (Carousel)
                      Text(
                        'Fotos da Máquina (Opcional)',
                        style: theme.titleMedium.override(
                          fontFamily: 'Outfit',
                          color: theme.secondaryText,
                        ),
                      ),
                      const SizedBox(height: 8),
                      GymPhotoPicker(
                        images: model.selectedImages,
                        existingImages: model.existingMachineImages,
                        onPickImages: () => model.pickImages(),
                        onRemoveImage: (index) => model.removeImage(index),
                        onRemoveExistingImage: (index) =>
                            model.removeExistingMachineImage(index),
                      ),
                      const SizedBox(height: 32),

                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: model.isLoading
                              ? null
                              : () async {
                                  final success = await model.saveExercise(
                                    context,
                                  );
                                  if (success && context.mounted) {
                                    Navigator.pop(context, success);
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: model.isLoading
                              ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                              : Text(
                                  isEditing
                                      ? 'Salvar Alterações'
                                      : 'Salvar Exercício',
                                  style: theme.titleSmall.override(
                                    fontFamily: 'Outfit',
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> _showAddWorkoutDialog(
    BuildContext context,
    GymRegisterModel model,
  ) async {
    final theme = FlutterFlowTheme.of(context);
    final nameController = TextEditingController();
    final groupController = TextEditingController();
    final descController = TextEditingController();

    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Novo Grupo de Treino'),
        backgroundColor: theme.secondaryBackground,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: nameController,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Nome (Ex: Treino A)',
              ),
              style: theme.bodyMedium,
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: groupController,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Foco (Ex: Costas e Bíceps)',
              ),
              style: theme.bodyMedium,
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: descController,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Info extra (Ex: 3x15 Mobilidade)',
              ),
              style: theme.bodyMedium,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.isEmpty) return;
              try {
                final supabase = Supabase.instance.client;
                final userId = supabase.auth.currentUser?.id;
                if (userId == null) return;

                final data = {
                  'user_id': userId,
                  'name': nameController.text,
                  'muscle_group': groupController.text,
                  'description': descController.text,
                  'created_at': DateTime.now().toIso8601String(),
                };

                await GymWorkoutsTable().insert(data);
                await model.loadWorkouts();
                if (context.mounted) Navigator.pop(context);
              } catch (e) {
                Logger().e('Error creating workout: $e');
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: theme.primary),
            child: const Text('Criar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
