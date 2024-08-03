import 'dart:ui';

import 'segment.dart';
import 'point.dart';
import 'dart:math';

class Form {
  int id;
  List<Segment> segments = [];
  String name = "";

  Form(this.id, this.segments);

  Form.fromPoints(this.id, List<Point> pts) {
    Point last = Point(0, 0);
    bool isFirstPoint = true;

    for (Point pt in pts) {
      if (isFirstPoint) {
        isFirstPoint = false;
      } else {
        if (pt.x == last.x && pt.y == last.y) {
          throw Exception("2 same points can't generate a segment");
        }
        late double u;
        late double v;
        late double minT;
        late double maxT;

        if (pt.x != last.x) {
          u = (pt.y - last.y) / (pt.x - last.x);
          v = (pt.x * last.y - pt.y * last.x) / (pt.x - last.x);
          minT = min(pt.x, last.x);
          maxT = max(pt.x, last.x);
        } else {
          u = double.nan;
          v = pt.x;
          minT = min(pt.y, last.y);
          maxT = max(pt.y, last.y);
        }

        segments.add(Segment(id, u, v, minT, maxT));
      }
      last = pt;
    }

    late double u;
    late double v;
    late double minT;
    late double maxT;

    if (pts[0].x != last.x) {
      u = (pts[0].y - last.y) / (pts[0].x - last.x);
      v = (pts[0].x * last.y - pts[0].y * last.x) / (pts[0].x - last.x);
      minT = min(pts[0].x, last.x);
      maxT = max(pts[0].x, last.x);
    } else {
      u = double.nan;
      v = last.x;
      minT = min(pts[0].y, last.y);
      maxT = max(pts[0].y, last.y);
    }

    segments.add(Segment(id, u, v, minT, maxT));
  }

  bool contains(Point pt) {
    // Verification by segments
    int count = 0;

    for (Segment segment in segments) {
      if (segment.crossesRight(pt)) {
        count++;
      }
    }

    return count % 2 == 1;
  }

  Set<Point> getPoints() {
    Set<Point> points = {};

    for (Segment segment in segments) {
      Point pt = Point(segment.minT, segment.minT * segment.u + segment.v);
      points.add(pt);
      pt = Point(segment.maxT, segment.maxT * segment.u + segment.v);
      points.add(pt);
    }

    return points;
  }

  Color getAreaColor() {
    int modulo = id % 10;
    switch (modulo) {
      case 1:
        return const Color.fromARGB(64, 255, 0, 0);
      case 2:
        return const Color.fromARGB(64, 255, 123, 0);
      case 3:
        return const Color.fromARGB(64, 251, 255, 0);
      case 4:
        return const Color.fromARGB(64, 81, 255, 0);
      case 5:
        return const Color.fromARGB(64, 0, 255, 106);
      case 6:
        return const Color.fromARGB(64, 0, 255, 242);
      case 7:
        return const Color.fromARGB(64, 0, 110, 255);
      case 8:
        return const Color.fromARGB(64, 17, 0, 255);
      case 9:
        return const Color.fromARGB(64, 153, 0, 255);
      case 0:
        return const Color.fromARGB(64, 247, 0, 255);

      default:
        return const Color.fromARGB(64, 0, 0, 0);
    }
  }
}
