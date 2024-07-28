import 'dart:io';

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';
import 'package:regions_music/application/zone_controller.dart';
import 'package:regions_music/data/database.dart' as z;
import 'package:regions_music/data/file_picker.dart';
import 'package:regions_music/domain/global_state.dart';
import 'package:regions_music/presentation/components/data_loader_widget.dart';
import 'package:regions_music/presentation/components/edit_modal_bottom.dart';
import 'package:regions_music/presentation/components/list_view_option.dart';
import 'package:regions_music/presentation/tree/mapview/zones/zone_info/zone_info.dart';
import 'package:sqflite/sqflite.dart';

import '../../../../domain/alert_exception.dart';
import '../../../../domain/zone.dart';
import '../../../components/exception_message.dart';

class Zones extends StatefulWidget {
  const Zones({super.key});

  @override
  State<Zones> createState() => ZonesState();
}

class ZonesState extends State<Zones> {
  void setStateIfMounted() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GlobalState>(
      builder: (BuildContext context, GlobalState state, Widget? child) =>
          DataLoaderWidget(
              future: z.getAllZones(state.db, state.player),
              onSuccess: ((context, List<Zone> data) {
                return Scaffold(
                  appBar: AppBar(
                    title: const Center(
                      child: Text(
                        "Zones",
                        style: TextStyle(fontSize: 32),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  body: Expanded(
                      child: ListView(
                    children: [
                      ...data.map((zone) => ListViewOption(
                          leading: const Icon(Icons.place),
                          text: zone.name,
                          onTap: () {
                            editZone(context, zone, data, state.db,
                                state.player, setStateIfMounted);
                          }))
                    ],
                  )),
                  floatingActionButton: FloatingActionButton(
                    onPressed: () {
                      showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            String newZoneName = "";
                            File? imageFile;
                            File? musicFile;
                            return StatefulBuilder(
                                builder: (context, setStateDialog) {
                              return AlertDialog(
                                title: const Text("New Zone"),
                                content: SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * 0.75,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Row(
                                        children: [
                                          const Text("Name : "),
                                          Expanded(child: TextField(
                                            onChanged: (String newName) {
                                              newZoneName = newName;
                                            },
                                          ))
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          const Text("Music : "),
                                          Expanded(
                                              child: TextField(
                                            readOnly: true,
                                            controller: TextEditingController(
                                                text: musicFile?.path),
                                            onTap: () async {
                                              try {
                                                File? f = await fileAudioPick();
                                                if (f == null) return;
                                                setStateDialog(() {
                                                  musicFile = f;
                                                });
                                              } on AlertException catch (e) {
                                                if (!context.mounted) return;
                                                showMessage(e, context);
                                              }
                                            },
                                          )),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          const Text("Image : "),
                                          Expanded(
                                              child: TextField(
                                            readOnly: true,
                                            controller: TextEditingController(
                                                text: imageFile?.path),
                                            onTap: () async {
                                              try {
                                                File? f = await fileImagePick();
                                                if (f == null) return;
                                                setStateDialog(() {
                                                  imageFile = f;
                                                });
                                              } on AlertException catch (e) {
                                                if (!context.mounted) return;
                                                showMessage(e, context);
                                              }
                                            },
                                          )),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                actions: <Widget>[
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, 'Cancel'),
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () async {
                                      if (musicFile == null ||
                                          imageFile == null ||
                                          newZoneName.isEmpty) {
                                        return;
                                      }
                                      Navigator.pop(context, 'Create');
                                      try {
                                        Zone z = await createZone(
                                            state.db,
                                            state.player,
                                            newZoneName,
                                            imageFile!,
                                            musicFile!,
                                            null);
                                        data.add(z);
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
                    },
                    child: const Icon(Icons.add),
                  ),
                );
              })),
    );
  }
}

void editZone(BuildContext context, Zone zone, List<Zone> data, Database db,
    AudioPlayer player, void Function() setState) {
  showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (context) => EditModalBottom(
            change: "Change the zone",
            delete: "Delete the zone",
            onDelete: () async {
              Navigator.pop(context);
              await z.deleteZone(db, zone);
              setState();
            },
            onChange: () => {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => ZoneInfos(
                      zone: zone, allZones: data, db: db, player: player)))
            },
          ));
}
