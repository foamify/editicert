part of '../state.dart';

/// Selection marquee rectangle is visible
final isMarquee = signal(false);

/// Selection marquee rectangle
final marqueeRect = computed(() {
  // TODO: this is very heavy. Need to find lighter way and/or put it in another thread

  untracked(() => canvasHoveredMultipleElements.value = {});
  final canvasTransform = canvasTransformCurrent.peek().peek();
  final fromScene = canvasTransform.fromScene;
  final rect = isMarquee()
      ? Rect.fromPoints(
          pointerPositionInitial().toOffset(),
          pointerPositionCurrent().toOffset(),
        )
      : null;
  if (rect == null) {
    return null;
  }

  final linesRect = [
    (rect.topLeft.toVector2(), rect.topRight.toVector2()),
    (rect.topRight.toVector2(), rect.bottomRight.toVector2()),
    (rect.bottomRight.toVector2(), rect.bottomLeft.toVector2()),
    (rect.bottomLeft.toVector2(), rect.topLeft.toVector2()),
  ].map((e) => (e.$1, e.$2)).toList();

  for (final element in canvasElements()) {
    final linesElement = [
      (
        element.transform.rotated.offset0.toVector2(),
        element.transform.rotated.offset1.toVector2(),
      ),
      (
        element.transform.rotated.offset1.toVector2(),
        element.transform.rotated.offset2.toVector2(),
      ),
      (
        element.transform.rotated.offset2.toVector2(),
        element.transform.rotated.offset3.toVector2(),
      ),
      (
        element.transform.rotated.offset3.toVector2(),
        element.transform.rotated.offset0.toVector2(),
      ),
    ]
        .map(
          (e) => (
            fromScene(e.$1.toOffset()).toVector2(),
            fromScene(e.$2.toOffset()).toVector2(),
          ),
        )
        .toList();

    var intersect = false;
    var offsetInside = 0;

    linesElement.forEach((element1) {
      if (intersect) return;
      linesRect.forEach((element2) {
        if (intersect) return;
        intersect = isTwoLinesIntersetcing(
          element1.$1,
          element1.$2,
          element2.$1,
          element2.$2,
        );
      });
    });

    element.transform.rotated.offsets.map(fromScene).forEach((e) {
      if (rect.contains(e)) {
        offsetInside++;
      }
    });

    //TODO: change 4 to number of polygon
    if (intersect || offsetInside == 4) {
      canvasHoveredMultipleElements.peek().add(element.id);
    }
  }
  return rect;
});
