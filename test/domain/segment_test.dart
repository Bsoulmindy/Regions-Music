import 'package:flutter_test/flutter_test.dart';
import 'package:regions_music/domain/point.dart';
import 'package:regions_music/domain/segment.dart';

void main() {
  group("Testing vertical segments", () {
    Segment segment = Segment.fromTwoPoints(Point(5, 5), Point(5, -5));

    test("Testing crossing from left to right", () {
      Point pt = Point(0, 0);
      expect(segment.crossesRight(pt), true);
      pt = Point(10, 0);
      expect(segment.crossesRight(pt), false);
      pt = Point(5, 0);
      expect(segment.crossesRight(pt), true,
          reason:
              "Point which is inside segment should be considered crossed from right");
    });

    test("Testing the containing of points inside the segment", () {
      Point pt = Point(0, 0);
      expect(segment.contains(pt), false);
      pt = Point(5, 0);
      expect(segment.contains(pt), true);
      pt = Point(5, 5);
      expect(segment.contains(pt), true);
      pt = Point(5, -5);
      expect(segment.contains(pt), true);
    });
  });
}
