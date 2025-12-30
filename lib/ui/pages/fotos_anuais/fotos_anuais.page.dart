import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:sentimento_app/core/theme.dart';
import 'package:sentimento_app/core/util.dart';
import 'package:sentimento_app/ui/pages/fotos_anuais/fotos_anuais.model.dart';
import 'package:sentimento_app/ui/shared/widgets/gradient_card.dart';

class FotosAnuaisPage extends StatefulWidget {
  const FotosAnuaisPage({super.key});

  @override
  State<FotosAnuaisPage> createState() => _FotosAnuaisPageState();
}

class _FotosAnuaisPageState extends State<FotosAnuaisPage> {
  late FotosAnuaisModel _model;

  @override
  void initState() {
    super.initState();
    _model = FotosAnuaisModel();
    _model.initState(context);
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);

    return ChangeNotifierProvider.value(
      value: _model,
      child: GestureDetector(
        onTap: () => FocusScope.of(context).requestFocus(_model.unfocusNode),
        child: Scaffold(
          backgroundColor: theme.primaryBackground,
          appBar: AppBar(
            backgroundColor: theme.primary,
            automaticallyImplyLeading: true,
            title: Text(
              'Fotos 365 Dias',
              style: theme.typography.headlineMedium.override(
                color: Colors.white,
                fontSize: 22,
              ),
            ),
            actions: [],
            centerTitle: false,
            elevation: 2,
          ),
          body: SafeArea(
            top: true,
            child: Consumer<FotosAnuaisModel>(
              builder: (context, model, child) {
                return SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(
                          16,
                          24,
                          16,
                          0,
                        ),
                        child: Text(
                          'Capture um momento especial todos os dias para o seu vídeo de retrospectiva!',
                          textAlign: TextAlign.center,
                          style: theme.typography.bodyLarge,
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(
                          0,
                          16,
                          0,
                          0,
                        ),
                        child: GradientCard(
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              if (model.selectedImageBytes != null)
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.memory(
                                    model.selectedImageBytes!,
                                    width: double.infinity,
                                    height: 300,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              else
                                Container(
                                  width: double.infinity,
                                  height: 200,
                                  decoration: BoxDecoration(
                                    color: theme.accent4,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: theme.alternate,
                                      width: 2,
                                    ),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.add_a_photo_outlined,
                                        color: theme.secondaryText,
                                        size: 48,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Nenhuma foto selecionada',
                                        style: theme.typography.labelMedium,
                                      ),
                                    ],
                                  ),
                                ),

                              const SizedBox(height: 16),

                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  _actionButton(
                                    context,
                                    icon: Icons.camera_alt,
                                    label: 'Tirar Foto',
                                    onTap: () => model.pickImage(
                                      context,
                                      ImageSource.camera,
                                    ),
                                  ),
                                  _actionButton(
                                    context,
                                    icon: Icons.photo_library,
                                    label: 'Galeria',
                                    onTap: () => model.pickImage(
                                      context,
                                      ImageSource.gallery,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(
                          16,
                          16,
                          16,
                          0,
                        ),
                        child: GradientCard(
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Como você está se sentindo?',
                                style: theme.typography.titleMedium,
                              ),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  _moodOption(context, 1, '😢'),
                                  _moodOption(context, 2, '😟'),
                                  _moodOption(context, 3, '😐'),
                                  _moodOption(context, 4, '🙂'),
                                  _moodOption(context, 5, '😄'),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(
                          16,
                          16,
                          16,
                          0,
                        ),
                        child: GradientCard(
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Frase (Opcional)',
                                style: theme.typography.titleMedium,
                              ),
                              const SizedBox(height: 12),
                              TextFormField(
                                controller: model.fraseController,
                                decoration: InputDecoration(
                                  hintText:
                                      'Escreva algo sobre este momento...',
                                  hintStyle: theme.typography.labelMedium,
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: theme.alternate,
                                      width: 1,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: theme.primary,
                                      width: 1,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  filled: true,
                                  fillColor: theme.accent4,
                                ),
                                style: theme.typography.bodyMedium,
                                maxLines: 3,
                              ),
                            ],
                          ),
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(
                          16,
                          16,
                          16,
                          0,
                        ),
                        child: GradientCard(
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Data e Hora',
                                style: theme.typography.titleMedium,
                              ),
                              const SizedBox(height: 12),
                              InkWell(
                                onTap: () async {
                                  final date = await showDatePicker(
                                    context: context,
                                    initialDate: model.selectedDate,
                                    firstDate: DateTime(2000),
                                    lastDate: DateTime(2100),
                                  );
                                  if (date != null) {
                                    if (!context.mounted) return;
                                    final time = await showTimePicker(
                                      context: context,
                                      initialTime: TimeOfDay.fromDateTime(
                                        model.selectedDate,
                                      ),
                                    );
                                    if (time != null) {
                                      model.selectedDate = DateTime(
                                        date.year,
                                        date.month,
                                        date.day,
                                        time.hour,
                                        time.minute,
                                      );
                                    }
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: theme.accent4,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        dateTimeFormat(
                                          'd/M/y H:mm',
                                          model.selectedDate,
                                        ),
                                        style: theme.typography.bodyLarge,
                                      ),
                                      Icon(
                                        Icons.calendar_today,
                                        color: theme.primary,
                                        size: 20,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextButton.icon(
                                onPressed: () =>
                                    model.selectedDate = DateTime.now(),
                                icon: const Icon(
                                  Icons.timer_outlined,
                                  size: 16,
                                ),
                                label: const Text('Usar horário atual'),
                                style: TextButton.styleFrom(
                                  foregroundColor: theme.primary,
                                  padding: EdgeInsets.zero,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(
                          16,
                          32,
                          16,
                          40,
                        ),
                        child: ElevatedButton(
                          onPressed: model.isUploading
                              ? null
                              : () async {
                                  final success = await model.savePhoto(
                                    context,
                                  );
                                  if (success && context.mounted) {
                                    // Navigate back or reset
                                    Navigator.pop(context);
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.primary,
                            minimumSize: const Size(double.infinity, 56),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: model.isUploading
                              ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                              : Text(
                                  'Salvar Foto',
                                  style: theme.typography.titleMedium.override(
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _moodOption(BuildContext context, int level, String emoji) {
    final theme = FlutterFlowTheme.of(context);
    final isSelected = _model.moodLevel == level;

    return InkWell(
      onTap: () => _model.moodLevel = level,
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: isSelected ? theme.primary : theme.accent4,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? theme.primary : theme.alternate,
            width: 2,
          ),
        ),
        child: Center(child: Text(emoji, style: TextStyle(fontSize: 24))),
      ),
    );
  }

  Widget _actionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final theme = FlutterFlowTheme.of(context);
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.primary,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(height: 8),
          Text(label, style: theme.typography.labelMedium),
        ],
      ),
    );
  }
}
