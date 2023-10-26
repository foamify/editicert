import 'package:flutter_bloc/flutter_bloc.dart';

base class ComponentIndexCubit extends Cubit<Set<int>> {
  ComponentIndexCubit() : super({});

  void add(int index) => emit({...state..add(index)});

  void remove(int index) => emit({...state..remove(index)});

  void removeAll(List<int> indexes) {
    emit({...state..removeWhere((index) => indexes.contains(index))});
  }

  void replaceAll(Set<int> indexes) {
    emit(Set.of(indexes));
  }

  void clear() => emit({});

  bool contains(int index) => state.contains(index);

  void reorder(int oldIndex, int newIndex) {
    final components = state
        .map(
          (componentIndex) =>
              (componentIndex == oldIndex) ? newIndex : componentIndex,
        )
        .toSet();

    emit(components.toSet());
  }
}

final class SelectedCubit extends ComponentIndexCubit {}

final class HoveredCubit extends ComponentIndexCubit {}
