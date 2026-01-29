import 'package:flutter/material.dart';
import 'package:sentimento_app/backend/tables/gym_exercises.dart';
import 'package:sentimento_app/core/theme.dart';

class GymExerciseInfo extends StatelessWidget {
  const GymExerciseInfo({super.key, required this.exercise});

  final GymExercisesRow exercise;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);

    return Wrap(
      spacing: 12,
      runSpacing: 8,
      children: [
        // Sets x Reps
        if (exercise.sets != null || exercise.reps != null)
          _buildInfoItem(
            theme,
            Icons.repeat_rounded,
            '${exercise.sets ?? "-"}x ${exercise.reps ?? "-"}',
          ),

        // Weight
        if (exercise.weight != null)
          _buildInfoItem(
            theme,
            Icons.fitness_center_rounded,
            '${exercise.weight!.toStringAsFixed(1).replaceAll('.0', '')} kg',
          ),

        // Rest Time
        if (exercise.restTime != null)
          _buildInfoItem(theme, Icons.timer_outlined, '${exercise.restTime}s'),

        // Time text
        if (exercise.exerciseTime != null && exercise.exerciseTime!.isNotEmpty)
          _buildInfoItem(theme, Icons.timer_rounded, exercise.exerciseTime!),
      ],
    );
  }

  Widget _buildInfoItem(FlutterFlowTheme theme, IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: theme.secondaryText, size: 16),
        const SizedBox(width: 4),
        Text(text, style: theme.bodyMedium),
      ],
    );
  }
}
