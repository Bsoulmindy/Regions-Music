import 'dart:async';

import 'package:geolocator/geolocator.dart';
import 'package:just_audio/just_audio.dart';
import 'package:regions_music/domain/point.dart';
import 'package:regions_music/domain/wrapper.dart';
import 'package:sqflite/sqflite.dart';

import '../application/zone_controller.dart';
import 'music.dart';
import 'zone.dart';

/// Singleton for stream position
class PositionFactory {
  static final PositionFactory _position = PositionFactory._internal();
  static StreamSubscription<Position>? stream;

  factory PositionFactory() {
    return _position;
  }

  PositionFactory._internal();

  StreamSubscription<Position>? getStreamSubscription(
      Wrapper<Zone> currentZone,
      Music? defaultMusic,
      Wrapper<Music> currentMusic,
      Database db,
      AudioPlayer player,
      List<Zone> zones,
      void Function() setStateIfMounted,
      LocationSettings locationSettings) {
    stream ??= Geolocator.getPositionStream(locationSettings: locationSettings)
        .listen((Position? pos) async {
      if (pos != null) {
        Point pt = Point(pos.latitude, pos.longitude);

        // Checking the parent of zone if current zone is not the current anymore
        if (currentZone.value != null && !currentZone.value!.contains(pt)) {
          Zone? tmp = currentZone.value!.parentZone;
          if (tmp != null && tmp.contains(pt)) {
            currentZone.value = tmp;
            setStateIfMounted();
            return;
          }
        }
        if (currentZone.value == null || !currentZone.value!.contains(pt)) {
          Zone? zone = await getCurrentZone(zones, pt, db, player);
          currentZone.value = zone;
          setStateIfMounted();
        }

        // Playing music
        if (currentZone.value == null && currentMusic.value != defaultMusic) {
          currentMusic.value?.stop();
          currentZone.value?.stopMusic();
          currentMusic.value = defaultMusic;
          await currentMusic.value?.playLoop();
        } else if (currentZone.value != null &&
            currentMusic.value != currentZone.value!.music) {
          currentMusic.value?.stop();
          currentZone.value?.stopMusic();
          currentMusic.value = currentZone.value!.music;
          await currentZone.value?.playMusic();
        }
      }
    });

    return stream;
  }
}
