import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:just_audio/just_audio.dart';
import 'package:mockito/annotations.dart';
import 'package:provider/provider.dart';
import 'package:regions_music/domain/form.dart' as f;
import 'package:regions_music/domain/global_state.dart';
import 'package:regions_music/domain/music.dart';
import 'package:regions_music/domain/point.dart';
import 'package:regions_music/domain/position_factory.dart';
import 'package:regions_music/domain/zone.dart';
import 'package:regions_music/presentation/main_bar.dart';
import 'package:sqflite/sqflite.dart';
import 'zone_test.mocks.dart';
import 'zone_test.dart';

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

Zone parent = Zone.fromForm(0, "parent", "image", formParent, testMusic, null);
Zone zone = Zone.fromForm(1, "zone", "image", form, testMusic, parent);
Zone zoneChild1 =
    Zone.fromForm(2, "zoneChild1", "image", formChild1, testMusic, zone);
Zone zoneChild2 =
    Zone.fromForm(3, "zoneChild2", "image", formChild2, testMusic, zone);

@GenerateNiceMocks([MockSpec<AudioPlayer>(), MockSpec<Database>()])
void main() {
  testWidgets("Changing zone status after zone change", (tester) async {
    List<Zone> zones = [parent, zone, zoneChild1, zoneChild2];
    Zone currentZone = zone;
    Music currentMusic = testMusic;
    StreamController<Position> controllerMock = StreamController<Position>();
    Stream<Position> mockStream = controllerMock.stream;

    prepareMocks(audioPlayer, db);
    var globalState = GlobalState(
        db: db,
        player: audioPlayer,
        zones: zones,
        currentZone: currentZone,
        currentMusic: currentMusic);
    mockStream.listen((pos) => updateCurrentZoneOnLocation(globalState, pos));

    var statusWidget = MaterialApp(
        home: ChangeNotifierProvider.value(
      value: globalState,
      child: const MainBar(),
    ));

    await tester.pumpWidget(statusWidget);
    await tester.pump(const Duration(milliseconds: 200));

    //Initial
    Position pos = createMockPosition(0, 0);
    controllerMock.add(pos);
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text(zone.name), findsOneWidget,
        reason: "Initially the status should display the main zone");

    //Entering the child zone 1
    pos = createMockPosition(4, 4);
    controllerMock.add(pos);
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text(zoneChild1.name), findsOneWidget,
        reason: "We moved to child zone 1");

    //Leaving the child zone 1
    pos = createMockPosition(2, 2);
    controllerMock.add(pos);
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text(zone.name), findsOneWidget,
        reason: "We moved back to main zone from child zone 1");
  });
}
