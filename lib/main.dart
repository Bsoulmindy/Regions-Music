import 'dart:io';

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';
import 'package:regions_music/application/gps.dart';
import 'package:regions_music/data/database.dart';
import 'package:regions_music/domain/global_state.dart';
import 'package:regions_music/domain/position_factory.dart';
import 'package:regions_music/presentation/tree/main_bar.dart';
import 'package:regions_music/theme.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'application/zone_controller.dart' as z;
import 'domain/music.dart';
import 'domain/zone.dart';

void main() async {
  if (Platform.isWindows || Platform.isLinux) {
    // Initialize FFI
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }
  // Change the default factory. On iOS/Android, if not using `sqlite_flutter_lib` you can forget
  // this step, it will use the sqlite version available on the system.

  Database db = await getData();
  AudioPlayer player = AudioPlayer();
  Music? defaultMusic = await getDefaultMusic(db, player);
  List<Zone> zones = await z.getAllZones(db, player);

  var globalState = GlobalState(
      db: db, player: player, defaultMusic: defaultMusic, zones: zones);
  getGPSStreamPosition()
      .listen((pos) => updateCurrentZoneOnLocation(globalState, pos));

  runApp(
    ChangeNotifierProvider<GlobalState>.value(
      value: globalState,
      child: MediaQuery(
        data: const MediaQueryData(),
        child: MaterialApp(
          theme: ThemeData(colorScheme: MaterialTheme.lightScheme()),
          darkTheme: ThemeData.from(colorScheme: MaterialTheme.darkScheme()),
          home: const MainBar(),
        ),
      ),
    ),
  );
}
