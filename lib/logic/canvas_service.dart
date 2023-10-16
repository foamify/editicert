import 'package:flutter/material.dart';

class CanvasService {
  final state = ValueNotifier(CanvasData(
    color: Colors.white,
    hidden: false,
    opacity: 1,
    size: const Size(1920, 1080),
  ));

  void update({
    Color? backgroundColor,
    bool? backgroundHidden,
    double? backgroundOpacity,
    Size? backgroundSize,
  }) {
    state.value = state.value.copyWith(
      color: backgroundColor,
      hidden: backgroundHidden,
      opacity: backgroundOpacity,
      size: backgroundSize,
    );
  }
}

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
