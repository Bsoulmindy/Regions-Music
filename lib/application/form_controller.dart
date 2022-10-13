import 'dart:convert';
import 'dart:io';

import 'package:regions_music/domain/alert_exception.dart';
import 'package:sqflite/sqflite.dart';

import '../data/database.dart';
import '../domain/point.dart';
import '../domain/zone.dart';
import '../domain/form.dart' as f;

Future<f.Form> createForm(Database db, Zone zone) async {
  f.Form form = f.Form(0, []);
  form.id = await insertForm(db, form, zone.id);
  zone.space.add(form);

  return form;
}

Future<void> deleteFormFromZone(Database db, f.Form form, Zone zone) async {
  await deleteForm(db, form);
  zone.space.remove(form);
}

Future<void> createFormFromFile(Database db, File? file, Zone zone) async {
  if (file != null) {
    Stream<String> lines =
        file.openRead().transform(utf8.decoder).transform(const LineSplitter());

    try {
      List<Point> points = List.empty(growable: true);
      await for (var line in lines) {
        List<String> splitted = line.split(" ");
        if (splitted.length != 2) continue;
        double? x = double.tryParse(splitted[0]);
        double? y = double.tryParse(splitted[1]);

        if (x == null || y == null) continue;
        points.add(Point(x, y));
      }

      // Creating the form
      f.Form form = f.Form.fromPoints(0, points);
      form.id = await insertForm(db, form, zone.id);
      zone.space.add(form);
    } catch (e) {
      throw AlertException("Please specify a valid file!");
    }
  }
}
