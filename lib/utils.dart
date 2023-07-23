import 'dart:math';
import 'package:editicert/logic/canvas_service.dart';
import 'package:editicert/logic/component_index_service.dart';
import 'package:editicert/logic/component_service.dart';
import 'package:editicert/logic/global_state_service.dart';
import 'package:editicert/logic/services.dart';
import 'package:editicert/logic/tool_service.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';

final _get = GetIt.I.get;

TransformationControllerData get canvasTransform =>
    _get<TransformationControllerData>();

Components get componentsNotifier => _get<Components>();

Tool get toolNotifier => _get<Tool>();

Keys get keysNotifier => _get<Keys>();

Selected get selectedNotifier => _get<Selected>();

Hovered get hoveredNotifier => _get<Hovered>();

GlobalState get globalStateNotifier => _get<GlobalState>();

CanvasState get canvasStateNotifier => _get<CanvasState>();

Services get services => _get<Services>();

const sidebarWidth = 240.0;
const topbarHeight = 52.0;
const gestureSize = 8.0;
const textFieldWidth = 96.0;

({Offset bl, Offset br, Offset tl, Offset tr}) rotateRect(
  Rect rect,
  double angle,
  Offset origin,
) {
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
  Offset outsideOffset,
  double rotationDegree,
  Offset originalOffset,
) {
  // Step 1: Convert the rotation degree to radians.
  double rotationRadians = rotationDegree * pi / 180;

  // Step 2: Calculate the direction vector from the original offset to the outside offset.
  Offset directionVector = originalOffset - outsideOffset;

  // Step 3: Project the direction vector onto the line made from the original offset and the rotation degree.
  double projectionLength = directionVector.dx * cos(rotationRadians) +
      directionVector.dy * sin(rotationRadians);
  Offset projectionVector = Offset(
    projectionLength * cos(rotationRadians),
    projectionLength * sin(rotationRadians),
  );

  // Step 4: Add the projection vector to the original offset to get the closest offset on the line.
  Offset closestOffset = outsideOffset + projectionVector;

  return closestOffset;
}

Rect rectFromEdges(({Offset bl, Offset br, Offset tl, Offset tr}) edges) {
  final topLeft = edges.tl;
  final topRight = edges.tr;

  return Rect.fromLTWH(
    topLeft.dx,
    topLeft.dy,
    topRight.dx - topLeft.dx,
    topRight.dy - edges.bl.dy,
  );
}

/// Snaps the value to the nearest snap value if the keys are pressed
double snap(double value, int snapValue, Set<PhysicalKeyboardKey> keys) =>
    keys.contains(PhysicalKeyboardKey.altLeft)
        ? (value / snapValue).truncateToDouble() * snapValue
        : (value / 0.1).truncateToDouble() * 0.1;
