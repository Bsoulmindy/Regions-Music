import 'dart:collection';

import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mockito/mockito.dart';
import 'package:regions_music/domain/form.dart' as f;
import 'package:regions_music/domain/music.dart';
import 'package:regions_music/domain/point.dart';
import 'package:regions_music/domain/segment.dart';
import 'package:regions_music/domain/zone.dart';

import '../domain/zone_test.mocks.dart';

final audioPlayer = MockAudioPlayer();
final db = MockDatabase();
Music testMusicDefault = Music(0, "path", [0, 1000], audioPlayer);
Music testMusicParent = Music(1, "path", [0, 1000], audioPlayer);
Music testMusic = Music(2, "path", [0, 1000], audioPlayer);
Music testMusicChild1 = Music(3, "path", [0, 1000], audioPlayer);
Music testMusicChild2 = Music(4, "path", [0, 1000], audioPlayer);

f.Form formParent = f.Form.fromPoints(
    0, [Point(10, 10), Point(-10, 10), Point(-10, -10), Point(10, -10)]);
f.Form form = f.Form.fromPoints(
    1, [Point(5, 5), Point(-5, 5), Point(-5, -5), Point(5, -5)]);
f.Form formChild1 =
    f.Form.fromPoints(2, [Point(5, 5), Point(3, 5), Point(3, 3), Point(5, 3)]);
f.Form formChild2 = f.Form.fromPoints(
    3, [Point(-5, -5), Point(-3, -5), Point(-3, -3), Point(-5, -3)]);

Zone parent =
    Zone.fromForm(0, "parent", "image", formParent, testMusicParent, null);
Zone zone = Zone.fromForm(1, "zone", "image", form, testMusic, parent);
Zone zoneChild1 =
    Zone.fromForm(2, "zoneChild1", "image", formChild1, testMusicChild1, zone);
Zone zoneChild2 =
    Zone.fromForm(3, "zoneChild2", "image", formChild2, testMusicChild2, zone);

Position createMockPosition(double x, double y) {
  return Position(
      longitude: y,
      latitude: x,
      accuracy: 0,
      altitude: 0,
      heading: 0,
      speed: 0,
      speedAccuracy: 0,
      timestamp: DateTime.now(),
      altitudeAccuracy: 0,
      headingAccuracy: 0);
}

void prepareMocks(MockAudioPlayer player, MockDatabase db) {
  when(db.rawQuery("SELECT * FROM Zone WHERE zone_idref = ?", [parent.id]))
      .thenAnswer((_) => convertZonesToList([zone]));
  when(db.rawQuery("SELECT * FROM Zone WHERE zone_idref = ?", [zone.id]))
      .thenAnswer((_) => convertZonesToList([zoneChild1, zoneChild2]));
  when(db.rawQuery("SELECT * FROM Zone WHERE zone_idref = ?", [zoneChild1.id]))
      .thenAnswer((_) => convertZonesToList([]));
  when(db.rawQuery("SELECT * FROM Zone WHERE zone_idref = ?", [zoneChild2.id]))
      .thenAnswer((_) => convertZonesToList([]));

  // Forms
  when(db.rawQuery("SELECT * FROM Form WHERE zone_idref = ?", [parent.id]))
      .thenAnswer((_) => convertFormsToList([formParent]));
  when(db.rawQuery("SELECT * FROM Form WHERE zone_idref = ?", [zone.id]))
      .thenAnswer((_) => convertFormsToList([form]));
  when(db.rawQuery("SELECT * FROM Form WHERE zone_idref = ?", [zoneChild1.id]))
      .thenAnswer((_) => convertFormsToList([formChild1]));
  when(db.rawQuery("SELECT * FROM Form WHERE zone_idref = ?", [zoneChild2.id]))
      .thenAnswer((_) => convertFormsToList([formChild2]));

  // Segments
  when(db.rawQuery(
          "SELECT * FROM Segment WHERE form_idref = ?", [formParent.id]))
      .thenAnswer((_) => convertSegmentsToList(formParent.segments));
  when(db.rawQuery("SELECT * FROM Segment WHERE form_idref = ?", [form.id]))
      .thenAnswer((_) => convertSegmentsToList(form.segments));
  when(db.rawQuery(
          "SELECT * FROM Segment WHERE form_idref = ?", [formChild1.id]))
      .thenAnswer((_) => convertSegmentsToList(formChild1.segments));
  when(db.rawQuery(
          "SELECT * FROM Segment WHERE form_idref = ?", [formChild2.id]))
      .thenAnswer((_) => convertSegmentsToList(formChild2.segments));

  // Zones
  when(db.rawQuery("SELECT * FROM Zone WHERE id = ?", [parent.id]))
      .thenAnswer((_) => convertZoneToList(parent));
  when(db.rawQuery("SELECT * FROM Zone WHERE id = ?", [zone.id]))
      .thenAnswer((_) => convertZoneToList(zone));
  when(db.rawQuery("SELECT * FROM Zone WHERE id = ?", [zoneChild1.id]))
      .thenAnswer((_) => convertZoneToList(zoneChild1));
  when(db.rawQuery("SELECT * FROM Zone WHERE id = ?", [zoneChild2.id]))
      .thenAnswer((_) => convertZoneToList(zoneChild2));

  // Most Parent Zones
  when(db.rawQuery("SELECT * FROM Zone WHERE zone_idref is NULL"))
      .thenAnswer((_) => convertZoneToList(parent));

  // Musics & Levels
  when(db.rawQuery("SELECT * FROM Music WHERE zone_idref = ?", [parent.id]))
      .thenAnswer((_) => convertMusicToList([testMusicParent]));
  when(db.rawQuery("SELECT * FROM Music WHERE zone_idref = ?", [zone.id]))
      .thenAnswer((_) => convertMusicToList([testMusic]));
  when(db.rawQuery("SELECT * FROM Music WHERE zone_idref = ?", [zoneChild1.id]))
      .thenAnswer((_) => convertMusicToList([testMusicChild1]));
  when(db.rawQuery("SELECT * FROM Music WHERE zone_idref = ?", [zoneChild2.id]))
      .thenAnswer((_) => convertMusicToList([testMusicChild2]));

  when(db.rawQuery(
          "SELECT * FROM Level WHERE music_idref = ?", [testMusicDefault.id]))
      .thenAnswer((_) => convertLevelsToList(testMusicDefault));
  when(db.rawQuery("SELECT * FROM Level WHERE music_idref = ?", [testMusic.id]))
      .thenAnswer((_) => convertLevelsToList(testMusic));
  when(db.rawQuery(
          "SELECT * FROM Level WHERE music_idref = ?", [testMusicParent.id]))
      .thenAnswer((_) => convertLevelsToList(testMusicParent));
  when(db.rawQuery(
          "SELECT * FROM Level WHERE music_idref = ?", [testMusicChild1.id]))
      .thenAnswer((_) => convertLevelsToList(testMusicChild1));
  when(db.rawQuery(
          "SELECT * FROM Level WHERE music_idref = ?", [testMusicChild2.id]))
      .thenAnswer((_) => convertLevelsToList(testMusicChild2));
}

Future<List<Map<String, dynamic>>> convertZonesToList(List<Zone> zones) async {
  List<Map<String, dynamic>> list = [];

  for (Zone zone in zones) {
    Map<String, dynamic> map = HashMap();
    map["id"] = zone.id;
    map["name"] = zone.name;
    map["image"] = zone.image;
    list.add(map);
  }

  return list;
}

Future<List<Map<String, dynamic>>> convertMusicToList(
    List<Music> musics) async {
  List<Map<String, dynamic>> list = [];

  for (var music in musics) {
    Map<String, dynamic> map = HashMap();
    map["id"] = music.id;
    map["path"] = music.path;
    list.add(map);
  }

  return list;
}

Future<List<Map<String, dynamic>>> convertLevelsToList(Music music) async {
  List<Map<String, dynamic>> list = [];

  for (var level in music.levels) {
    Map<String, dynamic> map = HashMap();
    map["time"] = level;
    list.add(map);
  }

  return list;
}

Future<List<Map<String, dynamic>>> convertFormsToList(
    List<f.Form> forms) async {
  List<Map<String, dynamic>> list = [];

  for (var form in forms) {
    Map<String, dynamic> map = HashMap();
    map["id"] = form.id;
    list.add(map);
  }

  return list;
}

Future<List<Map<String, dynamic>>> convertSegmentsToList(
    List<Segment> segments) async {
  List<Map<String, dynamic>> list = [];

  for (var segment in segments) {
    Map<String, dynamic> map = HashMap();
    map["id"] = segment.id;
    map["u"] = segment.u;
    map["v"] = segment.v;
    map["minT"] = segment.minT;
    map["maxT"] = segment.maxT;
    list.add(map);
  }

  return list;
}

Future<List<Map<String, dynamic>>> convertZoneToList(Zone zone) async {
  List<Map<String, dynamic>> list = [];

  Map<String, dynamic> map = HashMap();
  map["id"] = zone.id;
  map["name"] = zone.name;
  map["image"] = zone.image;
  map["zone_idref"] = zone.parentZone?.id;
  list.add(map);

  return list;
}
