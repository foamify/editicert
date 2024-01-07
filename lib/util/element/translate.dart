import 'package:editicert/models/element_model.dart';
import 'package:editicert/models/snap_line.dart';
import 'package:editicert/state/state.dart';
import 'package:editicert/util/extensions.dart';
import 'package:editicert/util/geometry.dart';
import 'package:flutter/gestures.dart';

/// Start moving the element.
void handleMoveStart(ElementModel element, DragStartDetails details) {
  element.initialTransform = element.transform.clone();
  pointerPositionInitial.value = details.globalPosition.toVector2();
}

/// Update the element position and handles snapping.
void handleMoveUpdate(
  ElementModel element,
  DragUpdateDetails details,
  List<ElementModel> elements,
  int index,
) {
  final initialBox = element.initialTransform!.clone();
  final delta = (details.globalPosition.toVector2() - pointerPositionInitial())
      .toOffset();
  final scale = canvasTransformCurrent()().getMaxScaleOnAxis();
  element.transform = initialBox.translate(delta / scale);

  final lines = snapLines();

  if (lines.isNotEmpty) {
    final shortestLineX = lines.where((e) => e.isSnapX).fold(
          lines.firstOrNull!,
          (value, e) => value.length < e.length ? value : e,
        );

    final shortestLineY = lines.where((e) => e.isSnapY).fold(
          lines.firstOrNull!,
          (value, e) => value.length < e.length ? value : e,
        );

    element.transform.translate(shortestLineX.delta.toOffset() / 2);
    element.transform.translate(shortestLineY.delta.toOffset() / 2);
  }

  canvasElements.value = [...elements]..[index] = element;
}

/// End moving the element.
void handleMoveEnd(
  ElementModel element,
  Box box,
  List<ElementModel> elements,
  int index,
) {
  element.transform = Box(
    quad: box.quad,
    angle: box.angle,
    origin: box.rect.center,
  ).translate(
    -element.transform.rotated.rect.center + box.rotated.rect.center,
  );
  canvasElements.value = [...elements]..[index] = element;
}
