import 'package:editicert/models/canvas_data.dart';
import 'package:editicert/util/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CanvasCubit extends Cubit<CanvasData> {
  CanvasCubit()
      : super(
          CanvasData(
            color: Colors.white.toVector4(),
            hidden: false,
            opacity: 1,
            size: const Size(1920, 1080).toVector2(),
            offset: const Offset(0, 0).toVector2(),
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
        color: backgroundColor?.toVector4(),
        hidden: backgroundHidden,
        opacity: backgroundOpacity,
        size: backgroundSize?.toVector2(),
      ),
    );
  }
}
