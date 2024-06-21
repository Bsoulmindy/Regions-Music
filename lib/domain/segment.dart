import 'dart:math';

import 'point.dart';

// y = u*x + v
class Segment {
  late int id;
  late double u;
  late double v;
  late double minT;
  late double maxT;

  Segment(this.id, this.u, this.v, this.minT, this.maxT);

  Segment.fromTwoPoints(Point pt1, Point pt2) {
    id = 0;
    if (pt1.x != pt2.x) {
      u = (pt2.y - pt1.y) / (pt2.x - pt1.x);
      v = (pt2.x * pt1.y - pt2.y * pt1.x) / (pt2.x - pt1.x);
      minT = min(pt2.x, pt1.x);
      maxT = max(pt2.x, pt1.x);
    } else {
      u = double.nan;
      v = pt1.x;
      minT = min(pt2.y, pt1.y);
      maxT = max(pt2.y, pt1.y);
    }
  }

  bool contains(Point pt) {
    if (!u.isNaN) {
      if (pt.x < minT || pt.x > maxT) return false;

      double y = pt.y - u * pt.x - v;

      return y < 0.001 && y > -0.001; // small errors are accepted
    } else {
      return pt.y <= maxT && pt.y >= minT && pt.x == v;
    }
  }

  bool crossesRight(Point pt) {
    if (!u.isNaN) {
      if (u != 0) {
        double t = (pt.y - v) / u;

        return t >= minT && t <= maxT && t >= pt.x;
      } else {
        return pt.x == v;
      }
    } else {
      return pt.y <= maxT && pt.y >= minT && pt.x <= v;
    }
  }
}
