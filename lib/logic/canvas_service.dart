import 'package:editicert/models/canvas_data.dart';
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
