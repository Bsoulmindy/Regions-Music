import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:regions_music/domain/global_state.dart';
import 'package:regions_music/domain/zone.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => DashboardState();
}

class DashboardState extends State<Dashboard> {
  String actualZone = "No Zone";
  int currentLevel = 0;

  @override
  void initState() {
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
                color: Theme.of(context).colorScheme.error,
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
                  color: actualZone != null ? Colors.green : Colors.red)),
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
