import 'package:collection/collection.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

base class ComponentIndexCubit extends Cubit<Set<int>> {
  ComponentIndexCubit() : super({});

  void add(int index) => emit({...state..add(index)});

  void remove(int index) => emit({...state..remove(index)});

  void clear() => emit({});

  bool contains(int index) => state.contains(index);

  void reorder(int oldIndex, int newIndex) {
    if (oldIndex < 0 || oldIndex >= state.length || newIndex < 0 || newIndex >= state.length) {
      // TODO(damywise): Handle this better
      return;
    }

    final components = List.of(state)
      ..swap(oldIndex, newIndex);

    emit(components.toSet());
  }
}

final class Selected extends ComponentIndexCubit {}

final class Hovered extends ComponentIndexCubit {}
