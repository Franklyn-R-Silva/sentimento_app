import 'package:flutter/material.dart';
import 'package:sentimento_app/core/theme.dart';

class GymExerciseCarousel extends StatefulWidget {
  const GymExerciseCarousel({super.key, required this.imageUrls});

  final List<String> imageUrls;

  @override
  State<GymExerciseCarousel> createState() => _GymExerciseCarouselState();
}

class _GymExerciseCarouselState extends State<GymExerciseCarousel> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    if (widget.imageUrls.isEmpty) return const SizedBox.shrink();

    final theme = FlutterFlowTheme.of(context);

    return SizedBox(
      height: 200,
      child: Stack(
        children: [
          PageView.builder(
            itemCount: widget.imageUrls.length,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemBuilder: (context, index) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  widget.imageUrls[index],
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
                        value: loadingProgress.expectedTotalBytes != null
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
          if (widget.imageUrls.length > 1)
            Positioned(
              bottom: 8,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: widget.imageUrls.asMap().entries.map((entry) {
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
                                _currentIndex == entry.key ? 0.9 : 0.4,
                              ),
                    ),
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }
}
