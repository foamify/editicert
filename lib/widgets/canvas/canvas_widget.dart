part of '../../main.dart';

/// Tha canvas controller and background.
class CanvasWidget extends StatelessWidget {
  /// Tha canvas controller and background.
  ///
  /// [keyboardFocus] is the focus node for the keyboard.
  const CanvasWidget({required FocusNode keyboardFocus, super.key})
      : _keyboardFocus = keyboardFocus;

  final FocusNode _keyboardFocus;

  @override
  Widget build(BuildContext context) {
    return TransparentPointer(
      child: Listener(
        onPointerDown: (event) {
          _keyboardFocus.requestFocus();
          pointerButton.value = event.buttons;
        },
        onPointerUp: (event) {
          pointerButton.value = event.buttons;
        },
        child: MouseRegion(
          child: Watch.builder(
            builder: (cubitContext) {
              final _ = canvasTransformCurrent.value;
              return CanvasInteractiveViewer.builder(
                minScale: .01,
                boundaryMargin: const EdgeInsets.all(double.infinity),
                clipBehavior: Clip.none,
                // scaleEnabled: false,
                transformationController: canvasTransformController(),
                // onInteractionStart: (details) {
                //   final button =
                //       context.read<PointersCubit>().state;
                //   if (button != PointerButton.middle &&
                //       button != null) {
                //     return;
                //   }
                //   context
                //       .read<EventHandlerBloc>()
                //       .add(PanCanvasInitial());
                // },
                // onInteractionUpdate: (details) {
                //   final button =
                //       context.read<PointersCubit>().state;
                //   if (button != PointerButton.middle &&
                //       button != null) {
                //     return;
                //   }
                //   final eventHandlerBloc =
                //       context.read<EventHandlerBloc>();
                //   if (details.focalPointDelta != Offset.zero) {
                //     eventHandlerBloc.add(
                //       PanCanvasEvent(details.focalPointDelta),
                //     );
                //   } else if (details.scale != 0) {
                //     print(details.)
                //     print('Scale: ${details.scale}');
                //     eventHandlerBloc.add(
                //       ZoomCanvasEvent(
                //         details.scale,
                //         details.focalPoint,
                //       ),
                //     );
                //   }
                // },
                // onInteractionEnd: (details) {
                //   context
                //       .read<EventHandlerBloc>()
                //       .add(PanCanvasEnd());
                // },
                builder: (iVContext, viewport) {
                  return Container(
                    width: 200,
                    height: 200,
                    color: Colors.red,
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
