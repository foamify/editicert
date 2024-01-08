// ignore_for_file: prefer-match-file-name

import 'package:editicert/src/rust/api/canvas.dart';
import 'package:flutter/services.dart';
import 'package:vector_math/vector_math_64.dart';

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

  /// Converts the current object to a [Point] object.
  ///
  /// Returns:
  ///     A [Point] object with x and y of the [Vector2].
  CanvasPoint toPoint() => CanvasPoint(x: x, y: y);
}

/// Extension on the [Matrix4] class.
extension Matrix4Ex on Matrix4 {
  /// Return the scene point at the given viewport point.
  Offset toScene(Offset viewportPoint) {
    // On viewportPoint, perform the inverse transformation of the scene to get
    // where the point would be in the scene before the transformation.
    final inverseMatrix = Matrix4.inverted(this);
    final untransformed = inverseMatrix.transform3(
      Vector3(viewportPoint.dx, viewportPoint.dy, 0),
    );
    return Offset(untransformed.x, untransformed.y);
  }

  Offset fromScene(Offset scenePoint) {
    final untransformed = transform3(
      Vector3(scenePoint.dx, scenePoint.dy, 0),
    );
    return Offset(untransformed.x, untransformed.y);
  }
}
