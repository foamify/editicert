import 'dart:math';

import 'package:editicert/providers/component.dart';
import 'package:editicert/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ControllerWidget extends ConsumerStatefulWidget {
  const ControllerWidget({
    super.key,
    required this.index,
  });

  final int index;

  @override
  ConsumerState<ControllerWidget> createState() => _ComponentWidgetState();
}

class _ComponentWidgetState extends ConsumerState<ControllerWidget> {
  final ValueNotifier<Offset> originalPosition = ValueNotifier(Offset.zero);

  final _originalTriangle = ValueNotifier(Triangle(Offset.zero, Size.zero, 0));
  final _triangle = ValueNotifier(Triangle(Offset.zero, Size.zero, 0));
  final _visualTriangle = ValueNotifier(Triangle(Offset.zero, Size.zero, 0));

  final _moving = ValueNotifier(false);

  @override
  void initState() {
    final triangle = ref
        .read(componentsProvider.select((value) => value[widget.index]))
        .triangle;
    _triangle.value = triangle;
    _visualTriangle.value = triangle;
    _triangle.addListener(() {
      ref
          .read(componentsProvider.notifier)
          .replace(widget.index, triangle: _triangle.value);
      _visualTriangle.value = _triangle.value;
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final keys = ref.watch(keysProvider);
    final selected = ref.watch(
        selectedProvider.select((value) => value.contains(widget.index)));
    final hovered = ref
        .watch(hoveredProvider.select((value) => value.contains(widget.index)));

    ref.listen(componentsProvider, (previous, next) {
      if (next[widget.index].triangle != _triangle.value) {
        _visualTriangle.value = next[widget.index].triangle;
      }
    });

    return RawKeyboardListener(
      focusNode: FocusNode(),
      autofocus: true,
      onKey: (value) => value.isKeyPressed(value.logicalKey)
          ? keys.add(value.physicalKey)
          : keys.remove(value.physicalKey),
      child: AnimatedBuilder(
          animation: Listenable.merge([
            _visualTriangle,
            _moving,
          ]),
          builder: (context, child) {
            final triangle = _visualTriangle.value;
            final selectedValue = selected && !_moving.value;
            return SizedBox(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: Stack(
                children: [
                  if (selectedValue)
                    // rotation controls
                    ...[
                      Alignment.topLeft,
                      Alignment.topRight,
                      Alignment.bottomLeft,
                      Alignment.bottomRight,
                    ].map((e) => _buildEdgeControl(triangle,
                        alignment: e, rotate: true)),
                  if (selectedValue)
                    // side resize controls
                    ...[
                      Alignment.topCenter,
                      Alignment.bottomCenter,
                      Alignment.centerLeft,
                      Alignment.centerRight,
                    ].map((e) => _buildResizer(
                          triangle,
                          alignment: e,
                        )),
                  if (selectedValue)
                    // edge resize controls
                    ...[
                      Alignment.topLeft,
                      Alignment.topRight,
                      Alignment.bottomLeft,
                      Alignment.bottomRight,
                    ].map((e) => _buildEdgeControl(triangle,
                        alignment: e, resize: true)),
                  // movement control
                  Positioned(
                    left: triangle.pos.dx +
                        (triangle.size.width < 0 ? triangle.size.width : 0),
                    top: triangle.pos.dy +
                        (triangle.size.height < 0 ? triangle.size.height : 0),
                    child: Transform.rotate(
                      angle: triangle.angle,
                      child: Transform.flip(
                        flipX: triangle.size.width < 0,
                        flipY: triangle.size.height < 0,
                        child: Listener(
                          onPointerDown: (event) {
                            ref.read(selectedProvider.notifier)
                              ..clear()
                              ..add(widget.index);
                            handlePointerDown(event);
                          },
                          onPointerMove: handleMove,
                          onPointerUp: handlePointerUp,
                          child: MouseRegion(
                            onEnter: (_) => ref
                                .read(hoveredProvider.notifier)
                                .add(widget.index),
                            onExit: (_) => ref
                                .read(hoveredProvider.notifier)
                                .remove(widget.index),
                            child: Container(
                              width: triangle.size.width < 0
                                  ? -triangle.size.width
                                  : triangle.size.width,
                              height: triangle.size.height < 0
                                  ? -triangle.size.height
                                  : triangle.size.height,
                              decoration: hovered && !selected
                                  ? BoxDecoration(
                                      border: Border.all(
                                      strokeAlign: .5,
                                      width: 4,
                                      color: Colors.blueAccent,
                                    ))
                                  : const BoxDecoration(),
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

  /// Builds the side resizer
  Widget _buildResizer(
    Triangle tValue, {
    required Alignment alignment,
  }) {
    const margin = 5.0;

    final edges = tValue.edges;
    final rotatedEdges = tValue.rotatedEdges;
    final width = switch (alignment) {
      Alignment.topCenter ||
      Alignment.bottomCenter when tValue.size.width < 0 =>
        -tValue.size.width - margin * 2,
      Alignment.topCenter ||
      Alignment.bottomCenter =>
        tValue.size.width - margin * 2,
      _ => 1.0,
    };
    final height = switch (alignment) {
      Alignment.centerLeft ||
      Alignment.centerRight when tValue.size.height < 0 =>
        -tValue.size.height - margin * 2,
      Alignment.centerLeft ||
      Alignment.centerRight =>
        tValue.size.height - margin * 2,
      _ => 1.0,
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

    return Positioned(
        // this is for the whole widget
        left: rotatedEdges.tl.dx,
        top: rotatedEdges.tl.dy,
        child: Transform.rotate(
          angle: tValue.angle,
          origin: -Offset(width + margin * 2, height + margin * 2) / 2,
          child: Transform.translate(
            offset: offset,
            child: Listener(
              onPointerDown: handlePointerDown,
              onPointerMove: (event) {
                handleResizeSide(event, alignment, selectedSide);
              },
              onPointerUp: handlePointerUp,
              child: MouseRegion(
                cursor: SystemMouseCursors.grab,
                child: Container(
                  margin: const EdgeInsets.all(margin),
                  width: max(width, 0),
                  height: max(height, 0),
                  color: Colors.blueAccent,
                ),
              ),
            ),
          ),
        ));
  }

  /// handles the pointer down event
  void handlePointerDown(PointerDownEvent event) {
    _triangle.value = ref.read(
        componentsProvider.select((value) => value[widget.index].triangle));
    originalPosition.value = event.position;
    _originalTriangle.value = _triangle.value;
  }

  /// basically save data
  void handlePointerUp(PointerUpEvent event) {
    _triangle.value = _visualTriangle.value;
    _moving.value = false;
  }

  /// Builds the edge resize and rotate control
  Widget _buildEdgeControl(
    Triangle triangle, {
    Alignment? alignment,
    bool rotate = false,
    bool resize = false,
  }) {
    final edges = triangle.edges;
    final rotatedEdges = triangle.rotatedEdges;

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
          angle: triangle.angle,
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
              onPointerUp: handlePointerUp,
              child: MouseRegion(
                cursor: resize
                    ? SystemMouseCursors.precise
                    : SystemMouseCursors.grabbing,
                child: Container(
                  width: alignment == Alignment.topCenter ||
                          alignment == Alignment.bottomCenter
                      ? triangle.size.width
                      : gestureSize * (rotate ? 2 : 1),
                  height: gestureSize * (rotate ? 2 : 1),
                  decoration: rotate
                      ? null
                      : BoxDecoration(
                          color: Colors.white,
                          border:
                              Border.all(width: 1, color: Colors.blueAccent)),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Handles movement
  void handleMove(
    PointerMoveEvent event,
  ) {
    final delta = event.position - originalPosition.value;
    _triangle.value = _originalTriangle.value.copyWith(
      pos: _originalTriangle.value.pos + delta,
    );
    _moving.value = true;
  }

  /// Handles rotation from the center of the widget to the pointer
  void handleRotate(PointerMoveEvent event) {
    final center = _originalTriangle.value.rect.center;
    final originalAngle = atan2(
        originalPosition.value.dx - sidebarWidth - center.dx,
        originalPosition.value.dy - center.dy);
    final newAngle = atan2(event.position.dx - sidebarWidth - center.dx,
        event.position.dy - center.dy);
    final deltaAngle = newAngle - originalAngle;

    _triangle.value = _originalTriangle.value
        .copyWith(angle: _originalTriangle.value.angle - deltaAngle);
  }

  /// Handles resizing from the sides
  void handleResizeSide(
      PointerMoveEvent event, Alignment alignment, Offset selectedSide) {
    final tValue = _originalTriangle.value;

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

    _triangle.value = Triangle.fromEdges(
      newEdgesR,
      flipX: newRect.size.width < 0,
      flipY: newRect.size.height > 0,
    );
  }

  /// Handles resizing from the edges
  void handleResizeEdges(
      PointerMoveEvent event, Alignment alignment, Offset selectedEdge) {
    final tValue = _originalTriangle.value;

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

    _triangle.value = tValue.copyWith(
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

  /// Snaps the value to the nearest snap value if the keys are pressed
  double snap(double value, int snapValue, Set<PhysicalKeyboardKey> keys) =>
      keys.contains(PhysicalKeyboardKey.altLeft)
          ? (value / snapValue).truncateToDouble() * snapValue
          : (value / 0.1).truncateToDouble() * 0.1;
}

class Triangle {
  Offset pos;
  Size size;
  double angle;

  Triangle(this.pos, this.size, this.angle);

  Rect get rect => Rect.fromLTWH(pos.dx, pos.dy, size.width, size.height);

  ({Offset bl, Offset br, Offset tl, Offset tr}) get rotatedEdges => rotateRect(
        rect,
        angle,
        pos + Offset(size.width / 2, size.height / 2),
      );

  ({Offset bl, Offset br, Offset tl, Offset tr}) get edges => rotateRect(
        rect,
        angle,
        pos,
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

    final newTriangle = Triangle(
      newEdges.tl,
      size,
      angle + (flipX ? pi : 0),
    );
    return newTriangle;
  }

  copyWith({Offset? pos, Size? size, double? angle, Offset? origin}) {
    return Triangle(pos ?? this.pos, size ?? this.size, angle ?? this.angle);
  }

  @override
  String toString() {
    return 'Triangle{pos: $pos, size: $size, angle: $angle}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Triangle &&
          runtimeType == other.runtimeType &&
          pos == other.pos &&
          size == other.size &&
          angle == other.angle;

  @override
  int get hashCode => pos.hashCode ^ size.hashCode ^ angle.hashCode;
}
