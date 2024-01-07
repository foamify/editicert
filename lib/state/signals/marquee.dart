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

  final ids = <String>[];
  for (final e in canvasElements.values) {
    final element = e();
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

    var offsetInside = 0;
    element.transform.rotated.offsets.map(fromScene).forEach((e) {
      if (rect.contains(e)) {
        offsetInside++;
      }
    });

    if (offsetInside == 4) {
      ids.add(element.id);
      break;
    }

    var intersect = false;
    for (final element1 in linesElement) {
      if (intersect) continue;
      for (final element2 in linesRect) {
        if (intersect) continue;
        intersect = isTwoLinesIntersetcing(
          element1.$1,
          element1.$2,
          element2.$1,
          element2.$2,
        );
      }
    }

    if (intersect) {
      ids.add(element.id);
      break;
    }
  }
  if (ids.isNotEmpty) {
    untracked(() => canvasHoveredMultipleElements.value = ids.toSet());
  }
  return rect;
});
