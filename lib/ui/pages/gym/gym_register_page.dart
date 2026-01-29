// Dart imports:

// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:provider/provider.dart';

// Project imports:
import 'package:sentimento_app/backend/tables/gym_exercises.dart';
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
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller:
                                  model.repsController, // Text input for range
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
}
