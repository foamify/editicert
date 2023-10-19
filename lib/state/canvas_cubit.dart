import 'package:editicert/models/canvas_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CanvasCubit extends Cubit<CanvasData> {
  CanvasCubit()
      : super(
          CanvasData(
            color: Colors.white,
            hidden: false,
            opacity: 1,
            size: const Size(1920, 1080),
          ),
        );

  void update({
    Color? backgroundColor,
    bool? backgroundHidden,
    double? backgroundOpacity,
    Size? backgroundSize,
  }) {
    emit(
      state.copyWith(
        color: backgroundColor,
        hidden: backgroundHidden,
        opacity: backgroundOpacity,
        size: backgroundSize,
      ),
    );
  }
}
