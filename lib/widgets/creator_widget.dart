import 'dart:math';

import 'package:editicert/logic/services.dart';
import 'package:editicert/utils.dart';
import 'package:editicert/widgets/controller_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CreatorWidget extends StatefulWidget {
  CreatorWidget({super.key});

  @override
  State<CreatorWidget> createState() => _CreatorWidgetState();
}

class _CreatorWidgetState extends State<CreatorWidget> {
  final oTriangle = ValueNotifier(const Triangle(Offset.zero, Size.zero, 0));

  final oPosition = ValueNotifier(Offset.zero);

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: handlePointerDown,
      onPointerMove: handlePointerMove,
      onPointerUp: handlePointerUp,
      child: MouseRegion(
        cursor: SystemMouseCursors.precise,
        child: Container(
          width: double.infinity,
          height: double.infinity,
          color: Colors.transparent,
        ),
      ),
    );
  }

  void handlePointerDown(PointerDownEvent event) {
    globalStateNotifier
        .update(globalStateNotifier.state.value + GlobalStates.creating);
    final tController = canvasTransform.state.value;
    oPosition.value = tController
        .toScene(event.position + const Offset(-sidebarWidth, -topbarHeight));
    oTriangle.value = Triangle(oPosition.value, Size.zero, 0);
    final index = componentsNotifier.state.value.length;
    componentsNotifier.add(ComponentData(
      triangle: oTriangle.value,
      name: 'Rectangle ${index + 1}',
    ));
  }

  void handlePointerMove(PointerMoveEvent event) {
    final tController = canvasTransform.state.value;
    final keys = keysNotifier.state.value;
    final shift = pressedShift(keys);

    final index = componentsNotifier.state.value.length - 1;
    hoveredNotifier.clear();
    selectedNotifier
      ..clear()
      ..add(index);

    final pos = tController
        .toScene(event.position + const Offset(-sidebarWidth, -topbarHeight));
    final deltaX = (oPosition.value.dx - pos.dx) > 0;
    final deltaY = (oPosition.value.dy - pos.dy) > 0;

    final longestSide = max(
      (oPosition.value.dx - pos.dx).abs(),
      (oPosition.value.dy - pos.dy).abs(),
    );

    final xScale = (deltaX ? -1 : 1);
    final yScale = (deltaY ? -1 : 1);

    final newRect = Rect.fromPoints(
      oPosition.value,
      shift
          ? oPosition.value +
              Offset(
                longestSide * xScale,
                longestSide * yScale,
              )
          : Offset(
              pos.dx,
              pos.dy,
            ),
    );
    final newTriangle = oTriangle.value.copyWith(
      pos: newRect.topLeft,
      size: newRect.size,
    );
    componentsNotifier.replace(index, triangle: newTriangle);
  }

  bool pressedShift(Set<LogicalKeyboardKey> keys) {
    return keys.contains(LogicalKeyboardKey.shiftLeft) ||
        keys.contains(LogicalKeyboardKey.shiftRight);
  }

  void handlePointerUp(PointerUpEvent _) {
    globalStateNotifier
        .update(globalStateNotifier.state.value - GlobalStates.creating);

    final components = componentsNotifier.state.value;
    final index = components.length - 1;
    final triangle = components[index].triangle;
    if (triangle.size.width == 0 || triangle.size.height == 0) {
      componentsNotifier.replace(
        index,
        triangle: Triangle(
          oTriangle.value.pos - const Offset(50, 50),
          const Size(100, 100),
          0,
        ),
      );
    }
    toolNotifier.setMove();
    selectedNotifier
      ..clear()
      ..add(index);
  }
}
