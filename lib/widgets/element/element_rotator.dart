part of '../../main.dart';

/// Rotates the selected element
class ElementRotator extends StatelessWidget {
  /// Rotates the selected element
  const ElementRotator(this.i, {super.key});

  /// The index of the selected element in the [canvasElements]
  final int i;

  @override
  Widget build(BuildContext context) {
    return Watch.builder(
      builder: (_) {
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
        final valueOffset = box.rotated.offsets.elementAtOrNull(i)! * scale;
        final offset = Offset(translate.x, translate.y) + valueOffset;
        return Positioned(
          left: offset.dx,
          top: offset.dy,
          child: Watch.builder(
            builder: (_) {
              final transform = canvasTransformController.value;
              final alignment = switch (i) {
                0 => Alignment.topLeft,
                1 => Alignment.topRight,
                2 => Alignment.bottomRight,
                _ => Alignment.bottomLeft,
              };
              return AnimatedSlide(
                duration: Duration.zero,
                offset: const Offset(-.5, -.5),
                child: Transform.rotate(
                  angle: box.angle * pi / 180,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onPanUpdate: (event) {
                      element.transform = box.rotateByPan(
                        transform.toScene(event.globalPosition),
                        alignment,
                      );
                      canvasElements.value = [...elements]..[index] = element;
                    },
                    child: Container(
                      width: 20,
                      height: 20,
                      color: kColorList.elementAtOrNull(i)!.withOpacity(.25),
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
