// ignore_for_file: public_member_api_docs

import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vector_math/vector_math_64.dart';

part 'event_handler/pan_canvas.dart';
part 'event_handler/zoom_canvas.dart';

class EventHandlerBloc extends Bloc<EventHandlerEvent, EventHandlerState> {
  EventHandlerBloc(super.initialState) {
    on<PanCanvasInitial>(_handlePanCanvasInitial);

    on<PanCanvasEvent>(_handlePanCanvasEvent);

    on<ZoomCanvasEvent>(_handleZoomCanvasEvent);
  }

  FutureOr<void> _handlePanCanvasInitial(
    PanCanvasInitial event,
    Emitter<EventHandlerState> emit,
  ) {
    final matrix = state.canvasMatrix.currentMatrix ?? Matrix4.identity();
    emit(
      state.copyWith(
        canvasMatrix: CanvasMatrix(
          initialMatrix: matrix,
          currentMatrix: matrix,
        ),
      ),
    );
  }

  double get scale =>
      1 / (state.canvasMatrix.currentMatrix?.getMaxScaleOnAxis() ?? 1);

  FutureOr<void> _handlePanCanvasEvent(
    PanCanvasEvent event,
    Emitter<EventHandlerState> emit,
  ) {
    final offset = event.offset * scale;
    final matrix = state.canvasMatrix.currentMatrix!.clone()
      ..translate(offset.dx, offset.dy);
    emit(
      state.copyWith(
        canvasMatrix: state.canvasMatrix.copyWith(currentMatrix: matrix),
      ),
    );
  }

  Offset toScene(Offset viewportPoint) {
    // On viewportPoint, perform the inverse transformation of the scene to get
    // where the point would be in the scene before the transformation.
    final inverseMatrix = Matrix4.inverted(
      state.canvasMatrix.currentMatrix ?? Matrix4.identity(),
    );
    final untransformed = inverseMatrix.transform3(
      Vector3(viewportPoint.dx, viewportPoint.dy, 0),
    );
    return Offset(untransformed.x, untransformed.y);
  }

  FutureOr<void> _handleZoomCanvasEvent(
    ZoomCanvasEvent event,
    Emitter<EventHandlerState> emit,
  ) {
    final offset = toScene(event.localFocalPoint);

    final matrix = state.canvasMatrix.currentMatrix!.clone()
      ..translate(offset.dx, offset.dy)
      ..scale(event.scale)
      ..translate(-offset.dx, -offset.dy);
    emit(
      state.copyWith(
        canvasMatrix: state.canvasMatrix.copyWith(currentMatrix: matrix),
      ),
    );
  }
}

class EventHandlerState extends Equatable {
  const EventHandlerState({required this.canvasMatrix});

  final CanvasMatrix canvasMatrix;

  EventHandlerState copyWith({CanvasMatrix? canvasMatrix}) {
    return EventHandlerState(
      canvasMatrix: canvasMatrix ?? this.canvasMatrix,
    );
  }

  @override
  List<Object?> get props => [canvasMatrix];
}

abstract class EventHandlerEvent {}

class CanvasMatrix extends Equatable {
  const CanvasMatrix({
    required this.initialMatrix,
    required this.currentMatrix,
  });

  final Matrix4? initialMatrix;
  final Matrix4? currentMatrix;

  CanvasMatrix copyWith({Matrix4? initialMatrix, Matrix4? currentMatrix}) {
    return CanvasMatrix(
      initialMatrix: initialMatrix ?? this.initialMatrix,
      currentMatrix: currentMatrix ?? this.currentMatrix,
    );
  }

  @override
  List<Object?> get props => [initialMatrix, currentMatrix];
}
