import 'dart:async';

import 'package:geolocator/geolocator.dart';
import 'package:regions_music/domain/global_state.dart';
import 'package:regions_music/domain/point.dart';

import '../application/zone_controller.dart';
import '../data/database.dart';
import 'zone.dart';

Future<void> updateCurrentZoneOnLocation(
    GlobalState state, Position pos) async {
  Point pt = Point(pos.latitude, pos.longitude);

  // Checking if we reached a child zone inside our current zone
  if (state.currentZone != null && state.currentZone!.contains(pt)) {
    List<Zone> childZones =
        await getChildZonesOfParent(state.db, state.currentZone!);
    for (Zone childZone in childZones) {
      if (childZone.contains(pt)) {
        state.currentZone = childZone;
        break;
      }
    }
  }

  // Checking the parent of zone if current zone is not the current anymore
  if (state.currentZone != null && !state.currentZone!.contains(pt)) {
    Zone? parent = state.currentZone!.parentZone;
    if (parent != null && parent.contains(pt)) {
      state.currentZone = parent;
      return;
    }
  }
  if (state.currentZone == null || !state.currentZone!.contains(pt)) {
    List<Zone> zones = await getMostParentZones(state.db, state.player);
    Zone? zone = await getCurrentZone(zones, pt, state.db, state.player);
    state.currentZone = zone;
  }

  // Playing music
  if (state.currentZone == null && state.currentMusic != state.defaultMusic) {
    state.currentMusic?.stop();
    state.currentZone?.stopMusic();
    state.currentMusic = state.defaultMusic;
    state.currentMusic?.playLoop();
  } else if (state.currentZone != null &&
      state.currentMusic != state.currentZone!.music) {
    state.currentMusic?.stop();
    state.currentZone?.stopMusic();
    state.currentMusic = state.currentZone!.music;
    state.currentZone?.playMusic();
  }
}
