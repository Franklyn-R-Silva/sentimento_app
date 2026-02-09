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
      spacing: 8,
      runSpacing: 8,
      children: [
        // Sets x Reps (or Time)
        if (exercise.sets != null || hasReps || hasTime)
          _buildInfoItem(
            context,
            hasTime ? Icons.timer_rounded : Icons.repeat_rounded,
            hasTime && !hasReps
                ? '${exercise.sets ?? "-"}x ${exercise.exerciseTime}'
                : '${exercise.sets ?? "-"}x ${exercise.reps ?? exercise.exerciseQty ?? "-"}',
            // Default color
          ),

        // Weight
        if (exercise.weight != null)
          _buildInfoItem(
            context,
            Icons.fitness_center_rounded,
            '${exercise.weight!.toStringAsFixed(1).replaceAll('.0', '')} kg',
            color: theme.primary,
          ),

        // Rest Time
        if (exercise.restTime != null)
          _buildInfoItem(
            context,
            Icons.hourglass_empty_rounded,
            '${exercise.restTime}s',
            color: theme.tertiary,
          ),

        // Elevation
        if (exercise.elevation != null && exercise.elevation! > 0)
          _buildInfoItem(
            context,
            Icons.trending_up_rounded,
            '${exercise.elevation!.toStringAsFixed(1).replaceAll('.0', '')}%',
            color: Colors.purpleAccent,
          ),

        // Speed
        if (exercise.speed != null && exercise.speed! > 0)
          _buildInfoItem(
            context,
            Icons.speed_rounded,
            exercise.speed!.toStringAsFixed(1).replaceAll('.0', ''),
            color: Colors.orangeAccent,
          ),
      ],
    );
  }

  Widget _buildInfoItem(
    BuildContext context,
    IconData icon,
    String text, {
    Color? color,
  }) {
    final theme = FlutterFlowTheme.of(context);
    final itemColor = color ?? theme.secondaryText;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: itemColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: itemColor.withOpacity(0.2), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: itemColor, size: 14),
          const SizedBox(width: 6),
          Text(
            text,
            style: theme.bodyMedium.override(
              fontFamily: 'Outfit',
              fontWeight: FontWeight.w600,
              color: theme.primaryText,
            ),
          ),
        ],
      ),
    );
  }
}
