import 'dart:math';

import 'package:editicert/logic/component_index_service.dart';
import 'package:editicert/logic/component_service.dart';
import 'package:editicert/state/canvas_events_cubit.dart';
import 'package:editicert/state/canvas_transform_cubit.dart';
import 'package:editicert/state/keys_cubit.dart';
import 'package:editicert/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it_mixin/get_it_mixin.dart';

class ControllerWidget extends StatefulWidget with GetItStatefulWidgetMixin {
  ControllerWidget(this.index, {super.key});

  final int index;

  @override
  State<ControllerWidget> createState() => _ControllerWidgetState();
}

class _ControllerWidgetState extends State<ControllerWidget>
    with GetItStateMixin {
  Offset toScene(Offset offset) => tControl().toScene(offset);

  TransformationController tControl() =>
      (context.read<CanvasTransformCubit>().state);

  ({Offset bl, Offset br, Offset tl, Offset tr}) getRotatedEdges() {
    final ({Offset bl, Offset br, Offset tl, Offset tr}) edge =
        (componentsNotifier.state.value[widget.index]).component.rotatedEdges;

    final transform = tControl().value;

    return (
      tl: MatrixUtils.transformPoint(transform, edge.tl),
      tr: MatrixUtils.transformPoint(transform, edge.tr),
      bl: MatrixUtils.transformPoint(transform, edge.bl),
      br: MatrixUtils.transformPoint(transform, edge.br),
    );
  }

  ({Offset bl, Offset br, Offset tl, Offset tr}) getEdges() {
    final ({Offset bl, Offset br, Offset tl, Offset tr}) edge =
        (componentsNotifier.state.value[widget.index]).component.edges;

    final transform = tControl().value;

    return (
      tl: MatrixUtils.transformPoint(transform, edge.tl),
      tr: MatrixUtils.transformPoint(transform, edge.tr),
      bl: MatrixUtils.transformPoint(transform, edge.bl),
      br: MatrixUtils.transformPoint(transform, edge.br),
    );
  }

  final _originalPosition = ValueNotifier(Offset.zero);

  final _originalComponent =
      ValueNotifier(const Component(Offset.zero, Size.zero, 0));

  final _component = ValueNotifier(const Component(Offset.zero, Size.zero, 0));

  final _visualComponent =
      ValueNotifier(const Component(Offset.zero, Size.zero, 0));

  final stopwatch = Stopwatch();

  @override
  void initState() {
    final component = (componentsNotifier.state.value[widget.index]).component;
    _component.value = component;
    _visualComponent.value = component;
    _component.addListener(() {
      (componentsNotifier).replace(widget.index, transform: _component.value);
      _visualComponent.value = _component.value;
    });

    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hovereds = watchX(
      (Hovered hovered) => hovered.state,
    );
    final components = watchX(
      (Components components) => components.state,
    );
    //
    final hovered = hovereds.contains(widget.index);
    final component = components[widget.index];
    //
    final hidden = component.hidden;
    final locked = component.locked;
    //
    final moving = (context.read<CanvasEventsCubit>().state)
        .contains(CanvasEvent.draggingComponent);

    registerHandler(
      (Components components) => components.state,
      (context, next, _) {
        if (next.length <= widget.index) return;
        if (next[widget.index].component != _component.value) {
          _visualComponent.value = next[widget.index].component;
        }
      },
    );

    return AnimatedBuilder(
      animation: Listenable.merge([
        _visualComponent,
        (context.read<CanvasTransformCubit>().state),
        selectedNotifier.state,
      ]),
      builder: (context, child) {
        final pos = getPos();
        final tSize = getSize();
        final tAngle = _visualComponent.value.angle;
        final selected = selectedNotifier.state.value.contains(widget.index);
        final selectedValue = selected && !moving;
        final borderWidth = selectedValue ? 1.0 : 2.0;

        return Stack(
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
                        stopwatch.start();
                        (context.read<CanvasEventsCubit>()).add(
                              CanvasEvent.draggingComponent,
                        );
                        if (!selectedNotifier.state.value
                            .contains(widget.index)) {
                          selectedNotifier.clear();
                          hoveredNotifier.clear();
                        }
                        handlePointerDownGlobal(event);
                      },
                      onPointerMove: locked
                          ? null
                          : (event) {
                              if (stopwatch.isRunning) {
                                stopwatch
                                  ..stop()
                                  ..reset();
                              }
                              handleMove(event);
                            },
                      onPointerUp: (event) {
                        // handle text edit
                        if (componentsNotifier.state.value[widget.index].type ==
                                ComponentType.text &&
                            stopwatch.isRunning &&
                            stopwatch.elapsedMilliseconds <= 500) {
                          print('TAPPED');
                          (context.read<CanvasEventsCubit>()).add(
                                  CanvasEvent.editingText);
                          componentsNotifier.replace(widget.index,
                              controller:
                                  TextEditingController(text: component.name));
                        }
                        selectedNotifier.add(widget.index);
                        hoveredNotifier.add(widget.index);
                        handlePointerUp(event);
                      },
                      child: MouseRegion(
                        onEnter: (_) => (hoveredNotifier).add(widget.index),
                        onExit: (_) => (hoveredNotifier).remove(widget.index),
                        child: Container(
                          width: tSize.width < 0 ? -tSize.width : tSize.width,
                          height:
                              tSize.height < 0 ? -tSize.height : tSize.height,
                          decoration: (hovered || selected) && !moving
                              ? BoxDecoration(
                                  border: Border.all(
                                    strokeAlign: .5,
                                    width: borderWidth,
                                    color: Colors.blueAccent,
                                  ),
                                )
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
                      (e) => _buildEdgeControl(alignment: e, rotate: true),
                    ),
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
                      (e) => _buildEdgeControl(alignment: e, resize: true),
                    ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Offset getPos() {
    return MatrixUtils.transformPoint(
      tControl().value,
      _visualComponent.value.pos,
    );
  }

  /// handles the pointer down event for rotation
  void handlePointerDownGlobal(PointerDownEvent event) {
    _component.value = (componentsNotifier.state.value[widget.index].component);
    _originalPosition.value = event.position;
    _originalComponent.value = _component.value;
  }

  /// basically save data
  void handlePointerUp(PointerUpEvent _) {
    print('UP');
    context.read<CanvasEventsCubit>()
      ..remove(CanvasEvent.draggingComponent)
      ..remove(CanvasEvent.resizingComponent)
      ..remove(CanvasEvent.rotatingComponent);
    _component.value = _visualComponent.value;
  }

  /// Builds the edge resize and rotate control
  Widget _buildEdgeControl({
    Alignment? alignment,
    bool rotate = false,
    bool resize = false,
  }) {
    final component = _visualComponent.value;
    final edges = getEdges();
    final rotatedEdges = getRotatedEdges();
    final topRight = rotatedEdges.tl;

    final rotatedEdge = switch (alignment) {
      Alignment.topLeft => topRight,
      Alignment.topRight => rotatedEdges.tr,
      Alignment.bottomLeft => rotatedEdges.bl,
      Alignment.bottomRight => rotatedEdges.br,
      //
      Alignment.topCenter => topRight,
      _ => Offset.zero,
    };

    final selected = switch (alignment) {
      Alignment.topLeft => edges.tl,
      Alignment.topRight => edges.tr,
      Alignment.bottomLeft => edges.bl,
      Alignment.bottomRight => edges.br,
      //
      _ => Offset.zero,
    };

    final edgeScale = rotate ? 2 : 1;

    return Positioned(
      // this is for the whole widget
      left: rotatedEdge.dx,
      top: rotatedEdge.dy,
      child: Transform.translate(
        // this is for the widget inside the widget
        offset: -const Offset(gestureSize, gestureSize) / (rotate ? 1 : 2),
        child: Transform.rotate(
          angle: component.angle,
          child: Transform.translate(
            offset: Offset.zero,
            child: Listener(
              onPointerDown: (event) {
                (context.read<CanvasEventsCubit>()).add(
                  (rotate
                      ? CanvasEvent.rotatingComponent
                      : CanvasEvent.resizingComponent),
                );
                handlePointerDownGlobal(event);
              },
              onPointerMove: (event) {
                (context.read<CanvasEventsCubit>()).add(
                  (rotate
                      ? CanvasEvent.rotatingComponent
                      : CanvasEvent.resizingComponent),
                );
                if (resize && alignment != null) {
                  handleResize(event, alignment, selected);
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
                      ? component.size.width
                      : gestureSize * edgeScale,
                  height: gestureSize * edgeScale,
                  decoration: rotate
                      ? null
                      : BoxDecoration(
                          color: Colors.white,
                          border:
                              Border.all(width: 1, color: Colors.blueAccent),
                          borderRadius: BorderRadius.circular(2)),
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
    final tValue = _visualComponent.value;
    // final scale = (context.read<CanvasTransformCubit>()Notifier.state.value).getMaxScaleOnAxis();
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
        Offset(-width - margin * 2, -gestureSize / 2),
      Alignment.topCenter => const Offset(0, -gestureSize / 2),
      Alignment.centerLeft when tSize.height < 0 =>
        Offset(-gestureSize / 2, tSize.height),
      Alignment.centerLeft => const Offset(-gestureSize / 2, 0),
      Alignment.bottomCenter when tSize.width < 0 =>
        Offset(-width - margin * 2, tSize.height - gestureSize / 2),
      Alignment.bottomCenter => Offset(0, tSize.height - gestureSize / 2),
      Alignment.centerRight when tSize.height < 0 =>
        Offset(tSize.width - gestureSize / 2, tSize.height),
      Alignment.centerRight => Offset(tSize.width - gestureSize / 2, 0),
      _ => Offset.zero,
    };
    final topLeft = edges.tl;
    final bottomRight = edges.br;
    final rTopLeft = rotatedEdges.tl;

    final selectedSide = switch (alignment) {
      Alignment.topCenter => topLeft,
      Alignment.centerLeft => topLeft,
      Alignment.bottomCenter => bottomRight,
      Alignment.centerRight => bottomRight,
      _ => Offset.zero,
    };

    return Positioned(
      // this is for the whole widget
      left: rTopLeft.dx,
      top: rTopLeft.dy,
      child: Transform.rotate(
        angle: tValue.angle,
        origin: -Offset(width + margin * 2, height + margin * 2) / 2,
        child: Transform.translate(
          offset: offset,
          child: Listener(
            onPointerDown: (event) {
              handlePointerDownGlobal(event);

              (context.read<CanvasEventsCubit>()).add(
                CanvasEvent.resizingComponent,
              );
            },
            onPointerMove: (event) {
              handleResize(event, alignment, selectedSide);
            },
            onPointerUp: handlePointerUp,
            child: MouseRegion(
              cursor: SystemMouseCursors.grab,
              child: Container(
                margin: const EdgeInsets.all(margin),
                width: max(width, 0),
                height: max(height, 0),
                // color: Colors.redAccent,
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
    (context.read<CanvasEventsCubit>()).add(
      CanvasEvent.draggingComponent,
    );
    final delta = event.position - _originalPosition.value;
    _component.value = _originalComponent.value.copyWith(
      pos: _originalComponent.value.pos + delta * getScale(),
    );
  }

  /// Handles rotation from the center of the widget to the pointer
  void handleRotate(PointerMoveEvent event) {
    final center = MatrixUtils.transformPoint(
      (context.read<CanvasTransformCubit>().state.value),
      _originalComponent.value.rect.center,
    );
    final originalAngle = atan2(
      _originalPosition.value.dx - sidebarWidth - center.dx,
      _originalPosition.value.dy - topbarHeight - center.dy,
    );
    final newAngle = atan2(
      event.position.dx - sidebarWidth - center.dx,
      event.position.dy - topbarHeight - center.dy,
    );
    final deltaAngle = newAngle - originalAngle;

    _component.value = _originalComponent.value
        .copyWith(angle: _originalComponent.value.angle - deltaAngle);
  }

  /// Handles resizing from all edges/sides
  void handleResize(
    PointerMoveEvent event,
    Alignment alignment,
    Offset selected,
  ) {
    final tValue = _originalComponent.value;

    final keys = context.read<KeysCubit>().state;
    // this is for mirrored resize
    final pressedAlt = keys.contains(LogicalKeyboardKey.alt) ||
        keys.contains(LogicalKeyboardKey.altLeft) ||
        keys.contains(LogicalKeyboardKey.altRight);
    // this is for rectangle resize
    final pressedShift = keys.contains(LogicalKeyboardKey.shift) ||
        keys.contains(LogicalKeyboardKey.shiftLeft) ||
        keys.contains(LogicalKeyboardKey.shiftRight);

    final rOriginalPoint = rotatePoint(
      _originalPosition.value,
      selected + Offset(tValue.size.width, tValue.size.height) / 2,
      -tValue.angle,
    );

    final rPosition = rotatePoint(
      event.position,
      selected + Offset(tValue.size.width, tValue.size.height) / 2,
      -tValue.angle,
    );

    final oRect = tValue.rect;
    final oEdges = rotateRect(oRect, 0, tValue.pos);

    final scale = getScale();

    final nDelta = (rPosition - rOriginalPoint) * scale;
    var rDelta = (rPosition - rOriginalPoint) * scale;

    if (pressedShift) {
      final width = pressedAlt ? oRect.width / 2 : oRect.width;
      final height = pressedAlt ? oRect.height / 2 : oRect.height;

      final flipWidth = switch (alignment) {
        Alignment.topLeft ||
        Alignment.bottomLeft =>
          width > 0 ? nDelta.dx > width : nDelta.dx < width,
        Alignment.topRight ||
        Alignment.bottomRight =>
          width > 0 ? -nDelta.dx > width : -nDelta.dx < width,
        _ => false,
      };
      final flipHeight = switch (alignment) {
        Alignment.topLeft ||
        Alignment.topRight =>
          height > 0 ? nDelta.dy > height : nDelta.dy < height,
        Alignment.bottomLeft ||
        Alignment.bottomRight =>
          height > 0 ? -nDelta.dy > height : -nDelta.dy < height,
        _ => false,
      };

      final kFlipWidth = width < 0 ? -1 : 1;
      final kFlipHeight = height < 0 ? -1 : 1;

      var offsetX = 0.0;
      var offsetY = 0.0;

      switch (alignment) {
        case Alignment.topLeft || Alignment.bottomLeft when flipWidth:
          offsetX = width * 2;
        case Alignment.topRight || Alignment.bottomRight when flipWidth:
          offsetX = -width * 2;
      }
      switch (alignment) {
        case Alignment.topLeft || Alignment.topRight when flipHeight:
          offsetY = height * 2;
        case Alignment.bottomLeft || Alignment.bottomRight when flipHeight:
          offsetY = -height * 2;
      }

      if (flipWidth) rDelta = rDelta.scale(-1, 1) + Offset(offsetX, 0);
      if (flipHeight) rDelta = rDelta.scale(1, -1) + Offset(0, offsetY);

      rDelta = switch (alignment) {
        Alignment.topLeft => rDelta.dx * kFlipWidth < rDelta.dy * kFlipHeight
            ? Offset(rDelta.dx * kFlipHeight, rDelta.dx * kFlipWidth)
            : Offset(rDelta.dy * kFlipWidth, rDelta.dy * kFlipHeight),
        Alignment.topRight => -rDelta.dx * kFlipWidth < rDelta.dy * kFlipHeight
            ? Offset(rDelta.dx * kFlipHeight, -rDelta.dx * kFlipWidth)
            : Offset(-rDelta.dy * kFlipWidth, rDelta.dy * kFlipHeight),
        Alignment.bottomLeft =>
          rDelta.dx * kFlipWidth < -rDelta.dy * kFlipHeight
              ? Offset(rDelta.dx * kFlipHeight, -rDelta.dx * kFlipWidth)
              : Offset(-rDelta.dy * kFlipWidth, rDelta.dy * kFlipHeight),
        Alignment.bottomRight =>
          -rDelta.dx * kFlipWidth < -rDelta.dy * kFlipHeight
              ? Offset(rDelta.dx * kFlipHeight, rDelta.dx * kFlipWidth)
              : Offset(rDelta.dy * kFlipWidth, rDelta.dy * kFlipHeight),
        _ => rDelta,
      };

      if (flipWidth) {
        rDelta = Offset(
          width > 0 ? offsetX - rDelta.dx : -rDelta.dx + offsetX,
          rDelta.dy,
        );
      }
      if (flipHeight) {
        rDelta = Offset(
          rDelta.dx,
          height > 0 ? offsetY - rDelta.dy : -rDelta.dy + offsetY,
        );
      }
    }

    final rDeltaInvert =
        pressedAlt ? Offset(-rDelta.dx, -rDelta.dy) : Offset.zero;

    final deltaTop = switch (alignment) {
      Alignment.topLeft || Alignment.topRight => Offset(0, rDelta.dy),
      Alignment.bottomLeft ||
      Alignment.bottomRight =>
        Offset(0, rDeltaInvert.dy),
      Alignment.topCenter => Offset(0, rDelta.dy),
      Alignment.bottomCenter => Offset(0, rDeltaInvert.dy),
      _ => Offset.zero,
    };

    final deltaBottom = switch (alignment) {
      Alignment.topLeft || Alignment.topRight => Offset(0, rDeltaInvert.dy),
      Alignment.bottomLeft || Alignment.bottomRight => Offset(0, rDelta.dy),
      Alignment.topCenter => Offset(0, rDeltaInvert.dy),
      Alignment.bottomCenter => Offset(0, rDelta.dy),
      _ => Offset.zero,
    };

    final deltaLeft = switch (alignment) {
      Alignment.topLeft || Alignment.bottomLeft => Offset(rDelta.dx, 0),
      Alignment.topRight || Alignment.bottomRight => Offset(rDeltaInvert.dx, 0),
      Alignment.centerLeft => Offset(rDelta.dx, 0),
      Alignment.centerRight => Offset(rDeltaInvert.dx, 0),
      _ => Offset.zero,
    };

    final deltaRight = switch (alignment) {
      Alignment.topLeft || Alignment.bottomLeft => Offset(rDeltaInvert.dx, 0),
      Alignment.topRight || Alignment.bottomRight => Offset(rDelta.dx, 0),
      Alignment.centerLeft => Offset(rDeltaInvert.dx, 0),
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
          Alignment.topLeft ||
          Alignment.bottomLeft =>
            (rDelta.dx - rDeltaInvert.dx) / 2,
          Alignment.topRight ||
          Alignment.bottomRight =>
            (-rDelta.dx + rDeltaInvert.dx) / 2,
          Alignment.centerLeft => (rDelta.dx - rDeltaInvert.dx) / 2,
          Alignment.centerRight => (-rDelta.dx + rDeltaInvert.dx) / 2,
          _ => 0,
        },
        switch (alignment) {
          Alignment.topLeft ||
          Alignment.topRight =>
            (rDelta.dy - rDeltaInvert.dy) / 2,
          Alignment.bottomLeft ||
          Alignment.bottomRight =>
            (-rDelta.dy + rDeltaInvert.dy) / 2,
          Alignment.topCenter => (rDelta.dy - rDeltaInvert.dy) / 2,
          Alignment.bottomCenter => (-rDelta.dy + rDeltaInvert.dy) / 2,
          _ => 0,
        },
      ),
    );

    _component.value = Component.fromEdges(
      newEdgesR,
      flipX: newRect.size.width < 0,
      flipY: newRect.size.height > 0,
    );
  }

  Size getSize() => _visualComponent.value.size / getScale();

  double getScale() => toScene(const Offset(1, 0)).dx - toScene(Offset.zero).dx;
}

class Component {
  final Offset pos;
  final Size size;
  final double angle;

  const Component(this.pos, this.size, this.angle);

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
    bool keepOrigin = false,
  }) {
    final topLeft = edges.tl;

    final size = Size(
      (topLeft - edges.tr).distance * (flipX ? -1 : 1),
      (topLeft - edges.bl).distance * (flipY ? -1 : 1),
    );
    final angle = atan2(edges.tr.dy - topLeft.dy, edges.tr.dx - topLeft.dx);

    final newEdges = !keepOrigin
        ? rotateRect(
            Rect.fromLTWH(topLeft.dx, topLeft.dy, size.width, size.height),
            0,
            Offset.zero,
          )
        : rotateRect(
            Rect.fromLTWH(0, 0, size.width, size.height),
            0,
            Offset.zero,
          );

    var newComponent = Component(
      newEdges.tl,
      size,
      angle + (flipX ? pi : 0),
    );

    if (keepOrigin) {
      final difference = topLeft - newComponent.rotatedEdges.tl;

      newComponent = Component(
        newEdges.tl + difference,
        size,
        angle + (flipX ? pi : 0),
      );
    }

    print('CORRECTEDRECT:');
    print(newComponent.rotatedEdges.tl);

    ///----------------------------------------
    print(
        Rect.fromLTWH(topLeft.dx, topLeft.dy, size.width, size.height).topLeft);
    print(newEdges.tl);

    ///----------------------------------------
    return newComponent;
  }

  Component copyWith({Offset? pos, Size? size, double? angle}) {
    return Component(pos ?? this.pos, size ?? this.size, angle ?? this.angle);
  }

  @override
  String toString() {
    return 'Component{pos: $pos, size: $size, angle: $angle}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Component &&
          runtimeType == other.runtimeType &&
          pos == other.pos &&
          size == other.size &&
          angle == other.angle;

  @override
  int get hashCode => pos.hashCode ^ size.hashCode ^ angle.hashCode;
}
