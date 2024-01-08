part of '../state.dart';

/// Selection marquee rectangle is visible
final isMarquee = signal(false);

/// Selection marquee rectangle
final marqueeRect = computed(() {
  // TODO: this is very heavy. Need to find lighter way and/or put it in another thread

  final canvasTransform = canvasTransformCurrent.peek().peek();
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
          x: rect.left, y: rect.top, width: rect.width, height: rect.height),
      polygons: canvasElements.peek().map((e) {
        final linesElement = [
          Line(
            p1: e.transform.rotated.quad.point0.xy.toPoint(),
            p2: e.transform.rotated.quad.point1.xy.toPoint(),
          ),
          Line(
            p1: e.transform.rotated.quad.point1.xy.toPoint(),
            p2: e.transform.rotated.quad.point2.xy.toPoint(),
          ),
          Line(
            p1: e.transform.rotated.quad.point2.xy.toPoint(),
            p2: e.transform.rotated.quad.point3.xy.toPoint(),
          ),
          Line(
            p1: e.transform.rotated.quad.point3.xy.toPoint(),
            p2: e.transform.rotated.quad.point0.xy.toPoint(),
          ),
        ];
        return Polygon(id: e.id, lines: linesElement);
      }).toList(),
      matrixStorage: canvasTransform.storage,
    );
    unawaited(
      batch(() async {
        if (ids.isNotEmpty) {
          untracked(() => canvasHoveredMultipleElements.value = ids.toSet());
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
