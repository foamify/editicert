part of '../../main.dart';

/// Paints the snap lines
class SnapLinePaint extends StatelessWidget {
  ///
  const SnapLinePaint({super.key});

  @override
  Widget build(BuildContext context) {
    return Watch.builder(
      builder: (_) {
        final lines = [...snapLines()];

        if (lines.isEmpty) {
          return const SizedBox();
        }

        final shortestLineX = lines.where((element) => element.isSnapX).fold(
              lines.firstOrNull!,
              (value, element) =>
                  value.length < element.length ? value : element,
            );

        final shortestLineY = lines.where((element) => element.isSnapY).fold(
              lines.firstOrNull!,
              (value, element) =>
                  value.length < element.length ? value : element,
            );

        final transform = canvasTransformCurrent()();
        return CustomPaint(
          painter: _SnapLinePainter([shortestLineX, shortestLineY], transform),
        );
      },
    );
  }
}

class _SnapLinePainter extends CustomPainter {
  const _SnapLinePainter(this.lines, this.transform);

  final List<SnapLine> lines;

  final Matrix4 transform;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.redAccent
      ..strokeWidth = .5;

    for (final line in lines) {
      canvas.drawLine(
        transform.fromScene(line.pos1.toOffset()),
        transform.fromScene(line.pos2.toOffset()),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
