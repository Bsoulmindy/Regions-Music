import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_window_close/flutter_window_close.dart';
import 'package:geolocator/geolocator.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';
import 'package:regions_music/application/gps.dart';
import 'package:regions_music/application/music_controller.dart';
import 'package:regions_music/data/file_picker.dart';
import 'package:regions_music/domain/global_state.dart';
import 'package:regions_music/domain/music.dart';
import 'package:regions_music/domain/wrapper.dart';
import 'package:regions_music/presentation/music_info.dart';
import 'package:regions_music/presentation/status.dart';
import 'package:regions_music/presentation/zones.dart';
import 'package:sqflite/sqflite.dart';

import '../domain/alert_exception.dart';
import '../domain/zone.dart';
import 'exception_message.dart';

class MainBar extends StatefulWidget {
  const MainBar(
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
  State<MainBar> createState() => MainBarState();
}

class MainBarState extends State<MainBar> {
  @override
  void initState() {
    super.initState();

    FlutterWindowClose.setWindowShouldCloseHandler(() async {
      return await showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
                title: const Text('Do you really want to quit?'),
                actions: [
                  Consumer<GlobalState>(
                    builder: (BuildContext context, GlobalState state,
                            Widget? child) =>
                        ElevatedButton(
                            onPressed: () async {
                              Navigator.of(context).pop(true);
                              await state.player.stop();
                            },
                            child: const Text('Yes')),
                  ),
                  ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('No')),
                ]);
          });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (Platform.isLinux && Process.runSync("which", ["mpv"]).exitCode != 0) {
      showMessage(
          Exception(
              "MPV package is not installed! Therefore we can't play music."),
          context);
    }

    return DefaultTabController(
      initialIndex: 0,
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          bottom: const TabBar(
            tabs: <Widget>[
              Tab(
                text: "Status",
              ),
              Tab(
                text: "Manage",
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: <Widget>[
            Center(
              child: Status(
                streamLocationFunction: widget.streamLocationFunction,
                streamPos: widget.streamPos,
              ),
            ),
            const Center(
              child: Zones(),
            ),
          ],
        ),
        drawer: Drawer(
            child: ListView(
          children: [
            const SizedBox(
                height: 100,
                child: DrawerHeader(
                  decoration: BoxDecoration(color: Colors.blue),
                  margin: EdgeInsets.only(bottom: 0),
                  child: Center(
                      child: Text(
                    "Settings",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 40,
                    ),
                  )),
                )),
            ListTile(
              leading: const Icon(Icons.music_note),
              title: const Text("Default music"),
              onTap: () async {
                File? musicFile;
                try {
                  musicFile = await fileAudioPick();
                } on AlertException catch (e) {
                  if (!context.mounted) return;
                  showMessage(e, context);
                }
                if (musicFile != null) {
                  if (!context.mounted) return;
                  GlobalState state = context.watch<GlobalState>();
                  Music? music =
                      await addDefaultMusic(state.db, state.player, musicFile);
                  state.defaultMusic = music;
                }
              },
              onLongPress: () {
                GlobalState state = context.read<GlobalState>();
                if (state.defaultMusic != null) {
                  Navigator.of(context)
                      .push(MaterialPageRoute(builder: (context) {
                    return MusicInfos(db: state.db, music: state.defaultMusic!);
                  }));
                }
              },
            ),
          ],
        )),
      ),
    );
  }
}
