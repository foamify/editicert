part of '../../main.dart';

/// The paint for the marquee.
class MarqueePaint extends StatelessWidget {
  /// The paint for the marquee.
  const MarqueePaint({super.key});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Watch.builder(
        builder: (_) {
          final marquee = marqueeRect();
          if (marquee == null) return const SizedBox.shrink();
          return Transform.translate(
            offset: marquee.topLeft,
            child: Container(
              width: marquee.width,
              height: marquee.height,
              decoration: BoxDecoration(
                color: Colors.blueAccent.withOpacity(.5),
                border: Border.all(
                  color: Color.alphaBlend(
                    Colors.blueAccent.withOpacity(.5),
                    Colors.blueAccent.withOpacity(.5),
                  ),
                  strokeAlign: BorderSide.strokeAlignOutside,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
