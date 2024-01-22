import 'package:editicert/models/element_model.dart';
import 'package:editicert/models/snap_line.dart';
import 'package:editicert/state/state.dart';
import 'package:editicert/util/constants.dart';
import 'package:editicert/util/extensions.dart';
import 'package:editicert/util/geometry.dart';
import 'package:editicert/util/utils.dart';
import 'package:flutter/gestures.dart';
import 'package:collection/collection.dart';
import 'package:signals/signals_flutter.dart';
import 'package:vector_math/vector_math_64.dart';

/// Start moving the element.
void handleMoveStart(ElementModel element, DragStartDetails details) {
  element.initialTransform = element.transform.clone();
  pointerPositionInitial.value = details.globalPosition.toVector2();
}

Iterable<SnapLine> calculateSnapLines(String id, Box transform) {
  // TODO: make work for moving element, not selected element

  final selectedBox = transform.clone().rotated;
  final selectedPoints = <Vector2>{
    selectedBox.quad.point0.xy,
    selectedBox.quad.point1.xy,
    selectedBox.quad.point2.xy,
    selectedBox.quad.point3.xy,
    getMiddleOffset(selectedBox.offset0, selectedBox.offset1).toVector2(),
    getMiddleOffset(selectedBox.offset2, selectedBox.offset1).toVector2(),
    getMiddleOffset(selectedBox.offset3, selectedBox.offset2).toVector2(),
    getMiddleOffset(selectedBox.offset0, selectedBox.offset3).toVector2(),
    getMiddleOffset(selectedBox.offset0, selectedBox.offset2).toVector2(),
  };

  final expand =
      canvasElements().where((element) => element().id != id).expand((e) {
    final originalPoints = e.peek().transform.rotated;
    final points = {
      originalPoints.quad.point0.xy,
      originalPoints.quad.point1.xy,
      originalPoints.quad.point2.xy,
      originalPoints.quad.point3.xy,
      getMiddleOffset(originalPoints.offset0, originalPoints.offset1)
          .toVector2(),
      getMiddleOffset(originalPoints.offset2, originalPoints.offset1)
          .toVector2(),
      getMiddleOffset(originalPoints.offset3, originalPoints.offset2)
          .toVector2(),
      getMiddleOffset(originalPoints.offset0, originalPoints.offset3)
          .toVector2(),
      getMiddleOffset(originalPoints.offset0, originalPoints.offset2)
          .toVector2(),
    };

    return selectedPoints.expand((sp) {
      return points.map((element) {
        final isSnapX = (sp.x - element.x).abs() < kSnapRadius;
        final isSnapY = (sp.y - element.y).abs() < kSnapRadius;
        if (isSnapX || isSnapY) {
          return SnapLine(element, sp, isSnapX: isSnapX, isSnapY: isSnapY);
        }
        return null;
      }).whereNotNull();
    });
  });
  snapLines.value = expand;
  return expand;
}

/// Update the element position and handles snapping.
void handleMoveUpdate(
  ValueSignal<ElementModel> element,
  DragUpdateDetails details,
) {
  final newElement = element();
  final initialBox = newElement.initialTransform!.clone();
  final scale = canvasTransformCurrent()().getMaxScaleOnAxis();
  final delta = (details.globalPosition.toVector2() - pointerPositionInitial())
          .toOffset() /
      scale;

  newElement.transform = initialBox.translate(delta);
  // final lines = calculateSnapLines(element.id, element.transform);

  // if (lines.isNotEmpty) {
  //   final shortestLineX = lines.where((e) => e.isSnapX).fold(
  //         lines.firstOrNull!,
  //         (value, e) => value.length < e.length ? value : e,
  //       );

  //   final shortestLineY = lines.where((e) => e.isSnapY).fold(
  //         lines.firstOrNull!,
  //         (value, e) => value.length < e.length ? value : e,
  //       );

  //   final snapDelta = Offset(shortestLineX.delta.x, shortestLineY.delta.y);
  //   element.transform = element.transform.translate(snapDelta);
  // }

  element.forceUpdate(newElement);
}

/// End moving the element.
void handleMoveEnd(ValueSignal<ElementModel> element, Box box) {
  final newElement = element();
  newElement.transform = Box(
    quad: box.quad,
    angle: box.angle,
    origin: box.rect.center,
  ).translate(
    -newElement.transform.rotated.rect.center + box.rotated.rect.center,
  );
  element.forceUpdate(newElement);
}
