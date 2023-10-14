part of '../main.dart';

class CustomCursorWidget extends StatelessWidget {
  const CustomCursorWidget({
    super.key,
    required this.isToolHand,
    required this.isNotCanvasTooling,
    required this.isCanvasTooling,
  });

  final bool isToolHand;
  final bool isNotCanvasTooling;
  final bool isCanvasTooling;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        componentsNotifier.state,
        selectedNotifier.state,
      ]),
      builder: (context2, _) {
        var canvasEvents = context2.watch<CanvasEventsCubit>();
        final stateContains = canvasEvents.state.contains;

        final tool = context.watch<ToolCubit>().state;
        if ((stateContains(CanvasEvent.normalCursor) ||
            tool != ToolType.move)) {
          print('normalcursor');
          return const SizedBox.shrink();
        }

        // final enabled = stateContainsAny({
        //   CanvasEvent.rotatingComponent,
        //   CanvasEvent.resizingComponent,
        // });

        var angle = 0.0;
        if (selectedNotifier.state.value.isNotEmpty) {
          // ignore: avoid-unsafe-collection-methods
          angle = componentsNotifier
              .state
              // ignore: avoid-unsafe-collection-methods
              .value[selectedNotifier.state.value.first]
              .component
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
        for (var MapEntry(:key, :value) in alignments.entries) {
          if (context2.read<CanvasEventsCubit>().state.contains(value)) {
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

        Widget child = const SizedBox.shrink();

        if (tool == ToolType.text) {
          child = const Icon(
            Icons.abc,
            size: 18,
            color: Colors.red,
            shadows: [
              Shadow(
                blurRadius: 2,
                color: Colors.black45,
                offset: Offset(-.5, 0),
              ),
            ],
          );
        } else if (alignment != null) {
          final rotations = {
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
              ],
            ),
          );
        }

        return BlocBuilder<PointerCubit, Offset>(
          builder: (_, state) {
            return Transform.translate(
              offset: state + const Offset(-4, -5),
              child: child,
            );
          },
        );
      },
    );
  }
}
