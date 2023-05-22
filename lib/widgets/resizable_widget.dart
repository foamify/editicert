import 'dart:math';

import 'package:editicert/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const gestureSize = 12.0;

class Triangle {
  Offset pos;
  Size size;
  double angle;
  Offset origin;

  Triangle(this.pos, this.size, this.angle, this.origin);

  get rect => Rect.fromLTWH(pos.dx, pos.dy, size.width, size.height);

  ({Offset bl, Offset br, Offset tl, Offset tr}) get rotatedEdges => rotateRect(
        rect,
        angle,
        pos + Offset(size.width / 2, size.height / 2),
      );

  ({Offset bl, Offset br, Offset tl, Offset tr}) get edges => rotateRect(
        rect,
        angle,
        pos
        // + origin
        ,
      );

  static fromRotatedEdges(
      ({Offset bl, Offset br, Offset tl, Offset tr}) rotatedEdges) {
    final size = Size((rotatedEdges.tl - rotatedEdges.tr).distance,
        (rotatedEdges.tl - rotatedEdges.bl).distance);
    final angle = atan2(rotatedEdges.tr.dy - rotatedEdges.tl.dy,
        rotatedEdges.tr.dx - rotatedEdges.tl.dx);

    // the center point between 4 Offsets
    final center = Offset(
          rotatedEdges.tl.dx +
              rotatedEdges.tr.dx +
              rotatedEdges.bl.dx +
              rotatedEdges.br.dx,
          rotatedEdges.tl.dy +
              rotatedEdges.tr.dy +
              rotatedEdges.bl.dy +
              rotatedEdges.br.dy,
        ) /
        4;

    final edges = rotateRect(
        Rect.fromLTWH(
            rotatedEdges.tl.dx, rotatedEdges.tl.dy, size.width, size.height),
        0,
        center + Offset(size.width, size.height) / 2);

    final rect = Rect.fromLTWH(
      edges.tl.dx,
      edges.tl.dy,
      size.width,
      size.height,
    );
    // final origin = -Offset(size.width, size.height) / 2;
    const origin = Offset.zero;
    final newTriangle = Triangle(
      edges.tl,
      size,
      angle,
      origin,
    );
    return newTriangle;
  }

  static fromEdges(({Offset bl, Offset br, Offset tl, Offset tr}) edges) {
    final size =
        Size((edges.tl - edges.tr).distance, (edges.tl - edges.bl).distance);
    final angle = atan2(edges.tr.dy - edges.tl.dy, edges.tr.dx - edges.tl.dx);

    final newEdges = rotateRect(
        Rect.fromLTWH(edges.tl.dx, edges.tl.dy, size.width, size.height),
        0,
        Offset.zero);

    // final origin = -Offset(size.width, size.height) / 2;
    const origin = Offset.zero;
    final newTriangle = Triangle(
      newEdges.tl,
      size,
      angle,
      origin,
    );
    return newTriangle;
  }

  copyWith({Offset? pos, Size? size, double? angle, Offset? origin}) {
    return Triangle(pos ?? this.pos, size ?? this.size, angle ?? this.angle,
        origin ?? this.origin);
  }

  @override
  String toString() {
    return 'Triangle{pos: $pos, size: $size, angle: $angle, origin: $origin}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Triangle &&
          runtimeType == other.runtimeType &&
          pos == other.pos &&
          size == other.size &&
          angle == other.angle &&
          origin == other.origin;

  @override
  int get hashCode =>
      pos.hashCode ^ size.hashCode ^ angle.hashCode ^ origin.hashCode;
}

class ResizableWidget extends StatefulWidget {
  const ResizableWidget(
      {super.key,
      required this.originalRect,
      required this.visualRect,
      required this.newRect,
      required this.flip,
      required this.keys,
      required this.originalPosition});

  final ValueNotifier<Rect> originalRect;
  final ValueNotifier<Rect> visualRect;
  final ValueNotifier<Rect> newRect;
  final ValueNotifier<({bool x, bool y})> flip;
  final ValueNotifier<Set<PhysicalKeyboardKey>> keys;
  final ValueNotifier<Offset> originalPosition;

  @override
  State<ResizableWidget> createState() => _ResizableWidgetState();
}

class _ResizableWidgetState extends State<ResizableWidget> {
  // ValueNotifier<Rect> get originalRect => widget.originalRect;
  //
  // ValueNotifier<Rect> get visualRect => widget.visualRect;
  //
  // ValueNotifier<Rect> get newRect => widget.newRect;

  ValueNotifier<({bool x, bool y})> get flip => widget.flip;

  ValueNotifier<Set<PhysicalKeyboardKey>> get keys => widget.keys;

  ValueNotifier<Offset> get originalPosition => widget.originalPosition;

  final ValueNotifier<Triangle> triangle = ValueNotifier(Triangle(
    const Offset(0, 0),
    const Size(200, 200),
    pi / 2,
    const Offset(0, 0),
  ));

  final originalTriangle =
      ValueNotifier(Triangle(Offset.zero, Size.zero, 0, Offset.zero));

  @override
  Widget build(BuildContext context) {
    final newTriangle = Triangle(
      const Offset(100, 100),
      const Size(200, 200),
      pi / 4,
      // 0,
      const Offset(100, 100),
    );
    triangle.value = Triangle.fromEdges(
      newTriangle.edges,
    );

    /// rect, but all values are positive numbers
    final borderRadius = BorderRadius.circular(8);
    return RawKeyboardListener(
      focusNode: FocusNode(),
      autofocus: true,
      onKey: (value) => value.isKeyPressed(value.logicalKey)
          ? keys.value.add(value.physicalKey)
          : keys.value.remove(value.physicalKey),
      child: AnimatedBuilder(
          animation: Listenable.merge([
            flip,
            // visualRect,
            keys,
            triangle,
            // angle,
          ]),
          builder: (context, child) {
            final flipValue = flip.value;
            final tValue = triangle.value;
            final keysValue = keys.value;
            return SizedBox(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: Stack(
                children: [
                  Positioned(
                    left: tValue.pos.dx,
                    top: tValue.pos.dy,
                    child: Transform.rotate(
                      angle: tValue.angle,
                      child: Transform.flip(
                        flipX: flipValue.x,
                        flipY: flipValue.y,
                        child: Container(
                          width: max(0, tValue.size.width),
                          height: max(0, tValue.size.height),
                          decoration: BoxDecoration(
                            borderRadius: borderRadius,
                            color: Colors.red,
                          ),
                          child: const Text('testfasd fa sdf'),
                        ),
                      ),
                    ),
                  ),
                  Transform.translate(
                    offset: tValue.rotatedEdges.tl,
                    child: Transform.translate(
                      offset: -const Offset(gestureSize, gestureSize) / 2,
                      child: Transform.rotate(
                        angle: tValue.angle,
                        child: Listener(
                          onPointerDown: (event) {
                            originalPosition.value = event.position;
                            originalTriangle.value = triangle.value;
                          },
                          onPointerMove: (event) {
                            final tValue = originalTriangle.value;
                            final edges = tValue.edges;

                            final rOriginalPoint = rotatePoint(
                              originalPosition.value,
                              edges.tl +
                                  Offset(tValue.size.width,
                                          tValue.size.height) /
                                      2,
                              -tValue.angle,
                            );

                            final rPosition = rotatePoint(
                              event.position,
                              edges.tl +
                                  Offset(tValue.size.width,
                                          tValue.size.height) /
                                      2,
                              -tValue.angle,
                            );

                            final delta =
                                event.position - originalPosition.value;
                            final rDelta = rPosition - rOriginalPoint;

                            triangle.value = tValue.copyWith(
                                pos: tValue.pos + delta / 2 + rDelta / 2,
                                size: tValue.size + -rDelta);
                          },
                          child: MouseRegion(
                            cursor: SystemMouseCursors.precise,
                            child: Container(
                              width: gestureSize,
                              height: gestureSize,
                              color: Colors.white60,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
    );
  }

  double snap(double value, int snapValue) =>
      keys.value.contains(PhysicalKeyboardKey.altLeft)
          ? (value / snapValue).truncateToDouble() * snapValue
          : (value / 0.1).truncateToDouble() * 0.1;
}
