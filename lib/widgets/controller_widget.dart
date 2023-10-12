part of '../main.dart';

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

  final _originalTransform = ValueNotifier(Matrix4.identity());

  final _originalComponent =
      ValueNotifier(const Component(Offset.zero, Size.zero, 0, false, false));

  final _component =
      ValueNotifier(const Component(Offset.zero, Size.zero, 0, false, false));

  final _visualComponent =
      ValueNotifier(const Component(Offset.zero, Size.zero, 0, false, false));

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
        final flipX = _visualComponent.value.flipX;
        final flipY = _visualComponent.value.flipY;

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
                    flipX: flipX,
                    flipY: flipY,
                    child: Listener(
                      onPointerDown: (event) {
                        if (event.buttons == kMiddleMouseButton) return;
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
                              if (event.buttons == kMiddleMouseButton) return;
                              if (stopwatch.isRunning) {
                                stopwatch
                                  ..stop()
                                  ..reset();
                              }
                              handleMove(event);
                            },
                      onPointerUp: (event) {
                        if (event.buttons == kMiddleMouseButton) return;
                        // handle text edit
                        if (componentsNotifier.state.value[widget.index].type ==
                                ComponentType.text &&
                            stopwatch.isRunning &&
                            stopwatch.elapsedMilliseconds <= 500) {
                          print('TAPPED');
                          (context.read<CanvasEventsCubit>())
                              .add(CanvasEvent.editingText);
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
    if (event.buttons == kMiddleMouseButton) return;
    _component.value = (componentsNotifier.state.value[widget.index].component);
    _originalPosition.value = event.position;
    _originalTransform.value = tControl().value;
    _originalComponent.value = _component.value;
  }

  /// basically save data
  void handlePointerUp(PointerUpEvent event) {
    if (event.buttons == kMiddleMouseButton) return;
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
                if (event.buttons == kMiddleMouseButton) return;
                (context.read<CanvasEventsCubit>()).add(
                  (rotate
                      ? CanvasEvent.rotatingComponent
                      : CanvasEvent.resizingComponent),
                );
                handlePointerDownGlobal(event);
              },
              onPointerMove: (event) {
                if (event.buttons == kMiddleMouseButton) return;
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
              if (event.buttons == kMiddleMouseButton) return;
              handlePointerDownGlobal(event);

              (context.read<CanvasEventsCubit>()).add(
                CanvasEvent.resizingComponent,
              );
            },
            onPointerMove: (event) {
              if (event.buttons == kMiddleMouseButton) return;
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

    print('Alt: $pressedAlt');
    print('Shift: $pressedShift');

    final originalRect = tValue.rect;
    final angle = tValue.angle;

    final rectCenter = originalRect.center;
    final originalEdges = rotateRect(originalRect, 0, Offset.zero);

    final opposingOffset = getOffset(alignment, originalEdges, opposite: true);
    final selectedOffset = getOffset(alignment, originalEdges);

    final invertedComponentTransform = tControl().value.clone()..invert();

    final rotatedOriginalPoint = rotatePoint(
      MatrixUtils.transformPoint(
          invertedComponentTransform, _originalPosition.value),
      selected + Offset(tValue.size.width, tValue.size.height) / 2,
      -angle,
    );

    final rotatedCursorPoint = rotatePoint(
      MatrixUtils.transformPoint(invertedComponentTransform, event.position),
      selected + Offset(tValue.size.width, tValue.size.height) / 2,
      -angle,
    );

    final rotatedOriginalRect = rotateRect(originalRect, angle, rectCenter);
    final originalCenter = rotatedOriginalRect.center;

    final rotatedOpposingPoint = rotatePoint(
      opposingOffset,
      originalCenter,
      angle,
    );

    final rotatedSelectedPoint = rotatePoint(
      selectedOffset,
      originalCenter,
      angle,
    );

    var cursorDelta = (rotatedCursorPoint - rotatedOriginalPoint);
    Offset rotatedCursorDelta() => rotatePoint(cursorDelta, Offset.zero, angle);

    if (alignment case Alignment.topCenter || Alignment.bottomCenter) {
      // Remove the horizontal delta if top/bottom side resize
      cursorDelta = Offset(0, cursorDelta.dy);
    } else if (alignment case Alignment.centerLeft || Alignment.centerRight) {
      // Remove the vertical delta if left/right side resize
      cursorDelta = Offset(cursorDelta.dx, 0);
    }

    final newCenter = getMiddleOffset(
        rotatedOpposingPoint + rotatedCursorDelta(), rotatedSelectedPoint);

    // TODO(damywise): Found method to keep aspect ratio but rotate
    // final otherEdge1 = rotatePoint(rotatedSelectedPoint + originalCursorDelta, newCenter, -90);
    // final otherEdge2 = rotatePoint(rotatedOpposingPoint, newCenter, -90);

    var pointModifier = switch (alignment) {
      // edges
      Alignment.topRight => const Point(1, -1),
      Alignment.topLeft => const Point(-1, -1),
      Alignment.bottomRight => const Point(1, 1),
      Alignment.bottomLeft => const Point(-1, 1),
      // sides
      Alignment.topCenter => const Point(0, -1),
      Alignment.centerLeft => const Point(-1, 0),
      Alignment.centerRight => const Point(1, 0),
      Alignment.bottomCenter => const Point(0, 1),
      _ => const Point(0, 0),
    };

    final center = pressedAlt ? originalCenter : newCenter;
    if (pressedAlt) {
      // Resized twice as big if mirrored (pressed alt/option)
      pointModifier = pointModifier * 2;
    }

    final resizedRect = Rect.fromCenter(
      center: center,
      width: originalRect.width + cursorDelta.dx * pointModifier.x,
      height: originalRect.height + cursorDelta.dy * pointModifier.y,
    );

    // final rotatedResizedRect = rotateRect(resizedRect, angle, center);
    // context.read<DebugPointCubit>().update([
    //   rotatedResizedRect.tl,
    //   rotatedResizedRect.tr,
    //   rotatedResizedRect.bl,
    //   rotatedResizedRect.br,
    //   cursorDelta,
    //   rotatedCursorDelta(),
    // ]);

    var topLeft = resizedRect.topLeft;
    var size = resizedRect.size;
    var flipX = resizedRect.edges.tr.dx < resizedRect.edges.tl.dx;
    var flipY = resizedRect.edges.tr.dy > resizedRect.edges.br.dy;

    _component.value = Component(
      topLeft,
      size,
      angle,
      flipX,
      flipY,
    );
  }

  Size getSize() => _visualComponent.value.size / getScale();

  double getScale() => toScene(const Offset(1, 0)).dx - toScene(Offset.zero).dx;
}
