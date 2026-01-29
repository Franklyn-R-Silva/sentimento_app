// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:sentimento_app/backend/tables/fotos_anuais.dart';
import 'package:sentimento_app/core/theme.dart';
import 'package:sentimento_app/ui/pages/gallery/gallery.model.dart';
import 'package:sentimento_app/ui/pages/gallery/widgets/supabase_photo_widget.dart';
import 'photo_detail_sheet.dart';

// Package imports:


class PhotoGridWidget extends StatelessWidget {
  final GalleryModel model;

  const PhotoGridWidget({super.key, required this.model});

  static const _moodEmojis = ['', '😢', '😟', '😐', '🙂', '😄'];

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);

    return RefreshIndicator(
      onRefresh: model.loadPhotos,
      color: theme.primary,
      child: GridView.builder(
        padding: const EdgeInsets.all(8),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 4,
          mainAxisSpacing: 4,
        ),
        itemCount: model.photos.length,
        itemBuilder: (context, index) {
          final photo = model.photos[index];
          return _buildPhotoTile(context, theme, photo);
        },
      ),
    );
  }

  Widget _buildPhotoTile(
    BuildContext context,
    FlutterFlowTheme theme,
    FotosAnuaisRow photo,
  ) {
    return GestureDetector(
      onTap: () => _showPhotoDetail(context, photo),
      child: Hero(
        tag: 'photo_${photo.id}',
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Photo
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SupabasePhotoWidget(
                imageUrl: photo.imageUrl,
                fit: BoxFit.cover,
              ),
            ),

            // Mood Overlay
            if (photo.moodLevel != null && photo.moodLevel! > 0)
              Positioned(
                bottom: 4,
                right: 4,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _moodEmojis[photo.moodLevel!],
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showPhotoDetail(BuildContext context, FotosAnuaisRow photo) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PhotoDetailSheet(photo: photo, model: model),
    );
  }
}
