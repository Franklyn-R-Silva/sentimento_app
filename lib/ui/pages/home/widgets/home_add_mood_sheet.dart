// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:logger/logger.dart';

// Project imports:
import 'package:sentimento_app/core/theme.dart';
import 'package:sentimento_app/ui/shared/widgets/mood_selector.dart';
import 'package:sentimento_app/ui/shared/widgets/tag_selector.dart';

class HomeAddMoodSheet extends StatefulWidget {
  final void Function(int mood, String? note, List<String> tags) onSave;

  const HomeAddMoodSheet({super.key, required this.onSave});

  @override
  State<HomeAddMoodSheet> createState() => _HomeAddMoodSheetState();
}

class _HomeAddMoodSheetState extends State<HomeAddMoodSheet> {
  int selectedMood = 3;
  List<String> selectedTags = [];
  late TextEditingController textController;

  @override
  void initState() {
    super.initState();
    textController = TextEditingController();
  }

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Logger().t('HomeAddMoodSheet: build called');
    final theme = FlutterFlowTheme.of(context);

    // Handle keyboard padding
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
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

              Center(
                child: Text(
                  'Como você está se sentindo?',
                  style: theme.titleMedium,
                ),
              ),
              const SizedBox(height: 16),

              // Mood selector
              MoodSelector(
                selectedMood: selectedMood,
                onMoodSelected: (mood) => setState(() => selectedMood = mood),
              ),

              const SizedBox(height: 24),

              // Tags Section
              Text(
                'O que está acontecendo?',
                style: theme.titleSmall.override(
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 16),
              TagSelector(
                selectedTags: selectedTags,
                onSelectionChanged: (tags) =>
                    setState(() => selectedTags = tags),
              ),

              const SizedBox(height: 32),

              // Note input
              Text(
                'Quer adicionar algum detalhe?',
                style: theme.titleSmall.override(
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: textController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Hoje eu senti gratidão por...',
                  hintStyle: theme.bodyMedium.override(
                    color: theme.secondaryText.withValues(alpha: 0.7),
                  ),
                  filled: true,
                  fillColor: theme.primaryBackground,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide(
                      color: theme.alternate.withValues(alpha: 0.3),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide(
                      color: theme.primary.withValues(alpha: 0.5),
                      width: 1.5,
                    ),
                  ),
                  contentPadding: const EdgeInsets.all(20),
                ),
                style: theme.bodyMedium,
                cursorColor: theme.primary,
              ),

              const SizedBox(height: 32),

              // Save button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    widget.onSave(
                      selectedMood,
                      textController.text.isEmpty ? null : textController.text,
                      selectedTags,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.primary,
                    foregroundColor: Colors.white,
                    elevation: 4,
                    shadowColor: theme.primary.withValues(alpha: 0.4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    'Salvar Registro',
                    style: theme.titleSmall.override(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
