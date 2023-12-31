// ignore_for_file: prefer-match-file-name

import 'package:editicert/models/component_data.dart';
import 'package:editicert/state/state.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vector_math/vector_math_64.dart';

/// An extension of [BuildContext].
extension BuildContextExt on BuildContext {
  // ----------------------Read Methods----------------------

  /// Reads the [CanvasCubit] of this context.
  CanvasCubit get canvasCubit => read<CanvasCubit>();

  /// Reads the [CanvasEventsCubit] of this context.
  CanvasEventsCubit get canvasEventsCubit => read<CanvasEventsCubit>();

  /// Reads the [CanvasTransformCubit] of this context.
  CanvasTransformCubit get canvasTransformCubit => read<CanvasTransformCubit>();

  /// Reads the [ComponentIndexCubit] of this context.
  SelectedCubit get selectedCubit => read<SelectedCubit>();

  /// Reads the [ComponentsCubit] of this context.
  HoveredCubit get hoveredCubit => read<HoveredCubit>();

  /// Reads the [ComponentsCubit] of this context.
  ComponentsCubit get componentsCubit => read<ComponentsCubit>();

  /// Reads the [DebugPointCubit] of this context.
  DebugPointCubit get debugPointCubit => read<DebugPointCubit>();

  /// Reads the [KeysCubit] of this context.
  KeysCubit get keysCubit => read<KeysCubit>();

  /// Reads the [PointerCubit] of this context.
  PointerCubit get pointerCubit => read<PointerCubit>();

  /// Reads the [ToolCubit] of this context.
  ToolCubit get toolCubit => read<ToolCubit>();

  // ----------------------Watch Methods----------------------

  /// Reads the [CanvasCubit] of this context.
  CanvasCubit get canvasCubitWatch => watch<CanvasCubit>();

  /// Reads the [CanvasEventsCubit] of this context.
  CanvasEventsCubit get canvasEventsCubitWatch => watch<CanvasEventsCubit>();

  /// Reads the [CanvasTransformCubit] of this context.
  CanvasTransformCubit get canvasTransformCubitWatch =>
      watch<CanvasTransformCubit>();

  /// Reads the [ComponentIndexCubit] of this context.
  SelectedCubit get selectedCubitWatch => watch<SelectedCubit>();

  /// Reads the [ComponentsCubit] of this context.
  HoveredCubit get hoveredCubitWatch => watch<HoveredCubit>();

  /// Reads the [ComponentsCubit] of this context.
  ComponentsCubit get componentsCubitWatch => watch<ComponentsCubit>();

  /// Reads the [DebugPointCubit] of this context.
  DebugPointCubit get debugPointCubitWatch => watch<DebugPointCubit>();

  /// Reads the [KeysCubit] of this context.
  KeysCubit get keysCubitWatch => watch<KeysCubit>();

  /// Reads the [PointerCubit] of this context.
  PointerCubit get pointerCubitWatch => watch<PointerCubit>();

  /// Reads the [ToolCubit] of this context.
  ToolCubit get toolCubitWatch => watch<ToolCubit>();

  // ----------------------Select Methods----------------------

  R canvasCubitSelect<R>(R Function(CanvasCubit value) function) =>
      select<CanvasCubit, R>(function);

  R canvasEventsCubitSelect<R>(R Function(CanvasEventsCubit value) function) =>
      select<CanvasEventsCubit, R>(function);

  R canvasTransformCubitSelect<R>(
    R Function(CanvasTransformCubit value) function,
  ) =>
      select<CanvasTransformCubit, R>(function);

  R selectedCubitSelect<R>(R Function(SelectedCubit value) function) =>
      select<SelectedCubit, R>(function);

  R hoveredCubitSelect<R>(R Function(HoveredCubit value) function) =>
      select<HoveredCubit, R>(function);

  R componentsCubitSelect<R>(R Function(ComponentsCubit value) function) =>
      select<ComponentsCubit, R>(function);

  R debugPointCubitSelect<R>(R Function(DebugPointCubit value) function) =>
      select<DebugPointCubit, R>(function);

  R keysCubitSelect<R>(R Function(KeysCubit value) function) =>
      select<KeysCubit, R>(function);

  R pointerCubitSelect<R>(R Function(PointerCubit value) function) =>
      select<PointerCubit, R>(function);

  R toolCubitSelect<R>(R Function(ToolCubit value) function) =>
      select<ToolCubit, R>(function);

  ComponentData componentAt(int index) => componentsCubit.state[index];

  /// Delete all selected components from the [ComponentsCubit], and clear
  /// [SelectedCubit] and [HoveredCubit].
  void deleteSelectedComponent() {
    final selectedComponentIndexes = selectedCubit.state;
    componentsCubit.remove(selectedComponentIndexes.first);
    selectedCubit.clear();
    hoveredCubit.clear();
  }

  /// Reorder the selected components to be below the component below it.
  void handleGoBackward() {
    final index = selectedCubit.state.singleOrNull;
    if (index == null || index == 0) return;
    componentsCubit.reorder(index, index - 1);
  }

  /// Reorder the selected components to be above the component above it.
  void handleGoForward() {
    final index = selectedCubit.state.singleOrNull;
    if (index == null || index == componentsCubit.state.length - 1) {
      return;
    }
    componentsCubit.reorder(index, index + 1);
  }
}

/// An extension of [Offset].
extension OffsetEx on Offset {
  /// Multiplies two Offset instances together
  ///
  /// Accepts [Offset] instance and returns a new [Offset] which
  /// represents the product of two Offsets on both dimensions.
  Offset multiply(Offset offset) => Offset(dx * offset.dx, dy * offset.dy);

  /// Converts from [Offset] to [Vector2]
  ///
  /// Returns a [Vector2] instance with dx as 'x' and dy as 'y' of the
  /// [Offset].
  Vector2 toVector2() => Vector2(dx, dy);
}

extension LogicalKeyboardKeySet on Set<LogicalKeyboardKey> {
  bool containsAny(Iterable<LogicalKeyboardKey> keys) => any(keys.contains);
}

/// Extension on the [Color] class.
extension ColorEx on Color {
  /// Converts the current object to a [Vector4] object.
  /// The [Vector4] object represents the RGBA color values.
  ///
  /// Returns:
  ///     A [Vector4] object representing the RGBA color values.
  Vector4 toVector4() => Vector4(
        red.toDouble(), // Convert the red value to double
        green.toDouble(), // Convert the green value to double
        blue.toDouble(), // Convert the blue value to double
        opacity, // Use the existing opacity value
      );
}

/// Extends the [Vector4] class to include additional functionality.
extension Vector4Ex on Vector4 {
  /// Converts the values [x], [y], [z], and [w] to a [Color] object.
  /// The values [x], [y], and [z] should be integers between 0 and 255.
  /// The value [w] should be a double between 0.0 and 1.0.
  Color toColor() => Color.fromRGBO(x.toInt(), y.toInt(), z.toInt(), w);
}

/// Extension on the [Size] class.
extension SizeEx on Size {
  /// Converts the [Size] to a [Vector2] object.
  ///
  /// Returns:
  ///     A [Vector2] object with width and height of the [Size].
  Vector2 toVector2() => Vector2(width, height);
}

/// Extension on the [Vector2] class.
extension Vector2Ex on Vector2 {
  /// Converts the current object to a [Size] object.
  ///
  /// Returns:
  ///     A [Size] object with width as 'x' and height as 'y' of the [Vector2].
  Size toSize() => Size(x, y);

  /// Converts the current object to a [Offset] object.
  ///
  /// Returns:
  ///     A [Offset] object with x and y of the [Vector2].
  Offset toOffset() => Offset(x, y);
}
