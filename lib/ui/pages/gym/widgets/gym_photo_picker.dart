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
  final PageController _pageController = PageController(viewportFraction: 0.9);
  int _currentIndex = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final existingCount = widget.existingImages?.length ?? 0;
    final totalCount = existingCount + widget.images.length;

    if (totalCount == 0) {
      return InkWell(
        onTap: widget.onPickImages,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: double.infinity,
          height: 220,
          decoration: BoxDecoration(
            color: theme.secondaryBackground,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: theme.primary.withOpacity(0.3),
              width: 1,
              style: BorderStyle.solid,
            ),
            boxShadow: [
              BoxShadow(
                color: theme.primary.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.add_a_photo_rounded,
                  color: theme.primary,
                  size: 32,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Adicionar Fotos',
                style: theme.titleMedium.override(
                  fontFamily: 'Outfit',
                  color: theme.primaryText,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Registre seu progresso visual',
                style: theme.bodySmall.override(color: theme.secondaryText),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        SizedBox(
          height: 280,
          child: PageView.builder(
            controller: _pageController,
            itemCount: totalCount,
            onPageChanged: (index) {
              setState(() => _currentIndex = index);
            },
            itemBuilder: (context, index) {
              final bool isExisting = index < existingCount;
              Widget imageWidget;

              if (isExisting) {
                imageWidget = Image.network(
                  widget.existingImages![index],
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: 280,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                            : null,
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: theme.alternate,
                    child: Icon(
                      Icons.broken_image,
                      color: theme.secondaryText,
                      size: 40,
                    ),
                  ),
                );
              } else {
                final newIndex = index - existingCount;
                imageWidget = Image.file(
                  File(widget.images[newIndex].path),
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: 280,
                );
              }

              return AnimatedBuilder(
                animation: _pageController,
                builder: (context, child) {
                  double value = 1.0;
                  if (_pageController.position.haveDimensions) {
                    value = _pageController.page! - index;
                    value = (1 - (value.abs() * 0.1)).clamp(0.9, 1.0);
                  } else {
                    // Initial state when controller doesn't have dimensions yet
                    // If it's the current index, scale is 1, else 0.9 is a safe default for neighbors
                    value = index == _currentIndex ? 1.0 : 0.9;
                  }

                  return Center(
                    child: SizedBox(
                      height: Curves.easeOut.transform(value) * 280,
                      width: Curves.easeOut.transform(value) * 350,
                      child: child,
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: imageWidget,
                      ),
                      // Gradient overlay at the bottom for text readability if needed
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withOpacity(0.0),
                                Colors.black.withOpacity(0.3),
                              ],
                              stops: const [0.6, 0.8, 1.0],
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 12,
                        right: 12,
                        child: Material(
                          color: Colors.black.withOpacity(0.5),
                          shape: const CircleBorder(),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(20),
                            onTap: () {
                              final newTotal = totalCount - 1;
                              if (isExisting) {
                                widget.onRemoveExistingImage?.call(index);
                              } else {
                                widget.onRemoveImage(index - existingCount);
                              }

                              // Logic to update current index safely
                              if (_currentIndex >= newTotal && newTotal > 0) {
                                setState(() => _currentIndex = newTotal - 1);
                              } else if (newTotal == 0) {
                                setState(() => _currentIndex = 0);
                              }
                            },
                            child: const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Icon(
                                Icons.delete_outline_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      ),
                      if (!isExisting)
                        Positioned(
                          bottom: 12,
                          left: 12,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: theme.primary,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'NOVA',
                              style: theme.bodySmall.override(
                                fontFamily: 'Outfit',
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        // Page Indicators
        if (totalCount > 1)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(totalCount, (index) {
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: _currentIndex == index ? 24.0 : 8.0,
                height: 8.0,
                margin: const EdgeInsets.symmetric(horizontal: 4.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: _currentIndex == index
                      ? theme.primary
                      : theme.alternate,
                ),
              );
            }),
          ),
        const SizedBox(height: 16),
        // Add More Button
        Center(
          child: TextButton.icon(
            onPressed: widget.onPickImages,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(color: theme.primary.withOpacity(0.5)),
              ),
            ),
            icon: Icon(
              Icons.add_photo_alternate_rounded,
              size: 20,
              color: theme.primary,
            ),
            label: Text(
              'Adicionar mais fotos',
              style: theme.bodyMedium.override(
                fontFamily: 'Outfit',
                color: theme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
