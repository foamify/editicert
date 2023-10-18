// ignore_for_file: public_member_api_docs

import 'package:collection/collection.dart';
import 'package:editicert/models/component_data.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ComponentsBloc extends Bloc<ComponentsEvent, List<ComponentData>> {
  ComponentsBloc(super.initialState) {
    on<AddComponent>((event, emit) {
      emit([...state, event.component]);
    });

    on<RemoveComponent>((event, emit) {
      emit(
        state.whereIndexed((index, element) => index != event.index).toList(),
      );
    });

    on<UpdateComponent>((event, emit) {
      final updatedList = List<ComponentData>.of(state)
        ..replaceRange(event.index, event.index + 1, [event.component]);
      emit(updatedList);
    });

    on<ClearComponents>((event, emit) {
      emit(List.empty());
    });

    on<ReorderComponents>((event, emit) {
      final oldIndex = event.oldIndex;
      final newIndex = event.newIndex;

      if (oldIndex < 0 ||
          oldIndex >= state.length ||
          newIndex < 0 ||
          newIndex >= state.length) {
        // TODO(damywise): Handle this better
        return;
      }

      final components = List<ComponentData>.of(state)
        ..swap(oldIndex, newIndex);

      emit(components);
    });
  }
}

abstract class ComponentsEvent extends Equatable {
  final List<ComponentData> _components = [];

  List<ComponentData> get components => _components;

  @override
  List<Object?> get props => [_components];
}

class AddComponent extends ComponentsEvent {
  AddComponent(this.index, this.component);
  final int? index;
  final ComponentData component;

  @override
  List<Object?> get props => [index, component];
}

class RemoveComponent extends ComponentsEvent {
  RemoveComponent(this.index);
  final int index;
}

class UpdateComponent extends ComponentsEvent {
  UpdateComponent(this.index, this.component);
  final int index;
  final ComponentData component;
}

class ClearComponents extends ComponentsEvent {
  ClearComponents();
}

class ReorderComponents extends ComponentsEvent {
  ReorderComponents({required this.oldIndex, required this.newIndex});

  final int oldIndex;
  final int newIndex;

  @override
  List<Object?> get props => [oldIndex, newIndex];
}
