import 'dart:ui';

class CanvasData {
  CanvasData({
    required this.color,
    required this.hidden,
    required this.opacity,
    required this.size,
  });

  Color color;
  bool hidden;
  double opacity;
  Size size;

  CanvasData copyWith({
    Color? color,
    bool? hidden,
    double? opacity,
    Size? size,
  }) {
    return CanvasData(
      color: color ?? this.color,
      hidden: hidden ?? this.hidden,
      opacity: opacity ?? this.opacity,
      size: size ?? this.size,
    );
  }
}
