// ignore_for_file: public_member_api_docs

import 'package:collection/collection.dart';
import 'package:editicert/models/component_data.dart';
import 'package:editicert/models/component_transform.dart';
import 'package:editicert/models/component_type.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ComponentsCubit extends Cubit<List<ComponentData>> {
  ComponentsCubit(super.initialState);

  void add(ComponentData component) => emit([...state, component]);

  void remove(int index) =>
      emit(state.whereIndexed((index, element) => index != index).toList());

  void clear() => emit(List.empty());

  bool contains(int index) => state.contains(index);

  void reorder(int oldIndex, int newIndex) {
    if (oldIndex < 0 ||
        oldIndex >= state.length ||
        newIndex < 0 ||
        newIndex >= state.length) {
      // TODO(damywise): Handle this better
      return;
    }

    final components = List<ComponentData>.of(state)..swap(oldIndex, newIndex);

    emit(components);
  }

  void replace(int index, ComponentData component) {
    print('replace1');
    final components = List<ComponentData>.of(state);
    components[index] = component;
    emit(components);
  }

  void replaceCopyWith(
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
    TextEditingController? textController,
  }) {
    final oldComponent = state[index];
    final newComponent = oldComponent.copyWithRequired(
      name: name,
      transform: transform,
      color: color,
      borderRadius: borderRadius,
      border: border,
      shadow: shadow,
      content: content,
      hidden: hidden,
      locked: locked,
      type: type,
      textController: textController,
    );
    replace(index, newComponent);
  }
}
