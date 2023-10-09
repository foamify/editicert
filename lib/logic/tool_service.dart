import 'package:flutter/foundation.dart';

class Tool {
  final tool = ValueNotifier(ToolType.move);

  ToolType get state => tool.value;

  set state(ToolType value) => tool.value = value;

  void setMove() => state = ToolType.move;

  void setRectangle() => state = ToolType.rectangle;

  void setHand() => state = ToolType.hand;

  void setFrame() => state = ToolType.frame;

  void setText() => state = ToolType.text;
}

enum ToolType {
  move,
  rectangle,
  hand,
  frame,
  text,
}
