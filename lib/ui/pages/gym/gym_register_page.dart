// Dart imports:
import 'dart:io';

// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:provider/provider.dart';

// Project imports:
import 'package:sentimento_app/core/theme.dart';
import 'package:sentimento_app/core/util.dart';
import 'package:sentimento_app/ui/pages/gym/gym_register_model.dart';

class GymRegisterPage extends StatefulWidget {
  const GymRegisterPage({super.key});

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
          'Novo Exercício',
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

                    // Dia da Semana
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
                            controller: model.exerciseSeriesController,
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
                            validator: (val) {
                              if (val == null || val.isEmpty) return 'Informe';
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: model.exerciseQtyController,
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
                            validator: (val) {
                              if (val == null || val.isEmpty) return 'Informe';
                              return null;
                            },
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
                    const SizedBox(height: 8),
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
                              labelText: 'Segundos/Rep',
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

                    // Foto da Maquina
                    Text(
                      'Foto da Máquina (Opcional)',
                      style: theme.titleMedium.override(
                        fontFamily: 'Outfit',
                        color: theme.secondaryText,
                      ),
                    ),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: () => model.pickImage(),
                      child: Container(
                        width: double.infinity,
                        height: 200,
                        decoration: BoxDecoration(
                          color: theme.secondaryBackground,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: theme.alternate,
                            width: 2,
                            style: BorderStyle.solid,
                          ),
                        ),
                        child: model.selectedImage != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.file(
                                  File(model.selectedImage!.path),
                                  fit: BoxFit.cover,
                                ),
                              )
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.camera_alt_rounded,
                                    color: theme.secondaryText,
                                    size: 48,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Toque para tirar foto',
                                    style: theme.bodyMedium.override(
                                      color: theme.secondaryText,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                    if (model.selectedImage != null)
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton.icon(
                          onPressed: () => model.removeImage(),
                          icon: const Icon(Icons.delete, color: Colors.red),
                          label: const Text(
                            'Remover foto',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
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
                                  context.safePop();
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
                                'Salvar Exercício',
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
    );
  }
}
