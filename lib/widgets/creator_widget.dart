import 'dart:math';

import 'package:editicert/logic/component_service.dart';
import 'package:editicert/logic/global_state_service.dart';
import 'package:editicert/logic/tool_service.dart';
import 'package:editicert/utils.dart';
import 'package:editicert/widgets/controller_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CreatorWidget extends StatefulWidget {
  const CreatorWidget({super.key});

  @override
  State<CreatorWidget> createState() => _CreatorWidgetState();
}

class _CreatorWidgetState extends State<CreatorWidget> {
  final oComponent = ValueNotifier(const Component(Offset.zero, Size.zero, 0));

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
    final componentType = {
      ToolType.frame: ComponentType.frame,
      ToolType.rectangle: ComponentType.rectangle,
      ToolType.text: ComponentType.text,
    };
    final componentName = {
      ToolType.frame: 'Frame',
      ToolType.rectangle: 'Rectangle',
      ToolType.text: 'Text',
    };

    globalStateNotifier.update(
      globalStateNotifier.state.value + GlobalStates.creatingRectangle,
    );

    final tController = canvasTransform.state.value;

    oPosition.value = tController
        .toScene(event.position + const Offset(-sidebarWidth, -topbarHeight));
    oComponent.value = Component(oPosition.value, Size.zero, 0);

    final index = componentsNotifier.state.value.length;

    componentsNotifier.add(ComponentData(
      component: oComponent.value,
      name: '${componentName[toolNotifier.tool.value]} ${index + 1}',
      type: componentType[toolNotifier.tool.value] ?? ComponentType.other,
      color: toolNotifier.tool.value == ToolType.text
          ? Colors.transparent
          : const Color(0xFF9E9E9E),
    ));
  }

  void handlePointerMove(PointerMoveEvent event) {
    final tController = canvasTransform.state.value;
    final keys = keysNotifier.state.value;
    final shift = keys.contains(LogicalKeyboardKey.shiftLeft) ||
        keys.contains(LogicalKeyboardKey.shiftRight);
    final alt = keys.contains(LogicalKeyboardKey.altLeft) ||
        keys.contains(LogicalKeyboardKey.altRight);

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

    final xScale = alt
        ? 1
        : deltaX
            ? -1
            : 1;
    final yScale = alt
        ? 1
        : deltaY
            ? -1
            : 1;

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
    final newComponent = oComponent.value.copyWith(
      pos: (alt
          ? newRect.topLeft -
              switch ((deltaX, deltaY)) {
                _ when shift => newRect.size.bottomRight(Offset.zero),
                (false, false) => newRect.size.bottomRight(Offset.zero),
                (true, false) => newRect.size.bottomLeft(Offset.zero),
                (false, true) => newRect.size.topRight(Offset.zero),
                (true, true) => newRect.size.topLeft(Offset.zero),
              }
          : newRect.topLeft),
      size: (alt ? newRect.size * 2 : newRect.size),
    );
    componentsNotifier.replace(index, transform: newComponent);
  }

  void handlePointerUp(PointerUpEvent _) {
    globalStateNotifier.update(
        globalStateNotifier.state.value - GlobalStates.creatingRectangle);

    final components = componentsNotifier.state.value;
    final index = components.length - 1;
    final component = components[index].component;
    if (component.size.width == 0 || component.size.height == 0) {
      componentsNotifier.replace(
        index,
        transform: Component(
          oComponent.value.pos - const Offset(50, 50),
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
