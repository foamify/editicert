import 'package:flutter_bloc/flutter_bloc.dart';

enum CanvasEvent {
  //
  leftClick,
  rightClick,
  middleClick,
  panningCanvas,
  zoomingCanvas,
  //
  draggingComponent,
  resizingComponent,
  rotatingComponent,
  //
  creatingRectangle,
  creatingFrame,
  creatingText,
  //
  editingText,
  //
  draggingSidebarComponent,
  fullscreen,
}

class CanvasEventsCubit extends Cubit<Set<CanvasEvent>> {
  CanvasEventsCubit() : super({});

  void replaceAll(Set<CanvasEvent> events) {
    state.clear();
    state.addAll(events);
  }

  void add(CanvasEvent event) {
    if (!state.contains(event)) {
      state.add(event);
    }
  }

  void remove(CanvasEvent event) {
    if (state.contains(event)) {
      state.remove(event);
    }
  }

  void clear() {
    state.clear();
  }

  bool containsAny(Set<CanvasEvent> events) =>
      state.any((element) => events.contains(element));

  CanvasEvent operator +(CanvasEvent other) => CanvasEvent
      .values[state.indexed.where((element) => element.$2 == other).first.$1];

  CanvasEvent operator -(CanvasEvent other) => CanvasEvent
      .values[state.indexed.where((element) => element.$2 == other).first.$1];
}
