// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:auto_size_text/auto_size_text.dart';
import 'package:provider/provider.dart';

// Project imports:
import 'package:sentimento_app/core/nav/nav.dart';
import 'package:sentimento_app/core/theme.dart';
import 'package:sentimento_app/ui/pages/gallery/gallery.model.dart';
import 'widgets/gallery_filters_widget.dart';
import 'widgets/photo_grid_widget.dart';

class GalleryPageWidget extends StatefulWidget {
  const GalleryPageWidget({super.key});

  static const routeName = 'Gallery';
  static const routePath = '/gallery';

  @override
  State<GalleryPageWidget> createState() => _GalleryPageWidgetState();
}

class _GalleryPageWidgetState extends State<GalleryPageWidget> {
  late GalleryModel _model;
  bool _showFilters = false;

  @override
  void initState() {
    super.initState();
    _model = GalleryModel();
    _model.loadPhotos();
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);

    return ChangeNotifierProvider.value(
      value: _model,
      child: Consumer<GalleryModel>(
        builder: (context, model, child) {
          return Scaffold(
            backgroundColor: theme.primaryBackground,
            appBar: AppBar(
              backgroundColor: theme.primary,
              automaticallyImplyLeading: true,
              title: AutoSizeText(
                'Minha Galeria',
                style: theme.typography.headlineMedium.copyWith(
                  color: Colors.white,
                  fontSize: 22,
                ),
                minFontSize: 14,
              ),
              actions: [
                IconButton(
                  icon: Icon(
                    _showFilters ? Icons.filter_list_off : Icons.filter_list,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    setState(() => _showFilters = !_showFilters);
                  },
                  tooltip: 'Filtros',
                ),
              ],
              centerTitle: false,
              elevation: 2,
            ),
            body: Column(
              children: [
                // Filters
                if (_showFilters) GalleryFiltersWidget(model: model),

                // Photo Grid
                Expanded(
                  child: model.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : model.photos.isEmpty
                      ? _buildEmptyState(theme)
                      : PhotoGridWidget(model: model),
                ),
              ],
            ),
            floatingActionButton: FloatingActionButton.extended(
              onPressed: () {
                context.pushNamed('FotosAnuais');
              },
              backgroundColor: theme.primary,
              icon: const Icon(Icons.add_a_photo_rounded, color: Colors.white),
              label: AutoSizeText(
                'Nova Foto',
                style: theme.titleSmall.override(color: Colors.white),
                minFontSize: 10,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(FlutterFlowTheme theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.photo_library_outlined,
              size: 80,
              color: theme.secondaryText.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 24),
            AutoSizeText(
              'Nenhuma foto ainda',
              style: theme.headlineSmall,
              textAlign: TextAlign.center,
              minFontSize: 14,
            ),
            const SizedBox(height: 8),
            AutoSizeText(
              'Comece sua jornada de 365 dias!\nToque no botão abaixo para adicionar sua primeira foto.',
              style: theme.bodyMedium.override(color: theme.secondaryText),
              textAlign: TextAlign.center,
              minFontSize: 10,
            ),
          ],
        ),
      ),
    );
  }
}
