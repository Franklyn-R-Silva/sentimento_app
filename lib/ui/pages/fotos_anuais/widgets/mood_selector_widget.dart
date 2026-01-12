// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:sentimento_app/core/theme.dart';
import 'package:sentimento_app/ui/shared/widgets/gradient_card.dart';
import 'package:sentimento_app/ui/shared/widgets/mood_selector.dart';
import '../fotos_anuais.model.dart';

class MoodSelectorWidget extends StatefulWidget {
  final FotosAnuaisModel model;

  const MoodSelectorWidget({super.key, required this.model});

  @override
  State<MoodSelectorWidget> createState() => _MoodSelectorWidgetState();
}

class _MoodSelectorWidgetState extends State<MoodSelectorWidget> {
  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);

    // Ensure we handle updates when model changes if needed,
    // but here we are stateless mostly, except for SetState to refresh UI if model doesn't notify.
    // Actually, passing 'model.moodLevel' to MoodSelector is fine, but we need to rebuild when it changes.
    // Since FotosAnuaisModel is likely a ChangeNotifier, we might need to wrap in ListenableBuilder or just setState.
    // But the original widget was StatelessWidget and seemingly didn't listen to model, just set it?
    // The original widget was StatelessWidget using 'model.moodLevel'.
    // If 'model' is not listened to, the UI won't update when tapped unless the PARENT rebuilds.
    // But the original code had GestureDetector -> model.moodLevel = level.
    // It used `AnimatedContainer`, so it MUST have been rebuilding?
    // Ah, `AnimatedContainer` handles animation, but `isSelected` calculation depends on `build`.
    // If `FotosAnuaisPage` calls `setState` when model changes, then it works.
    // Or if `MoodSelectorWidget` was Stateful? No, it was Stateless.
    // This implies the parent (Page) rebuilds or the user click didn't update UI immediately?
    // Actually, looking at original code:
    // `onTap: () => model.moodLevel = level,`
    // It DOES NOT call setState.
    // This looks like a bug in the original code! The selection wouldn't update visually unless something else triggered a rebuild.
    // I will fix this by making it Stateful and calling setState.

    return GradientCard(
      moodLevel: widget.model.moodLevel ?? 3,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Como você está se sentindo?',
              style: theme.typography.titleMedium.copyWith(color: Colors.white),
            ),
            const SizedBox(height: 16),
            MoodSelector(
              selectedMood: widget.model.moodLevel ?? 3,
              onMoodSelected: (val) {
                setState(() {
                  widget.model.moodLevel = val;
                });
              },
              showLabels: false,
            ),
          ],
        ),
      ),
    );
  }
}
