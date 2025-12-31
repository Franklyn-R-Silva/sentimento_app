// Dart imports:
import 'dart:ui';

// Flutter imports:
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

// Project imports:
import 'package:sentimento_app/core/theme.dart';

class GoalsAddSheet extends StatefulWidget {
  final Future<void> Function({
    required String titulo,
    String? descricao,
    required int metaValor,
    required String icone,
    required String cor,
    required String frequencia,
  })
  onSave;

  const GoalsAddSheet({super.key, required this.onSave});

  @override
  State<GoalsAddSheet> createState() => _GoalsAddSheetState();
}

class _GoalsAddSheetState extends State<GoalsAddSheet> {
  final titleController = TextEditingController();
  final descController = TextEditingController();
  int targetValue = 7;
  String selectedEmoji = '🎯';
  String selectedColor = '#7C4DFF';
  String selectedFrequency = 'diaria';
  bool isSaving = false;

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

  @override
  void dispose() {
    titleController.dispose();
    descController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (titleController.text.isEmpty) return;
    if (isSaving) return;

    setState(() => isSaving = true);

    try {
      await widget.onSave(
        titulo: titleController.text,
        descricao: descController.text.isEmpty ? null : descController.text,
        metaValor: targetValue,
        icone: selectedEmoji,
        cor: selectedColor,
        frequencia: selectedFrequency,
      );
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erro ao criar meta: $e')));
      }
    } finally {
      if (mounted) setState(() => isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
      child: Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        decoration: BoxDecoration(
          color: theme.secondaryBackground,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
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
                AutoSizeText(
                  'Nova Meta',
                  style: theme.headlineSmall.override(
                    fontWeight: FontWeight.bold,
                  ),
                  minFontSize: 18,
                ),
                const SizedBox(height: 24),

                // Emoji selector
                AutoSizeText(
                  'Escolha um ícone',
                  style: theme.labelMedium,
                  minFontSize: 10,
                ),
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
                        onTap: () => setState(() => selectedEmoji = emoji),
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
                                ? Border.all(color: theme.primary, width: 2)
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
                AutoSizeText(
                  'Escolha uma cor',
                  style: theme.labelMedium,
                  minFontSize: 10,
                ),
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
                        onTap: () => setState(() => selectedColor = color),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 44,
                          margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            color: parsedColor,
                            shape: BoxShape.circle,
                            border: isSelected
                                ? Border.all(color: Colors.white, width: 3)
                                : null,
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: parsedColor.withValues(alpha: 0.5),
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
                AutoSizeText(
                  'Meta de dias',
                  style: theme.labelMedium,
                  minFontSize: 10,
                ),
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
                          child: AutoSizeText(
                            '$targetValue dias',
                            style: theme.titleMedium.override(
                              color: theme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                            minFontSize: 12,
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
                AutoSizeText(
                  'Frequência',
                  style: theme.labelMedium,
                  minFontSize: 10,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _FrequencyChip(
                      label: 'Diária',
                      value: 'diaria',
                      selected: selectedFrequency,
                      onTap: () => setState(() => selectedFrequency = 'diaria'),
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
                      onTap: () => setState(() => selectedFrequency = 'mensal'),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Create button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isSaving ? null : _handleSave,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.primary,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 8,
                      shadowColor: theme.primary.withValues(alpha: 0.5),
                    ),
                    child: isSaving
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : AutoSizeText(
                            'Criar Meta',
                            style: theme.titleSmall.override(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                            minFontSize: 12,
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
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
        child: AutoSizeText(
          label,
          style: theme.labelMedium.override(
            color: isSelected ? Colors.white : theme.primaryText,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
          minFontSize: 10,
        ),
      ),
    );
  }
}
