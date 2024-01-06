import 'package:collection/collection.dart';
import 'package:editicert/models/canvas_data.dart';
import 'package:editicert/models/element_model.dart';
import 'package:editicert/models/snap_line.dart';
import 'package:editicert/util/extensions.dart';
import 'package:editicert/util/geometry.dart';
import 'package:editicert/util/utils.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart' hide Colors;
import 'package:flutter/services.dart';
import 'package:signals/signals_flutter.dart';
import 'package:vector_math/vector_math_64.dart';

/// Represents the state of a signal.
///
/// This is an abstract interface class that defines the behavior of a signal state.
/// It provides access to the signal and the value it represents.
interface class SignalState<T> {
  /// Constructs a new instance of the [SignalState] class.
  const SignalState();

  /// The signal associated with this state.
  Signal<T> get _signal => throw UnimplementedError();
}

/// An extension on [SignalState]
extension SignalStateEx<T> on SignalState<T> {
  /// The value represented by the signal.
  T get value => _signal();
  set value(T value) => _signal.value = value;

  /// Calls the signal.
  T call() => _signal();
}

/// An extension on [SignalState]
extension SignalStateIterable<T> on SignalState<Iterable<T>> {
  void add(T element) => _signal.add(element);

  void remove(T element) => _signal.remove(element);

  void clear() => _signal.clear();
}

/// An extension on [Signal]
extension SignalIterable<T> on Signal<Iterable<T>> {
  void add(T element) => value is Set
      ? value = ({...value}..add(element))
      : value = [...value, element];

  void remove(T element) => value is Set
      ? value = (<T>{...value}..remove(element))
      : value = ([...value]..remove(element));

  void clear() => value is Set ? value = <T>{} : value = <T>[];
}

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

final canvasElements = signal(<ElementModel>[]);

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
  void setHover(String? id) {
    if (value != id) {
      value = id;
    }
  }

  /// Clears the hover if it's the same as [id].
  void clearHover(String? id) {
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

/// Pointer buttons, see [kMiddleMouseButton] and the like;
final pointerButton = signal(0);

/// The initial position of the pointer
/// Used for calculating the delta during operations
final pointerPositionInitial = signal(Vector2.zero());

/// The current position of the pointer
/// Used for calculating the delta during operations
final pointerPositionCurrent = signal(Vector2.zero());

/// Selection marquee rectangle is visible
final isMarquee = signal(false);

/// Selection marquee rectangle
final marqueeRect = computed(() {
  // TODO: this is very heavy. Need to find lighter way and/or put it in another thread

  untracked(() => canvasHoveredMultipleElements.value = {});
  final rect = isMarquee()
      ? Rect.fromPoints(
          pointerPositionInitial().toOffset(),
          pointerPositionCurrent().toOffset(),
        )
      : null;
  if (rect == null) {
    return null;
  }

  final polyRect = [
    [rect.topLeft, rect.topRight, rect.bottomRight, rect.bottomLeft]
        .map((e) => e.toVector2())
        .toList(),
  ];

  final linesRect = [
    (rect.topLeft.toVector2(), rect.topRight.toVector2()),
    (rect.topRight.toVector2(), rect.bottomRight.toVector2()),
    (rect.bottomRight.toVector2(), rect.bottomLeft.toVector2()),
    (rect.bottomLeft.toVector2(), rect.topLeft.toVector2()),
  ];

  for (final element in canvasElements()) {
    final linesElement = [
      (
        element.transform.rect.topLeft.toVector2(),
        element.transform.rect.topRight.toVector2(),
      ),
      (
        element.transform.rect.topRight.toVector2(),
        element.transform.rect.bottomRight.toVector2(),
      ),
      (
        element.transform.rect.bottomRight.toVector2(),
        element.transform.rect.bottomLeft.toVector2(),
      ),
      (
        element.transform.rect.bottomLeft.toVector2(),
        element.transform.rect.topLeft.toVector2(),
      ),
    ];

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

    element.transform.rotated.offsets.forEach((e) {
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

const snapRadius = 3.0;

final snapLines = computed<Iterable<SnapLine>>(() {
  final selected = canvasElements()
      .firstWhereOrNull((element) => element.id == canvasSelectedElement());
  if (selected == null) return [];
  return [...canvasElements().whereNot((element) => element.id == selected.id)]
      .map((e) {
        final originalPoints = e.transform.rotated;
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
            final isSnapX = (e.x - element.x).abs() < snapRadius;
            final isSnapY = (e.y - element.y).abs() < snapRadius;
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
