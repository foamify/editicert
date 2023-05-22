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
                            final delta =
                                event.position - originalPosition.value;

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

                  // Positioned(
                  //   left: rectValue.left,
                  //   top: rectValue.top,
                  //   child: Container(
                  //     width: rectValue.width,
                  //     height: rectValue.height,
                  //     decoration:
                  //         BoxDecoration(border: Border.all(color: Colors.white)),
                  //   ),
                  // ),
                  /// Rotater

                  // Transform.translate(
                  //   offset: rotateRect(rectValue.inflate(gestureSize / 2),
                  //           angle.value, rectValue.center)
                  //       .tr,
                  //   child: Transform.rotate(
                  //     angle: angle.value,
                  //     origin: const Offset(-gestureSize, -gestureSize),
                  //     child: Transform.translate(
                  //       offset: const Offset(-gestureSize, -gestureSize),
                  //       child: Listener(
                  //         onPointerMove: (event) {
                  //           final newAngle = atan2(
                  //                   event.position.dy - rectValue.center.dy,
                  //                   event.position.dx - rectValue.center.dx) +
                  //               pi / 3;
                  //           print(newAngle / pi * 180);
                  //           angle.value = newAngle;
                  //         },
                  //         child: MouseRegion(
                  //           cursor: SystemMouseCursors.grabbing,
                  //           child: Container(
                  //             width: gestureSize * 2,
                  //             height: gestureSize * 2,
                  //             color: Colors.blueAccent,
                  //           ),
                  //         ),
                  //       ),
                  //     ),
                  //   ),
                  // ),

                  /// Resizer
                  // Transform.translate(
                  //   offset: Offset(rectValue.left - gestureSize / 2,
                  //       rectValue.top - gestureSize / 2),
                  //   child: Transform.flip(
                  //     flipX: flipValue.x,
                  //     flipY: flipValue.y,
                  //     child: Transform.rotate(
                  //       angle: angle.value *
                  //           (!(flipValue.x && flipValue.y) &&
                  //                   (flipValue.y || flipValue.x)
                  //               ? -1
                  //               : 1),
                  //       child: SizedBox(
                  //         width: rectValue.width + gestureSize,
                  //         height: rectValue.height + gestureSize,
                  //         child: Stack(
                  //           clipBehavior: Clip.none,
                  //           children: [
                  //             Alignment.center,
                  //             Alignment.centerLeft,
                  //             Alignment.topCenter,
                  //             Alignment.centerRight,
                  //             Alignment.bottomCenter,
                  //             Alignment.topLeft,
                  //             Alignment.topRight,
                  //             Alignment.bottomLeft,
                  //             Alignment.bottomRight,
                  //           ]
                  //               .map((e) => buildResizer(flipValue,
                  //                   newRectValue, gestureSize, keysValue, e))
                  //               .toList(),
                  //         ),
                  //       ),
                  //     ),
                  //   ),
                  // ),
                ],
              ),
            );
          }),
    );
  }

  // Widget buildResizer(
  //   ({bool x, bool y}) flipValue,
  //   Rect rectValue,
  //   double gestureSize,
  //   Set<PhysicalKeyboardKey> keys,
  //   AlignmentGeometry alignment,
  // ) {
  //   final fromLeft = alignment == Alignment.centerLeft ||
  //       alignment == Alignment.topLeft ||
  //       alignment == Alignment.bottomLeft;
  //   final fromRight = alignment == Alignment.centerRight ||
  //       alignment == Alignment.topRight ||
  //       alignment == Alignment.bottomRight;
  //   final fromTop = alignment == Alignment.topLeft ||
  //       alignment == Alignment.topCenter ||
  //       alignment == Alignment.topRight;
  //   final fromBottom = alignment == Alignment.bottomLeft ||
  //       alignment == Alignment.bottomCenter ||
  //       alignment == Alignment.bottomRight;
  //   final edge = alignment == Alignment.topLeft ||
  //       alignment == Alignment.topRight ||
  //       alignment == Alignment.bottomLeft ||
  //       alignment == Alignment.bottomRight;
  //   return Positioned(
  //     left: (!flipValue.x
  //         ? switch (alignment) {
  //             _ when fromRight => rectValue.right - 1,
  //             _ => rectValue.left
  //           }
  //         : switch (alignment) {
  //             _ when !edge && fromRight => rectValue.right - 1,
  //             _ when !edge => rectValue.left,
  //             _ when fromRight => rectValue.right,
  //             _ => rectValue.left
  //           }),
  //     top: (!flipValue.y
  //         ? switch (alignment) {
  //             _ when fromBottom => rectValue.bottom - 1,
  //             _ => rectValue.top
  //           }
  //         : switch (alignment) {
  //             _ when !edge && fromBottom => rectValue.bottom - 1,
  //             _ when !edge => rectValue.top,
  //             _ when fromBottom => rectValue.top,
  //             _ => rectValue.bottom
  //           }),
  //     child: Listener(
  //       onPointerDown: (event) {
  //         originalPosition.value = event.position;
  //       },
  //       onPointerUp: (event) {
  //         originalRect.value = visualRect.value;
  //       },
  //       onPointerMove: (event) {
  //         handleMoveResize(
  //           direction: alignment,
  //           mousePosition: event.position,
  //           originalPosition: originalPosition.value,
  //           rotation: angle.value,
  //           origin: Offset.zero,
  //         );
  //       },
  //       child: MouseRegion(
  //         cursor: edge
  //             ? SystemMouseCursors.precise
  //             : switch ((fromLeft || fromRight, fromTop || fromBottom)) {
  //                 (true, false) => SystemMouseCursors.resizeLeftRight,
  //                 (false, true) => SystemMouseCursors.resizeUpDown,
  //                 _ => SystemMouseCursors.grab
  //               },
  //         child: Container(
  //           margin: edge ? null : EdgeInsets.all(gestureSize / 2),
  //           color: alignment == Alignment.center
  //               ? Colors.blueAccent.withOpacity(.25)
  //               : Colors.white30,
  //           width: switch (alignment) {
  //             Alignment.topCenter ||
  //             Alignment.bottomCenter ||
  //             Alignment.center =>
  //               max(0, rectValue.width),
  //             Alignment.centerLeft || Alignment.centerRight => 1,
  //             _ when edge => gestureSize,
  //             _ => 0,
  //           },
  //           height: switch (alignment) {
  //             Alignment.centerLeft ||
  //             Alignment.centerRight ||
  //             Alignment.center =>
  //               max(0, rectValue.height),
  //             Alignment.topCenter || Alignment.bottomCenter => 1,
  //             _ when edge => gestureSize,
  //             _ => 0,
  //           },
  //         ),
  //       ),
  //     ),
  //   );
  // }

  // void handleMoveResize({
  //   required Offset originalPosition,
  //   required Offset mousePosition,
  //   required AlignmentGeometry direction,
  //   required Offset origin,
  //   required double rotation,
  // }) {
  //   final delta = mousePosition - originalPosition;
  //   final rect = originalRect.value;
  //   // handle move
  //   if (direction == Alignment.center) {
  //     newRect.value = Rect.fromLTRB(
  //       rect.left + delta.dx,
  //       rect.top + delta.dy,
  //       rect.right + delta.dx,
  //       rect.bottom + delta.dy,
  //     );
  //   } else {
  //     // handle resize
  //
  //     final fromLeft = direction == Alignment.centerLeft ||
  //         direction == Alignment.topLeft ||
  //         direction == Alignment.bottomLeft;
  //     final fromRight = direction == Alignment.centerRight ||
  //         direction == Alignment.topRight ||
  //         direction == Alignment.bottomRight;
  //     final fromTop = direction == Alignment.topLeft ||
  //         direction == Alignment.topCenter ||
  //         direction == Alignment.topRight;
  //     final fromBottom = direction == Alignment.bottomLeft ||
  //         direction == Alignment.bottomCenter ||
  //         direction == Alignment.bottomRight;
  //     final edge = direction == Alignment.topLeft ||
  //         direction == Alignment.topRight ||
  //         direction == Alignment.bottomLeft ||
  //         direction == Alignment.bottomRight;
  //     final pressedCmd = keys.value.contains(PhysicalKeyboardKey.metaLeft);
  //     final delta = mousePosition - originalPosition;
  //     const snapValue = 20;
  //     final position = Offset(
  //       snap(mousePosition.dx, snapValue),
  //       snap(mousePosition.dy, snapValue),
  //     );
  //     final rect = originalRect.value;
  //     newRect.value = edge
  //         ? Rect.fromPoints(
  //             position,
  //             switch ((fromRight, fromBottom)) {
  //                   (false, false) => rect.bottomRight,
  //                   (true, false) => rect.bottomLeft,
  //                   (false, true) => rect.topRight,
  //                   (true, true) => rect.topLeft
  //                 } -
  //                 (pressedCmd ? delta : Offset.zero),
  //           )
  //         : Rect.fromPoints(
  //             Offset(
  //                 switch ((fromLeft, fromRight)) {
  //                   (true, false) => position.dx,
  //                   (false, true) => position.dx,
  //                   _ => rect.right,
  //                 },
  //                 switch ((fromTop, fromBottom)) {
  //                   (true, false) => position.dy,
  //                   (false, true) => position.dy,
  //                   _ => rect.top,
  //                 }),
  //             switch ((fromRight, fromBottom)) {
  //                   (false, false) => rect.bottomRight,
  //                   (true, false) => rect.bottomLeft,
  //                   (false, true) => rect.topRight,
  //                   (true, true) => rect.topLeft
  //                 } -
  //                 (pressedCmd
  //                     ? Offset(
  //                         switch ((fromLeft, fromRight)) {
  //                           (true, false) => delta.dx,
  //                           (false, true) => delta.dx,
  //                           _ => 0
  //                         },
  //                         switch ((fromTop, fromBottom)) {
  //                           (true, false) => delta.dy,
  //                           (false, true) => delta.dy,
  //                           _ => 0
  //                         },
  //                       )
  //                     : Offset.zero),
  //           );
  //     flip.value = (
  //       x: switch ((x: flip.value.x, fromRight: fromRight)) {
  //         (x: false, fromRight: false)
  //             when position.dx > visualRect.value.right =>
  //           true,
  //         (x: false, fromRight: true)
  //             when position.dx < visualRect.value.left =>
  //           true,
  //         (x: true, fromRight: false)
  //             when position.dx < visualRect.value.left =>
  //           false,
  //         (x: true, fromRight: true)
  //             when position.dx > visualRect.value.right =>
  //           false,
  //         _ => flip.value.x // should never be used
  //       },
  //       y: switch ((y: flip.value.y, fromBottom: fromBottom)) {
  //         (y: false, fromBottom: false)
  //             when position.dy > visualRect.value.bottom =>
  //           true,
  //         (y: false, fromBottom: true)
  //             when position.dy < visualRect.value.top =>
  //           true,
  //         (y: true, fromBottom: false)
  //             when position.dy < visualRect.value.top =>
  //           false,
  //         (y: true, fromBottom: true)
  //             when position.dy > visualRect.value.bottom =>
  //           false,
  //         _ => flip.value.y // should never be used
  //       }
  //     );
  //   }
  //   // update visual rect with snapped values
  //   visualRect.value = Rect.fromLTRB(
  //     snap(newRect.value.left, 10),
  //     snap(newRect.value.top, 10),
  //     snap(newRect.value.right, 10),
  //     snap(newRect.value.bottom, 10),
  //   );
  // }

  double snap(double value, int snapValue) =>
      keys.value.contains(PhysicalKeyboardKey.altLeft)
          ? (value / snapValue).truncateToDouble() * snapValue
          : (value / 0.1).truncateToDouble() * 0.1;
}
