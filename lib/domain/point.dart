class Point {
  double x;
  double y;

  Point(this.x, this.y);

  @override
  bool operator ==(Object other) {
    if (other is Point) {
      double difX = x - other.x;
      double difY = y - other.y;
      return difX < 0.0001 && difY < 0.0001 && difX > -0.0001 && difY > -0.0001;
    }
    return false;
  }

  @override
  int get hashCode {
    return x.round() + y.round();
  }
}
