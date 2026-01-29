// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:auto_size_text/auto_size_text.dart';

// Project imports:
import 'package:sentimento_app/backend/tables/gym_exercises.dart';
import 'package:sentimento_app/core/nav/nav.dart';
import 'package:sentimento_app/core/theme.dart';
import 'package:sentimento_app/ui/pages/gym/gym_register_page.dart';
import 'package:sentimento_app/ui/pages/gym/widgets/gym_exercise_carousel.dart';
import 'package:sentimento_app/ui/pages/gym/widgets/gym_exercise_info.dart';

class GymExerciseCard extends StatefulWidget {
  const GymExerciseCard({
    super.key,
    required this.exercise,
    this.workoutName,
    this.index,
    this.onRefresh,
    this.onMoveToTop,
    this.isReorderable = true,
  });

  final GymExercisesRow exercise;
  final String? workoutName;
  final int? index;
  final VoidCallback? onRefresh;
  final VoidCallback? onMoveToTop;
  final bool isReorderable;

  @override
  State<GymExerciseCard> createState() => _GymExerciseCardState();
}

class _GymExerciseCardState extends State<GymExerciseCard> {
  List<String> get _imageUrls {
    final url = widget.exercise.machinePhotoUrl;
    if (url == null || url.isEmpty) return [];

    if (url.trim().startsWith('[')) {
      try {
        final clean = url.trim().substring(1, url.trim().length - 1);
        if (clean.isEmpty) return [];
        return clean
            .split(',')
            .map((e) => e.trim().replaceAll('"', '').replaceAll("'", ''))
            .toList();
      } catch (_) {
        return [url];
      }
    }
    return [url];
  }

  List<String> get _stretchingImageUrls {
    final url = widget.exercise.stretchingPhotoUrl;
    if (url == null || url.isEmpty) return [];

    if (url.trim().startsWith('[')) {
      try {
        final clean = url.trim().substring(1, url.trim().length - 1);
        if (clean.isEmpty) return [];
        return clean
            .split(',')
            .map((e) => e.trim().replaceAll('"', '').replaceAll("'", ''))
            .toList();
      } catch (_) {
        return [url];
      }
    }
    return [url];
  }

  Color _getCategoryColor(String? category) {
    switch (category?.toLowerCase()) {
      case 'musculação':
        return Colors.blue;
      case 'cardio':
        return Colors.red;
      case 'mobilidade':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  Color _getMuscleGroupColor(String? muscleGroup) {
    switch (muscleGroup?.toLowerCase()) {
      case 'peito':
        return Colors.purple;
      case 'costas':
        return Colors.indigo;
      case 'pernas':
        return Colors.teal;
      case 'ombros':
        return Colors.orange;
      case 'bíceps':
        return Colors.pink;
      case 'tríceps':
        return Colors.cyan;
      case 'abdômen':
        return Colors.amber;
      default:
        return Colors.blueGrey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final imageUrls = _imageUrls;
    final stretchingImageUrls = _stretchingImageUrls;

    return Dismissible(
      key: ValueKey('swipe_${widget.exercise.id}'),
      direction: DismissDirection.startToEnd,
      confirmDismiss: (direction) async {
        // Toggle complete status
        await _toggleComplete();
        return false; // Don't remove the item
      },
      background: Container(
        decoration: BoxDecoration(
          color: widget.exercise.isCompleted ? Colors.orange : Colors.green,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 20),
        child: Row(
          children: [
            Icon(
              widget.exercise.isCompleted
                  ? Icons.undo_rounded
                  : Icons.check_circle_rounded,
              color: Colors.white,
              size: 28,
            ),
            const SizedBox(width: 8),
            Text(
              widget.exercise.isCompleted ? 'Desmarcar' : 'Concluir',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: widget.exercise.isCompleted
              ? Colors.green.withOpacity(0.1)
              : theme.secondaryBackground,
          borderRadius: BorderRadius.circular(12),
          border: widget.exercise.isCompleted
              ? Border.all(color: Colors.green, width: 2)
              : null,
          boxShadow: const [
            BoxShadow(
              blurRadius: 4,
              color: Color(0x33000000),
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Reorder Handle
                  if (widget.isReorderable && widget.index != null)
                    ReorderableDragStartListener(
                      index: widget.index!,
                      key: ValueKey('drag_${widget.exercise.id}'),
                      child: Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Icon(
                          Icons.drag_indicator_rounded,
                          color: theme.secondaryText,
                          size: 24,
                        ),
                      ),
                    ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            if (widget.exercise.category != null)
                              Container(
                                margin: const EdgeInsets.only(right: 8),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: _getCategoryColor(
                                    widget.exercise.category,
                                  ).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  widget.exercise.category!,
                                  style: theme.labelSmall.override(
                                    color: _getCategoryColor(
                                      widget.exercise.category,
                                    ),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            if (widget.exercise.muscleGroup != null)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: _getMuscleGroupColor(
                                    widget.exercise.muscleGroup,
                                  ).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  widget.exercise.muscleGroup!,
                                  style: theme.labelSmall.override(
                                    color: _getMuscleGroupColor(
                                      widget.exercise.muscleGroup,
                                    ),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            if (widget.workoutName != null)
                              Container(
                                margin: const EdgeInsets.only(right: 8),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: theme.tertiary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(
                                    color: theme.tertiary.withOpacity(0.3),
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.fitness_center_rounded,
                                      size: 10,
                                      color: theme.tertiary,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      widget.workoutName!,
                                      style: theme.labelSmall.override(
                                        fontFamily: 'Outfit',
                                        color: theme.tertiary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        AutoSizeText(
                          widget.exercise.name,
                          style: theme.bodyLarge.override(
                            fontFamily: 'Outfit',
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                        ),
                      ],
                    ),
                  ),

                  Checkbox(
                    value: widget.exercise.isCompleted,
                    onChanged: (val) async {
                      final newValue = val ?? false;
                      setState(() {
                        widget.exercise.isCompleted = newValue;
                      });
                      try {
                        await GymExercisesTable().update(
                          data: {'is_completed': newValue},
                          matchingRows: (t) => t.eq('id', widget.exercise.id),
                        );
                        // Call onRefresh to update parent state (progress bar)
                        widget.onRefresh?.call();
                      } catch (e) {
                        setState(() {
                          widget.exercise.isCompleted = !newValue;
                        });
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Erro ao atualizar status: $e',
                                style: const TextStyle(color: Colors.white),
                              ),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    },
                    activeColor: theme.primary,
                    checkColor: theme.info,
                  ),
                  PopupMenuButton<String>(
                    icon: Icon(
                      Icons.more_vert_rounded,
                      color: theme.secondaryText,
                    ),
                    onSelected: (value) async {
                      if (value == 'edit') {
                        await context.pushNamedAuth(
                          GymRegisterPage.routeName,
                          mounted,
                          extra: widget.exercise,
                        );
                        widget.onRefresh?.call();
                      } else if (value == 'duplicate') {
                        await context.pushNamedAuth(
                          GymRegisterPage.routeName,
                          mounted,
                          extra: {
                            'exercise': widget.exercise,
                            'isDuplication': true,
                          },
                        );
                      } else if (value == 'move') {
                        final days = [
                          'Segunda',
                          'Terça',
                          'Quarta',
                          'Quinta',
                          'Sexta',
                          'Sábado',
                          'Domingo',
                        ];

                        // Show simple dialog to pick day
                        final String? targetDay = await showDialog<String>(
                          context: context,
                          builder: (context) => SimpleDialog(
                            title: const Text('Mover para...'),
                            children: days
                                .map(
                                  (d) => SimpleDialogOption(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 24,
                                      vertical: 12,
                                    ),
                                    onPressed: () => Navigator.pop(context, d),
                                    child: Text(
                                      d,
                                      style: theme.bodyMedium.override(
                                        fontFamily: 'Outfit',
                                        fontWeight:
                                            d == widget.exercise.dayOfWeek
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                        color: d == widget.exercise.dayOfWeek
                                            ? theme.primary
                                            : theme.primaryText,
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                        );

                        if (targetDay != null &&
                            targetDay != widget.exercise.dayOfWeek) {
                          try {
                            await GymExercisesTable().update(
                              data: {'day_of_week': targetDay},
                              matchingRows: (t) =>
                                  t.eq('id', widget.exercise.id),
                            );
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Movido para $targetDay'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                              // Ideally parent should refresh.
                              // If we are in GymManagerPage, reorder mechanism might handle state if models are shared?
                              // Actually GymExerciseCard keeps local state for isCompleted.
                              // This change affects list presence.
                              // We really should trigger a callback or reload.
                              // But for now, user might need to pull refresh.
                              widget.onRefresh?.call();
                            }
                          } catch (e) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Erro ao mover exercício'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        }
                      } else if (value == 'move_top') {
                        widget.onMoveToTop?.call();
                      } else if (value == 'delete') {
                        final confirmed = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Excluir Exercício'),
                            content: const Text(
                              'Tem certeza que deseja excluir este exercício?',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('Cancelar'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text(
                                  'Excluir',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                          ),
                        );

                        if (confirmed == true) {
                          try {
                            await GymExercisesTable().delete(
                              matchingRows: (t) =>
                                  t.eq('id', widget.exercise.id),
                            );
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Exercício excluído com sucesso!',
                                  ),
                                  backgroundColor: Colors.green,
                                ),
                              );
                              widget.onRefresh?.call();
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Erro ao excluir: $e'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        }
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'move_top',
                        child: Row(
                          children: [
                            Icon(Icons.vertical_align_top_rounded, size: 20),
                            SizedBox(width: 8),
                            Text('Mover para o topo'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, size: 20),
                            SizedBox(width: 8),
                            Text('Editar'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'duplicate',
                        child: Row(
                          children: [
                            Icon(Icons.copy, size: 20),
                            SizedBox(width: 8),
                            Text('Duplicar'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'move',
                        child: Row(
                          children: [
                            Icon(Icons.drive_file_move_rounded, size: 20),
                            SizedBox(width: 8),
                            Text('Mover para...'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, color: Colors.red, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Excluir',
                              style: TextStyle(color: Colors.red),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Info Row (Refactored)
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: GymExerciseInfo(exercise: widget.exercise),
              ),

              // Carousel (Refactored)
              if (imageUrls.isNotEmpty) ...[
                const SizedBox(height: 12),
                GymExerciseCarousel(imageUrls: imageUrls),
              ],

              if (widget.exercise.description != null &&
                  widget.exercise.description!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  widget.exercise.description!,
                  style: theme.bodySmall.override(
                    fontFamily: 'Outfit',
                    color: theme.secondaryText,
                  ),
                ),
              ],

              if (widget.exercise.stretchingName != null ||
                  widget.exercise.stretchingSeries != null ||
                  widget.exercise.stretchingQty != null ||
                  stretchingImageUrls.isNotEmpty) ...[
                const SizedBox(height: 12),
                Divider(color: theme.alternate, thickness: 1),
                const SizedBox(height: 8),
                if (widget.exercise.stretchingName != null) ...[
                  Text(
                    'Alongamento: ${widget.exercise.stretchingName}',
                    style: theme.bodyMedium.override(
                      fontFamily: 'Outfit',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                ],
                Row(
                  children: [
                    Icon(
                      Icons.accessibility_new_rounded,
                      color: theme.secondaryText,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${widget.exercise.stretchingSeries ?? "-"}x ${widget.exercise.stretchingQty ?? "-"}',
                      style: theme.bodyMedium,
                    ),
                    if (widget.exercise.stretchingTime != null &&
                        widget.exercise.stretchingTime!.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      Icon(
                        Icons.timer_rounded,
                        color: theme.secondaryText,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        widget.exercise.stretchingTime!,
                        style: theme.bodyMedium,
                      ),
                    ],
                  ],
                ),
                if (stretchingImageUrls.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  GymExerciseCarousel(imageUrls: stretchingImageUrls),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _toggleComplete() async {
    final exercise = widget.exercise;
    final newValue = !exercise.isCompleted;

    setState(() {
      exercise.isCompleted = newValue;
    });

    try {
      await GymExercisesTable().update(
        data: {'is_completed': newValue},
        matchingRows: (t) => t.eq('id', exercise.id),
      );
      widget.onRefresh?.call();
    } catch (e) {
      // Revert on error
      setState(() {
        exercise.isCompleted = !newValue;
      });
    }
  }
}
