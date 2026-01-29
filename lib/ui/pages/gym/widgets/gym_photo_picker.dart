// Dart imports:
import 'dart:io';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:image_picker/image_picker.dart';

// Project imports:
import 'package:sentimento_app/core/theme.dart';

class GymPhotoPicker extends StatefulWidget {
  const GymPhotoPicker({
    super.key,
    required this.images,
    this.existingImages,
    required this.onPickImages,
    required this.onRemoveImage,
    this.onRemoveExistingImage,
  });

  final List<XFile> images;
  final List<String>? existingImages;
  final VoidCallback onPickImages;
  final void Function(int) onRemoveImage;
  final void Function(int)? onRemoveExistingImage;

  @override
  State<GymPhotoPicker> createState() => _GymPhotoPickerState();
}

class _GymPhotoPickerState extends State<GymPhotoPicker> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final existingCount = widget.existingImages?.length ?? 0;
    final totalCount = existingCount + widget.images.length;

    if (totalCount == 0) {
      return InkWell(
        onTap: widget.onPickImages,
        child: Container(
          width: double.infinity,
          height: 200,
          decoration: BoxDecoration(
            color: theme.secondaryBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: theme.alternate,
              width: 2,
              style: BorderStyle.solid,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.camera_alt_rounded,
                color: theme.secondaryText,
                size: 48,
              ),
              const SizedBox(height: 8),
              Text(
                'Toque para adicionar fotos',
                style: theme.bodyMedium.override(color: theme.secondaryText),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        SizedBox(
          height: 250,
          child: Stack(
            children: [
              PageView.builder(
                itemCount: totalCount,
                onPageChanged: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                itemBuilder: (context, index) {
                  final bool isExisting = index < existingCount;
                  Widget imageWidget;

                  if (isExisting) {
                    imageWidget = Image.network(
                      widget.existingImages![index],
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: 250,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return const Center(child: CircularProgressIndicator());
                      },
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: Colors.grey[300],
                        child: const Icon(Icons.error),
                      ),
                    );
                  } else {
                    final newIndex = index - existingCount;
                    imageWidget = Image.file(
                      File(widget.images[newIndex].path),
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: 250,
                    );
                  }

                  return Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: imageWidget,
                        ),
                      ),
                      Positioned(
                        top: 8,
                        right: 12,
                        child: InkWell(
                          onTap: () {
                            final newTotal = totalCount - 1;
                            if (isExisting) {
                              widget.onRemoveExistingImage?.call(index);
                            } else {
                              widget.onRemoveImage(index - existingCount);
                            }
                            // Reset current index if it would be out of bounds
                            if (_currentIndex >= newTotal && newTotal > 0) {
                              setState(() {
                                _currentIndex = newTotal - 1;
                              });
                            } else if (newTotal == 0) {
                              setState(() {
                                _currentIndex = 0;
                              });
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.6),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.delete,
                              color: Colors.red,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
              if (totalCount > 1)
                Positioned(
                  bottom: 8,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(totalCount, (index) {
                      return Container(
                        width: 8.0,
                        height: 8.0,
                        margin: const EdgeInsets.symmetric(horizontal: 4.0),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color:
                              (Theme.of(context).brightness == Brightness.dark
                                      ? Colors.white
                                      : Colors.black)
                                  .withOpacity(
                                    _currentIndex == index ? 0.9 : 0.4,
                                  ),
                        ),
                      );
                    }),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton.icon(
            onPressed: widget.onPickImages,
            icon: Icon(Icons.add_a_photo, color: theme.primary),
            label: Text(
              'Adicionar mais fotos',
              style: TextStyle(color: theme.primary),
            ),
          ),
        ),
      ],
    );
  }
}
