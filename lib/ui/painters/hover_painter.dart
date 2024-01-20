import 'dart:typed_data';
import 'dart:ui';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

class HoverPainter extends CustomPainter {
  final List<Float32List> points;

  const HoverPainter(this.points);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.blue;

    for (var i = 0; i < points.length; i++) {
      if (points.elementAtOrNull(i) == null) continue;
      // ignore: avoid-unsafe-collection-methods
      canvas.drawRawPoints(PointMode.polygon, points[i], paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) =>
      !const DeepCollectionEquality()
          .equals(points, (oldDelegate as HoverPainter).points);
}
