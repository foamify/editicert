import 'dart:math';

import 'package:editicert/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const rotation = pi / 4;

class ResizableWidget extends StatelessWidget {
  ResizableWidget({
    super.key,
    required this.originalRect,
    required this.visualRect,
    required this.newRect,
    required this.flip,
    required this.originalPosition,
  });

  final ValueNotifier<Rect> originalRect;
  final ValueNotifier<Rect> visualRect;
  final ValueNotifier<Rect> newRect;
  final ValueNotifier<({bool x, bool y})> flip;
  final keys = ValueNotifier<Set<PhysicalKeyboardKey>>({});
  final ValueNotifier<Offset> originalPosition;

  final edges = ValueNotifier((
    tl: Offset.zero + const Offset(200, 200),
    tr: const Offset(100, 0) + const Offset(200, 200),
    bl: const Offset(0, 100) + const Offset(200, 200),
    br: const Offset(100, 100) + const Offset(200, 200),
  ));

  final visualEdges = ValueNotifier((
    tl: Offset.zero + const Offset(200, 200),
    tr: const Offset(100, 0) + const Offset(200, 200),
    bl: const Offset(0, 100) + const Offset(200, 200),
    br: const Offset(100, 100) + const Offset(200, 200),
  ));

  final angle = ValueNotifier(0.0);

  final lock = ValueNotifier(Alignment.topLeft);

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation:
          Listenable.merge([flip, visualRect, keys, visualEdges, angle, lock]),
      builder: (context, child) {
        final edge = visualEdges.value;
        angle.value = atan2(edge.tr.dy - edge.tl.dy, edge.tr.dx - edge.tl.dx);
        final size =
            Size((edge.tl - edge.tr).distance, (edge.tl - edge.bl).distance);

        return Positioned(
          left: 0,
          top: 0,
          // left: -visualRect.value.width / 2,
          // top: -visualRect.value.height / 2,
          child: Transform.translate(
            offset: edge.tl + const Offset(-6, -6),
            child: RawKeyboardListener(
              focusNode: FocusNode(),
              autofocus: true,
              onKey: (value) => value.isKeyPressed(value.logicalKey)
                  ? keys.value.add(value.physicalKey)
                  : keys.value.remove(value.physicalKey),
              child: Transform.rotate(
                angle: angle.value,
                origin: -edge.tl + origin(edge, size, Alignment.topLeft),
                child: SizedBox.fromSize(
                  size: Size(size.width + 12, size.height + 12),
                  child: Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(6.0),
                        child: Column(
                          children: [
                            Expanded(
                              child: SizedBox.expand(
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    color: Colors.red,
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: SizedBox.expand(
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    color: Colors.blueAccent,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      ...[
                        Alignment.center,
                        Alignment.centerLeft,
                        Alignment.topCenter,
                        Alignment.centerRight,
                        Alignment.bottomCenter,
                        Alignment.topLeft,
                        Alignment.topRight,
                        Alignment.bottomLeft,
                        Alignment.bottomRight,
                      ].map(
                        (e) => buildResizer(edge, size, e),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Rect rectFromEdges(({Offset bl, Offset br, Offset tl, Offset tr}) edge) {
    final size =
        Size((edge.tl - edge.tr).distance, (edge.tl - edge.bl).distance);
    return Rect.fromLTWH(edge.tl.dx, edge.tl.dy, size.width, size.height);
  }

  Offset origin(({Offset bl, Offset br, Offset tl, Offset tr}) edge, Size size,
          Alignment alignment) =>
      edge.tl + Offset(size.width * alignment.x, size.width * alignment.y) / 2;

  Widget buildResizer(
    ({Offset bl, Offset br, Offset tl, Offset tr}) edge,
    Size size,
    Alignment alignment,
  ) {
    return Align(
      alignment: alignment,
      child: Listener(
        onPointerUp: (event) => edges.value = visualEdges.value,
        onPointerDown: (event) => originalPosition.value = event.position,
        onPointerMove: (event) {
          final delta = event.position - originalPosition.value;
          if (alignment == Alignment.center) {
            visualEdges.value = rotateRect(
                rectFromEdges(edges.value).shift(delta), 0, Offset.zero);
          } else {
            final pressedCmd =
                keys.value.contains(PhysicalKeyboardKey.metaLeft);
            final newEdges = (
              tl: edges.value.tl +
                  switch (alignment) {
                    Alignment.topLeft => delta,
                    _ => Offset.zero,
                  },
              tr: edges.value.tr +
                  switch (alignment) {
                    Alignment.topLeft => -delta.translate(
                        -delta.dx * (pressedCmd ? -1 : 1), -delta.dy * 2),
                    _ => Offset.zero,
                  },
              bl: edges.value.bl +
                  switch (alignment) {
                    Alignment.topLeft =>
                      delta.translate(0, -delta.dy * (pressedCmd ? 2 : 1)),
                    _ => Offset.zero,
                  },
              br: edges.value.br,
            );
            visualEdges.value = newEdges;
          }
        },
        child: MouseRegion(
          cursor: SystemMouseCursors.precise,
          child: Container(
            width: switch (alignment) {
              Alignment.center => size.width,
              _ => 12,
            },
            height: switch (alignment) {
              Alignment.center => size.height,
              _ => 12,
            },
            color: Colors.white,
          ),
        ),
      ),
    );
  }

//
// const gestureSize = 12.0;
//
// class ResizableWidget extends StatefulWidget {
//   const ResizableWidget(
//       {super.key,
//       required this.originalRect,
//       required this.visualRect,
//       required this.newRect,
//       required this.flip,
//       required this.keys,
//       required this.originalPosition});
//
//   final ValueNotifier<Rect> originalRect;
//   final ValueNotifier<Rect> visualRect;
//   final ValueNotifier<Rect> newRect;
//   final ValueNotifier<({bool x, bool y})> flip;
//   final ValueNotifier<Set<PhysicalKeyboardKey>> keys;
//   final ValueNotifier<Offset> originalPosition;
//
//   @override
//   State<ResizableWidget> createState() => _ResizableWidgetState();
// }
//
// class _ResizableWidgetState extends State<ResizableWidget> {
//   ValueNotifier<Rect> get originalRect => widget.originalRect;
//
//   ValueNotifier<Rect> get visualRect => widget.visualRect;
//
//   ValueNotifier<Rect> get newRect => widget.newRect;
//
//   ValueNotifier<({bool x, bool y})> get flip => widget.flip;
//
//   ValueNotifier<Set<PhysicalKeyboardKey>> get keys => widget.keys;
//
//   ValueNotifier<Offset> get originalPosition => widget.originalPosition;
//
//   final angle = ValueNotifier(0.0);
//
//   @override
//   Widget build(BuildContext context) {
//     angle.value = 0;
//
//     /// rect, but all values are positive numbers
//     final borderRadius = BorderRadius.circular(8);
//     return RawKeyboardListener(
//       focusNode: FocusNode(),
//       autofocus: true,
//       onKey: (value) => value.isKeyPressed(value.logicalKey)
//           ? keys.value.add(value.physicalKey)
//           : keys.value.remove(value.physicalKey),
//       child: AnimatedBuilder(
//           animation: Listenable.merge([flip, visualRect, keys]),
//           builder: (context, child) {
//             final flipValue = flip.value;
//             final rectValue = visualRect.value;
//             final newRectValue = visualRect.value
//                 .translate(-visualRect.value.left, -visualRect.value.top);
//             final keysValue = keys.value;
//             return SizedBox(
//               width: MediaQuery.of(context).size.width,
//               height: MediaQuery.of(context).size.height,
//               child: Stack(
//                 children: [
//                   Positioned(
//                     left: rectValue.left,
//                     top: rectValue.top,
//                     child: Transform.rotate(
//                       angle: angle.value,
//                       child: Transform.flip(
//                         flipX: flipValue.x,
//                         flipY: flipValue.y,
//                         child: Container(
//                           width: max(0, rectValue.width),
//                           height: max(0, rectValue.height),
//                           decoration: BoxDecoration(
//                             borderRadius: borderRadius,
//                             color: Colors.red,
//                           ),
//                           child: const Text('testfasd fa sdf'),
//                         ),
//                       ),
//                     ),
//                   ),
//                   // Positioned(
//                   //   left: rectValue.left,
//                   //   top: rectValue.top,
//                   //   child: Container(
//                   //     width: rectValue.width,
//                   //     height: rectValue.height,
//                   //     decoration:
//                   //         BoxDecoration(border: Border.all(color: Colors.white)),
//                   //   ),
//                   // ),
//                   Transform.translate(
//                     offset: Offset(rectValue.left - gestureSize / 2,
//                         rectValue.top - gestureSize / 2),
//                     child: Transform.rotate(
//                       angle: angle.value,
//                       child: Transform.flip(
//                         flipX: flipValue.x,
//                         flipY: flipValue.y,
//                         child: SizedBox(
//                           width: rectValue.width + gestureSize,
//                           height: rectValue.height + gestureSize,
//                           child: Stack(
//                             clipBehavior: Clip.none,
//                             children: [
//                               Alignment.center,
//                               Alignment.centerLeft,
//                               Alignment.topCenter,
//                               Alignment.centerRight,
//                               Alignment.bottomCenter,
//                               Alignment.topLeft,
//                               Alignment.topRight,
//                               Alignment.bottomLeft,
//                               Alignment.bottomRight,
//                             ]
//                                 .map((e) => buildResizer(flipValue,
//                                     newRectValue, gestureSize, keysValue, e))
//                                 .toList(),
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             );
//           }),
//     );
//   }

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
  //             _ when edge && fromRight => rectValue.width - gestureSize,
  //             _ when fromRight => rectValue.width - 1,
  //             _ => 0
  //           }
  //         : switch (alignment) {
  //             _ when !edge && fromRight => rectValue.width - 1,
  //             _ when !edge => 0,
  //             _ when fromRight => rectValue.width - gestureSize,
  //             _ => 0
  //           }),
  //     top: (!flipValue.y
  //         ? switch (alignment) {
  //             _ when edge && fromBottom => rectValue.height - gestureSize,
  //             _ when fromBottom => rectValue.height - 1,
  //             _ => 0
  //           }
  //         : switch (alignment) {
  //             _ when !edge && fromBottom => rectValue.height - 1,
  //             _ when !edge => 0,
  //             _ when fromBottom => rectValue.height - gestureSize,
  //             _ => 0
  //           }),
  //     child: Listener(
  //       onPointerDown: (event) {
  //         originalPosition.value = event.position;
  //       },
  //       onPointerUp: (event) {
  //         originalRect.value = visualRect.value;
  //       },
  //       onPointerMove: (event) {
  //         // handleMoveResize(
  //         //   direction: alignment,
  //         //   mousePosition: event.position,
  //         //   originalPosition: originalPosition.value,
  //         //   rotation: rotation,
  //         //   origin: Offset(
  //         //     rectValue.width,
  //         //     rectValue.height,
  //         //   ),
  //         // );
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
  //           // margin: edge ? null : EdgeInsets.all(gestureSize / 2),
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
  //   final vRect = visualRect.value;
  //   edges.value = rotateRect(vRect, rotation,
  //       vRect.topLeft + Offset(vRect.width / 2, vRect.height / 2));
  //   final deltas = (
  //     tl: vRect.topLeft - edges.value.$1,
  //     tr: vRect.topRight - edges.value.$2,
  //     bl: vRect.bottomLeft - edges.value.$3,
  //     br: vRect.bottomRight - edges.value.$4,
  //   );
  //
  //   [
  //     originalPosition,
  //     mousePosition,
  //     edges.value,
  //     vRect,
  //     deltas,
  //   ].forEach(print);
  //   print('');
  //
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
  //     final pressedCmd = keys.value.contains(PhysicalKeyboardKey.metaLeft);
  //     final delta = mousePosition - originalPosition;
  //     const snapValue = 20;
  //     final position = Offset(
  //       snap(mousePosition.dx, snapValue),
  //       snap(mousePosition.dy, snapValue),
  //     );
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
  //
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
  //   }
  //   // update visual rect with snapped values
  //   visualRect.value = Rect.fromLTRB(
  //     snap(
  //         newRect.value.left +
  //             (switch (direction) {
  //               Alignment.topLeft => deltas.tl,
  //               Alignment.bottomLeft => deltas.bl,
  //               _ => Offset.zero,
  //             })
  //                 .dx,
  //         10),
  //     snap(
  //         newRect.value.top +
  //             (switch (direction) {
  //               Alignment.topLeft => deltas.tl,
  //               Alignment.topRight => deltas.tr,
  //               _ => Offset.zero,
  //             })
  //                 .dy,
  //         10),
  //     snap(
  //         newRect.value.right +
  //             (switch (direction) {
  //               Alignment.topRight => deltas.tr,
  //               Alignment.bottomRight => deltas.br,
  //               _ => Offset.zero,
  //             })
  //                 .dx,
  //         10),
  //     snap(
  //         newRect.value.bottom +
  //             (switch (direction) {
  //               Alignment.bottomLeft => deltas.bl,
  //               Alignment.bottomRight => deltas.br,
  //               _ => Offset.zero,
  //             })
  //                 .dy,
  //         10),
  //   );
  // }

  double snap(double value, int snapValue) =>
      keys.value.contains(PhysicalKeyboardKey.altLeft)
          ? (value / snapValue).truncateToDouble() * snapValue
          : (value / 0.1).truncateToDouble() * 0.1;
}
