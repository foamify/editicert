import 'package:flutter_bloc/flutter_bloc.dart';

class PointersCubit extends Cubit<List<PointerButton>> {
  PointersCubit() : super([]);

  void add(PointerButton button) {
    if (!state.contains(button)) {
      state.add(button);
    }
  }

  void remove(PointerButton button) {
    if (state.contains(button)) {
      state.remove(button);
    }
  }

  void update(List<PointerButton> buttons) {
    emit([...buttons]);
  }

  void clear() {
    state.clear();
  }
}

enum PointerButton {
  left,
  middle,
  right,
}
