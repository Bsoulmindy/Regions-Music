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
        if (pt.x == last.x) {
          throw Exception("2 same points can't generate a segment");
        }

        double u = (pt.y - last.y) / (pt.x - last.x);
        double v = (pt.x * last.y - pt.y * last.x) / (pt.x - last.x);
        double minT = min(pt.x, last.x);
        double maxT = max(pt.x, last.x);

        segments.add(Segment(id, u, v, minT, maxT));
      }
      last = pt;
    }

    double u = (pts[0].y - last.y) / (pts[0].x - last.x);
    double v = (pts[0].x * last.y - pts[0].y * last.x) / (pts[0].x - last.x);
    double minT = min(pts[0].x, last.x);
    double maxT = max(pts[0].x, last.x);

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
}
