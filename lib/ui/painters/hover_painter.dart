import 'dart:typed_data';
import 'dart:ui';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

class HoverPainter extends CustomPainter {
  const HoverPainter(this.points);

  final List<Float32List> points;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
          //
          ..color = Colors.blue
        //
        ;

    for (var i = 0; i < points.length; i++) {
      if (points.elementAtOrNull(i) == null) continue;
      canvas.drawRawPoints(PointMode.polygon, points[i], paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) =>
      !const DeepCollectionEquality()
          .equals(points, (oldDelegate as HoverPainter).points);
}
