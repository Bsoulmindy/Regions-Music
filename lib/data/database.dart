import 'dart:io';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter/widgets.dart';
import 'dart:async';
import '../domain/music.dart';
import '../domain/zone.dart';
import '../domain/form.dart' as f;
import '../domain/segment.dart';
import 'package:just_audio/just_audio.dart';

Future<Database> getData() async {
  WidgetsFlutterBinding.ensureInitialized();
  //String dbPath = await getDatabasesPath();
  String? home = Platform.environment['HOME'];
  String dbPath;
  if (home != null) {
    dbPath = "$home/snap/regions-music/common";
  } else {
    dbPath = await getDatabasesPath();
  }

  return openDatabase(
    // Set the path to the database. Note: Using the `join` function from the
    // `path` package is best practice to ensure the path is correctly
    // constructed for each platform.
    join(dbPath, 'zone_database.db'),
    // When the database is first created, create the tables.
    onCreate: (db, version) {
      // Run the CREATE TABLE statement on the database.
      return createTables(db);
    },
    // Set the version. This executes the onCreate function and provides a
    // path to perform database upgrades and downgrades.
    version: 2,
  );
}

Future<void> createTables(Database db) async {
  await db.execute(
    'CREATE TABLE Zone(id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, image TEXT, zone_idref INTEGER, FOREIGN KEY(zone_idref) REFERENCES Zone(id))',
  );
  await db.execute(
    'CREATE TABLE Form(id INTEGER PRIMARY KEY AUTOINCREMENT, zone_idref INTEGER, FOREIGN KEY(zone_idref) REFERENCES Zone(id))',
  );
  await db.execute(
    'CREATE TABLE Segment(id INTEGER PRIMARY KEY AUTOINCREMENT, u REAL, v REAL, minT REAL, maxT REAL, form_idref INTEGER, FOREIGN KEY(form_idref) REFERENCES Form(id))',
  );
  await db.execute(
    'CREATE TABLE Music(id INTEGER PRIMARY KEY AUTOINCREMENT, path TEXT, zone_idref INTEGER, FOREIGN KEY(zone_idref) REFERENCES Zone(id))',
  );
  await db.execute(
    'CREATE TABLE Level(id INTEGER PRIMARY KEY AUTOINCREMENT, time INTEGER, music_idref INTEGER, FOREIGN KEY(music_idref) REFERENCES Music(id))',
  );
}

Future<int> insertMusic(Database db, Music music, int zoneAssociedId) async {
  return await db.insert('Music', {
    'path': music.path,
    'zone_idref': zoneAssociedId,
  });
}

Future<int> insertDefaultMusic(Database db, Music music) async {
  await db.rawQuery("DELETE FROM Music WHERE zone_idref is NULL");

  return await db.insert('Music', {
    'path': music.path,
    'zone_idref': null,
  });
}

Future<int> insertZone(Database db, Zone zone, int? zoneParentId) async {
  return await db.insert('Zone', {
    'name': zone.name,
    'image': zone.image,
    'zone_idref': zoneParentId,
  });
}

Future<int> insertForm(Database db, f.Form form, int zoneAssociedId) async {
  int id = await db.insert('Form', {
    'zone_idref': zoneAssociedId,
  });

  for (Segment segment in form.segments) {
    await db.insert('Segment', {
      'u': segment.u,
      'v': segment.v,
      'minT': segment.minT,
      'maxT': segment.maxT,
      'form_idref': id,
    });
  }

  return id;
}

Future<void> insertLevels(Database db, Music musicAssocied) async {
  for (int time in musicAssocied.levels) {
    await db.insert('Level', {
      'time': time,
      'music_idref': musicAssocied.id,
    });
  }
}

Future<int> insertSegment(
    Database db, Segment segment, f.Form formAssocied) async {
  formAssocied.segments.add(segment);
  return await db.insert('Segment', {
    'u': segment.u,
    'v': segment.v,
    'minT': segment.minT,
    'maxT': segment.maxT,
    'form_idref': formAssocied.id,
  });
}

Future<Music> getMusicOfZone(
    Database db, int zoneId, AudioPlayer player) async {
  final List<Map<String, dynamic>> maps =
      await db.rawQuery("SELECT * FROM Music WHERE zone_idref = ?", [zoneId]);

  if (maps.isEmpty) {
    throw Exception("No music attached to a zone (ID : $zoneId )");
  }

  List<int> levels = await getLevelsOfMusic(db, maps[0]['id']);

  return Music(
    maps[0]['id'],
    maps[0]['path'],
    levels,
    player,
  );
}

Future<Music?> getDefaultMusic(Database db, AudioPlayer player) async {
  final List<Map<String, dynamic>> maps =
      await db.rawQuery("SELECT * FROM Music WHERE zone_idref is NULL");

  if (maps.isEmpty) {
    return null;
  }

  List<int> levels = await getLevelsOfMusic(db, maps[0]['id']);

  return Music(
    maps[0]['id'],
    maps[0]['path'],
    levels,
    player,
  );
}

Future<List<f.Form>> getFormsOfZone(Database db, int zoneId) async {
  final List<Map<String, dynamic>> maps =
      await db.rawQuery("SELECT * FROM Form WHERE zone_idref = ?", [zoneId]);

  return Future.wait(List.generate(maps.length, (i) async {
    List<Segment> segments = await getSegmentsOfForm(db, maps[i]['id']);
    return f.Form(maps[i]['id'], segments);
  }));
}

Future<f.Form?> getFormById(Database db, int formId) async {
  final List<Map<String, dynamic>> maps =
      await db.rawQuery("SELECT * FROM Form WHERE id = ?");

  if (maps.isEmpty) {
    return null;
  } else {
    var list = await getSegmentsOfForm(db, formId);
    return f.Form(formId, list);
  }
}

Future<List<Segment>> getSegmentsOfForm(Database db, int formId) async {
  final List<Map<String, dynamic>> maps =
      await db.rawQuery("SELECT * FROM Segment WHERE form_idref = ?", [formId]);

  return List.generate(maps.length, (i) {
    return Segment(
      maps[i]['id'],
      maps[i]['u'],
      maps[i]['v'],
      maps[i]['minT'],
      maps[i]['maxT'],
    );
  });
}

Future<List<int>> getLevelsOfMusic(Database db, int musicId) async {
  final List<Map<String, dynamic>> maps =
      await db.rawQuery("SELECT * FROM Level WHERE music_idref = ?", [musicId]);

  return List.generate(maps.length, (i) {
    return maps[i]['time'];
  });
}

/// Get all zones that have no parents (the most parent zones)
Future<List<Zone>> getMostParentZones(Database db, AudioPlayer player) async {
  final List<Map<String, dynamic>> maps =
      await db.rawQuery("SELECT * FROM Zone WHERE zone_idref is NULL");

  return Future.wait(List.generate(maps.length, (i) async {
    List<f.Form> forms = await getFormsOfZone(db, maps[i]['id']);
    Music music = await getMusicOfZone(db, maps[i]['id'], player);
    return Zone(
        maps[i]['id'], maps[i]['name'], maps[0]['image'], forms, music, null);
  }));
}

Future<List<Zone>> getChildZonesOfParent(Database db, Zone zoneParent) async {
  final List<Map<String, dynamic>> maps = await db
      .rawQuery("SELECT * FROM Zone WHERE zone_idref = ?", [zoneParent.id]);

  return Future.wait(List.generate(maps.length, (i) async {
    List<f.Form> forms = await getFormsOfZone(db, maps[i]['id']);
    Music music =
        await getMusicOfZone(db, maps[i]['id'], zoneParent.music.player);
    return Zone(maps[i]['id'], maps[i]['name'], maps[0]['image'], forms, music,
        zoneParent);
  }));
}

/// Get all zones from database
Future<List<Zone>> getAllZones(Database db, AudioPlayer player) async {
  final List<Map<String, dynamic>> maps =
      await db.rawQuery("SELECT * FROM Zone");

  return Future.wait(List.generate(maps.length, (i) async {
    List<f.Form> forms = await getFormsOfZone(db, maps[i]['id']);
    Music music = await getMusicOfZone(db, maps[i]['id'], player);
    Zone? parentZone = await getZone(db, maps[i]['zone_idref'], player);
    return Zone(maps[i]['id'], maps[i]['name'], maps[0]['image'], forms, music,
        parentZone);
  }));
}

Future<Zone?> getZone(Database db, int? id, AudioPlayer player) async {
  if (id == null) {
    return null;
  }

  final List<Map<String, dynamic>> maps =
      await db.rawQuery("SELECT * FROM Zone WHERE id = ?", [id]);

  if (maps.isEmpty) {
    return null;
  }

  List<f.Form> forms = await getFormsOfZone(db, id);
  Music music = await getMusicOfZone(db, id, player);
  Zone? zoneParent = await getZone(db, maps[0]['zone_idref'], player);

  return Zone(id, maps[0]['name'], maps[0]['image'], forms, music, zoneParent);
}

Future<void> updateMusic(Database db, Music updatedMusic) async {
  await db.update(
    'Music',
    {'path': updatedMusic.path},
    where: 'id = ?',
    whereArgs: [updatedMusic.id],
  );
}

Future<void> updateLevel(Database db, Music updatedMusic) async {
  deleteLevelsOfMusic(db, updatedMusic);
  insertLevels(db, updatedMusic);
}

Future<void> updateZone(Database db, Zone updatedZone) async {
  await db.update(
    'Zone',
    {
      'name': updatedZone.name,
      'image': updatedZone.image,
      'zone_idref': updatedZone.parentZone?.id,
    },
    where: 'id = ?',
    whereArgs: [updatedZone.id],
  );
}

Future<void> updateSegment(Database db, Segment updatedSegment) async {
  await db.update(
    'Segment',
    {
      'u': updatedSegment.u,
      'v': updatedSegment.v,
      'minT': updatedSegment.minT,
      'maxT': updatedSegment.maxT
    },
    where: 'id = ?',
    whereArgs: [updatedSegment.id],
  );
}

Future<void> deleteSegmentsOfForm(Database db, f.Form form) async {
  await db.delete(
    'Segment',
    where: 'form_idref = ?',
    whereArgs: [form.id],
  );
}

Future<void> deleteSegment(Database db, Segment segment) async {
  await db.delete(
    'Segment',
    where: 'id = ?',
    whereArgs: [segment.id],
  );
}

Future<void> deleteFormsOfZone(Database db, Zone zone) async {
  for (f.Form form in zone.space) {
    deleteSegmentsOfForm(db, form);
  }
  await db.delete(
    'Form',
    where: 'zone_idref = ?',
    whereArgs: [zone.id],
  );
}

Future<void> deleteForm(Database db, f.Form form) async {
  deleteSegmentsOfForm(db, form);
  await db.delete(
    'Form',
    where: 'id = ?',
    whereArgs: [form.id],
  );
}

Future<void> deleteLevelsOfMusic(Database db, Music music) async {
  await db.delete(
    'Level',
    where: 'music_idref = ?',
    whereArgs: [music.id],
  );
}

// Delete the zone, the music associed, the forms associed, and mark the childs with the parent of this zone
Future<void> deleteZone(Database db, Zone zone) async {
  deleteLevelsOfMusic(db, zone.music);
  await db.delete(
    'Music',
    where: 'zone_idref = ?',
    whereArgs: [zone.id],
  );
  await db.update(
    'Zone',
    {'zone_idref': zone.parentZone},
    where: 'zone_idref = ?',
    whereArgs: [zone.id],
  );
  await db.delete(
    'Zone',
    where: 'id = ?',
    whereArgs: [zone.id],
  );
  await db.delete(
    'Form',
    where: 'zone_idref = ?',
    whereArgs: [zone.id],
  );
}

Future<void> deleteMusic(Database db, Music music) async {
  await db.delete(
    'Music',
    where: 'zone_idref = ?',
    whereArgs: [null],
  );
}
