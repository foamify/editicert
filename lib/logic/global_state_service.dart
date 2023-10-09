import 'package:flutter/foundation.dart';

class GlobalState {
  final state = ValueNotifier(GlobalStateData({}));

  void update(GlobalStateData value) {
    if (state.value.states != value.states) state.value = value;
  }

  void add(GlobalStates value) => state.value = state.value + value;

  void remove(GlobalStates value) => state.value = state.value - value;

  void clear() => state.value = GlobalStateData({});
}

class GlobalStateData {
  GlobalStateData(this.states);

  final Set<GlobalStates> states;

  bool containsAny(Set<GlobalStates> states) =>
      states.any((element) => this.states.contains(element));

  GlobalStateData copyWith({
    required Set<GlobalStates> states,
  }) =>
      GlobalStateData(states);

  GlobalStateData merge(GlobalStateData other) =>
      GlobalStateData(states..addAll(other.states));

  GlobalStateData operator +(GlobalStates other) =>
      GlobalStateData(states..add(other));

  GlobalStateData operator -(GlobalStates other) =>
      GlobalStateData(states..remove(other));
}

enum GlobalStates {
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
