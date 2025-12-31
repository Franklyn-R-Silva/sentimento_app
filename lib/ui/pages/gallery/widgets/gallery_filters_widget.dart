// Flutter imports:
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

// Project imports:
import 'package:sentimento_app/core/theme.dart';
import 'package:sentimento_app/ui/pages/gallery/gallery.model.dart';

class GalleryFiltersWidget extends StatelessWidget {
  final GalleryModel model;

  const GalleryFiltersWidget({super.key, required this.model});

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        border: Border(
          bottom: BorderSide(color: theme.alternate.withValues(alpha: 0.5)),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date Filters
          AutoSizeText(
            'Período',
            style: theme.labelMedium.override(
              color: theme.secondaryText,
              fontWeight: FontWeight.w600,
            ),
            minFontSize: 9,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              _buildFilterChip(
                context,
                theme,
                label: 'Todos',
                isSelected: model.filter == GalleryFilter.all,
                onTap: () => model.filter = GalleryFilter.all,
              ),
              _buildFilterChip(
                context,
                theme,
                label: 'Este mês',
                isSelected: model.filter == GalleryFilter.thisMonth,
                onTap: () => model.filter = GalleryFilter.thisMonth,
              ),
              _buildFilterChip(
                context,
                theme,
                label: 'Este ano',
                isSelected: model.filter == GalleryFilter.thisYear,
                onTap: () => model.filter = GalleryFilter.thisYear,
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Mood Filters
          AutoSizeText(
            'Humor',
            style: theme.labelMedium.override(
              color: theme.secondaryText,
              fontWeight: FontWeight.w600,
            ),
            minFontSize: 9,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              _buildMoodChip(context, theme, null, 'Todos'),
              _buildMoodChip(context, theme, 1, '😢'),
              _buildMoodChip(context, theme, 2, '😟'),
              _buildMoodChip(context, theme, 3, '😐'),
              _buildMoodChip(context, theme, 4, '🙂'),
              _buildMoodChip(context, theme, 5, '😄'),
            ],
          ),

          // Clear Filters
          if (model.filter != GalleryFilter.all || model.moodFilter != null)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: TextButton.icon(
                onPressed: model.clearFilters,
                icon: Icon(Icons.clear_all, color: theme.error, size: 18),
                label: AutoSizeText(
                  'Limpar filtros',
                  style: theme.bodySmall.override(color: theme.error),
                  minFontSize: 9,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(
    BuildContext context,
    FlutterFlowTheme theme, {
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? theme.primary : theme.primaryBackground,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? theme.primary : theme.alternate,
          ),
        ),
        child: AutoSizeText(
          label,
          style: theme.bodySmall.override(
            color: isSelected ? Colors.white : theme.primaryText,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
          minFontSize: 9,
        ),
      ),
    );
  }

  Widget _buildMoodChip(
    BuildContext context,
    FlutterFlowTheme theme,
    int? mood,
    String label,
  ) {
    final isSelected = model.moodFilter == mood;

    return GestureDetector(
      onTap: () => model.moodFilter = mood,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? theme.primary : theme.primaryBackground,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? theme.primary : theme.alternate,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: mood == null ? 12 : 18,
            color: isSelected && mood == null ? Colors.white : null,
          ),
        ),
      ),
    );
  }
}
