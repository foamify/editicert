part of '../../main.dart';

/// Resizes the selected element
class ElementEdgeResizer extends StatelessWidget {
  /// Resizes the selected element
  const ElementEdgeResizer(this.i, {super.key});

  /// The index of the selected element in the [canvasElements]
  final int i;

  @override
  Widget build(BuildContext context) {
    return Watch.builder(
      builder: (context) {
        final isMoving = canvasIsMovingSelected();
        if (isMoving) return const SizedBox.shrink();
        final elements = canvasElements();
        final selected = canvasSelectedElement();
        final elementIndexed = elements.indexed.firstWhereOrNull(
          (element) => element.$2.id == selected,
        );
        if (elementIndexed == null) return const SizedBox.shrink();
        final (index, element) = elementIndexed;
        final box = element.transform;
        //--
        final canvasTransform = canvasTransformCurrent()();
        final scale = canvasTransform.getMaxScaleOnAxis();
        final translate = canvasTransform.getTranslation();
        final valueOffset = box.rotated.offsets[i] * scale;
        final offset = Offset(translate.x, translate.y) + valueOffset;
        return Positioned(
          left: offset.dx,
          top: offset.dy,
          child: Watch.builder(
            builder: (_) {
              final transform = canvasTransformController.value;
              final alignment = switch (i) {
                0 => Alignment.centerLeft,
                1 => Alignment.topCenter,
                2 => Alignment.centerRight,
                _ => Alignment.bottomCenter,
              };
              return Transform.rotate(
                angle: box.angle * pi / 180,
                alignment: Alignment.topLeft,
                child: Transform.translate(
                  offset: switch (i) {
                    0 => Offset(
                        -5,
                        box.flipY ? -box.rect.height * scale + 5 : 5,
                      ),
                    1 =>
                      Offset(box.flipX ? 5 : -box.rect.width * scale + 5, -5),
                    2 => Offset(
                        -5,
                        box.flipY ? 5 : -box.rect.height * scale + 5,
                      ),
                    _ =>
                      Offset(box.flipX ? -box.rect.width * scale + 5 : 5, -5),
                  },
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onPanStart: (details) {
                      element.initialTransform = element.transform;
                      canvasElements.value = [...elements]..[index] = element;
                      pointerPositionInitial.value =
                          transform.toScene(details.localPosition).toVector2();
                    },
                    onPanUpdate: (details) {
                      final keys = canvasLogicalKeys.value;

                      final pressedShift = keys.containsAny([
                        LogicalKeyboardKey.shift,
                        LogicalKeyboardKey.shiftLeft,
                        LogicalKeyboardKey.shiftRight,
                      ]);

                      final pressedAlt = keys.containsAny([
                        LogicalKeyboardKey.alt,
                        LogicalKeyboardKey.altLeft,
                        LogicalKeyboardKey.altRight,
                      ]);

                      final initialBox = element.initialTransform!;
                      final initialPosition =
                          pointerPositionInitial().toOffset();

                      if (pressedShift && pressedAlt) {
                        element.transform = box.resizeSymmetricScaled(
                          initialBox,
                          initialPosition,
                          transform.toScene(details.localPosition),
                          alignment,
                        );
                      } else if (pressedShift) {
                        element.transform = box.resizeScaled(
                          initialBox,
                          initialPosition,
                          transform.toScene(details.localPosition),
                          alignment,
                        );
                      } else if (pressedAlt) {
                        element.transform = box.resizeSymmetric(
                          initialBox,
                          initialPosition,
                          transform.toScene(details.localPosition),
                          alignment,
                        );
                      } else {
                        element.transform = box.resize(
                          initialBox,
                          initialPosition,
                          transform.toScene(details.localPosition),
                          alignment,
                        );
                      }
                      canvasElements.value = [...elements]..[index] = element;
                    },
                    onPanEnd: (details) {
                      element.transform = Box(
                        quad: box.quad,
                        angle: box.angle,
                        origin: box.rect.center,
                      ).translate(
                        -element.transform.rotated.rect.center +
                            box.rotated.rect.center,
                      );
                      canvasElements.value = [...elements]..[index] = element;
                    },
                    child: Container(
                      width: switch (i) {
                        0 || 2 => 10,
                        _ => max(0, box.rect.width * scale - 10),
                      },
                      height: switch (i) {
                        1 || 3 => 10,
                        _ => max(0, box.rect.height * scale - 10),
                      },
                      color: kColorList[i].withOpacity(.5),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
