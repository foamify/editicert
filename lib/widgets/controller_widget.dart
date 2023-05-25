import 'dart:math';

import 'package:editicert/providers/component.dart';
import 'package:editicert/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ControllerWidget extends ConsumerStatefulWidget {
  const ControllerWidget(this.index, {super.key});

  final int index;

  @override
  ConsumerState<ControllerWidget> createState() => _NControllerWidgetState();
}

class _NControllerWidgetState extends ConsumerState<ControllerWidget> {
  int get index => widget.index;

  Offset toScene(Offset offset) => tControl().toScene(offset);

  TransformationController tControl() =>
      ref.read(transformationControllerDataProvider);

  ({Offset bl, Offset br, Offset tl, Offset tr}) getRotatedEdges() {
    final ({Offset bl, Offset br, Offset tl, Offset tr}) edge = ref
        .read(componentsProvider.select((value) => value[widget.index]))
        .triangle
        .rotatedEdges;

    return (
      tl: MatrixUtils.transformPoint(tControl().value, edge.tl),
      tr: MatrixUtils.transformPoint(tControl().value, edge.tr),
      bl: MatrixUtils.transformPoint(tControl().value, edge.bl),
      br: MatrixUtils.transformPoint(tControl().value, edge.br),
    );
  }

  ({Offset bl, Offset br, Offset tl, Offset tr}) getEdges() {
    final ({Offset bl, Offset br, Offset tl, Offset tr}) edge = ref
        .read(componentsProvider.select((value) => value[widget.index]))
        .triangle
        .edges;

    return (
      tl: MatrixUtils.transformPoint(tControl().value, edge.tl),
      tr: MatrixUtils.transformPoint(tControl().value, edge.tr),
      bl: MatrixUtils.transformPoint(tControl().value, edge.bl),
      br: MatrixUtils.transformPoint(tControl().value, edge.br),
    );
  }

  final _originalPosition = ValueNotifier(Offset.zero);

  final _originalTriangle =
      ValueNotifier(const Triangle(Offset.zero, Size.zero, 0));
  final _triangle = ValueNotifier(const Triangle(Offset.zero, Size.zero, 0));
  final _visualTriangle =
      ValueNotifier(const Triangle(Offset.zero, Size.zero, 0));

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
    final selected = ref.watch(
        selectedProvider.select((value) => value.contains(widget.index)));
    final hovered = ref
        .watch(hoveredProvider.select((value) => value.contains(widget.index)));
    final component =
        ref.watch(componentsProvider.select((value) => value[widget.index]));
    final hidden = component.hidden;
    final locked = component.locked;

    ref.listen(componentsProvider, (previous, next) {
      if (next[widget.index].triangle != _triangle.value) {
        _visualTriangle.value = next[widget.index].triangle;
      }
    });

    ref.listen(
      transformationControllerDataProvider,
      (previous, next) {},
    );
    return AnimatedBuilder(
        animation: Listenable.merge([
          _visualTriangle,
          _moving,
          ref.watch(transformationControllerDataProvider),
        ]),
        builder: (context, child) {
          final pos = getPos();
          final tSize = getSize();
          final tAngle = _visualTriangle.value.angle;
          final selectedValue = selected && !_moving.value;

          return Positioned.fill(
            child: Stack(
              children: [
                // movement control
                Positioned(
                  left: pos.dx + (tSize.width < 0 ? tSize.width : 0),
                  top: pos.dy + (tSize.height < 0 ? tSize.height : 0),
                  child: IgnorePointer(
                    ignoring: hidden,
                    child: Transform.rotate(
                      angle: tAngle,
                      child: Transform.flip(
                        flipX: tSize.width < 0,
                        flipY: tSize.height < 0,
                        child: Listener(
                          onPointerDown: (event) {
                            ref.read(selectedProvider.notifier)
                              ..clear()
                              ..add(widget.index);
                            handlePointerDownGlobal(event);
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
                              width:
                                  tSize.width < 0 ? -tSize.width : tSize.width,
                              height: tSize.height < 0
                                  ? -tSize.height
                                  : tSize.height,
                              decoration:
                                  (hovered || selected) && !_moving.value
                                      ? BoxDecoration(
                                          border: Border.all(
                                          strokeAlign: .5,
                                          width: selectedValue ? 1 : 2,
                                          color: Colors.blueAccent,
                                        ))
                                      : const BoxDecoration(),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                IgnorePointer(
                  ignoring: locked,
                  child: Stack(
                    children: [
                      // rotation controls
                      if (selectedValue)
                        ...[
                          Alignment.topLeft,
                          Alignment.topRight,
                          Alignment.bottomLeft,
                          Alignment.bottomRight,
                        ].map(
                            (e) => _buildEdgeControl(alignment: e, rotate: true)),
                      // side resize controls
                      if (selectedValue)
                        ...[
                          Alignment.topCenter,
                          Alignment.bottomCenter,
                          Alignment.centerLeft,
                          Alignment.centerRight,
                        ].map((e) => _buildResizer(
                              alignment: e,
                            )),
                      // edge resize controls
                      if (selectedValue)
                        ...[
                          Alignment.topLeft,
                          Alignment.topRight,
                          Alignment.bottomLeft,
                          Alignment.bottomRight,
                        ].map(
                            (e) => _buildEdgeControl(alignment: e, resize: true)),
                    ],
                  ),
                )
              ],
            ),
          );
        });
  }

  Offset getPos() {
    return MatrixUtils.transformPoint(
        tControl().value, _visualTriangle.value.pos);
  }

  /// handles the pointer down event
  void handlePointerDownLocal(PointerDownEvent event) {
    _triangle.value = ref.read(
        componentsProvider.select((value) => value[widget.index].triangle));
    _originalPosition.value = event.position;
    _originalTriangle.value = _triangle.value;
  }

  /// handles the pointer down event for rotation
  void handlePointerDownGlobal(PointerDownEvent event) {
    _triangle.value = ref.read(
        componentsProvider.select((value) => value[widget.index].triangle));
    _originalPosition.value = event.position;
    _originalTriangle.value = _triangle.value;
  }

  /// basically save data
  void handlePointerUp(PointerUpEvent event) {
    _triangle.value = _visualTriangle.value;
    _moving.value = false;
  }

  //------------------------------build functions------------------------------

  /// Builds the edge resize and rotate control
  Widget _buildEdgeControl({
    Alignment? alignment,
    bool rotate = false,
    bool resize = false,
  }) {
    final triangle = _visualTriangle.value;
    final edges = getEdges();
    final rotatedEdges = getRotatedEdges();

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

    return Positioned(
      // this is for the whole widget
      left: rotatedEdge.dx,
      top: rotatedEdge.dy,
      child: Transform.translate(
        // this is for the widget inside the widget
        offset: -const Offset(gestureSize, gestureSize) / (rotate ? 1 : 2),
        child: Transform.rotate(
          angle: triangle.angle,
          child: Transform.translate(
            offset: Offset.zero,
            child: Listener(
              onPointerDown: handlePointerDownGlobal,
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

  /// Builds the side resizer
  Widget _buildResizer({
    required Alignment alignment,
  }) {
    final tValue = _visualTriangle.value;
    const margin = 5.0;

    final edges = tValue.edges;
    final rotatedEdges = getRotatedEdges();

    final tSize = getSize();
    final width = switch (alignment) {
      Alignment.topCenter ||
      Alignment.bottomCenter when tSize.width < 0 =>
        -tSize.width - margin * 2,
      Alignment.topCenter || Alignment.bottomCenter => tSize.width - margin * 2,
      _ => 1.0,
    };
    final height = switch (alignment) {
      Alignment.centerLeft ||
      Alignment.centerRight when tSize.height < 0 =>
        -tSize.height - margin * 2,
      Alignment.centerLeft ||
      Alignment.centerRight =>
        tSize.height - margin * 2,
      _ => 1.0,
    };

    final offset = switch (alignment) {
      Alignment.topCenter when tSize.width < 0 =>
        Offset(-width, -gestureSize / 2),
      Alignment.topCenter => const Offset(0, -gestureSize / 2),
      Alignment.centerLeft when tSize.height < 0 =>
        Offset(-gestureSize / 2, tSize.height),
      Alignment.centerLeft => const Offset(-gestureSize / 2, 0),
      Alignment.bottomCenter when tSize.width < 0 =>
        Offset(-width, tSize.height - gestureSize / 2),
      Alignment.bottomCenter => Offset(0, tSize.height - gestureSize / 2),
      Alignment.centerRight when tSize.height < 0 =>
        Offset(tSize.width - gestureSize / 2, tSize.height),
      Alignment.centerRight => Offset(tSize.width - gestureSize / 2, 0),
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
              onPointerDown: handlePointerDownGlobal,
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

  //------------------------------handle controls------------------------------

  /// Handles movement
  void handleMove(
    PointerMoveEvent event,
  ) {
    final delta = event.position - _originalPosition.value;
    _triangle.value = _originalTriangle.value.copyWith(
      pos: _originalTriangle.value.pos + delta * getScale(),
    );
    _moving.value = true;
  }

  /// Handles rotation from the center of the widget to the pointer
  void handleRotate(PointerMoveEvent event) {
    final center = MatrixUtils.transformPoint(
        ref.read(canvasTransformProvider), _originalTriangle.value.rect.center);
    final originalAngle = atan2(
        _originalPosition.value.dx - sidebarWidth - center.dx,
        _originalPosition.value.dy - center.dy);
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
      _originalPosition.value,
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

    final rDelta = (rPosition - rOriginalPoint) * getScale();

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
    final tSize = getSize();
    final tValue = _originalTriangle.value;

    final position = event.position;
    final oPosition = _originalPosition.value;

    final rOriginalPoint = rotatePoint(
      oPosition,
      selectedEdge + Offset(tSize.width, tSize.height) / 2,
      -tValue.angle,
    );

    final rPosition = rotatePoint(
      position,
      selectedEdge + Offset(tSize.width, tSize.height) / 2,
      -tValue.angle,
    );

    final delta = (position - oPosition) * getScale();
    final rDelta = (rPosition - rOriginalPoint) * getScale();

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

  Size getSize() => _visualTriangle.value.size / getScale();

  double getScale() => toScene(const Offset(1, 0)).dx - toScene(Offset.zero).dx;
}

class Triangle {
  final Offset pos;
  final Size size;
  final double angle;

  const Triangle(this.pos, this.size, this.angle);

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
