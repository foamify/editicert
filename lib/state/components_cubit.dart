// ignore_for_file: public_member_api_docs

import 'package:collection/collection.dart';
import 'package:editicert/models/component_data.dart';
import 'package:equatable/equatable.dart';
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
}
