import 'package:flutter_bloc/flutter_bloc.dart';

class ToolCubit extends Cubit<ToolType> {
  ToolCubit(super.initialState);

  void setMove() => emit(ToolType.move);

  void setRectangle() => emit(ToolType.rectangle);

  void setHand() => emit(ToolType.hand);

  void setFrame() => emit(ToolType.frame);

  void setText() => emit(ToolType.text);
}

enum ToolType {
  move,
  rectangle,
  hand,
  frame,
  text,
}
