// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:auto_size_text/auto_size_text.dart';

// Project imports:
import 'package:sentimento_app/backend/tables/gym_exercises.dart';
import 'package:sentimento_app/core/theme.dart';

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
            .map((e) => e.trim().replaceAll('"', '').replaceAll("'", ""))
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
            .map((e) => e.trim().replaceAll('"', '').replaceAll("'", ""))
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
                  child: AutoSizeText(
                    widget.exercise.name,
                    style: theme.bodyLarge.override(
                      fontFamily: 'Outfit',
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Info Row
            Row(
              children: [
                if (widget.exercise.exerciseSeries != null ||
                    widget.exercise.exerciseQty != null)
                  Expanded(
                    child: Row(
                      children: [
                        Icon(
                          Icons.repeat_rounded,
                          color: theme.secondaryText,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${widget.exercise.exerciseSeries ?? "-"}x ${widget.exercise.exerciseQty ?? "-"}',
                          style: theme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                if (widget.exercise.stretchingSeries != null ||
                    widget.exercise.stretchingQty != null)
                  Expanded(
                    child: Row(
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
                      ],
                    ),
                  ),
              ],
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
          ],
        ),
      ),
    );
  }
}
