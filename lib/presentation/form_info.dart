import 'package:flutter/material.dart';
import 'package:regions_music/domain/form.dart' as f;
import 'package:regions_music/domain/segment.dart';
import 'package:sqflite/sqflite.dart';

import '../domain/point.dart';

class FormInfos extends StatefulWidget {
  const FormInfos({super.key, required this.form, required this.db});

  final Database db;
  final f.Form form;

  @override
  State<FormInfos> createState() => FormInfosState();
}

class FormInfosState extends State<FormInfos> {
  double? x1;
  double? x2;
  double? y1;
  double? y2;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Form's Points"),
        ),
        body: Table(
          columnWidths: const <int, TableColumnWidth>{
            0: FlexColumnWidth(),
            1: FlexColumnWidth(),
          },
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          children: [
            TableRow(children: [
              Container(
                  padding: const EdgeInsets.only(top: 16, bottom: 16),
                  decoration: const BoxDecoration(
                      border: Border(bottom: BorderSide(color: Colors.grey))),
                  child: const Center(
                      child: Text("X", style: TextStyle(fontSize: 24)))),
              Container(
                  padding: const EdgeInsets.only(top: 16, bottom: 16),
                  decoration: const BoxDecoration(
                      border: Border(bottom: BorderSide(color: Colors.grey))),
                  child: const Center(
                      child: Text("Y", style: TextStyle(fontSize: 24))))
            ]),
            ...getPoints(widget.form.segments)
                .map((point) => TableRow(children: [
                      Container(
                          padding: const EdgeInsets.only(top: 16, bottom: 16),
                          child: Center(
                              child: Text("${point.x}",
                                  style: const TextStyle(
                                      fontSize: 24, color: Colors.grey)))),
                      Container(
                          padding: const EdgeInsets.only(top: 16, bottom: 16),
                          child: Center(
                              child: Text("${point.y}",
                                  style: const TextStyle(
                                      fontSize: 24, color: Colors.grey))))
                    ]))
          ],
        ));
  }
}

Set<Point> getPoints(List<Segment> segments) {
  Set<Point> points = {};

  for (Segment segment in segments) {
    Point pt = Point(segment.minT, segment.minT * segment.u + segment.v);
    points.add(pt);
    pt = Point(segment.maxT, segment.maxT * segment.u + segment.v);
    points.add(pt);
  }

  return points;
}
