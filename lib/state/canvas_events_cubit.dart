import 'package:flutter_bloc/flutter_bloc.dart';

class CanvasEventsCubit extends Cubit<Set<CanvasEvent>> {
  CanvasEventsCubit() : super({});

  void replaceAll(Set<CanvasEvent> events) {
    state.clear();
    state.addAll(events);
    emit({...state});
  }

  void add(CanvasEvent event) {
    if (!state.contains(event)) {
      print('add $event');
      state.add(event);
      emit({...state});
    }
  }

  void remove(CanvasEvent event) {
    if (state.contains(event)) {
      print('remove $event');
      state.remove(event);
      emit({...state});
    }
  }

  void removeAll(List<CanvasEvent> events) {
    state.removeAll(events);
    emit({...state});
  }

  void clear() {
    state.clear();
    emit({...state});
  }

  bool containsAny(Set<CanvasEvent> events) =>
      state.any((element) => events.contains(element));
}

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
  resizeControllerTopLeft,
  resizeControllerTopCenter,
  resizeControllerTopRight,
  resizeControllerCenterLeft,
  resizeControllerCenterRight,
  resizeControllerBottomLeft,
  resizeControllerBottomCenter,
  resizeControllerBottomRight,
  rotateCursor,
  normalCursor,
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
