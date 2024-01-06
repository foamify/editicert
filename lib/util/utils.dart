// ignore_for_file: prefer-match-file-name

import 'dart:math';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:uuid/uuid.dart';
import 'package:vector_math/vector_math_64.dart';

final _get = GetIt.I.get;
final uuid = Uuid();

const kSidebarWidth = 240.0;
const kTopbarHeight = 52.0;
const kGestureSize = 8.0;
const kGextFieldWidth = 96.0;

typedef Edges = ({Offset bl, Offset br, Offset tl, Offset tr});

extension RectEx on Rect {
  Edges get edges => rotateRect(this, 0, Offset.zero);
}

extension EdgesEx on Edges {
  Edges translated(Offset offset) {
    return (bl: bl + offset, br: br + offset, tl: tl + offset, tr: tr + offset);
  }

  double get angle => getAngleFromPoints(tl, tr);

  Size get size => Size(tr.dx - tl.dx, tr.dy - br.dy);

  Offset get center => getMiddleOffset(tr, bl);

  Rect get unrotated => Rect.fromPoints(
        rotatePoint(bl, center, -angle),
        rotatePoint(tr, center, -angle),
      );
}

Edges rotateRect(Rect rect, double angle, Offset origin) {
  final topLeft = rotatePoint(rect.topLeft, origin, angle);
  final topRight = rotatePoint(rect.topRight, origin, angle);
  final bottomLeft = rotatePoint(rect.bottomLeft, origin, angle);
  final bottomRight = rotatePoint(rect.bottomRight, origin, angle);

  return (tl: topLeft, tr: topRight, bl: bottomLeft, br: bottomRight);
}

Offset rotatePoint(Offset point, Offset origin, double angle) {
  final cosTheta = cos(angle);
  final sinTheta = sin(angle);

  final oPoint = point - origin;
  final x = oPoint.dx;
  final y = oPoint.dy;

  final newX = x * cosTheta - y * sinTheta;
  final newY = x * sinTheta + y * cosTheta;

  return Offset(newX, newY) + origin;
}

Offset closestOffsetOnLine(
  Offset outsideOffset,
  double rotationDegree,
  Offset originalOffset,
) {
  // Step 1: Convert the rotation degree to radians.
  final rotationRadians = rotationDegree * pi / 180;

  // Step 2: Calculate the direction vector from the original offset to the outside offset.
  final directionVector = originalOffset - outsideOffset;

  // Step 3: Project the direction vector onto the line made from the original offset and the rotation degree.
  final projectionLength = directionVector.dx * cos(rotationRadians) +
      directionVector.dy * sin(rotationRadians);
  final projectionVector = Offset(
    projectionLength * cos(rotationRadians),
    projectionLength * sin(rotationRadians),
  );

  // Step 4: Add the projection vector to the original offset to get the closest offset on the line.
  final closestOffset = outsideOffset + projectionVector;

  return closestOffset;
}

/// Snaps the value to the nearest snap value if the keys are pressed
double snap(double value, int snapValue, Set<PhysicalKeyboardKey> keys) =>
    keys.contains(PhysicalKeyboardKey.altLeft)
        ? (value / snapValue).truncateToDouble() * snapValue
        : (value / 0.1).truncateToDouble() * 0.1;

Offset getMiddleOffset(Offset offset1, Offset offset2) {
  final middleX = (offset1.dx + offset2.dx) / 2;
  final middleY = (offset1.dy + offset2.dy) / 2;
  return Offset(middleX, middleY);
}

double getAngleFromPoints(Offset point1, Offset point2) {
  return atan2(point2.dy - point1.dy, point2.dx - point1.dx);
}

Offset getOffset(
  Alignment alignment,
  Edges edges, {
  bool opposite = false,
  bool flipX = false,
  bool flipY = false,
}) {
  var newAlignment = alignment;
  if (flipX) {
    newAlignment = switch (newAlignment) {
      Alignment.topLeft ||
      Alignment.bottomLeft ||
      Alignment.centerLeft =>
        Alignment.topRight,
      Alignment.topRight ||
      Alignment.bottomRight ||
      Alignment.centerRight =>
        Alignment.topLeft,
      _ => newAlignment,
    };
  }
  if (flipY) {
    newAlignment = switch (newAlignment) {
      Alignment.topLeft ||
      Alignment.topRight ||
      Alignment.centerRight =>
        Alignment.bottomLeft,
      Alignment.bottomLeft ||
      Alignment.bottomRight ||
      Alignment.centerLeft =>
        Alignment.topLeft,
      _ => newAlignment,
    };
  }
  final offset = switch (newAlignment) {
    Alignment.topLeft ||
    Alignment.centerLeft ||
    Alignment.topCenter =>
      opposite ? edges.br : edges.tl,
    Alignment.topRight ||
    Alignment.centerRight =>
      opposite ? edges.bl : edges.tr,
    Alignment.bottomLeft ||
    Alignment.bottomCenter =>
      opposite ? edges.tr : edges.bl,
    Alignment.bottomRight => opposite ? edges.tl : edges.br,
    _ => Offset.zero,
  };
  return offset;
}

/// Returns whether there is an intersection between two lines.
/// First two vectors [p1] and [p2] are the first line, and the second two
/// vectors [p3] and [p4] are the second line.
///
/// [returns] whether there is an intersection or not
bool isTwoLinesIntersetcing(Vector2 p1, Vector2 p2, Vector2 p3, Vector2 p4) {
  final double t =
      ((p1.x - p3.x) * (p3.y - p4.y) - (p1.y - p3.y) * (p3.x - p4.x)) /
          ((p1.x - p2.x) * (p3.y - p4.y) - (p1.y - p2.y) * (p3.x - p4.x));
  final double u =
      ((p1.x - p3.x) * (p1.y - p2.y) - (p1.y - p3.y) * (p1.x - p2.x)) /
          ((p1.x - p2.x) * (p3.y - p4.y) - (p1.y - p2.y) * (p3.x - p4.x));

  return 0 <= t && t <= 1 && 0 <= u && u <= 1;
}
