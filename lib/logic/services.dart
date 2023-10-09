import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Services {
  final mousePosition = ValueNotifier(Offset.zero);
}

class Keys {
  final state = ValueNotifier<Set<LogicalKeyboardKey>>({});

  Set<LogicalKeyboardKey> get _keys => state.value;

  set _keys(Set<LogicalKeyboardKey> value) => state.value = value;

  void add(LogicalKeyboardKey key) {
    if (!_keys.contains(key)) _keys = {..._keys..add(key)};
  }

  void remove(LogicalKeyboardKey key) {
    if (_keys.contains(key)) {
      _keys = {..._keys..remove(key)};
    }
  }
}

class TransformationControllerData {
  final state = ValueNotifier(TransformationController());

  void change(TransformationController value) => state.value = value;

  void update(Matrix4 value) => state.value = TransformationController(value);
}
