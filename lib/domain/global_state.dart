import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'music.dart';
import 'zone.dart';

class GlobalState with ChangeNotifier {
  Database _db;
  AudioPlayer _player;
  Music? _defaultMusic;
  Music? _currentMusic;
  List<Zone> _zones;
  Zone? _currentZone;

  Database get db => _db;
  AudioPlayer get player => _player;
  Music? get defaultMusic => _defaultMusic;
  Music? get currentMusic => _currentMusic;
  List<Zone> get zones => _zones;
  Zone? get currentZone => _currentZone;

  GlobalState({
    required Database db,
    required AudioPlayer player,
    Music? defaultMusic,
    Music? currentMusic,
    Zone? currentZone,
    List<Zone> zones = const [],
  })  : _db = db,
        _player = player,
        _defaultMusic = defaultMusic,
        _currentMusic = currentMusic,
        _currentZone = currentZone,
        _zones = zones;

  set db(Database db) {
    _db = db;
    notifyListeners();
  }

  set player(AudioPlayer player) {
    _player = player;
    notifyListeners();
  }

  set defaultMusic(Music? defaultMusic) {
    _defaultMusic = defaultMusic;
    notifyListeners();
  }

  set currentMusic(Music? currentMusic) {
    _currentMusic = currentMusic;
    notifyListeners();
  }

  set currentZone(Zone? currentZone) {
    _currentZone = currentZone;
    notifyListeners();
  }

  set zones(List<Zone> zones) {
    _zones = zones;
    notifyListeners();
  }
}
