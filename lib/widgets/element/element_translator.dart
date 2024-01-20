part of '../../main.dart';

/// A widget that translates the selected element.
typedef ElementTranslatorBuilder = Widget Function(
  BuildContext context,
  ElementModel element,
);

/// Translates the selected/provided element
class ElementTranslator extends StatelessWidget {
  /// Translates the selected/provided element.
  const ElementTranslator({required this.builder, super.key, this.index});

  /// The builder that builds the widget
  final ElementTranslatorBuilder builder;

  /// Optional: The index of the selected element in the [canvasElements].
  /// If not provided, the [canvasSelectedElement] is used
  final int? index;

  @override
  Widget build(BuildContext context) {
    return Watch.builder(
      builder: (_) {
        final elements = canvasElements();
        final selected = canvasSelectedElement();
        final element = index == null
            ? elements.firstWhereOrNull((e) => e.id == selected)
            : elements.elementAtOrNull(index!);
        if (element == null) return const SizedBox.shrink();
        final elementIndex = index ?? elements.indexOf(element);

        final transform = canvasTransformCurrent()();
        final scale = transform.getMaxScaleOnAxis();
        final translate = transform.getTranslation();
        final box = element.transform;
        final alignmentIndex = switch ((box.flipX, box.flipY)) {
          (false, false) => 0,
          (true, false) => 1,
          (false, true) => 3,
          _ => 2,
        };
        final valueOffset =
            box.rotated.offsets.elementAtOrNull(alignmentIndex)! * scale;
        final offset = Offset(translate.x, translate.y) + valueOffset;

        return Positioned(
          left: offset.dx,
          top: offset.dy,
          child: Transform.scale(
            scale: transform.getMaxScaleOnAxis(),
            alignment: Alignment.topLeft,
            child: Transform.rotate(
              angle: box.angle * pi / 180,
              alignment: Alignment.topLeft,
              child: Transform.flip(
                flipX: box.flipX,
                flipY: box.flipY,
                child: MouseRegion(
                  onEnter: (event) {
                    canvasHoveredElement.setHover(element.id);
                  },
                  onExit: (event) =>
                      canvasHoveredElement.clearHover(element.id),
                  child: GestureDetector(
                    onTap: () => canvasSelectedElement.value = element.id,
                    onPanStart: (details) {
                      canvasIsMovingSelected.value = true;
                      handleMoveStart(element, details);
                    },
                    onPanUpdate: (details) {
                      handleMoveUpdate(
                        element,
                        details,
                        elements,
                        elementIndex,
                      );
                    },
                    onPanEnd: (details) {
                      canvasIsMovingSelected.value = false;
                      handleMoveEnd(element, box, elements, elementIndex);
                    },
                    child: builder(context, element),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
