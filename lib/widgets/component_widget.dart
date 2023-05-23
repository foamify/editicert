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

  static fromEdges(
    ({Offset bl, Offset br, Offset tl, Offset tr}) edges, {
    bool flipX = false,
    bool flipY = false,
  }) {
    final size = Size(
      (edges.tl - edges.tr).distance * (flipX ? -1 : 1),
      (edges.tl - edges.bl).distance * (flipY ? -1 : 1),
    );
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
      angle + (flipX ? pi : 0),
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

class ComponentWidget extends StatelessWidget {
  ComponentWidget({
    super.key,
    required this.triangle,
    required this.keys,
  });

  final ValueNotifier<Triangle> triangle;
  final ValueNotifier<Set<PhysicalKeyboardKey>> keys;

  final ValueNotifier<Offset> originalPosition = ValueNotifier(Offset.zero);
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
                  // rotation controls
                  ...[
                    Alignment.topLeft,
                    Alignment.topRight,
                    Alignment.bottomLeft,
                    Alignment.bottomRight,
                  ].map((e) =>
                      buildEdgeControl(tValue, alignment: e, rotate: true)),

                  // content
                  Positioned(
                    left: tValue.pos.dx +
                        (tValue.size.width < 0 ? tValue.size.width : 0),
                    top: tValue.pos.dy +
                        (tValue.size.height < 0 ? tValue.size.height : 0),
                    child: Transform.rotate(
                      angle: tValue.angle,
                      child: Transform.flip(
                        flipX: tValue.size.width < 0,
                        flipY: tValue.size.height < 0,
                        child: Listener(
                          onPointerDown: handlePointerDown,
                          onPointerMove: handleMove,
                          child: Container(
                            width: tValue.size.width < 0
                                ? -tValue.size.width
                                : tValue.size.width,
                            height: tValue.size.height < 0
                                ? -tValue.size.height
                                : tValue.size.height,
                            decoration: BoxDecoration(
                              borderRadius: borderRadius,
                              color: Colors.red,
                            ),
                            child: const Text('testfasd fa sdf'),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // side resize controls
                  ...[
                    Alignment.topCenter,
                    Alignment.bottomCenter,
                    Alignment.centerLeft,
                    Alignment.centerRight,
                  ].map((e) => buildResizer(
                        tValue,
                        alignment: e,
                      )),

                  // edge resize controls
                  ...[
                    Alignment.topLeft,
                    Alignment.topRight,
                    Alignment.bottomLeft,
                    Alignment.bottomRight,
                  ].map((e) =>
                      buildEdgeControl(tValue, alignment: e, resize: true)),
                ],
              ),
            );
          }),
    );
  }

  Widget buildResizer(
    Triangle tValue, {
    required Alignment alignment,
  }) {
    final edges = tValue.edges;
    final rotatedEdges = tValue.rotatedEdges;
    final width = switch (alignment) {
      Alignment.topCenter ||
      Alignment.bottomCenter when tValue.size.width < 0 =>
        -tValue.size.width,
      Alignment.topCenter || Alignment.bottomCenter => tValue.size.width,
      _ => gestureSize,
    };
    final height = switch (alignment) {
      Alignment.centerLeft ||
      Alignment.centerRight when tValue.size.height < 0 =>
        -tValue.size.height,
      Alignment.centerLeft || Alignment.centerRight => tValue.size.height,
      _ => gestureSize,
    };

    final offset = switch (alignment) {
      Alignment.topCenter when tValue.size.width < 0 =>
        Offset(-width, -gestureSize / 2),
      Alignment.topCenter => const Offset(0, -gestureSize / 2),
      Alignment.centerLeft when tValue.size.height < 0 =>
        Offset(-gestureSize / 2, tValue.size.height),
      Alignment.centerLeft => const Offset(-gestureSize / 2, 0),
      Alignment.bottomCenter when tValue.size.width < 0 =>
        Offset(-width, tValue.size.height - gestureSize / 2),
      Alignment.bottomCenter => Offset(0, tValue.size.height - gestureSize / 2),
      Alignment.centerRight when tValue.size.height < 0 =>
        Offset(tValue.size.width - gestureSize / 2, tValue.size.height),
      Alignment.centerRight => Offset(tValue.size.width - gestureSize / 2, 0),
      _ => Offset.zero,
    };

    final selectedSide = switch (alignment) {
      Alignment.topCenter => edges.tl,
      Alignment.centerLeft => edges.tl,
      Alignment.bottomCenter => edges.br,
      Alignment.centerRight => edges.br,
      _ => Offset.zero,
    };

    return Transform.translate(
        // this is for the whole widget
        offset: rotatedEdges.tl,
        child: Transform.rotate(
          angle: tValue.angle,
          origin: -Offset(width, height) / 2,
          child: Transform.translate(
            offset: offset,
            child: Listener(
              onPointerDown: handlePointerDown,
              onPointerMove: (event) {
                handleResizeSide(event, alignment, selectedSide);
              },
              child: MouseRegion(
                cursor: SystemMouseCursors.grab,
                child: Container(
                  width: width,
                  height: height,
                  color: Colors.green.withOpacity(.5),
                ),
              ),
            ),
          ),
        ));
  }

  void handlePointerDown(event) {
    originalPosition.value = event.position;
    originalTriangle.value = triangle.value;
  }

  Widget buildEdgeControl(
    Triangle tValue, {
    Alignment? alignment,
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
      Alignment.topCenter => rotatedEdges.tl,
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
      offset: rotatedEdge,
      child: Transform.translate(
        // this is for the widget inside the widget
        offset: -const Offset(gestureSize, gestureSize) / (rotate ? 1 : 2),
        child: Transform.rotate(
          angle: tValue.angle,
          child: Transform.translate(
            offset: Offset.zero,
            child: Listener(
              onPointerDown: handlePointerDown,
              onPointerMove: (event) {
                if (resize && alignment != null) {
                  handleResizeEdges(event, alignment, selectedEdge);
                } else if (rotate) {
                  handleRotate(event);
                }
              },
              child: MouseRegion(
                cursor: resize
                    ? SystemMouseCursors.precise
                    : SystemMouseCursors.grabbing,
                child: Container(
                  width: alignment == Alignment.topCenter ||
                          alignment == Alignment.bottomCenter
                      ? triangle.value.size.width
                      : gestureSize * (rotate ? 2 : 1),
                  height: gestureSize * (rotate ? 2 : 1),
                  color: rotate
                      ? Colors.blueAccent.withOpacity(.5)
                      : Colors.white60,
                ),
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

  void handleResizeSide(
      PointerMoveEvent event, Alignment alignment, Offset selectedSide) {
    final tValue = originalTriangle.value;
    final edges = tValue.edges;
    final rEdges = tValue.rotatedEdges;

    final rOriginalPoint = rotatePoint(
      originalPosition.value,
      selectedSide + Offset(tValue.size.width, tValue.size.height) / 2,
      -tValue.angle,
    );

    final rPosition = rotatePoint(
      event.position,
      selectedSide + Offset(tValue.size.width, tValue.size.height) / 2,
      -tValue.angle,
    );

    final rect = tValue.rect;
    final oEdges = rotateRect(rect, 0, tValue.pos);

    final rDelta = rPosition - rOriginalPoint;

    final deltaTop = switch (alignment) {
      Alignment.topCenter => Offset(0, rDelta.dy),
      _ => Offset.zero,
    };

    final deltaBottom = switch (alignment) {
      Alignment.bottomCenter => Offset(0, rDelta.dy),
      _ => Offset.zero,
    };

    final deltaLeft = switch (alignment) {
      Alignment.centerLeft => Offset(rDelta.dx, 0),
      _ => Offset.zero,
    };

    final deltaRight = switch (alignment) {
      Alignment.centerRight => Offset(rDelta.dx, 0),
      _ => Offset.zero,
    };

    var newEdges = (
      tl: oEdges.tl + deltaTop + deltaLeft,
      tr: oEdges.tr + deltaTop + deltaRight,
      bl: oEdges.bl + deltaBottom + deltaLeft,
      br: Offset.zero
    );
    final newRect = rectFromEdges(newEdges);
    final newEdgesR = rotateRect(
        newRect,
        tValue.angle,
        tValue.pos.translate(
            switch (alignment) {
              Alignment.centerLeft => rDelta.dx / 2,
              Alignment.centerRight => -rDelta.dx / 2,
              _ => 0,
            },
            switch (alignment) {
              Alignment.topCenter => rDelta.dy / 2,
              Alignment.bottomCenter => -rDelta.dy / 2,
              _ => 0,
            }));

    print(newRect.size);

    triangle.value = Triangle.fromEdges(
      newEdgesR,
      flipX: newRect.size.width < 0,
      flipY: newRect.size.height > 0,
    );
  }

  void handleResizeEdges(
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
