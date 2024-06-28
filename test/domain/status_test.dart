import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:regions_music/domain/global_state.dart';
import 'package:regions_music/domain/music.dart';
import 'package:regions_music/domain/position_factory.dart';
import 'package:regions_music/domain/zone.dart';
import 'package:regions_music/presentation/main_bar.dart';
import '../utils/utils.dart';

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
