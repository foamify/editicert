import 'dart:ui';

import 'package:flutter_bloc/flutter_bloc.dart';

class PointerCubit extends Cubit<Offset> {
  PointerCubit(super.initialState);

  void update(Offset value) => emit(value);
}
