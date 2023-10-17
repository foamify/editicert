import 'package:editicert/logic/component_index_service.dart';
import 'package:editicert/models/component.dart';
import 'package:editicert/models/component_data.dart';
import 'package:editicert/models/component_type.dart';
import 'package:editicert/util/utils.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class ComponentService {
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

    // ignore: avoid-unsafe-collection-methods
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
    ComponentTransform? transform,
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
    // ignore: avoid-unsafe-collection-methods
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
