// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';

// Project imports:
import 'package:sentimento_app/backend/tables/fotos_anuais.dart';
import 'package:sentimento_app/core/theme.dart';
import 'package:sentimento_app/ui/pages/gallery/gallery.model.dart';

class PhotoDetailSheet extends StatelessWidget {
  final FotosAnuaisRow photo;
  final GalleryModel model;

  const PhotoDetailSheet({super.key, required this.photo, required this.model});

  static const _moodEmojis = ['', '😢', '😟', '😐', '🙂', '😄'];
  static const _moodLabels = [
    '',
    'Muito triste',
    'Triste',
    'Neutro',
    'Bem',
    'Muito feliz',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final dateFormat = DateFormat('dd/MM/yyyy', 'pt_BR');

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: theme.primaryBackground,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Handle bar
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: theme.alternate,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),

          // Image
          Expanded(
            child: Hero(
              tag: 'photo_${photo.id}',
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: CachedNetworkImage(
                  imageUrl: photo.imageUrl,
                  fit: BoxFit.contain,
                  placeholder: (context, url) =>
                      const Center(child: CircularProgressIndicator()),
                  errorWidget: (context, url, error) => Center(
                    child: Icon(
                      Icons.broken_image_rounded,
                      size: 64,
                      color: theme.secondaryText,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Details
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Date
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today_rounded,
                      size: 18,
                      color: theme.primary,
                    ),
                    const SizedBox(width: 8),
                    AutoSizeText(
                      dateFormat.format(photo.dataFoto),
                      style: theme.bodyLarge,
                      minFontSize: 12,
                    ),
                  ],
                ),

                // Mood
                if (photo.moodLevel != null && photo.moodLevel! > 0) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Text(
                        _moodEmojis[photo.moodLevel!],
                        style: const TextStyle(fontSize: 20),
                      ),
                      const SizedBox(width: 8),
                      AutoSizeText(
                        _moodLabels[photo.moodLevel!],
                        style: theme.bodyLarge,
                        minFontSize: 12,
                      ),
                    ],
                  ),
                ],

                // Location
                if (photo.lat != null && photo.lng != null) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_rounded,
                        size: 18,
                        color: theme.error,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: AutoSizeText(
                          '${photo.lat!.toStringAsFixed(4)}, ${photo.lng!.toStringAsFixed(4)}',
                          style: theme.bodyMedium.override(
                            color: theme.secondaryText,
                          ),
                          minFontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ],

                // Phrase
                if (photo.frase != null && photo.frase!.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.secondaryBackground,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: theme.alternate.withValues(alpha: 0.5),
                      ),
                    ),
                    child: AutoSizeText(
                      '"${photo.frase}"',
                      style: theme.bodyMedium.override(
                        fontStyle: FontStyle.italic,
                      ),
                      minFontSize: 10,
                    ),
                  ),
                ],

                const SizedBox(height: 24),

                // Delete Button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => _confirmDelete(context, theme),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: theme.error,
                      side: BorderSide(color: theme.error),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.delete_outline_rounded),
                    label: AutoSizeText(
                      'Excluir Foto',
                      style: theme.bodyMedium.override(color: theme.error),
                      minFontSize: 10,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, FlutterFlowTheme theme) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: theme.secondaryBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: AutoSizeText(
          'Excluir foto?',
          style: theme.titleLarge,
          minFontSize: 14,
        ),
        content: AutoSizeText(
          'Esta ação não pode ser desfeita.',
          style: theme.bodyMedium,
          minFontSize: 10,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: AutoSizeText(
              'Cancelar',
              style: theme.bodyMedium,
              minFontSize: 10,
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              final success = await model.deletePhoto(context, photo);
              if (success && context.mounted) {
                Navigator.pop(context); // Close bottom sheet
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: theme.error),
            child: AutoSizeText(
              'Excluir',
              style: theme.bodyMedium.override(color: Colors.white),
              minFontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}
