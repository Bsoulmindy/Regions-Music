import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:regions_music/presentation/tree/mapview/zones/zones.dart';

class MapView extends StatefulWidget {
  const MapView({super.key});

  @override
  State<StatefulWidget> createState() => MapViewState();
}

class MapViewState extends State<MapView> {
  final _mapController = MapController();

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      mapController: _mapController,
      options: const MapOptions(
        initialCenter: LatLng(30.36, -9.51),
        initialZoom: 4.0,
        keepAlive: true,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'ma.bhc.regions_music',
        ),
        RichAttributionWidget(
          alignment: AttributionAlignment.bottomLeft,
          attributions: [
            TextSourceAttribution(
              'OpenStreetMap contributors',
              onTap: () => (Uri.parse('https://openstreetmap.org/copyright')),
            ),
          ],
        ),
        Align(
          alignment: Alignment.bottomRight,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Zoom in
                Builder(
                  builder: (context) => FloatingActionButton(
                    shape: const Border(bottom: BorderSide()),
                    onPressed: () {
                      _mapController.move(MapCamera.of(context).center,
                          min(MapCamera.of(context).zoom + 0.5, 20));
                    },
                    child: const Icon(Icons.add),
                  ),
                ),

                // Zoom out
                Builder(builder: (context) {
                  return FloatingActionButton(
                    shape: Border(
                        top: BorderSide(
                            color: Theme.of(context).colorScheme.onSecondary)),
                    onPressed: () {
                      _mapController.move(MapCamera.of(context).center,
                          max(MapCamera.of(context).zoom - 0.5, 3));
                    },
                    child: const Icon(Icons.remove),
                  );
                }),
                const SizedBox(height: 10),
                // Go to Zones page
                FloatingActionButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const Zones()),
                    );
                  },
                  child: const Icon(Icons.architecture),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }
}
