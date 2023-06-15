import 'package:collection/collection.dart';
import 'package:editicert/widgets/controller_widget.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';

class Services {}

final _get = GetIt.I.get;

TransformationControllerData get canvasTransform =>
    _get<TransformationControllerData>();

Components get componentsNotifier => _get<Components>();

Tool get toolNotifier => _get<Tool>();

Keys get keysNotifier => _get<Keys>();

Selected get selectedNotifier => _get<Selected>();

Hovered get hoveredNotifier => _get<Hovered>();

GlobalState get globalStateNotifier => _get<GlobalState>();

CanvasState get canvasStateNotifier => _get<CanvasState>();

class Components {
  final ValueNotifier<List<ComponentData>> state = ValueNotifier([]);

  List<ComponentData> get _state => state.value;

  set _state(List<ComponentData> value) => state.value = value;

  void add(ComponentData component) => _state.add(component);

  void reorder(
    int oldIndex,
    int newIndex,
  ) {
    selectedNotifier.clear();
    hoveredNotifier.clear();

    final component = _state[oldIndex];

    _state = [
      ..._state
        ..removeAt(oldIndex)
        ..insert(newIndex, component),
    ];
    selectedNotifier.add(newIndex);
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
    final component = _state[index];
    _state = [
      ..._state
        ..removeAt(index)
        ..insert(
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
        ),
    ];
  }

  void removeSelected() {
    final selectedIndex = GetIt.I.get<Selected>().state.value.firstOrNull;
    if (selectedIndex != null) {
      selectedNotifier.clear();
      hoveredNotifier.clear();
      _state = [..._state..removeAt(selectedIndex)];
    }
  }

}

@immutable
class ComponentData {
  const ComponentData({
    this.name = 'Component',
    this.triangle = const Triangle(Offset.zero, Size(200, 100), 0),
    this.color = const Color(0xFF9E9E9E),
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

class Keys {
  final state = ValueNotifier<Set<LogicalKeyboardKey>>({});

  Set<LogicalKeyboardKey> get _keys => state.value;

  set _keys(Set<LogicalKeyboardKey> value) => state.value = value;

  void add(LogicalKeyboardKey key) {
    if (!_keys.contains(key)) state.value = {...state.value..add(key)};
  }

  void remove(LogicalKeyboardKey key) {
    if (_keys.contains(key)) {
      state.value = {...state.value..remove(key)};
    }
  }
}

base class ComponentsIndex {
  final state = ValueNotifier<Set<int>>({});

  void add(int index) => state.value = {...state.value..add(index)};

  void remove(int index) => state.value = {...state.value..remove(index)};

  void clear() => state.value = {};

  bool contains(int index) => state.value.contains(index);
}

final class Selected extends ComponentsIndex {}

final class Hovered extends ComponentsIndex {}

class Tool {
  final tool = ValueNotifier(ToolData.move);

  ToolData get state => tool.value;

  set state(ToolData value) => tool.value = value;

  void setMove() => state = ToolData.move;

  void setRectangle() => state = ToolData.create;

  void setHand() => state = ToolData.hand;
}

enum ToolData {
  move,
  create,
  hand,
}

class TransformationControllerData {
  final state = ValueNotifier(TransformationController());

  void change(TransformationController value) => state.value = value;

  void update(Matrix4 value) => state.value = TransformationController(value);
}

class GlobalState {
  final state = ValueNotifier(GlobalStateData({}));

  void update(GlobalStateData value) => state.value = value;

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
  leftClick,
  rightClick,
  middleClick,
  panningCanvas,
  zoomingCanvas,
  draggingComponent,
  resizingComponent,
  rotatingComponent,
  creating,
  draggingSidebarComponent,
  fullscreen,
}

class CanvasState {
  final state = ValueNotifier<CanvasData>((
    transform: Matrix4.identity(),
    backgroundColor: const Color(0xFFF5F5F5),
    backgroundHidden: true,
    backgroundOpacity: 1,
  ));

  void update({
    Matrix4? transform,
    Color? backgroundColor,
    bool? backgroundHidden,
    double? backgroundOpacity,
  }) {
    state.value = state.value.copyWith(
      transform: transform,
      backgroundColor: backgroundColor,
      backgroundHidden: backgroundHidden,
      backgroundOpacity: backgroundOpacity,
    );
  }
}

typedef CanvasData = ({
  Matrix4 transform,
  Color backgroundColor,
  bool backgroundHidden,
  double backgroundOpacity,
});

extension CDataEx on CanvasData {
  CanvasData copyWith({
    Matrix4? transform,
    Color? backgroundColor,
    bool? backgroundHidden,
    double? backgroundOpacity,
  }) {
    return (
      transform: transform ?? this.transform,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      backgroundHidden: backgroundHidden ?? this.backgroundHidden,
      backgroundOpacity: backgroundOpacity ?? this.backgroundOpacity,
    );
  }
}

