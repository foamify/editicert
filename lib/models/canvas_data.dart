import 'package:equatable/equatable.dart';
import 'package:vector_math/vector_math_64.dart';

/// Represents the data of a canvas, used for saving/loading
class CanvasData extends Equatable {
  /// Constructs a new [CanvasData] instance.
  ///
  /// [color] - The color of the canvas.
  /// [hidden] - Indicates whether the canvas is hidden or not.
  /// [opacity] - The opacity of the canvas.
  /// [size] - The size of the canvas.
  /// [offset] - The offset of the canvas.
  const CanvasData({
    required this.color,
    required this.hidden,
    required this.opacity,
    required this.size,
    required this.offset,
  });

  /// The color of the canvas.
  final Vector4 color;

  /// Indicates whether the canvas is hidden or not.
  final bool hidden;

  /// The opacity of the canvas.
  final double opacity;

  /// The size of the canvas.
  final Vector2 size;

  /// The offset of the canvas.
  final Vector2 offset;

  /// Returns a new [CanvasData] instance with the given values.
  CanvasData copyWith({
    Vector4? color,
    bool? hidden,
    double? opacity,
    Vector2? size,
    Vector2? offset,
  }) {
    return CanvasData(
      color: color ?? this.color,
      hidden: hidden ?? this.hidden,
      opacity: opacity ?? this.opacity,
      size: size ?? this.size,
      offset: offset ?? this.offset,
    );
  }

  @override
  List<Object?> get props => [color, hidden, opacity, size];
}
