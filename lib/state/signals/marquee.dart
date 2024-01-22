part of '../state.dart';

/// Selection marquee rectangle is visible
final isMarquee = signal(false);

/// Selection marquee rectangle
final marqueeRect = computed(() {
  // TODO: this is very heavy. Need to find lighter way and/or put it in another thread

  final rect = isMarquee()
      ? Rect.fromPoints(
          pointerPositionInitial().toOffset(),
          pointerPositionCurrent().toOffset(),
        )
      : null;
  if (rect == null) {
    return null;
  }

  Future(() async {
    final ids = await getIntersectingIds(
      rect: MarqueeRect(
        x: rect.left,
        y: rect.top,
        width: rect.width,
        height: rect.height,
      ),
      polygons: canvasElements.peek().map((e) {
        final quad = e.peek().transform.quad;
        final linesElement = [
          Line(p1: quad.point0.xy.toPoint(), p2: quad.point1.xy.toPoint()),
          Line(p1: quad.point1.xy.toPoint(), p2: quad.point2.xy.toPoint()),
          Line(p1: quad.point2.xy.toPoint(), p2: quad.point3.xy.toPoint()),
          Line(p1: quad.point3.xy.toPoint(), p2: quad.point0.xy.toPoint()),
        ];
        return Polygon(id: e().id, lines: linesElement);
      }).toList(),
      matrixStorage: canvasTransformCurrent.peek().peek().storage,
    );
    unawaited(
      batch(() async {
        if (ids.isNotEmpty) {
          untracked(() {
            if (!DeepCollectionEquality()
                .equals(canvasHoveredMultipleElements.peek(), ids.toSet())) {
              canvasHoveredMultipleElements.value = ids.toSet();
            }
          });
        } else {
          if (canvasHoveredMultipleElements.peek().isNotEmpty) {
            untracked(() => canvasHoveredMultipleElements.value = {});
          }
        }
      }),
    );
  });

  return rect;
});
