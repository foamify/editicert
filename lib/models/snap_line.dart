import 'package:vector_math/vector_math_64.dart';

/// Represents an alignment line between two positions.
class SnapLine {
  /// Creates a [SnapLine] with the given positions.
  const SnapLine(this.pos1, this.pos2, {required this.isSnapX});

  /// First pos
  final Vector2 pos1;

  /// Second pos
  final Vector2 pos2;

  /// Whether the line is horizontal
  final bool isSnapX;
}

/// Extension on [SnapLine]
extension SnapLineExtension on SnapLine {
  /// Whether the line is vertical
  bool get isSnapY => !isSnapX;

  /// The length of the line
  double get length {
    if (isSnapX) {
      return (pos1.x - pos2.x).abs();
    }
    return (pos1.y - pos2.y);
  }

  /// Creates a [SnapLine] with the given positions.
  Vector2 get delta {
    Vector2 output;
    if (isSnapX) {
      output = Vector2(pos1.x - pos2.x, 0);
    } else {
      output = Vector2(0, pos1.y - pos2.y);
    }
    return output;
  }
}
