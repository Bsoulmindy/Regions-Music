import 'dart:io';

import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:regions_music/domain/alert_exception.dart';
import 'package:sqflite/sqflite.dart';

import '../data/database.dart';
import '../data/file_picker.dart';
import '../domain/music.dart';
import '../data/path.dart';

Future<void> addLevelToMusic(
    Database db, Music music, int time, int pos) async {
  if (pos >= music.levels.length) {
    pos = music.levels.length - 1;
  }
  if (pos < 0) {
    pos = 0;
  }

  music.levels.insert(pos, time);
  await deleteLevelsOfMusic(db, music);
  await insertLevels(db, music);
}

Future<void> addSortedLevelToMusic(Database db, Music music, int time) async {
  music.levels.add(time);
  music.levels.sort();
  await deleteLevelsOfMusic(db, music);
  await insertLevels(db, music);
}

Future<void> changeLevelOfMusic(
    Database db, Music music, int oldTime, int newTime) async {
  if (music.levels.remove(oldTime)) {
    music.levels.add(newTime);
    music.levels.sort();
    await deleteLevelsOfMusic(db, music);
    await insertLevels(db, music);
  }
}

Future<void> deleteLevelFromMusic(Database db, Music music, int time) async {
  if (music.levels.remove(time)) {
    await deleteLevelsOfMusic(db, music);
    await insertLevels(db, music);
  }
}

Future<Music?> addDefaultMusic(
    Database db, AudioPlayer player, File? musicFile) async {
  if (musicFile != null) {
    String localPath;
    try {
      localPath = await getLocalPath();
    } on MissingPlatformDirectoryException {
      rethrow;
    }
    String name = musicFile.uri.pathSegments.last;

    musicFile.copy("$localPath/$name");

    // ids here are abstracts
    Music music = Music(0, "$localPath/$name", [0], player);

    music.id = await insertDefaultMusic(db, music);
    await insertLevels(db, music);

    return music;
  }
  return null;
}

Future<void> changeDefaultMusic(Database db, Music oldDefaultMusic) async {
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
      rethrow;
    }
    String name = file.uri.pathSegments.last;

    file.copy("$localPath/$name");

    // Delete the older music
    File old = File(oldDefaultMusic.path);
    old.delete();

    oldDefaultMusic.path = "$localPath/$name";
    oldDefaultMusic.inactiveTimes = [];
    await updateMusic(db, oldDefaultMusic);
  } else {
    throw Exception("No files selected");
  }
}

Future<void> removeDefaultMusic(Database db, Music music) async {
  await deleteMusic(db, music);
}
