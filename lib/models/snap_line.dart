import 'package:vector_math/vector_math_64.dart';

/// Represents an alignment line between two positions.
class SnapLine {
  /// Creates a [SnapLine] with the given positions.
  const SnapLine(
    this.pos1,
    this.pos2, {
    required this.isSnapX,
    required this.isSnapY,
  });

  /// First pos, the snapped point
  final Vector2 pos1;

  /// Second pos, the element point
  final Vector2 pos2;

  /// Whether the line is horizontal
  final bool isSnapX;

  /// Whether the line is vertical
  final bool isSnapY;
}

/// Extension on [SnapLine]
extension SnapLineExtension on SnapLine {
  /// The length of the line
  double get length {
    if (isSnapX) {
      return (pos1.x - pos2.x).abs();
    }
    return pos1.y - pos2.y;
  }

  /// Creates a [SnapLine] with the given positions.
  Vector2 get delta {
    final output = Vector2.zero();
    if (isSnapX) {
      output.x = pos1.x - pos2.x;
    } else {
      output.y = pos1.y - pos2.y;
    }
    return output;
  }

  Vector2 get pos2Snapped =>
      isSnapX ? Vector2(pos1.x, pos2.y) : Vector2(pos2.x, pos1.y);
}
