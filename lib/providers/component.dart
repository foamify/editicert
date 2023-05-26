import 'package:editicert/widgets/controller_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'component.g.dart';

@immutable
class ComponentData {
  const ComponentData({
    this.name = 'Component',
    this.triangle = const Triangle(Offset.zero, Size(200, 100), 0),
    this.color = const Color(0xFF333333),
    this.borderRadius = BorderRadius.zero,
    this.border = const Border(),
    this.shadow = const [],
    this.content = const SizedBox.shrink(),
    this.hidden = false,
    this.locked = false,
  });

  final String name;
  final Triangle triangle;
  final Color color;
  final BorderRadius borderRadius;
  final Border border;
  final List<BoxShadow> shadow;
  final Widget content;
  final bool hidden;
  final bool locked;

  ComponentData copyWith({
    required String? name,
    required Triangle? triangle,
    required Color? color,
    required BorderRadius? borderRadius,
    required Border? border,
    required List<BoxShadow>? shadow,
    required Widget? content,
    required bool? hidden,
    required bool? locked,
  }) =>
      ComponentData(
        name: name ?? this.name,
        triangle: triangle ?? this.triangle,
        color: color ?? this.color,
        borderRadius: borderRadius ?? this.borderRadius,
        border: border ?? this.border,
        shadow: shadow ?? this.shadow,
        content: content ?? this.content,
        hidden: hidden ?? this.hidden,
        locked: locked ?? this.locked,
      );
}

@riverpod
class Components extends _$Components {
  @override
  List<ComponentData> build() {
    return [];
  }

  void add(ComponentData component) => state.add(component);

  void removeAt(int index) => state.removeAt(index);

  void reorder(int oldIndex, int newIndex) {
    ref.read(hoveredProvider.notifier).clear();
    ref.read(selectedProvider.notifier).clear();

    final component = state[oldIndex];
    final newState = [...state];
    newState.removeAt(oldIndex);
    newState.insert(newIndex, component);

    ref.read(selectedProvider.notifier).add(newIndex);

    state = [...newState];
  }

  void replace(
    int index, {
    String? name,
    Triangle? triangle,
    Color? color,
    BorderRadius? borderRadius,
    Border? border,
    List<BoxShadow>? shadow,
    Widget? content,
    bool? hidden,
    bool? locked,
  }) {
    final component = state[index];
    final newState = [...state];
    newState.removeAt(index);
    newState.insert(
      index,
      component.copyWith(
        name: name,
        triangle: triangle,
        color: color,
        borderRadius: borderRadius,
        border: border,
        shadow: shadow,
        content: content,
        hidden: hidden,
        locked: locked,
      ),
    );
    state = [...newState];
  }
}

@riverpod
class Keys extends _$Keys {
  @override
  Set<LogicalKeyboardKey> build() {
    return {};
  }

  Set<LogicalKeyboardKey> get keys => state;

  set keys(Set<LogicalKeyboardKey> value) => state = value;

  void add(LogicalKeyboardKey key) {
    if (!state.contains(key)) state = {...state..add(key)};
  }

  void remove(LogicalKeyboardKey key) {
    if (state.contains(key)) {
      state = {...state..remove(key)};
    }
  }
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

@riverpod
class Tool extends _$Tool {
  @override
  ToolData build() {
    return ToolData.move;
  }

  void setMove() => state = ToolData.move;

  void setCreate() => state = ToolData.create;

  void setHand() => state = ToolData.hand;
}

enum ToolData {
  move,
  create,
  hand,
}

@riverpod
Matrix4 canvasTransform(CanvasTransformRef ref) {
  return ref.watch(transformationControllerDataProvider).value;
}

@riverpod
class TransformationControllerData extends _$TransformationControllerData {
  @override
  TransformationController build() {
    return TransformationController();
  }

  void change(TransformationController value) => state = value;

  void update(Matrix4 value) => state = TransformationController(value);
}

@riverpod
class GlobalState extends _$GlobalState {
  @override
  GlobalStateData build() {
    return GlobalStateData({});
  }

  void update(GlobalStateData value) => state = value;

  void clear() => state = GlobalStateData({});
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
  leftClick,
  rightClick,
  middleClick,
  panningCanvas,
  zoomingCanvas,
  draggingComponent,
  resizingComponent,
  rotatingComponent,
  creating,
}
