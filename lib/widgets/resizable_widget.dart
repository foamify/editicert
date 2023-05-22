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

  Rect get rect => Rect.fromLTWH(pos.dx, pos.dy, size.width, size.height);

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
  const ResizableWidget({
    super.key,
    required this.triangle,
    required this.keys,
  });

  final ValueNotifier<Triangle> triangle;
  final ValueNotifier<Set<PhysicalKeyboardKey>> keys;

  @override
  State<ResizableWidget> createState() => _ResizableWidgetState();
}

class _ResizableWidgetState extends State<ResizableWidget> {
  // ValueNotifier<Rect> get originalRect => widget.originalRect;
  //
  // ValueNotifier<Rect> get visualRect => widget.visualRect;
  //
  // ValueNotifier<Rect> get newRect => widget.newRect;

  ValueNotifier<Set<PhysicalKeyboardKey>> get keys => widget.keys;

  final ValueNotifier<Offset> originalPosition = ValueNotifier(Offset.zero);

  ValueNotifier<Triangle> get triangle => widget.triangle;

  final originalTriangle =
      ValueNotifier(Triangle(Offset.zero, Size.zero, 0, Offset.zero));

  @override
  Widget build(BuildContext context) {
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
            keys,
            triangle,
          ]),
          builder: (context, child) {
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
                        // flipX: flipValue.x,
                        // flipY: flipValue.y,
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
                  ...[
                    Alignment.topLeft,
                    Alignment.topRight,
                    Alignment.bottomLeft,
                    Alignment.bottomRight,
                  ].map(
                      (e) => buildControl(tValue, alignment: e, rotate: true)),
                  buildControl(tValue, move: true),
                  ...[
                    Alignment.topLeft,
                    Alignment.topRight,
                    Alignment.bottomLeft,
                    Alignment.bottomRight,
                  ].map(
                      (e) => buildControl(tValue, alignment: e, resize: true)),
                ],
              ),
            );
          }),
    );
  }

  Widget buildControl(
    Triangle tValue, {
    Alignment? alignment,
    bool move = false,
    bool rotate = false,
    bool resize = false,
  }) {
    final edges = tValue.edges;
    final rotatedEdges = tValue.rotatedEdges;

    final rotatedEdge = switch (alignment) {
      Alignment.topLeft => rotatedEdges.tl,
      Alignment.topRight => rotatedEdges.tr,
      Alignment.bottomLeft => rotatedEdges.bl,
      Alignment.bottomRight => rotatedEdges.br,
      //
      _
          when move =>
        rotatedEdges.tl,
      _ => Offset.zero,
    };

    final selectedEdge = switch (alignment) {
      Alignment.topLeft => edges.tl,
      Alignment.topRight => edges.tr,
      Alignment.bottomLeft => edges.bl,
      Alignment.bottomRight => edges.br,
      //
      _ => Offset.zero,
    };

    return Transform.translate(
      // this is for the whole widget
      offset: move ? edges.tl : rotatedEdge,
      child: Transform.translate(
        // this is for the widget inside the widget
        offset: move
            ? Offset.zero
            : -const Offset(gestureSize, gestureSize) / (rotate ? 1 : 2),
        child: Transform.rotate(
          angle: tValue.angle,
          child: Listener(
            onPointerDown: (event) {
              originalPosition.value = event.position;
              originalTriangle.value = triangle.value;
            },
            onPointerMove: (event) {
              if (resize && alignment != null) {
                handleResize(event, alignment, selectedEdge);
              } else if (move) {
                handleMove(event);
              } else if (rotate) {
                handleRotate(event);
              }
            },
            child: MouseRegion(
              cursor: move
                  ? SystemMouseCursors.move
                  : resize
                      ? SystemMouseCursors.precise
                      : SystemMouseCursors.grabbing,
              child: Container(
                width:
                    move ? tValue.size.width : gestureSize * (rotate ? 2 : 1),
                height:
                    move ? tValue.size.height : gestureSize * (rotate ? 2 : 1),
                color:
                    rotate ? Colors.blueAccent.withOpacity(.5) : Colors.white60,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void handleMove(PointerMoveEvent event) {
    final delta = event.position - originalPosition.value;
    triangle.value = originalTriangle.value.copyWith(
      pos: originalTriangle.value.pos + delta,
    );
  }

  void handleRotate(PointerMoveEvent event) {
    final center = originalTriangle.value.rect.center;
    final originalAngle = atan2(originalPosition.value.dx - center.dx,
        originalPosition.value.dy - center.dy);
    final newAngle =
        atan2(event.position.dx - center.dx, event.position.dy - center.dy);
    final deltaAngle = newAngle - originalAngle;
    triangle.value = originalTriangle.value
        .copyWith(angle: originalTriangle.value.angle - deltaAngle);
  }

  void handleResize(
      PointerMoveEvent event, Alignment alignment, Offset selectedEdge) {
    final tValue = originalTriangle.value;

    final rOriginalPoint = rotatePoint(
      originalPosition.value,
      selectedEdge + Offset(tValue.size.width, tValue.size.height) / 2,
      -tValue.angle,
    );

    final rPosition = rotatePoint(
      event.position,
      selectedEdge + Offset(tValue.size.width, tValue.size.height) / 2,
      -tValue.angle,
    );

    final delta = event.position - originalPosition.value;
    final rDelta = rPosition - rOriginalPoint;

    triangle.value = tValue.copyWith(
      pos: switch (alignment) {
        Alignment.topLeft => tValue.pos + delta / 2 + rDelta / 2,
        Alignment.topRight =>
          tValue.pos + Offset(delta.dx - rDelta.dx, delta.dy + rDelta.dy) / 2,
        Alignment.bottomLeft =>
          tValue.pos + Offset(delta.dx + rDelta.dx, delta.dy - rDelta.dy) / 2,
        Alignment.bottomRight => tValue.pos + delta / 2 - rDelta / 2,
        // never called
        _ => Offset.zero,
      },
      size: switch (alignment) {
        Alignment.topLeft => tValue.size + -rDelta,
        Alignment.topRight => tValue.size +
            Offset(
              rDelta.dx,
              -rDelta.dy,
            ),
        Alignment.bottomLeft => tValue.size +
            Offset(
              -rDelta.dx,
              rDelta.dy,
            ),
        Alignment.bottomRight => tValue.size + rDelta,
        // never called
        _ => Size.zero,
      },
    );
  }

  double snap(double value, int snapValue) =>
      keys.value.contains(PhysicalKeyboardKey.altLeft)
          ? (value / snapValue).truncateToDouble() * snapValue
          : (value / 0.1).truncateToDouble() * 0.1;
}
