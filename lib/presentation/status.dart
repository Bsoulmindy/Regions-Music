import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:just_audio/just_audio.dart';
import 'package:regions_music/domain/zone.dart';
import 'package:sqflite/sqflite.dart';

import '../application/gps.dart';
import '../domain/music.dart';
import '../domain/wrapper.dart';

class Status extends StatefulWidget {
  const Status(
      {super.key,
      required this.db,
      required this.player,
      required this.defaultMusic,
      required this.currentMusic,
      required this.zones,
      required this.currentZone,
      this.streamPos,
      this.streamLocationFunction = updatorPosition});

  final Database db;
  final AudioPlayer player;
  final Wrapper<Music> defaultMusic;
  final Wrapper<Music> currentMusic;
  final List<Zone> zones;
  final Wrapper<Zone> currentZone;
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

  void setStateIfMounted() {
    if (mounted) {
      setState(() {
        actualZone = widget.currentZone.value == null
            ? "No Zone"
            : widget.currentZone.value!.name;
      });
    }
  }

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
    actualZone = widget.currentZone.value == null
        ? "No Zone"
        : widget.currentZone.value!.name;
    currentLevel = widget.currentZone.value == null
        ? 0
        : widget.currentZone.value!.music.currentLevel;

    if (widget.defaultMusic.value != null) {
      return Column(
        children: <Widget>[
          getStatusZone(actualZone),
          Expanded(
              flex: 3,
              child: Align(
                  alignment: Alignment.center,
                  child: getImage(widget.currentZone.value)))
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
          getStatusZone(actualZone),
          Expanded(
              flex: 3,
              child: Align(
                  alignment: Alignment.center,
                  child: getImage(widget.currentZone.value)))
        ],
      );
    }
  }
}

Widget getStatusZone(String actualZone) {
  return Expanded(
      flex: 1,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text("Actual Zone", style: TextStyle(fontSize: 32)),
          Text(actualZone,
              style: TextStyle(
                  fontSize: 20,
                  color: actualZone == "No Zone" ? Colors.red : Colors.green)),
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
