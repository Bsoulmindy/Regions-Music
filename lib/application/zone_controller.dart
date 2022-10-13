import 'dart:io';

import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import '../data/file_picker.dart';
import '../data/path.dart';
import '../data/database.dart';
import '../domain/alert_exception.dart';
import '../domain/music.dart';
import '../domain/point.dart';
import '../domain/zone.dart';

Future<Zone> createZone(Database db, AudioPlayer player, String name,
    File imageFile, File musicFile, int? zoneParentId) async {
  String localPath;
  try {
    localPath = await getLocalPath();
  } on MissingPlatformDirectoryException {
    throw AlertException(
        "The application couldn't get the save directory of your operating system.");
  }
  String nameMusic = musicFile.uri.pathSegments.last;
  musicFile.copy("$localPath/$nameMusic");

  String nameImage = imageFile.uri.pathSegments.last;
  imageFile.copy("$localPath/$nameImage");

  // ids here are abstracts
  Music music = Music(0, "$localPath/$nameMusic", [0], player);
  Zone zone = Zone(0, name, "$localPath/$nameImage", [], music, null);

  zone.id = await insertZone(db, zone, zoneParentId);
  music.id = await insertMusic(db, music, zone.id);
  await insertLevels(db, music);

  zone.music = music;

  return zone;
}

Future<void> changeMusicforZone(Database db, Zone zone) async {
  File? file;
  try {
    file = await fileAudioPick();
  } on AlertException {
    rethrow;
  }
  if (file != null) {
    String localPath;
    try {
      localPath = await getLocalPath();
    } on MissingPlatformDirectoryException {
      throw AlertException(
          "The application couldn't get the save directory of your operating system.");
    }
    String name = file.uri.pathSegments.last;

    // Delete the older music
    File old = File(zone.music.path);
    old.delete();

    file.copy("$localPath/$name");

    zone.music.path = "$localPath/$name";
    zone.music.inactiveTimes = [];
    await updateMusic(db, zone.music);
  }
}

Future<void> changeImageforZone(Database db, Zone zone) async {
  File? file;
  try {
    file = await fileImagePick();
  } on AlertException {
    rethrow;
  }
  if (file != null) {
    String localPath;
    try {
      localPath = await getLocalPath();
    } on MissingPlatformDirectoryException {
      throw AlertException(
          "The application couldn't get the save directory of your operating system.");
    }
    String name = file.uri.pathSegments.last;

    // Delete the older music
    File old = File(zone.music.path);
    old.delete();

    file.copy("$localPath/$name");

    zone.image = "$localPath/$name";

    await updateZone(db, zone);
  }
}

Future<void> changeNameOfZone(Database db, Zone zone, String newName) async {
  zone.name = newName;
  await updateZone(db, zone);
}

Future<void> changeParentOfZone(
    Database db, Zone zone, Zone? parentZone) async {
  zone.parentZone = parentZone;
  await updateZone(db, zone);
}

Future<void> removeZone(Database db, Zone zone) async {
  await deleteZone(db, zone);
}

/// Get all zones from database as form of tree whereas the root nodes are the most children
Future<List<Zone>> getAllZones(Database db, AudioPlayer player) async {
  List<Zone> result = [];
  List<Zone> tmp = await getMostParentZones(db, player);
  List<Zone> tmp2 = [];

  while (tmp.isNotEmpty) {
    for (Zone zone in tmp) {
      List<Zone> childZones = await getChildZonesOfParent(db, zone);
      if (childZones.isEmpty) {
        result.add(zone);
      } else {
        tmp2.addAll(childZones);
      }
    }
    tmp.clear();
    tmp.addAll(tmp2);
    tmp2.clear();
  }

  return result;
}

/// Get the current zone by your location, if no zone is found, return <code>null</code>
Future<Zone?> getCurrentZone(
    List<Zone> zones, Point currentPos, Database db, AudioPlayer player) async {
  Zone? currentZone;
  for (Zone zone in zones) {
    if (zone.contains(currentPos)) {
      currentZone = zone;
      break;
    }
  }

  if (currentZone != null) {
    List<Zone> childZones = await getChildZonesOfParent(db, currentZone);
    while (childZones.isNotEmpty) {
      Zone? tmp;
      for (Zone zone in childZones) {
        if (zone.contains(currentPos)) {
          tmp = zone;
          break;
        }
      }

      if (tmp != null) {
        currentZone = tmp;
        childZones = await getChildZonesOfParent(db, currentZone);
      } else {
        break;
      }
    }

    return currentZone;
  } else {
    return null;
  }
}
