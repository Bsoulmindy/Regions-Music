import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';
import 'package:regions_music/domain/global_state.dart';
import 'package:regions_music/domain/zone.dart';
import 'package:sqflite/sqflite.dart';

import '../application/gps.dart';
import '../domain/music.dart';
import '../domain/wrapper.dart';

class Status extends StatefulWidget {
  const Status(
      {super.key,
      this.streamPos,
      this.streamLocationFunction = updatorPosition});

  final Stream<Position>? streamPos;
  final Future<StreamSubscription<Position>?> Function(
      Wrapper<Zone>,
      Music?,
      Wrapper<Music>,
      Database,
      AudioPlayer,
      void Function(),
      Stream<Position>?) streamLocationFunction;

  @override
  State<Status> createState() => StatusState();
}

class StatusState extends State<Status> {
  String actualZone = "No Zone";
  int currentLevel = 0;

  @override
  void initState() {
    widget.streamLocationFunction(
        widget.currentZone,
        widget.defaultMusic.value,
        widget.currentMusic,
        widget.db,
        widget.player,
        setStateIfMounted,
        widget.streamPos);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    GlobalState state = context.watch<GlobalState>();
    if (state.defaultMusic != null) {
      return Column(
        children: <Widget>[
          getStatusZone(state.currentZone),
          Expanded(
              flex: 3,
              child: Align(
                  alignment: Alignment.center,
                  child: getImage(state.currentZone)))
        ],
      );
    } else {
      return Column(
        children: <Widget>[
          SizedBox(
            height: 50,
            child: Container(
                padding: const EdgeInsets.all(16),
                color: Colors.red[600],
                child: Row(
                  children: [
                    const Icon(Icons.warning),
                    Center(
                        child: Container(
                            padding: const EdgeInsets.only(left: 16),
                            child: const Text("No default music detected!")))
                  ],
                )),
          ),
          getStatusZone(state.currentZone),
          Expanded(
              flex: 3,
              child: Align(
                  alignment: Alignment.center,
                  child: getImage(state.currentZone)))
        ],
      );
    }
  }
}

Widget getStatusZone(Zone? actualZone) {
  return Expanded(
      flex: 1,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text("Actual Zone", style: TextStyle(fontSize: 32)),
          Text(actualZone != null ? actualZone.name : "No Zone",
              style: TextStyle(
                  fontSize: 20,
                  color: actualZone != null ? Colors.red : Colors.green)),
        ],
      ));
}

Widget getImage(Zone? actualZone) {
  if (actualZone == null) {
    return const Text("");
  }

  return Container(
      margin: const EdgeInsets.all(64),
      child: AspectRatio(
          aspectRatio: 1,
          child: Image.file(
            File(actualZone.image),
            fit: BoxFit.fill,
          )));
}
