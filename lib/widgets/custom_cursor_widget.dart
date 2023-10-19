part of '../main.dart';

/// Widget that handles the cursor on the canvas
class CustomCursorWidget extends StatelessWidget {
  const CustomCursorWidget({
    required this.isToolHand,
    required this.isNotCanvasTooling,
    required this.isCanvasTooling,
    super.key,
  });

  final bool isToolHand;
  final bool isNotCanvasTooling;
  final bool isCanvasTooling;

  @override
  Widget build(BuildContext context) {
    final canvasEvents = context.canvasEventsCubitWatch;
    final stateContains = canvasEvents.state.contains;
    final selectedIndexes = context.selectedCubitWatch;
    final componentsCubit = context.componentsCubitWatch;

    final tool = context.watch<ToolCubit>().state;
    print(tool);
    if (stateContains(CanvasEvent.normalCursor) ||
        stateContains(CanvasEvent.middleClick) ||
        tool == ToolType.hand) {
      canvasEvents.add(CanvasEvent.normalCursor);
      return const SizedBox.shrink();
    }
    canvasEvents.remove(CanvasEvent.normalCursor);

    // final enabled = stateContainsAny({
    //   CanvasEvent.rotatingComponent,
    //   CanvasEvent.resizingComponent,
    // });

    late final double angle;
    if (selectedIndexes.state.isNotEmpty) {
      // ignore: avoid-unsafe-collection-methods
      angle = componentsCubit
          // ignore: avoid-unsafe-collection-methods
          .state[selectedIndexes.state.first]
          .transform
          .angle;
    }

    final alignments = {
      Alignment.topLeft: CanvasEvent.resizeControllerTopLeft,
      Alignment.topCenter: CanvasEvent.resizeControllerTopCenter,
      Alignment.topRight: CanvasEvent.resizeControllerTopRight,
      Alignment.centerLeft: CanvasEvent.resizeControllerCenterLeft,
      Alignment.centerRight: CanvasEvent.resizeControllerCenterRight,
      Alignment.bottomLeft: CanvasEvent.resizeControllerBottomLeft,
      Alignment.bottomCenter: CanvasEvent.resizeControllerBottomCenter,
      Alignment.bottomRight: CanvasEvent.resizeControllerBottomRight,
    };

    Alignment? alignment;
    for (final MapEntry(:key, :value) in alignments.entries) {
      if (context.read<CanvasEventsCubit>().state.contains(value)) {
        alignment = key;
        break;
      }
    }

    // final grab = switch ((
    //   context
    //       .read<CanvasEventsCubit>()
    //       .state
    //       .contains(CanvasEvent.leftClick),
    //   isToolHand && (!isNotCanvasTooling || isCanvasTooling),
    // )) {
    //   (false, true) => SystemMouseCursors.grab,
    //   (true, true) => SystemMouseCursors.grabbing,
    //   _ => MouseCursor.defer,
    // };

    late final Widget child;

    if (alignment != null) {
      final selected = selectedIndexes.state.firstOrNull;
      if (selected == null) return const SizedBox.shrink();
      final component = componentsCubit.state
          .elementAtOrNull(selectedIndexes.state.firstOrNull!)
          ?.transform;
      final flipX = component?.flipX ?? false;
      final flipY = component?.flipY ?? false;
      if (flipX) {
        alignment = switch (alignment) {
          Alignment.topLeft => Alignment.topRight,
          Alignment.topRight => Alignment.topLeft,
          Alignment.bottomLeft => Alignment.bottomRight,
          Alignment.bottomRight => Alignment.bottomLeft,
          Alignment.centerLeft => Alignment.centerRight,
          Alignment.centerRight => Alignment.centerLeft,
          _ => alignment,
        };
      }
      if (flipY) {
        alignment = switch (alignment) {
          Alignment.topLeft => Alignment.bottomLeft,
          Alignment.topRight => Alignment.bottomRight,
          Alignment.bottomLeft => Alignment.topLeft,
          Alignment.bottomRight => Alignment.topRight,
          Alignment.centerLeft => Alignment.centerRight,
          Alignment.centerRight => Alignment.centerLeft,
          _ => alignment,
        };
      }
      final rotations = <Alignment, double>{
        Alignment.topLeft: 45.0,
        Alignment.topCenter: 90,
        Alignment.topRight: 135,
        Alignment.centerLeft: 0,
        // Alignment.center: ,
        Alignment.centerRight: 0,
        Alignment.bottomRight: 225,
        Alignment.bottomCenter: 90,
        Alignment.bottomLeft: 315,
      };

      final rotate = stateContains(CanvasEvent.rotateCursor) ||
          stateContains(CanvasEvent.rotatingComponent);

      final icon =
          rotate ? Icons.rotate_right : CupertinoIcons.arrow_left_right;

      child = Transform.translate(
        offset: const Offset(-6, -6),
        child: Transform.rotate(
          angle: angle + rotations[alignment]! / 180 * pi,
          child: SizedBox(
            width: 24,
            height: 24,
            child: Icon(
              icon,
              size: 14,
              color: Colors.black,
              shadows: const [
                Shadow(color: Colors.white, blurRadius: 1),
                Shadow(color: Colors.white, blurRadius: 1),
                Shadow(color: Colors.white, blurRadius: 1),
              ],
              // color: colorScheme.onPrimary,
            ),
          ),
        ),
      );
    } else {
      final toolIcon = switch (tool) {
        ToolType.frame => CupertinoIcons.grid,
        ToolType.rectangle => CupertinoIcons.square,
        ToolType.text => CupertinoIcons.textbox,
        _ => null,
      };

      child = Transform.rotate(
        angle: -pi / 5,
        alignment: const Alignment(-0.2, 0.3),
        child: Stack(
          children: [
            const Icon(
              Icons.navigation,
              size: 18,
              color: Colors.white,
              shadows: [
                Shadow(
                  blurRadius: 2,
                  color: Colors.black45,
                  offset: Offset(-.5, 0),
                ),
              ],
            ),
            Transform.translate(
              offset: const Offset(2, 2),
              child: const Icon(
                Icons.navigation,
                size: 14,
                color: Colors.black,
              ),
            ),
            if (toolIcon != null) ...[
              Transform.translate(
                offset: const Offset(4 - .5, 16 + .75),
                child: Transform.rotate(
                  angle: pi / 5,
                  child: Icon(toolIcon, size: 14, color: Colors.white),
                ),
              ),
              Transform.translate(
                offset: const Offset(4 + .75, 16 - .5),
                child: Transform.rotate(
                  angle: pi / 5,
                  child: Icon(toolIcon, size: 14, color: Colors.white),
                ),
              ),
              Transform.translate(
                offset: const Offset(4 + .75, 16 + .75),
                child: Transform.rotate(
                  angle: pi / 5,
                  child: Icon(toolIcon, size: 14, color: Colors.white),
                ),
              ),
              Transform.translate(
                offset: const Offset(4 - .5, 16 - .5),
                child: Transform.rotate(
                  angle: pi / 5,
                  child: Icon(toolIcon, size: 14, color: Colors.white),
                ),
              ),
              Transform.translate(
                offset: const Offset(4, 16),
                child: Transform.rotate(
                  angle: pi / 5,
                  child: Icon(
                    toolIcon,
                    size: 14,
                    color: Colors.black,
                    shadows: const [
                      Shadow(
                        blurRadius: 2,
                        color: Colors.black45,
                        offset: Offset(-.5, 0),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      );
    }

    return BlocBuilder<PointerCubit, Offset>(
      builder: (_, state) {
        return Transform.translate(
          offset: Offset(
                state.dx.truncateToDouble(),
                state.dy.truncateToDouble(),
              ) +
              const Offset(-4, -5),
          child: child,
        );
      },
    );
  }
}
