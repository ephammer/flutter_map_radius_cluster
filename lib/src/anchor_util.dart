import 'dart:math';

import 'package:flutter/widgets.dart';

class AnchorUtil {
  static Point<double> removeAnchor(
    Point pos,
    double width,
    double height,
    Alignment anchor,
  ) {
    final x = (pos.x - (width - anchor.x)).toDouble();
    final y = (pos.y - (height - anchor.y)).toDouble();
    return Point(x, y);
  }
}
