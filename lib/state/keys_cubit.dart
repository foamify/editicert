import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class KeysCubit extends Cubit<Set<LogicalKeyboardKey>> {
  KeysCubit() : super({});

  void add(LogicalKeyboardKey key) {
    if (!state.contains(key)) {
      state.add(key);
    }
  }

  void remove(LogicalKeyboardKey key) {
    if (state.contains(key)) {
      state.remove(key);
    }
  }

  void clear() {
    state.clear();
  }
}
