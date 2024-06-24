import 'dart:collection';

import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:just_audio/just_audio.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:regions_music/domain/form.dart' as f;
import 'package:regions_music/domain/global_state.dart';
import 'package:regions_music/domain/music.dart';
import 'package:regions_music/domain/point.dart';
import 'package:regions_music/domain/position_factory.dart';
import 'package:regions_music/domain/segment.dart';
import 'package:regions_music/domain/zone.dart';
import 'package:sqflite/sqflite.dart';
import 'zone_test.mocks.dart';

final audioPlayer = MockAudioPlayer();
final db = MockDatabase();
Music testMusic = Music(0, "path", [0, 10], audioPlayer);

f.Form formParent = f.Form.fromPoints(
    0, [Point(10, 10), Point(-10, 10), Point(-10, -10), Point(10, -10)]);
f.Form form = f.Form.fromPoints(
    1, [Point(5, 5), Point(-5, 5), Point(-5, -5), Point(5, -5)]);
f.Form formChild1 =
    f.Form.fromPoints(2, [Point(5, 5), Point(3, 5), Point(3, 3), Point(5, 3)]);
f.Form formChild2 = f.Form.fromPoints(
    3, [Point(-5, -5), Point(-3, -5), Point(-3, -3), Point(-5, -3)]);

Zone parent = Zone.fromForm(0, "parent", "image", formParent, testMusic, null);
Zone zone = Zone.fromForm(1, "zone", "image", form, testMusic, parent);
Zone zoneChild1 =
    Zone.fromForm(2, "zone", "image", formChild1, testMusic, zone);
Zone zoneChild2 =
    Zone.fromForm(3, "zone", "image", formChild2, testMusic, zone);

@GenerateNiceMocks([MockSpec<AudioPlayer>(), MockSpec<Database>()])
void main() {
  WidgetsFlutterBinding.ensureInitialized();

  group("Interaction of zones with location", () {
    List<Zone> zones = [parent, zone, zoneChild1, zoneChild2];
    Zone currentZone = zone;
    Music currentMusic = testMusic;
    GlobalState state = GlobalState(
        db: db,
        player: audioPlayer,
        currentMusic: currentMusic,
        currentZone: currentZone,
        zones: zones);

    prepareMocks(audioPlayer, db);

    test("Interacting with a child zone", () async {
      //Initial
      Position pos = createMockPosition(0, 0);
      await updateCurrentZoneOnLocation(state, pos);
      expect(state.currentZone, zone,
          reason: "Initially should be in main zone");

      //Entering the child zone 1
      pos = createMockPosition(4, 4);
      await updateCurrentZoneOnLocation(state, pos);
      expect(state.currentZone, zoneChild1, reason: "We moved to child zone 1");

      //Leaving the child zone 1
      pos = createMockPosition(2, 2);
      await updateCurrentZoneOnLocation(state, pos);
      expect(state.currentZone, zone,
          reason: "We moved back to main zone from child zone 1");
    });

    test("Interacting with a parent zone", () async {
      //Initial
      Position pos = createMockPosition(0, 0);
      await updateCurrentZoneOnLocation(state, pos);
      expect(state.currentZone, zone,
          reason: "Initially should be in main zone");

      //Entering the parent zone
      pos = createMockPosition(8, 8);
      await updateCurrentZoneOnLocation(state, pos);
      expect(state.currentZone, parent,
          reason: "We exited the main zone, but we still in parent zone");

      //Moving back to main zone
      pos = createMockPosition(2, 2);
      await updateCurrentZoneOnLocation(state, pos);
      expect(state.currentZone, zone,
          reason: "We moved back to main zone from parent zone");
    });

    test("Interacting with no zone", () async {
      //Initial
      Position pos = createMockPosition(8, 8);
      await updateCurrentZoneOnLocation(state, pos);
      expect(state.currentZone, parent,
          reason: "Initially should be in parent zone");

      //Exiting the area
      pos = createMockPosition(1000, 1000);
      await updateCurrentZoneOnLocation(state, pos);
      expect(state.currentZone, null,
          reason: "We exited the parent zone, we are in nowhere");

      //Moving back to parent zone
      pos = createMockPosition(8, 8);
      await updateCurrentZoneOnLocation(state, pos);
      expect(state.currentZone, parent,
          reason: "We moved back to main zone from parent zone");
    });
  });
}

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
  for (int i = 0; i < 4; i++) {
    when(db.rawQuery("SELECT * FROM Music WHERE zone_idref = ?", [i]))
        .thenAnswer((_) => convertMusicToList([testMusic]));
  }
  when(db.rawQuery("SELECT * FROM Level WHERE music_idref = ?", [0]))
      .thenAnswer((_) => convertLevelsToList(testMusic));
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
