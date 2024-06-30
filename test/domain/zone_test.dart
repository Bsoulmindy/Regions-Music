import 'package:flutter/cupertino.dart';
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

  group("Interaction of zones with location", () {
    List<Zone> zones = [parent, zone, zoneChild1, zoneChild2];
    Zone currentZone = zone;
    Music currentMusic = testMusic;
    GlobalState state = GlobalState(
        db: db,
        player: audioPlayer,
        currentMusic: currentMusic,
        currentZone: currentZone,
        defaultMusic: testMusicDefault,
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
