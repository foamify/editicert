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

final canvasLogicalKeys = setSignal(<LogicalKeyboardKey>{});

/// All elements in the canvas
final canvasElements = listSignal(<ElementModel>[]);

final idElements = listSignal(<String>[]);

final _canvasHoveredElement = signal<String?>('');
// ignore: public_member_api_docs
const canvasHoveredElement = CanvasHoveredElement();

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

final canvasHoveredMultipleElements = iterableSignal(<String>{});
final canvasSelectedMultipleElements = iterableSignal(<String>{});

/// Whether the canvas is moving an element
/// Hides the resize/rotate handles of the element visually
final canvasIsMovingSelected = signal(false);

/// Debug points
/// Used for debugging to visualize elements and operations
final debugPoints = listSignal(<Vector2>[]);

/// Snap lines for the selected element
final snapLines = iterableSignal(<SnapLine>[]);
