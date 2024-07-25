import 'package:flutter/material.dart';
import 'package:regions_music/application/music_controller.dart';
import 'package:regions_music/domain/music.dart';
import 'package:regions_music/presentation/components/edit_modal_bottom.dart';
import 'package:regions_music/presentation/components/list_view_option.dart';
import 'package:sqflite/sqflite.dart';

class MusicInfos extends StatefulWidget {
  const MusicInfos({super.key, required this.music, required this.db});

  final Music music;
  final Database db;

  @override
  State<MusicInfos> createState() => MusicInfosState();
}

class MusicInfosState extends State<MusicInfos> {
  int? time;

  void setStateIfMounted() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Music levels"),
      ),
      body: ListView(children: [
        const Divider(
          indent: 100,
          endIndent: 100,
        ),
        ...widget.music.levels.map((level) => ListViewOption(
            text: convertLevelToTime(level),
            leading: const Icon(Icons.music_video),
            onTap: () {
              editLevel(context, time, level, widget.db, widget.music,
                  setStateIfMounted);
            }))
      ]),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          time = null;
          showDialog(
              context: context,
              builder: ((BuildContext context) => AlertDialog(
                    title: const Text("New Level"),
                    content: SizedBox(
                      width: MediaQuery.of(context).size.width * 0.75,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              const Text("Start time (ms) : "),
                              Expanded(
                                  child: TextField(
                                keyboardType: TextInputType.number,
                                onChanged: (String value) {
                                  time = int.tryParse(value);
                                },
                              ))
                            ],
                          ),
                        ],
                      ),
                    ),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () => Navigator.pop(context, 'Cancel'),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () async {
                          if (time != null) {
                            Navigator.pop(context);
                            await addSortedLevelToMusic(
                                widget.db, widget.music, time!);
                            setState(() {});
                          }
                        },
                        child: const Text('Create'),
                      ),
                    ],
                  )));
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

void editLevel(BuildContext context, int? time, int level, Database db,
    Music music, void Function() setStateIfMounted) {
  showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (context) => EditModalBottom(
          onChange: () {
            time = null;
            showDialog(
                context: context,
                builder: ((BuildContext context) => AlertDialog(
                      title: const Text("Change Level"),
                      content: SizedBox(
                        width: MediaQuery.of(context).size.width * 0.75,
                        child: Row(
                          children: [
                            const Text("Start time (ms) : "),
                            Expanded(
                                child: TextField(
                              keyboardType: TextInputType.number,
                              onChanged: (String value) {
                                time = int.tryParse(value);
                              },
                            ))
                          ],
                        ),
                      ),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () => Navigator.pop(context, 'Cancel'),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () async {
                            if (time != null) {
                              Navigator.pop(context);
                              await changeLevelOfMusic(db, music, level, time!);
                              setStateIfMounted();
                            }
                          },
                          child: const Text('Change'),
                        ),
                      ],
                    )));
          },
          change: "Change the time",
          delete: "Delete the level",
          onDelete: () async {
            Navigator.pop(context);
            await deleteLevelFromMusic(db, music, level);
            setStateIfMounted();
          }));
}

String convertLevelToTime(int level) {
  int ms = level % 1000;
  level -= ms;
  level = (level / 1000).round();
  int s = level % 60;
  level -= s;
  level = (level / 60).round();
  int m = level % 60;
  level -= m;
  level = (level / 60).round();
  int h = level;

  String miliseconds;
  String seconds;
  String minutes;
  String hours;

  if (ms < 10) {
    miliseconds = "00$ms";
  } else if (ms < 100) {
    miliseconds = "0$ms";
  } else {
    miliseconds = ms.toString();
  }

  if (s < 10) {
    seconds = "0$s";
  } else {
    seconds = s.toString();
  }

  if (m < 10) {
    minutes = "0$m";
  } else {
    minutes = m.toString();
  }

  if (h < 10) {
    hours = "0$h";
  } else {
    hours = h.toString();
  }

  return "$hours:$minutes:$seconds:$miliseconds";
}
