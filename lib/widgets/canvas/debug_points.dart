part of '../../main.dart';

class DebugPoints extends StatelessWidget {
  const DebugPoints({super.key});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Watch.builder(
        builder: (_) {
          final state = debugPoints.value;
          return Stack(
            children: [
              for (var i = 0; i < state.length; i++)
                Positioned(
                  left: state.elementAtOrNull(i)!.x,
                  top: state.elementAtOrNull(i)!.y,
                  child: AnimatedSlide(
                    duration: Duration.zero,
                    offset: const Offset(-.5, -.5),
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: kColorList.elementAtOrNull(i)!.shade900,
                          strokeAlign: BorderSide.strokeAlignOutside,
                        ),
                        shape: BoxShape.circle,
                      ),
                      foregroundDecoration: BoxDecoration(
                        border: Border.all(
                          color: kColorList.elementAtOrNull(i)!.shade100,
                        ),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
