// ignore_for_file: prefer-match-file-name

part of '../state.dart';

final canvasData = signal(
  CanvasData(
    color: Colors.white,
    hidden: false,
    opacity: 1,
    size: Vector2(1920, 1080),
    offset: Vector2(0, 0),
  ),
);

final canvasTransformController = signal(
  TransformationController(Matrix4.identity()),
);

final canvasTransformInitial = signal<Matrix4?>(null);

final canvasTransformCurrent =
    computed(() => canvasTransformController().toSignal());

final canvasLogicalKeys = signal(<LogicalKeyboardKey>{});

/// All elements in the canvas
final canvasElements = mapSignal(<String, ValueSignal<ElementModel>>{});

final _canvasHoveredElement = signal<String?>('');
// ignore: public_member_api_docs
const canvasHoveredElement = CanvasHoveredElement();

final canvasIds = iterableSignal(<String>[]);

// ignore: public_member_api_docs
final class CanvasHoveredElement implements SignalState<String?> {
  // ignore: public_member_api_docs
  const CanvasHoveredElement();

  @override
  Signal<String?> get _signal => _canvasHoveredElement;

  /// Sets the hover if it's not the same as [id].
  void setHover(String id) {
    if (value != id) {
      value = id;
    }
  }

  /// Clears the hover if it's the same as [id].
  void clearHover(String id) {
    if (value == id) {
      value = null;
    }
  }
}

final canvasSelectedElement = signal<String?>('');

final canvasHoveredMultipleElements = signal(<String>{});
final canvasSelectedMultipleElements = signal(<String>{});

/// Whether the canvas is moving an element
/// Hides the resize/rotate handles of the element visually
final canvasIsMovingSelected = signal(false);

/// Debug points
/// Used for debugging to visualize elements and operations
final debugPoints = signal(<Vector2>[]);

/// Snap lines for the selected element
final snapLines = computed<Iterable<SnapLine>>(() {
  // TODO: make work for moving element, not selected element
  final selected = canvasElements[canvasSelectedElement()]?.call();
  if (selected == null) return [];
  return ([...canvasElements.keys]..remove(canvasSelectedElement()))
      .map((e) {
        final element = canvasElements[e]?.call();
        if (element == null) {
          return [
            [null],
          ];
        }
        final originalPoints = element.transform.rotated;
        final points = <Vector2>[
          ...originalPoints.offsets.map((e) => e.toVector2()),
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
        ];
        final selectedBox = selected.transform.rotated;

        final selectedPoints = <Vector2>[
          ...selectedBox.offsets.map((e) => e.toVector2()),
          getMiddleOffset(selectedBox.offset0, selectedBox.offset1).toVector2(),
          getMiddleOffset(selectedBox.offset2, selectedBox.offset1).toVector2(),
          getMiddleOffset(selectedBox.offset3, selectedBox.offset2).toVector2(),
          getMiddleOffset(selectedBox.offset0, selectedBox.offset3).toVector2(),
          getMiddleOffset(selectedBox.offset0, selectedBox.offset2).toVector2(),
        ];

        final closest = selectedPoints.map((e) {
          return points.map((element) {
            final isSnapX = (e.x - element.x).abs() < kSnapRadius;
            final isSnapY = (e.y - element.y).abs() < kSnapRadius;
            if (isSnapX || isSnapY) {
              return SnapLine(element, e, isSnapX: isSnapX);
            }
            return null;
          });
        });
        return closest;
      })
      .flattened
      .flattened
      .whereNotNull();
});
