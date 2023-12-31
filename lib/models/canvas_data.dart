import 'package:equatable/equatable.dart';
import 'package:vector_math/vector_math_64.dart';

class CanvasData extends Equatable {
  CanvasData({
    required this.color,
    required this.hidden,
    required this.opacity,
    required this.size,
    required this.offset,
  });

  Vector4 color;
  bool hidden;
  double opacity;
  Vector2 size;
  Vector2 offset;

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
