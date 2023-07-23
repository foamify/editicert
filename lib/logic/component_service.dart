import 'package:editicert/logic/component_index_service.dart';
import 'package:editicert/utils.dart';
import 'package:editicert/widgets/controller_widget.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class Components {
  // Components() {
  //   _state = List.filled(200, ComponentData());
  // }

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
    Component? transform,
    Color? color,
    BorderRadius? borderRadius,
    Border? border,
    List<BoxShadow>? shadow,
    Widget? content,
    bool? hidden,
    bool? locked,
    ComponentType? type,
    TextEditingController? controller,
  }) {
    final component = _state[index];
    _state = [
      ..._state
        ..removeAt(index)
        ..insert(
          index,
          component.copyWith(
            name: name,
            component: transform,
            color: color,
            borderRadius: borderRadius,
            border: border,
            shadow: shadow,
            content: content,
            hidden: hidden,
            locked: locked,
            type: type,
            textController: controller,
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
    this.component = const Component(Offset.zero, Size(100, 100), 0),
    this.color = const Color(0xFF9E9E9E),
    this.borderRadius = BorderRadius.zero,
    this.border = const Border(),
    this.shadow = const [],
    this.content = const SizedBox.shrink(),
    this.hidden = false,
    this.locked = false,
    this.type = ComponentType.frame,
    this.textController,
  });

  final String name;
  final Component component;
  final Color color;
  final BorderRadius borderRadius;
  final Border border;
  final List<BoxShadow> shadow;
  final Widget content;
  final bool hidden;
  final bool locked;
  final ComponentType type;
  final TextEditingController? textController;

  ComponentData copyWith({
    required String? name,
    required Component? component,
    required Color? color,
    required BorderRadius? borderRadius,
    required Border? border,
    required List<BoxShadow>? shadow,
    required Widget? content,
    required bool? hidden,
    required bool? locked,
    required ComponentType? type,
    required TextEditingController? textController,
  }) =>
      ComponentData(
        name: name ?? this.name,
        component: component ?? this.component,
        color: color ?? this.color,
        borderRadius: borderRadius ?? this.borderRadius,
        border: border ?? this.border,
        shadow: shadow ?? this.shadow,
        content: content ?? this.content,
        hidden: hidden ?? this.hidden,
        locked: locked ?? this.locked,
        type: type ?? this.type,
        textController: textController ?? this.textController,
      );
}

enum ComponentType {
  frame,
  text,
  image,
  rectangle,
  other,
}
