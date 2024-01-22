part of '../../main.dart';

/// The widget that handles create/updating the marquee selection.
class MarqueeWidget extends StatelessWidget {
  /// Creates a new widget that handles create/updating the marquee selection.
  const MarqueeWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Watch.builder(
      builder: (_) {
        final keys = canvasLogicalKeys();
        if (keys.contains(LogicalKeyboardKey.space)) {
          return const SizedBox.shrink();
        }
        return GestureDetector(
          supportedDevices: const {PointerDeviceKind.mouse},
          onPanStart: (details) {
            batch(() {
              canvasTransformInitial.value = canvasTransformCurrent()();
              pointerPositionInitial.value = details.globalPosition.toVector2();
              isMarquee.value = true;
            });
          },
          onPanUpdate: (details) {
            pointerPositionCurrent.value = details.globalPosition.toVector2();

            final initialPoint = pointerPositionInitial.peek();
            final currentPoint = pointerPositionCurrent.peek();

            final initialTransform = canvasTransformInitial.peek();
            if (initialTransform == null) return;
            final transform = canvasTransformCurrent.peek().peek();

            final delta = initialTransform.fromScene(Offset.zero) -
                transform.fromScene(Offset.zero);

            debugPoints.value = [
              initialTransform
                      .toScene(
                        initialTransform.fromScene(
                          initialPoint.toOffset() + delta,
                        ),
                      )
                      .toVector2() +
                  delta.toVector2(),
              currentPoint,
            ];
          },
          onPanEnd: (details) {
            batch(() {
              canvasTransformInitial.value = null;
              isMarquee.value = false;
              debugPoints.value = [];
            });
          },
        );
      },
    );
  }
}
