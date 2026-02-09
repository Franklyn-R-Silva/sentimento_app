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
    final isCompleted = widget.exercise.isCompleted;

    return Dismissible(
      key: ValueKey('swipe_${widget.exercise.id}'),
      direction: DismissDirection.startToEnd,
      confirmDismiss: (direction) async {
        await _toggleComplete();
        return false;
      },
      background: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: isCompleted ? Colors.orangeAccent : Colors.teal,
          borderRadius: BorderRadius.circular(24),
        ),
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Row(
          children: [
            Icon(
              isCompleted ? Icons.undo_rounded : Icons.check_circle_rounded,
              color: Colors.white,
              size: 32,
            ),
            const SizedBox(width: 12),
            Text(
              isCompleted ? 'Desmarcar' : 'Concluir',
              style: theme.titleMedium.override(
                fontFamily: 'Outfit',
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: isCompleted
              ? theme.secondaryBackground.withOpacity(0.6)
              : theme.secondaryBackground,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isCompleted
                ? theme.primary.withOpacity(0.2)
                : theme.alternate.withOpacity(0.6),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              blurRadius: 16,
              color: theme.primaryText.withOpacity(0.05),
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () async {
                await _toggleComplete();
              },
              // Allow distinct edit/menu tap
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Reorder Handle
                        if (widget.isReorderable && widget.index != null)
                          ReorderableDragStartListener(
                            index: widget.index!,
                            key: ValueKey('drag_${widget.exercise.id}'),
                            child: Container(
                              alignment: Alignment.centerLeft,
                              padding: const EdgeInsets.only(right: 12),
                              child: Icon(
                                Icons.drag_indicator_rounded,
                                color: theme.secondaryText.withOpacity(0.5),
                                size: 20,
                              ),
                            ),
                          ),
                        // Content
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Exercise Name & Badges
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        AutoSizeText(
                                          widget.exercise.name,
                                          style: theme.titleMedium.override(
                                            fontFamily: 'Outfit',
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                            color: isCompleted
                                                ? theme.secondaryText
                                                : theme.primaryText,
                                            decoration: isCompleted
                                                ? TextDecoration.lineThrough
                                                : null,
                                          ),
                                          maxLines: 2,
                                        ),
                                        const SizedBox(height: 6),
                                        Wrap(
                                          spacing: 6,
                                          runSpacing: 4,
                                          children: [
                                            if (widget.exercise.category !=
                                                null)
                                              _buildBadge(
                                                theme,
                                                label:
                                                    widget.exercise.category!,
                                                color: _getCategoryColor(
                                                  widget.exercise.category,
                                                ),
                                              ),
                                            if (widget.exercise.muscleGroup !=
                                                null)
                                              _buildBadge(
                                                theme,
                                                label: widget
                                                    .exercise
                                                    .muscleGroup!,
                                                color: _getMuscleGroupColor(
                                                  widget.exercise.muscleGroup,
                                                ),
                                              ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Checkbox Area
                                  Column(
                                    children: [
                                      _buildAnimatedCheckbox(
                                        isCompleted,
                                        theme,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Exercise Info (Sets, Reps, etc.)
                    GymExerciseInfo(exercise: widget.exercise),

                    // Images
                    if (imageUrls.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      GymExerciseCarousel(imageUrls: imageUrls),
                    ],

                    if (widget.exercise.description != null &&
                        widget.exercise.description!.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: theme.alternate.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          widget.exercise.description!,
                          style: theme.bodySmall.override(
                            fontFamily: 'Outfit',
                            color: theme.secondaryText,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ],

                    // Menu Button (Placed at bottom right or top right?
                    // Let's place it at top right in previous version, but now I used InkWell over whole card.
                    // Maybe a "More" button at the bottom right?)
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [_buildMenuButton(theme)],
                    ),

                    // Stretching Section
                    if (widget.exercise.stretchingName != null ||
                        stretchingImageUrls.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: theme.tertiary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: theme.tertiary.withOpacity(0.3),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.accessibility_new_rounded,
                                  color: theme.tertiary,
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Alongamento Opcional',
                                  style: theme.bodyMedium.override(
                                    fontFamily: 'Outfit',
                                    color: theme.tertiary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            if (widget.exercise.stretchingName != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                widget.exercise.stretchingName!,
                                style: theme.bodyMedium.override(
                                  fontFamily: 'Outfit',
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Text(
                                  '${widget.exercise.stretchingSeries ?? "-"}x ${widget.exercise.stretchingQty ?? "-"}',
                                  style: theme.bodySmall,
                                ),
                                if (widget.exercise.stretchingTime != null)
                                  Text(
                                    ' • ${widget.exercise.stretchingTime}',
                                    style: theme.bodySmall,
                                  ),
                              ],
                            ),
                            if (stretchingImageUrls.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              GymExerciseCarousel(
                                imageUrls: stretchingImageUrls,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedCheckbox(bool isCompleted, FlutterFlowTheme theme) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: isCompleted ? theme.primary : Colors.transparent,
        shape: BoxShape.circle,
        border: Border.all(
          color: isCompleted
              ? theme.primary
              : theme.secondaryText.withOpacity(0.5),
          width: 2,
        ),
        boxShadow: isCompleted
            ? [
                BoxShadow(
                  color: theme.primary.withOpacity(0.4),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : [],
      ),
      child: isCompleted
          ? const Icon(Icons.check_rounded, size: 18, color: Colors.white)
          : null,
    );
  }

  Widget _buildBadge(
    FlutterFlowTheme theme, {
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.3), width: 0.5),
      ),
      child: Text(
        label,
        style: theme.labelSmall.override(
          fontFamily: 'Outfit',
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 10,
        ),
      ),
    );
  }

  Widget _buildMenuButton(FlutterFlowTheme theme) {
    return PopupMenuButton<String>(
      icon: Icon(
        Icons.more_horiz_rounded,
        color: theme.secondaryText,
        size: 20,
      ),
      padding: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onSelected: (value) async {
        // ... (Logic copied from previous implementation, but reusing the existing handlers in _GymExerciseCardState if possible, or needing to copy-paste the logic here)
        // Since I'm inside the class, I have access to context and widget.
        // I will copy the logic here.
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
            extra: {'exercise': widget.exercise, 'isDuplication': true},
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
                          fontWeight: d == widget.exercise.dayOfWeek
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

          if (targetDay != null && targetDay != widget.exercise.dayOfWeek) {
            try {
              await GymExercisesTable().update(
                data: {'day_of_week': targetDay},
                matchingRows: (t) => t.eq('id', widget.exercise.id),
              );
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Movido para $targetDay'),
                    backgroundColor: Colors.green,
                  ),
                );
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
                matchingRows: (t) => t.eq('id', widget.exercise.id),
              );
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Exercício excluído com sucesso!'),
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
              Text('Excluir', style: TextStyle(color: Colors.red)),
            ],
          ),
        ),
      ],
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
