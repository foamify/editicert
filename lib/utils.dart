import 'package:flutter/rendering.dart';

import 'dart:math';
import 'package:flutter/material.dart';

({Offset bl, Offset br, Offset tl, Offset tr}) rotateRect(
    Rect rect, double angle, Offset origin) {
  final topLeft = rotatePoint(rect.topLeft, origin, angle);
  final topRight = rotatePoint(rect.topRight, origin, angle);
  final bottomLeft = rotatePoint(rect.bottomLeft, origin, angle);
  final bottomRight = rotatePoint(rect.bottomRight, origin, angle);

  return (tl: topLeft, tr: topRight, bl: bottomLeft, br: bottomRight);
}

Offset rotatePoint(Offset point, Offset origin, double angle) {
  final double dx = cos(angle) * (point.dx - origin.dx) -
      sin(angle) * (point.dy - origin.dy) +
      origin.dx;
  final double dy = sin(angle) * (point.dx - origin.dx) +
      cos(angle) * (point.dy - origin.dy) +
      origin.dy;
  return Offset(dx, dy);
}

Offset closestOffsetOnLine(
    Offset outsideOffset, double rotationDegree, Offset originalOffset) {
  // Step 1: Convert the rotation degree to radians.
  double rotationRadians = rotationDegree * pi / 180;

  // Step 2: Calculate the direction vector from the original offset to the outside offset.
  Offset directionVector = originalOffset - outsideOffset;

  // Step 3: Project the direction vector onto the line made from the original offset and the rotation degree.
  double projectionLength = directionVector.dx * cos(rotationRadians) +
      directionVector.dy * sin(rotationRadians);
  Offset projectionVector = Offset(projectionLength * cos(rotationRadians),
      projectionLength * sin(rotationRadians));

  // Step 4: Add the projection vector to the original offset to get the closest offset on the line.
  Offset closestOffset = outsideOffset + projectionVector;

  return closestOffset;
}

Rect rectFromEdges(({Offset bl, Offset br, Offset tl, Offset tr}) edges) {
  return Rect.fromLTWH(
    edges.tl.dx,
    edges.tl.dy,
    edges.tr.dx - edges.tl.dx,
    edges.tr.dy - edges.bl.dy,
  );
}
