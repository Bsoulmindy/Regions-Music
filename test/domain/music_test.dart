import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:just_audio/just_audio.dart';
import 'package:mockito/annotations.dart';
import 'package:regions_music/domain/global_state.dart';
import 'package:regions_music/domain/music.dart';
import 'package:regions_music/domain/position_factory.dart';
import 'package:regions_music/domain/zone.dart';
import 'package:sqflite/sqflite.dart';
import '../utils/utils.dart';

@GenerateNiceMocks([MockSpec<AudioPlayer>(), MockSpec<Database>()])
void main() {
  WidgetsFlutterBinding.ensureInitialized();

  group("Music Tests", () {
    List<Zone> zones = [parent, zone, zoneChild1, zoneChild2];
    Zone currentZone = zone;
    Music? currentMusic;

    prepareMocks(audioPlayer, db);

    test("Zone change : Base -> Child", () async {
      GlobalState state = GlobalState(
          db: db,
          player: audioPlayer,
          currentMusic: currentMusic,
          currentZone: currentZone,
          defaultMusic: testMusicDefault,
          zones: zones);
      //Initial
      Position pos = createMockPosition(0, 0);
      await updateCurrentZoneOnLocation(state, pos);
      expect(state.currentMusic, testMusic,
          reason: "Initially should be the base music");

      //Entering the child zone 1
      pos = createMockPosition(4, 4);
      await updateCurrentZoneOnLocation(state, pos);
      expect(state.currentMusic, testMusicChild1,
          reason: "We moved to child zone 1");
    });

    test("Infinite Loop", () async {
      GlobalState state = GlobalState(
          db: db,
          player: audioPlayer,
          currentMusic: currentMusic,
          currentZone: currentZone,
          defaultMusic: testMusicDefault,
          zones: zones);
      //Initial : First Level
      Position pos = createMockPosition(0, 0);
      await updateCurrentZoneOnLocation(state, pos);
      expect(state.currentMusic, testMusic,
          reason: "Initially should be the base music");
      expect(state.currentMusic!.currentLevel, 0,
          reason: "Initially the base music level should be 0");

      //Second Level
      await Future.delayed(const Duration(milliseconds: 1000));
      expect(state.currentMusic!.currentLevel, 1,
          reason:
              "After 1 second elpased, the base music level should be saved to 1");

      //Third Level
      await Future.delayed(const Duration(milliseconds: 2000));
      expect(state.currentMusic!.currentLevel, 2,
          reason:
              "After 2 second elpased, the base music level should be saved to 2");
    });

    test("Persistance of music when slight zone change", () async {
      GlobalState state = GlobalState(
          db: db,
          player: audioPlayer,
          currentMusic: currentMusic,
          currentZone: currentZone,
          defaultMusic: testMusicDefault,
          zones: zones);
      //Initial : First Level
      Position pos = createMockPosition(0, 0);
      await updateCurrentZoneOnLocation(state, pos);
      expect(state.currentMusic, testMusic,
          reason: "Initially should be the base music");
      expect(state.currentMusic!.currentLevel, 0,
          reason: "Initially the base music level should be 0");

      await Future.delayed(const Duration(seconds: 3));
      expect(state.currentMusic!.currentLevel, 2,
          reason:
              "After 3 seconds elpased, the base music level should be saved to 2");

      //Entering the child zone 1
      pos = createMockPosition(4, 4);
      await updateCurrentZoneOnLocation(state, pos);
      //Back to base zone
      pos = createMockPosition(0, 0);
      await updateCurrentZoneOnLocation(state, pos);
      expect(state.currentMusic, testMusic, reason: "Should be the base music");
      expect(state.currentMusic!.currentLevel, 2,
          reason: "The base music level should persisted to 2");
    });

    test("Parent music level should also be incremented as the base music",
        () async {
      GlobalState state = GlobalState(
          db: db,
          player: audioPlayer,
          currentMusic: currentMusic,
          currentZone: currentZone,
          defaultMusic: testMusicDefault,
          zones: zones);
      //Initial : First Level
      Position pos = createMockPosition(0, 0);
      await updateCurrentZoneOnLocation(state, pos);
      expect(state.currentMusic, testMusic,
          reason: "Initially should be the base music");
      expect(state.currentMusic!.currentLevel, 0,
          reason: "Initially the base music level should be 0");

      //Entering the child zone 1
      pos = createMockPosition(4, 4);
      await updateCurrentZoneOnLocation(state, pos);
      expect(state.currentMusic, testMusicChild1,
          reason: "Should be the child music");
      expect(state.currentMusic!.currentLevel, 0,
          reason: "the child music level should be initially 0");

      await Future.delayed(const Duration(seconds: 3));
      expect(state.currentMusic!.currentLevel, 2,
          reason: "The child music level should be 2");

      //Back to base zone
      pos = createMockPosition(0, 0);
      await updateCurrentZoneOnLocation(state, pos);
      expect(state.currentMusic, testMusic, reason: "Should be the base music");
      expect(state.currentMusic!.currentLevel, 2,
          reason: "The base music level should also increased to 2");

      //Going to parent zone
      pos = createMockPosition(8, 8);
      await updateCurrentZoneOnLocation(state, pos);
      expect(state.currentMusic, testMusicParent,
          reason: "Should be the parent music");
      expect(state.currentMusic!.currentLevel, 2,
          reason: "The parent music level should also increased to 2");
    });

    test("Inactivity", () async {
      GlobalState state = GlobalState(
          db: db,
          player: audioPlayer,
          currentMusic: currentMusic,
          currentZone: currentZone,
          defaultMusic: testMusicDefault,
          zones: zones);
      //Initial
      Position pos = createMockPosition(1000, 1000);
      await updateCurrentZoneOnLocation(state, pos);
      await Future.delayed(const Duration(seconds: 3));
      expect(state.currentMusic!.currentLevel, 2,
          reason: "The default music level should be 2");

      //Entering the child zone 1
      pos = createMockPosition(0, 0);
      await updateCurrentZoneOnLocation(state, pos);
      await Future.delayed(const Duration(seconds: 3));
      pos = createMockPosition(1000, 1000);
      await updateCurrentZoneOnLocation(state, pos);
      expect(state.currentMusic, testMusicDefault,
          reason: "Should be the default music");
      expect(state.currentMusic!.currentLevel, 0,
          reason:
              "The default music level should be resetted to 0 after the inactivity");
    });
  });
}
