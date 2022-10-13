import 'package:sqflite/sqflite.dart';

import '../data/database.dart';
import '../domain/form.dart' as f;
import '../domain/segment.dart';
import '../domain/point.dart';
import 'dart:math';

Future<Segment> addSegmentToForm(
    Database db, Point pt1, Point pt2, f.Form form) async {
  double u = (pt2.y - pt1.y) / (pt2.x - pt1.x);
  double v = (pt2.x * pt1.y - pt2.y * pt1.x) / (pt2.x - pt1.x);
  double minT = min(pt2.x, pt1.x);
  double maxT = max(pt2.x, pt1.x);
  Segment segment = Segment(0, u, v, minT, maxT);

  segment.id = await insertSegment(db, segment, form);
  form.segments.add(segment);

  return segment;
}

Future<void> changeSegment(
    Database db, Segment segment, Point pt1, Point pt2) async {
  segment.u = (pt2.y - pt1.y) / (pt2.x - pt1.x);
  segment.v = (pt2.x * pt1.y - pt2.y * pt1.x) / (pt2.x - pt1.x);
  segment.v = min(pt2.x, pt1.x);
  segment.maxT = max(pt2.x, pt1.x);

  await updateSegment(db, segment);
}

Future<void> deleteSegmentFromForm(
    Database db, Segment segment, f.Form form) async {
  await deleteSegment(db, segment);
  form.segments.remove(segment);
}
