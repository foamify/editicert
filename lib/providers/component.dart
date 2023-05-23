import 'package:editicert/widgets/component_widget.dart';
import 'package:flutter/services.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'component.g.dart';

@riverpod
class Components extends _$Components {
  @override
  List<({String name, Triangle triangle})> build() {
    return [];
  }

  void add(({String name, Triangle triangle}) component) =>
      state.add(component);

  void removeAt(int index) => state.removeAt(index);

  void reorder(int oldIndex, int newIndex) {
    final component = state[oldIndex];
    final newState = [...state];
    newState.removeAt(oldIndex);
    newState.insert(newIndex, component);
    state = [...newState];
  }

  void replace(int index, {String? name, Triangle? triangle}) {
    final component = state[index];
    final newState = [...state];
    newState.removeAt(index);
    newState.insert(index, (
      name: name ?? component.name,
      triangle: triangle ?? component.triangle
    ));
    state = [...newState];
  }
}

@riverpod
class Keys extends _$Keys {
  @override
  Set<PhysicalKeyboardKey> build() {
    return {};
  }

  Set<PhysicalKeyboardKey> get keys => state;

  set keys(Set<PhysicalKeyboardKey> value) => state = value;
}

@riverpod
class Selected extends _$Selected {
  @override
  Set<int> build() {
    return {};
  }

  void add(int index) => state = {...state..add(index)};
  void remove(int index) => state = {...state..remove(index)};
  bool contains(int index) => state.contains(index);
  void clear() => state = {...state..clear()};
}

@riverpod
class Hovered extends _$Hovered {
  @override
  Set<int> build() {
    return {};
  }

  void add(int index) => state = {...state..add(index)};
  void remove(int index) => state = {...state..remove(index)};
  bool contains(int index) => state.contains(index);
  void clear() => state = {...state..clear()};
}