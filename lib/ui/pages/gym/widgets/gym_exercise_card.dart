// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:auto_size_text/auto_size_text.dart';

// Project imports:
import 'package:sentimento_app/backend/tables/gym_exercises.dart';
import 'package:sentimento_app/core/theme.dart';
import 'package:sentimento_app/ui/pages/gym/gym_register_page.dart';

class GymExerciseCard extends StatefulWidget {
  const GymExerciseCard({super.key, required this.exercise});

  final GymExercisesRow exercise;

  @override
  State<GymExerciseCard> createState() => _GymExerciseCardState();
}

class _GymExerciseCardState extends State<GymExerciseCard> {
  int _currentImageIndex = 0;
  int _currentStretchingImageIndex = 0;

  List<String> get _imageUrls {
    final url = widget.exercise.machinePhotoUrl;
    if (url == null || url.isEmpty) return [];

    // Try to parse as a specific separator if needed, or JSON list
    // For now, assuming if it starts with '[' it's a JSON list, otherwise single URL
    if (url.trim().startsWith('[')) {
      try {
        // Simple manual parse to avoid importing dart:convert if not needed or just use strip
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

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final imageUrls = _imageUrls;
    final stretchingImageUrls = _stretchingImageUrls;

    return Container(
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            blurRadius: 4,
            color: Color(0x33000000),
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
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
                                color: theme.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                widget.exercise.category!,
                                style: theme.labelSmall.override(
                                  color: theme.primary,
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
                                color: theme.secondary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                widget.exercise.muscleGroup!,
                                style: theme.labelSmall.override(
                                  color: theme.secondary,
                                  fontWeight: FontWeight.bold,
                                ),
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
                    } catch (e) {
                      setState(() {
                        widget.exercise.isCompleted = !newValue;
                      });
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
                      await Navigator.pushNamed(
                        context,
                        GymRegisterPage.routeName,
                        arguments: widget.exercise,
                      );
                      // Ideally refresh list
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
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Exercício excluído com sucesso!'),
                              backgroundColor: Colors.green,
                            ),
                          );
                          // Trigger refresh somehow - or parent should handle.
                          // Since we don't have a callback ref here easily without refactoring,
                          // we depend on parent rebuilding or using a specialized notification.
                          // But wait, GymListModel handles the list. Ideally we should call a method on it.
                          // OR, we can just say to user "pull to refresh" or handle it via a callback param.
                          // For simplicity now, let's rely on user returning or re-entering, OR add a callback.
                          // But wait, this is inside `GymListPage` which listens to `GymListModel`.
                          // If `reset` is called it might work? No.
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Erro ao excluir: $e'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    }
                  },
                  itemBuilder: (context) => [
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
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Info Row
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Wrap(
                spacing: 12,
                runSpacing: 8,
                children: [
                  // Sets x Reps
                  if (widget.exercise.sets != null ||
                      widget.exercise.reps != null)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.repeat_rounded,
                          color: theme.secondaryText,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${widget.exercise.sets ?? "-"}x ${widget.exercise.reps ?? "-"}',
                          style: theme.bodyMedium,
                        ),
                      ],
                    ),

                  // Weight
                  if (widget.exercise.weight != null)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.fitness_center_rounded,
                          color: theme.secondaryText,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${widget.exercise.weight!.toStringAsFixed(1).replaceAll('.0', '')} kg',
                          style: theme.bodyMedium,
                        ),
                      ],
                    ),

                  // Rest Time
                  if (widget.exercise.restTime != null)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.timer_outlined,
                          color: theme.secondaryText,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${widget.exercise.restTime}s',
                          style: theme.bodyMedium,
                        ),
                      ],
                    ),

                  // Time text (if any still used)
                  if (widget.exercise.exerciseTime != null &&
                      widget.exercise.exerciseTime!.isNotEmpty)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.timer_rounded,
                          color: theme.secondaryText,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          widget.exercise.exerciseTime!,
                          style: theme.bodyMedium,
                        ),
                      ],
                    ),
                ],
              ),
            ),

            // Carousel
            if (imageUrls.isNotEmpty) ...[
              const SizedBox(height: 12),
              SizedBox(
                height: 200,
                child: Stack(
                  children: [
                    PageView.builder(
                      itemCount: imageUrls.length,
                      onPageChanged: (index) {
                        setState(() {
                          _currentImageIndex = index;
                        });
                      },
                      itemBuilder: (context, index) {
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            imageUrls[index],
                            fit: BoxFit.cover,
                            width: double.infinity,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: theme.alternate,
                                child: Icon(
                                  Icons.broken_image,
                                  color: theme.secondaryText,
                                ),
                              );
                            },
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Center(
                                child: CircularProgressIndicator(
                                  value:
                                      loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes!
                                      : null,
                                  color: theme.primary,
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                    if (imageUrls.length > 1)
                      Positioned(
                        bottom: 8,
                        left: 0,
                        right: 0,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: imageUrls.asMap().entries.map((entry) {
                            return Container(
                              width: 8.0,
                              height: 8.0,
                              margin: const EdgeInsets.symmetric(
                                horizontal: 4.0,
                              ),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color:
                                    (Theme.of(context).brightness ==
                                                Brightness.dark
                                            ? Colors.white
                                            : Colors.black)
                                        .withOpacity(
                                          _currentImageIndex == entry.key
                                              ? 0.9
                                              : 0.4,
                                        ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                  ],
                ),
              ),
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
                SizedBox(
                  height: 200,
                  child: Stack(
                    children: [
                      PageView.builder(
                        itemCount: stretchingImageUrls.length,
                        onPageChanged: (index) {
                          setState(() {
                            _currentStretchingImageIndex = index;
                          });
                        },
                        itemBuilder: (context, index) {
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              stretchingImageUrls[index],
                              fit: BoxFit.cover,
                              width: double.infinity,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: theme.alternate,
                                  child: Icon(
                                    Icons.broken_image,
                                    color: theme.secondaryText,
                                  ),
                                );
                              },
                              loadingBuilder:
                                  (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return Center(
                                      child: CircularProgressIndicator(
                                        value:
                                            loadingProgress
                                                    .expectedTotalBytes !=
                                                null
                                            ? loadingProgress
                                                      .cumulativeBytesLoaded /
                                                  loadingProgress
                                                      .expectedTotalBytes!
                                            : null,
                                        color: theme.primary,
                                      ),
                                    );
                                  },
                            ),
                          );
                        },
                      ),
                      if (stretchingImageUrls.length > 1)
                        Positioned(
                          bottom: 8,
                          left: 0,
                          right: 0,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: stretchingImageUrls.asMap().entries.map((
                              entry,
                            ) {
                              return Container(
                                width: 8.0,
                                height: 8.0,
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 4.0,
                                ),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color:
                                      (Theme.of(context).brightness ==
                                                  Brightness.dark
                                              ? Colors.white
                                              : Colors.black)
                                          .withOpacity(
                                            _currentStretchingImageIndex ==
                                                    entry.key
                                                ? 0.9
                                                : 0.4,
                                          ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}
