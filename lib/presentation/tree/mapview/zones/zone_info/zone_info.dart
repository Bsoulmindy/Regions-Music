import 'dart:io';

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:regions_music/application/form_controller.dart';
import 'package:regions_music/application/zone_controller.dart';
import 'package:regions_music/data/database.dart';
import 'package:regions_music/domain/alert_exception.dart';
import 'package:regions_music/domain/zone.dart';
import 'package:regions_music/presentation/components/edit_modal_bottom.dart';
import 'package:regions_music/presentation/tree/mapview/zones/zone_info/form_info/form_info.dart';
import 'package:regions_music/presentation/components/list_view_option.dart';
import 'package:regions_music/presentation/tree/music_info/music_info.dart';
import 'package:sqflite/sqflite.dart';
import '../../../../../data/file_picker.dart';
import '../../../../../domain/form.dart' as f;
import '../../../../components/exception_message.dart';

class ZoneInfos extends StatefulWidget {
  const ZoneInfos(
      {super.key,
      required this.zone,
      required this.allZones,
      required this.db,
      required this.player});

  final Zone zone;
  final List<Zone> allZones;
  final Database db;
  final AudioPlayer player;

  @override
  State<ZoneInfos> createState() => ZoneInfosState();
}

class ZoneInfosState extends State<ZoneInfos> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: getZone(widget.db, widget.zone.id, widget.player),
        initialData: widget.zone,
        builder: (context, AsyncSnapshot<Zone?> snapshot) {
          changeFormsName(snapshot.data!.space);
          return Scaffold(
            appBar: AppBar(
              title: Text(snapshot.data!.name),
            ),
            body: Column(children: [
              Row(
                children: [
                  Expanded(
                      flex: 1,
                      child: Container(
                        padding: const EdgeInsets.only(left: 24, right: 24),
                        child: const Text("Name",
                            style: TextStyle(fontSize: 20),
                            textAlign: TextAlign.center),
                      )),
                  Expanded(
                      flex: 3,
                      child: Container(
                        padding: const EdgeInsets.only(right: 24),
                        child: TextField(
                          controller:
                              TextEditingController(text: snapshot.data!.name),
                          onSubmitted: (String newName) async {
                            changeNameOfZone(
                                widget.db, snapshot.data!, newName);
                          },
                        ),
                      )),
                ],
              ),
              Row(
                children: [
                  Expanded(
                      flex: 1,
                      child: Container(
                        padding: const EdgeInsets.only(left: 24, right: 24),
                        child: const Text("Music",
                            style: TextStyle(fontSize: 20),
                            textAlign: TextAlign.center),
                      )),
                  Expanded(
                    flex: 3,
                    child: Container(
                        padding: const EdgeInsets.only(right: 24),
                        child: Material(
                          child: InkWell(
                            child: TextField(
                              controller: TextEditingController(
                                  text: snapshot.data!.music.path),
                              readOnly: true,
                              enabled: false,
                            ),
                            onTap: () {
                              changeMusic(widget.db, snapshot.data!, context);
                              setState(() {});
                            },
                            onLongPress: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => MusicInfos(
                                      music: snapshot.data!.music,
                                      db: widget.db)));
                            },
                          ),
                        )),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                      flex: 1,
                      child: Container(
                        padding: const EdgeInsets.only(left: 24, right: 24),
                        child: const Text("Image",
                            style: TextStyle(fontSize: 20),
                            textAlign: TextAlign.center),
                      )),
                  Expanded(
                    flex: 3,
                    child: Container(
                        padding: const EdgeInsets.only(right: 24),
                        child: Material(
                          child: InkWell(
                            child: TextField(
                              controller: TextEditingController(
                                  text: snapshot.data!.image),
                              readOnly: true,
                              enabled: false,
                            ),
                            onTap: () {
                              changeImage(widget.db, snapshot.data!, context);
                              setState(() {});
                            },
                            onLongPress: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => MusicInfos(
                                      music: snapshot.data!.music,
                                      db: widget.db)));
                            },
                          ),
                        )),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                      flex: 1,
                      child: Container(
                        padding: const EdgeInsets.only(left: 24, right: 24),
                        child: const Text("Parent zone",
                            style: TextStyle(fontSize: 20),
                            textAlign: TextAlign.center),
                      )),
                  Expanded(
                      flex: 3,
                      child: Container(
                          padding: const EdgeInsets.only(right: 24),
                          child: DropdownButton<Zone?>(
                            items: getItems(widget.allZones, widget.zone),
                            onChanged: (Zone? value) async {
                              await changeParentOfZone(
                                  widget.db, snapshot.data!, value);
                              setState(() {});
                            },
                            value: snapshot.data!.parentZone,
                          ))),
                ],
              ),
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Center(
                    child: Text(
                      "Forms",
                      style: TextStyle(fontSize: 32),
                      textAlign: TextAlign.center,
                    ),
                  )
                ],
              ),
              Expanded(
                  child: ListView(
                children: snapshot.data!.space
                    .map((form) => ListViewOption(
                        text: form.name,
                        onLongPress: () => {
                              showModalBottomSheet(
                                  context: context,
                                  builder: (context) => EditModalBottom(
                                        change: "Change the form",
                                        delete: "Delete the form",
                                        onDelete: () async {
                                          Navigator.pop(context);
                                          await deleteForm(widget.db, form);
                                          setState(() {
                                            snapshot.data!.space.remove(form);
                                          });
                                        },
                                        onChange: () => {
                                          Navigator.of(context).push(
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      FormInfos(
                                                          form: form,
                                                          db: widget.db)))
                                        },
                                      ))
                            },
                        onTap: () => {
                              showModalBottomSheet(
                                  context: context,
                                  builder: (context) => EditModalBottom(
                                        change: "Change the form",
                                        delete: "Delete the form",
                                        onDelete: () async {
                                          Navigator.pop(context);
                                          await deleteForm(widget.db, form);
                                          setState(() {
                                            snapshot.data!.space.remove(form);
                                          });
                                        },
                                        onChange: () => {
                                          Navigator.of(context).push(
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      FormInfos(
                                                          form: form,
                                                          db: widget.db)))
                                        },
                                      ))
                            }))
                    .toList(),
              ))
            ]),
            floatingActionButton: FloatingActionButton(
              onPressed: () async {
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      File? pointsFile;
                      return StatefulBuilder(
                          builder: (context, setStateDialog) {
                        return AlertDialog(
                          title: const Text("New Form"),
                          content: SizedBox(
                            width: MediaQuery.of(context).size.width * 0.75,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Row(
                                  children: [
                                    const Text("File"),
                                    Expanded(
                                        child: TextField(
                                      readOnly: true,
                                      controller: TextEditingController(
                                          text: pointsFile?.path),
                                      onTap: () async {
                                        try {
                                          File? f = await fileTextPick();
                                          setStateDialog(() {
                                            pointsFile = f;
                                          });
                                        } on AlertException catch (e) {
                                          if (!context.mounted) return;
                                          showMessage(e, context);
                                        }
                                      },
                                    )),
                                  ],
                                )
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
                                Navigator.pop(context, 'Create');
                                try {
                                  await createFormFromFile(
                                      widget.db, pointsFile, snapshot.data!);
                                  setState(() {});
                                } on AlertException catch (e) {
                                  if (!context.mounted) return;
                                  showMessage(e, context);
                                }
                              },
                              child: const Text('Create'),
                            ),
                          ],
                        );
                      });
                    });
                // await createForm(widget.db, snapshot.data!);
                // setState(() {});
              },
              child: const Icon(Icons.add),
            ),
          );
        });
  }
}

/// Fetch all zones that can be a parent for this current zone with avoiding a possible loop (child -> parent -> child -> ...)
List<DropdownMenuItem<Zone?>> getItems(List<Zone> zones, Zone currentZone) {
  List<DropdownMenuItem<Zone?>> list = [];

  for (Zone zone in zones) {
    // Checking if it's child of currentZone
    Zone? tmp = zone;
    while (tmp != null) {
      if (tmp == currentZone) break;
      tmp = tmp.parentZone;
    }
    if (tmp == currentZone) continue;

    list.add(DropdownMenuItem<Zone?>(
      value: zone,
      child: Text(zone.name),
    ));
  }

  list.add(const DropdownMenuItem<Zone?>(
    value: null,
    child: Text(""),
  ));

  return list;
}

void changeFormsName(List<f.Form> forms) {
  int i = 0;

  for (f.Form form in forms) {
    i++;
    form.name = "Form $i";
  }
}

void changeMusic(Database db, Zone zone, BuildContext context) async {
  try {
    await changeMusicforZone(db, zone);
  } on AlertException catch (e) {
    if (!context.mounted) return;
    showMessage(e, context);
  }
}

void changeImage(Database db, Zone zone, BuildContext context) async {
  try {
    await changeImageforZone(db, zone);
  } on AlertException catch (e) {
    if (!context.mounted) return;
    showMessage(e, context);
  }
}
