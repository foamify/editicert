part of '../main.dart';

class CreatorWidget extends StatefulWidget {
  const CreatorWidget({super.key});

  @override
  State<CreatorWidget> createState() => _CreatorWidgetState();
}

class _CreatorWidgetState extends State<CreatorWidget> {
  final oComponent =
      ValueNotifier(const Component(Offset.zero, Size.zero, 0, false, false));

  final oPosition = ValueNotifier(Offset.zero);

  @override
  void dispose() {
    oComponent.dispose();
    oPosition.dispose();
    super.dispose();
  }

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
    if (event.buttons == kMiddleMouseButton) return;

    final componentType = {
      ToolType.frame: ComponentType.frame,
      ToolType.rectangle: ComponentType.rectangle,
      ToolType.text: ComponentType.text,
      ToolType.hand: null,
      ToolType.move: null,
    };
    final componentName = {
      ToolType.frame: 'Frame',
      ToolType.rectangle: 'Rectangle',
      ToolType.text: 'Text',
      ToolType.hand: null,
      ToolType.move: null,
    };

    final canvasEvents = context.read<CanvasEventsCubit>();

    canvasEvents.add(CanvasEvent.creatingRectangle);

    final tController = context.read<CanvasTransformCubit>().state;

    oPosition.value = tController
        .toScene(event.position + const Offset(-kSidebarWidth, -kTopbarHeight));
    oComponent.value = Component(oPosition.value, Size.zero, 0, false, false);

    final index = componentsNotifier.state.value.length;

    final currentTool = context.read<ToolCubit>().state;

    componentsNotifier.add(ComponentData(
      component: oComponent.value,
      name: '${componentName[currentTool] ?? '[Error CompType]'} ${index + 1}',
      type: componentType[currentTool] ?? ComponentType.other,
      color: currentTool == ToolType.text
          ? Colors.transparent
          : const Color(0xFF9E9E9E),
    ));
  }

  void handlePointerMove(PointerMoveEvent event) {
    if (event.buttons == kMiddleMouseButton) return;
    final tController = context.read<CanvasTransformCubit>().state;
    final keys = context.read<KeysCubit>().state;
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
        .toScene(event.position + const Offset(-kSidebarWidth, -kTopbarHeight));
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
          ? oPosition.value + Offset(longestSide * xScale, longestSide * yScale)
          : Offset(pos.dx, pos.dy),
    );
    final newComponent = oComponent.value.copyWith(
      pos: (alt
          ? newRect.topLeft -
              switch ((deltaX, deltaY)) {
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

  void handlePointerUp(PointerUpEvent event) {
    if (context
        .read<CanvasEventsCubit>()
        .state
        .contains(CanvasEvent.middleClickUp)) {
      context.read<CanvasEventsCubit>().remove(CanvasEvent.creatingRectangle);

      final components = componentsNotifier.state.value;
      final index = components.length - 1;
      // ignore: avoid-unsafe-collection-methods
      final component = components[index].component;
      if (component.size.width == 0 || component.size.height == 0) {
        componentsNotifier.replace(
          index,
          transform: Component(
            oComponent.value.pos - const Offset(50, 50),
            const Size(100, 100),
            0,
            false,
            false,
          ),
        );
      }
      context.read<ToolCubit>().setMove();
      selectedNotifier
        ..clear()
        ..add(index);
      return;
    }
  }
}
