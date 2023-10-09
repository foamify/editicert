import 'package:flutter/foundation.dart';

base class ComponentsIndexService {
  final state = ValueNotifier<Set<int>>({});

  void add(int index) => state.value = {...state.value..add(index)};

  void remove(int index) => state.value = {...state.value..remove(index)};

  void clear() => state.value = {};

  bool contains(int index) => state.value.contains(index);
}

final class Selected extends ComponentsIndexService {}

final class Hovered extends ComponentsIndexService {}
