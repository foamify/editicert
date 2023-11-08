import 'package:flutter_bloc/flutter_bloc.dart';

class PointersCubit extends Cubit<PointerButton?> {
  PointersCubit() : super(null);

  void update(PointerButton? button) {
    emit(button);
  }

  void clear() {
    emit(null);
  }
}

enum PointerButton {
  left,
  middle,
  right,
}
