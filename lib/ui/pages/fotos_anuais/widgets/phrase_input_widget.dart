import 'package:flutter/material.dart';
import 'package:sentimento_app/core/theme.dart';
import 'package:sentimento_app/ui/shared/widgets/gradient_card.dart';
import '../fotos_anuais.model.dart';

class PhraseInputWidget extends StatelessWidget {
  final FotosAnuaisModel model;

  const PhraseInputWidget({super.key, required this.model});

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);

    return GradientCard(
      moodLevel: model.moodLevel ?? 3,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Uma frase para hoje',
              style: theme.typography.titleMedium.copyWith(color: Colors.white),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: model.fraseController,
              maxLines: 3,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Como foi o seu dia? Escreva algo marcante...',
                hintStyle: TextStyle(
                  color: Colors.white.withValues(alpha: 0.6),
                ),
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.2),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.all(16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
