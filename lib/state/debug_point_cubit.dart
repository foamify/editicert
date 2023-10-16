import 'dart:ui';

import 'package:flutter_bloc/flutter_bloc.dart';

class DebugPointCubit extends Cubit<List<Offset>> {
  DebugPointCubit() : super([]);

  void update(List<Offset> value) => emit(value);
}
