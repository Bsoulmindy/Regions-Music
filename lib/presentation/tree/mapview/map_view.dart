import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:regions_music/application/gps.dart';
import 'package:regions_music/domain/global_state.dart';
import 'package:regions_music/presentation/tree/mapview/zones/zones.dart';

class MapView extends StatefulWidget {
  const MapView({super.key});

  @override
  State<StatefulWidget> createState() => MapViewState();
}

class MapViewState extends State<MapView> {
  final _mapController = MapController();
  LatLng? _userPos;
  late StreamSubscription<Position> _gpsStreamListener;

  @override
  void initState() {
    _gpsStreamListener = getGPSStreamPosition().listen((pos) {
      setState(() {
        _userPos = LatLng(pos.latitude, pos.longitude);
      });
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      mapController: _mapController,
      options: const MapOptions(
        initialCenter: LatLng(30.36, -9.51),
        initialZoom: 4.0,
        keepAlive: true,
        maxZoom: 14,
        minZoom: 3,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'ma.bhc.regions_music',
        ),
        Consumer<GlobalState>(
            builder: (BuildContext context, GlobalState state, Widget? child) {
          List<Polygon> polygons = [];
          for (var zone in state.zones) {
            for (var form in zone.space) {
              polygons.add(Polygon(
                color: form.getAreaColor(),
                points: form
                    .getPoints()
                    .map((point) => LatLng(point.x, point.y))
                    .toList(),
              ));
            }
          }

          return PolygonLayer(polygons: polygons);
        }),
        MarkerLayer(
          markers: _userPos != null
              ? [
                  Marker(
                    point: _userPos!,
                    width: 24,
                    height: 24,
                    child: const Icon(Icons.gps_fixed),
                  ),
                ]
              : [],
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
                // Move to current position if available
                FloatingActionButton(
                  heroTag: "moveCurrPos-button",
                  onPressed: () {
                    LatLng? currUserPos = _userPos;
                    // If the current position is not found yet, do nothing
                    if (currUserPos == null) return;
                    _mapController.move(
                        currUserPos, MapCamera.of(context).zoom);
                  },
                  child: const Icon(Icons.gps_fixed),
                ),
                const SizedBox(height: 10),
                // Zoom in
                Builder(
                  builder: (context) => FloatingActionButton(
                    heroTag: "zoomin-button",
                    shape: const Border(bottom: BorderSide()),
                    onPressed: () {
                      _mapController.move(MapCamera.of(context).center,
                          min(MapCamera.of(context).zoom + 1, 14));
                    },
                    child: const Icon(Icons.add),
                  ),
                ),

                // Zoom out
                Builder(builder: (context) {
                  return FloatingActionButton(
                    heroTag: "zoomout-button",
                    shape: Border(
                        top: BorderSide(
                            color: Theme.of(context).colorScheme.onSecondary)),
                    onPressed: () {
                      _mapController.move(MapCamera.of(context).center,
                          max(MapCamera.of(context).zoom - 1, 3));
                    },
                    child: const Icon(Icons.remove),
                  );
                }),
                const SizedBox(height: 10),
                // Go to Zones page
                FloatingActionButton(
                  heroTag: "zonespage-button",
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
    _gpsStreamListener.cancel();
    super.dispose();
  }
}
