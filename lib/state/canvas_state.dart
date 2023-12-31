import 'package:editicert/models/canvas_data.dart';
import 'package:editicert/models/element_model.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart' hide Colors;
import 'package:flutter/services.dart';
import 'package:signals/signals.dart';
import 'package:signals/signals_flutter.dart';
import 'package:vector_math/vector_math_64.dart';

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

final canvasTransformCurrent =
    computed(() => canvasTransformController().toSignal());

final canvasLogicalKeys = signal(<LogicalKeyboardKey>{});

final canvasElements = signal(<ElementModel>[]);

typedef HoverId = String?;

final canvasHoveredElement = signal<HoverId>('');

extension HoverEx on Signal<HoverId> {
  /// Sets the hover if it's not the same as [id].
  void setHover(HoverId id) {
    if (value != id) {
      value = id;
    }
  }

  /// Clears the hover if it's the same as [id].
  void clearHover(HoverId id) {
    if (value == id) {
      value = null;
    }
  }
}

final canvasSelectedElement = signal<String?>('');

final canvasSelectedElements = signal(<String>{});

extension CanvasLogicalKeysEx on Signal<Set<LogicalKeyboardKey>> {
  void add(LogicalKeyboardKey key) {
    if (!value.contains(key)) {
      value.add(key);
    }
  }

  void remove(LogicalKeyboardKey key) {
    if (value.contains(key)) {
      value.remove(key);
    }
  }
}

final debugPoints = signal(<Vector2>[]);

/// Pointer buttons, see [kMiddleMouseButton] and the like;
final pointerButton = signal(0);

final pointerPositionInitial = signal(Vector2.zero);

final pointerPositionCurrent = signal(Vector2.zero);
