// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:sentimento_app/backend/tables/gym_exercises.dart';
import 'package:sentimento_app/core/theme.dart';

class GymExerciseInfo extends StatelessWidget {
  const GymExerciseInfo({super.key, required this.exercise});

  final GymExercisesRow exercise;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);

    final hasReps = exercise.reps != null && exercise.reps!.isNotEmpty;
    final hasTime =
        exercise.exerciseTime != null && exercise.exerciseTime!.isNotEmpty;

    return Wrap(
      spacing: 12,
      runSpacing: 8,
      children: [
        // Sets x Reps (or Time)
        if (exercise.sets != null || hasReps || hasTime)
          _buildInfoItem(
            theme,
            hasTime ? Icons.timer_rounded : Icons.repeat_rounded,
            hasTime && !hasReps
                ? '${exercise.sets ?? "-"}x ${exercise.exerciseTime}'
                : '${exercise.sets ?? "-"}x ${exercise.reps ?? exercise.exerciseQty ?? "-"}',
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

        // Elevation
        if (exercise.elevation != null && exercise.elevation! > 0)
          _buildInfoItem(
            theme,
            Icons.trending_up_rounded,
            '${exercise.elevation!.toStringAsFixed(1).replaceAll('.0', '')}%',
          ),

        // Speed
        if (exercise.speed != null && exercise.speed! > 0)
          _buildInfoItem(
            theme,
            Icons.speed_rounded,
            '${exercise.speed!.toStringAsFixed(1).replaceAll('.0', '')}',
          ),
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
