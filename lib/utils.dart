import 'package:flutter/rendering.dart';
import 'package:vector_math/vector_math_64.dart';

import 'dart:math';
import 'package:flutter/material.dart';

(Offset, Offset, Offset, Offset) rotateRect(Rect rect, double angle, Offset origin) {
  Offset rotatePoint(Offset point, Offset origin, double angle) {
    final double dx = cos(angle) * (point.dx - origin.dx) - sin(angle) * (point.dy - origin.dy) + origin.dx;
    final double dy = sin(angle) * (point.dx - origin.dx) + cos(angle) * (point.dy - origin.dy) + origin.dy;
    return Offset(dx, dy);
  }

  final topLeft = rotatePoint(rect.topLeft, origin, angle);
  final topRight = rotatePoint(rect.topRight, origin, angle);
  final bottomLeft = rotatePoint(rect.bottomLeft, origin, angle);
  final bottomRight = rotatePoint(rect.bottomRight, origin, angle);

  return (topLeft, topRight, bottomLeft, bottomRight);
}
