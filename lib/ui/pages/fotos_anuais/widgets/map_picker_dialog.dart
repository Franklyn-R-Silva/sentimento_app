import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:sentimento_app/core/theme.dart';

class MapPickerStyles {
  static BoxDecoration cardDecoration(BuildContext context) => BoxDecoration(
    color: FlutterFlowTheme.of(context).secondaryBackground,
    borderRadius: BorderRadius.circular(16),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.1),
        blurRadius: 10,
        offset: const Offset(0, 4),
      ),
    ],
  );
}

class MapPickerDialog extends StatefulWidget {
  final LatLng initialLocation;

  const MapPickerDialog({super.key, required this.initialLocation});

  @override
  State<MapPickerDialog> createState() => _MapPickerDialogState();
}

class _MapPickerDialogState extends State<MapPickerDialog> {
  late LatLng _pickedLocation;
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    _pickedLocation = widget.initialLocation;
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        height: 500,
        width: double.maxFinite,
        decoration: MapPickerStyles.cardDecoration(context),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Selecionar Localização',
                    style: theme.typography.titleLarge,
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Stack(
                children: [
                  FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      initialCenter: _pickedLocation,
                      initialZoom: 15.0,
                      onTap: (_, p) => setState(() => _pickedLocation = p),
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.example.app',
                      ),
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: _pickedLocation,
                            width: 80,
                            height: 80,
                            child: const Icon(
                              Icons.location_on,
                              color: Colors.red,
                              size: 40,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Positioned(
                    bottom: 16,
                    left: 16,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: theme.primaryBackground.withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Text(
                        'Toque no mapa para mudar o local',
                        textAlign: TextAlign.center,
                        style: theme.typography.bodySmall,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context, _pickedLocation),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.primary,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Confirmar Localização',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
