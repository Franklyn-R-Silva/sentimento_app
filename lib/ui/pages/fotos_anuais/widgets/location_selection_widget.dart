// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:latlong2/latlong.dart' as ll;

// Project imports:
import 'package:sentimento_app/core/theme.dart';
import 'package:sentimento_app/ui/shared/widgets/gradient_card.dart';
import '../fotos_anuais.model.dart';
import 'map_picker_dialog.dart';

class LocationSelectionWidget extends StatelessWidget {
  final FotosAnuaisModel model;

  const LocationSelectionWidget({super.key, required this.model});

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);

    return GradientCard(
      moodLevel: model.moodLevel ?? 3,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Localização',
                  style: theme.typography.titleMedium.copyWith(
                    color: Colors.white,
                  ),
                ),
                if (model.isFetchingLocation)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.location_on, color: Colors.white),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      model.currentLocation != null
                          ? '${model.currentLocation!.latitude.toStringAsFixed(6)}, ${model.currentLocation!.longitude.toStringAsFixed(6)}'
                          : 'Localização não definida',
                      style: theme.typography.bodyMedium.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.my_location, color: Colors.white),
                    onPressed: () => model.fetchCurrentLocation(context),
                    tooltip: 'Pegar localização atual',
                  ),
                  IconButton(
                    icon: const Icon(Icons.map, color: Colors.white),
                    onPressed: () async {
                      final ll.LatLng initial =
                          model.currentLocation ??
                          const ll.LatLng(-23.5505, -46.6333);
                      final result = await showDialog<ll.LatLng>(
                        context: context,
                        builder: (context) =>
                            MapPickerDialog(initialLocation: initial),
                      );
                      if (result != null) {
                        model.currentLocation = result;
                      }
                    },
                    tooltip: 'Selecionar no mapa',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
