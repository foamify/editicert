import 'dart:math';

import 'package:editicert/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ResizableWidget extends StatefulWidget {
  const ResizableWidget({super.key,
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
  ValueNotifier<Rect> get originalRect => widget.originalRect;

  ValueNotifier<Rect> get visualRect => widget.visualRect;

  ValueNotifier<Rect> get newRect => widget.newRect;

  ValueNotifier<({bool x, bool y})> get flip => widget.flip;

  ValueNotifier<Set<PhysicalKeyboardKey>> get keys => widget.keys;

  ValueNotifier<Offset> get originalPosition => widget.originalPosition;

  final angle = ValueNotifier(0.0);

  @override
  Widget build(BuildContext context) {
    angle.value =;

    /// rect, but all values are positive numbers
    final borderRadius = BorderRadius.circular(8);
    const gestureSize = 12.0;
    return RawKeyboardListener(
      focusNode: FocusNode(),
      autofocus: true,
      onKey: (value) =>
      value.isKeyPressed(value.logicalKey)
          ? keys.value.add(value.physicalKey)
          : keys.value.remove(value.physicalKey),
      child: AnimatedBuilder(
          animation: Listenable.merge([flip, visualRect, keys]),
          builder: (context, child) {
            final flipValue = flip.value;
            final rectValue = visualRect.value;
            final newRectValue = visualRect.value
                .translate(-visualRect.value.left, -visualRect.value.top);
            final keysValue = keys.value;
            return SizedBox(
              width: MediaQuery
                  .of(context)
                  .size
                  .width,
              height: MediaQuery
                  .of(context)
                  .size
                  .height,
              child: Stack(
                children: [
                  Positioned(
                    left: rectValue.left,
                    top: rectValue.top,
                    child: Transform.rotate(
                      angle: angle.value,
                      child: Transform.flip(
                        flipX: flipValue.x,
                        flipY: flipValue.y,
                        child: Container(
                          width: rectValue.width,
                          height: rectValue.height,
                          decoration: BoxDecoration(
                            borderRadius: borderRadius,
                            color: Colors.red,
                          ),
                          child: const Text('testfasd fa sdf'),
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
                  Transform.translate(
                    offset: Offset(rectValue.left - gestureSize / 2,
                        rectValue.top - gestureSize / 2),
                    child: Transform.rotate(
                      angle: angle.value,
                      child: SizedBox(
                        width: rectValue.width + gestureSize,
                        height: rectValue.height + gestureSize,
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Alignment.center,
                            Alignment.centerLeft,
                            Alignment.topCenter,
                            Alignment.centerRight,
                            Alignment.bottomCenter,
                            Alignment.topLeft,
                            Alignment.topRight,
                            Alignment.bottomLeft,
                            Alignment.bottomRight,
                          ]
                              .map((e) =>
                              buildResizer(flipValue, newRectValue,
                                  gestureSize, keysValue, e))
                              .toList(),
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

  Widget buildResizer(({bool x, bool y}) flipValue,
      Rect rectValue,
      double gestureSize,
      Set<PhysicalKeyboardKey> keys,
      AlignmentGeometry alignment,) {
    final fromLeft = alignment == Alignment.centerLeft ||
        alignment == Alignment.topLeft ||
        alignment == Alignment.bottomLeft;
    final fromRight = alignment == Alignment.centerRight ||
        alignment == Alignment.topRight ||
        alignment == Alignment.bottomRight;
    final fromTop = alignment == Alignment.topLeft ||
        alignment == Alignment.topCenter ||
        alignment == Alignment.topRight;
    final fromBottom = alignment == Alignment.bottomLeft ||
        alignment == Alignment.bottomCenter ||
        alignment == Alignment.bottomRight;
    final edge = alignment == Alignment.topLeft ||
        alignment == Alignment.topRight ||
        alignment == Alignment.bottomLeft ||
        alignment == Alignment.bottomRight;
    return Positioned(
      left: (!flipValue.x
          ? switch (alignment) {
        _ when fromRight => rectValue.right - 1,
        _ => rectValue.left
      }
          : switch (alignment) {
        _ when !edge => rectValue.left,
        _ when fromRight => rectValue.left,
        _ => rectValue.right
      }),
      top: (!flipValue.y
          ? switch (alignment) {
        _ when fromBottom => rectValue.bottom - 1,
        _ => rectValue.top
      }
          : switch (alignment) {
        _ when !edge => rectValue.top,
        _ when fromBottom => rectValue.top,
        _ => rectValue.bottom
      }),
      child: Listener(
        onPointerDown: (event) {
          originalPosition.value = event.position -
              (edge ? Offset(gestureSize, gestureSize) / 2 : Offset.zero);
          final (a, s, d, f) = (
          visualRect.value.topLeft,
          visualRect.value.topRight,
          visualRect.value.bottomRight,
          visualRect.value.bottomLeft,
          );
          final (l, t, r, b) =
          rotateRect(visualRect.value, 360, visualRect.value.topLeft);
          [
            originalPosition.value,
            visualRect.value,
            event.position,
            (a, s, d, f),
            (l, t, r, b),
          ].forEach(print);
        },
        onPointerUp: (event) {
          handlePointerUp();
        },
        onPointerMove: (event) {
          handleMoveResize(
            direction: alignment,
            mousePosition: event.position,
            originalPosition: originalPosition.value,
            rotation: angle.value,
            origin: Offset.zero,
          );
        },
        child: MouseRegion(
          cursor: edge
              ? SystemMouseCursors.precise
              : switch ((fromLeft || fromRight, fromTop || fromBottom)) {
            (true, false) => SystemMouseCursors.resizeLeftRight,
            (false, true) => SystemMouseCursors.resizeUpDown,
            _ => SystemMouseCursors.grab
          },
          child: Container(
            margin: edge ? null : EdgeInsets.all(gestureSize / 2),
            color: alignment == Alignment.center
                ? Colors.blueAccent.withOpacity(.25)
                : Colors.white30,
            width: switch (alignment) {
              Alignment.topCenter ||
              Alignment.bottomCenter ||
              Alignment.center =>
              rectValue.width,
              Alignment.centerLeft || Alignment.centerRight => 1,
              _ when edge => gestureSize,
              _ => 0,
            },
            height: switch (alignment) {
              Alignment.centerLeft ||
              Alignment.centerRight ||
              Alignment.center =>
              rectValue.height,
              Alignment.topCenter || Alignment.bottomCenter => 1,
              _ when edge => gestureSize,
              _ => 0,
            },
          ),
        ),
      ),
    );
  }

  void handleMoveResize({
    required Offset originalPosition,
    required Offset mousePosition,
    required AlignmentGeometry direction,
    required Offset origin,
    required double rotation,
  }) {
    final delta = mousePosition - originalPosition;
    final rect = originalRect.value;
    // handle move
    if (direction == Alignment.center) {
      newRect.value = Rect.fromLTRB(
        rect.left + delta.dx,
        rect.top + delta.dy,
        rect.right + delta.dx,
        rect.bottom + delta.dy,
      );
    } else {
      // handle resize

      final fromLeft = direction == Alignment.centerLeft ||
          direction == Alignment.topLeft ||
          direction == Alignment.bottomLeft;
      final fromRight = direction == Alignment.centerRight ||
          direction == Alignment.topRight ||
          direction == Alignment.bottomRight;
      final fromTop = direction == Alignment.topLeft ||
          direction == Alignment.topCenter ||
          direction == Alignment.topRight;
      final fromBottom = direction == Alignment.bottomLeft ||
          direction == Alignment.bottomCenter ||
          direction == Alignment.bottomRight;
      final edge = direction == Alignment.topLeft ||
          direction == Alignment.topRight ||
          direction == Alignment.bottomLeft ||
          direction == Alignment.bottomRight;
      final pressedCmd = keys.value.contains(PhysicalKeyboardKey.metaLeft);

      // handle resize according to direction, rotation, and origin
      newRect.value = Rect.fromLTRB(
        rect.left +
            switch (direction) {
              _ when pressedCmd && fromRight =>
              -(delta.dx * cos(rotation) - delta.dy * sin(rotation)),
              _ when !fromLeft => 0,
              _ => delta.dx * cos(rotation) - delta.dy * sin(rotation)
            },
        rect.top +
            switch (direction) {
              _ when pressedCmd && fromBottom =>
              -(delta.dy * cos(rotation) + delta.dx * sin(rotation)),
              _ when !fromTop => 0,
              _ => delta.dy * cos(rotation) + delta.dx * sin(rotation)
            },
        rect.right +
            switch (direction) {
              _ when pressedCmd && fromLeft =>
              -(delta.dx * cos(rotation) - delta.dy * sin(rotation)),
              _ when !fromRight => 0,
              _ => delta.dx * cos(rotation) + delta.dy * sin(rotation)
            },
        rect.bottom +
            switch (direction) {
              _ when pressedCmd && fromTop =>
              -(delta.dy * cos(rotation) + delta.dx * sin(rotation)),
              _ when !fromBottom => 0,
              _ => delta.dy * cos(rotation) - delta.dx * sin(rotation)
            },
      );
    }
    // update visual rect
    visualRect.value = newRect.value;
  }

  void handlePointerUp() {
    originalRect.value = visualRect.value;
  }

  void handleResize(double rotation,
      double origin,
      Offset originalMousePosition,
      Offset mousePosition,
      AlignmentGeometry direction,) {
    final delta = mousePosition - originalMousePosition;
    final rect = originalRect.value;
    // calculate new rect according to direction, rotation, and origin
    newRect.value = Rect.fromLTRB(
      rect.left + delta.dx * cos(rotation) - delta.dy * sin(rotation),
      rect.top + delta.dy * cos(rotation) + delta.dx * sin(rotation),
      rect.right + delta.dx * cos(rotation) + delta.dy * sin(rotation),
      rect.bottom + delta.dy * cos(rotation) - delta.dx * sin(rotation),
    );
    // update visual rect
    visualRect.value = newRect.value;
  }

  double snap(double value, int snapValue) =>
      keys.value.contains(PhysicalKeyboardKey.altLeft)
          ? (value / snapValue).truncateToDouble() * snapValue
          : (value / 0.1).truncateToDouble() * 0.1;
}
