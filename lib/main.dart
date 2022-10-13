import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:regions_music/data/database.dart';
import 'package:regions_music/domain/wrapper.dart';
import 'package:regions_music/presentation/main_bar.dart';
import 'package:sqflite/sqflite.dart';

import 'application/zone_controller.dart' as z;
import 'domain/music.dart';
import 'domain/zone.dart';

void main() async {
  Database db = await getData();
  AudioPlayer player = AudioPlayer();

  Wrapper<Music> defaultMusic = Wrapper(await getDefaultMusic(db, player));
  Wrapper<Music> currentMusic = Wrapper(null);
  List<Zone> zones = await z.getAllZones(db, player);
  Wrapper<Zone> currentZone = Wrapper(null);

  runApp(MediaQuery(
    data: const MediaQueryData(),
    child: MaterialApp(
        home: MainBar(
      db: db,
      player: player,
      defaultMusic: defaultMusic,
      zones: zones,
      currentZone: currentZone,
      currentMusic: currentMusic,
    )),
  ));
}
