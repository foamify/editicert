// ignore_for_file: avoid-unsafe-collection-methods

part of '../main.dart';

class ControllerWidget extends StatefulWidget {
  const ControllerWidget(this.index, {super.key});

  final int index;

  @override
  State<ControllerWidget> createState() => _ControllerWidgetState();
}

class _ControllerWidgetState extends State<ControllerWidget> {
  Offset toScene(Offset offset) => tControl().toScene(offset);

  TransformationController tControl() =>
      context.read<CanvasTransformCubit>().state;

  Edges getRotatedEdges() {
    final edge =
        context.componentsCubit.state[widget.index].transform.rotatedEdges;

    final transform = tControl().value;

    return (
      tl: MatrixUtils.transformPoint(transform, edge.tl),
      tr: MatrixUtils.transformPoint(transform, edge.tr),
      bl: MatrixUtils.transformPoint(transform, edge.bl),
      br: MatrixUtils.transformPoint(transform, edge.br),
    );
  }

  Edges getEdges() {
    final edge = context.componentsCubit.state[widget.index].transform.edges;

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

  final _originalComponent = ValueNotifier(
    const ComponentTransform(Offset.zero, Size.zero, 0, false, false),
  );

  final _component = ValueNotifier(
    const ComponentTransform(Offset.zero, Size.zero, 0, false, false),
  );

  final _visualComponent = ValueNotifier(
    const ComponentTransform(Offset.zero, Size.zero, 0, false, false),
  );

  final stopwatch = Stopwatch();

  late final VoidCallback _componentListener;

  @override
  void initState() {
    super.initState();
    _componentListener = () {
      context.componentsCubit
          .replaceCopyWith(widget.index, transform: _component.value);
      _visualComponent.value = _component.value;
    };
    final component = context.componentsCubit.state[widget.index].transform;
    _component.value = component;
    _visualComponent.value = component;
    _component.addListener(_componentListener);
  }

  @override
  void dispose() {
    _component
      ..removeListener(_componentListener)
      ..dispose();
    _visualComponent.dispose();
    _originalComponent.dispose();
    _originalPosition.dispose();
    _originalTransform.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final components = context.componentsCubitSelect((value) => value.state);
    final selected =
        context.selectedCubitSelect((value) => value.contains(widget.index));

    return BlocListener<ComponentsCubit, List<ComponentData>>(
      listener: (context, state) {
        if (state.length <= widget.index) return;
        if (state[widget.index].transform != _component.value) {
          _visualComponent.value = state[widget.index].transform;
        }
      },
      child: AnimatedBuilder(
        animation: Listenable.merge([
          _visualComponent,
        ]),
        builder: (context2, child) {
          final hovers = context.hoveredCubitWatch;
          //
          final hovered = hovers.contains(widget.index);
          final component = components[widget.index];
          //
          final hidden = component.hidden;
          final locked = component.locked;
          //
          final moving = context
              .read<CanvasEventsCubit>()
              .state
              .contains(CanvasEvent.draggingComponent);

          final pos = getPos();
          final tSize = getSize();
          final tAngle = _visualComponent.value.angle;
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
                          context2.read<CanvasEventsCubit>().add(
                                CanvasEvent.draggingComponent,
                              );
                          if (!context.selectedCubit.state
                              .contains(widget.index)) {
                            context.selectedCubit.clear();
                            context.hoveredCubit.clear();
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
                          if (context.componentsCubit.state[widget.index]
                                      .type ==
                                  ComponentType.text &&
                              stopwatch.isRunning &&
                              stopwatch.elapsedMilliseconds <= 500) {
                            print('TAPPED');
                            context2
                                .read<CanvasEventsCubit>()
                                .add(CanvasEvent.editingText);
                            context.componentsCubit.replaceCopyWith(
                              widget.index,
                              textController:
                                  TextEditingController(text: component.name),
                            );
                          }
                          context.selectedCubit.add(widget.index);
                          context.hoveredCubit.add(widget.index);
                          handlePointerUp(event);
                        },
                        child: MouseRegion(
                          onEnter: (_) =>
                              context.hoveredCubit.add(widget.index),
                          onExit: (_) =>
                              context.hoveredCubit.remove(widget.index),
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
                      ].map((e) => _buildResizer(alignment: e)),
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
      ),
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
    _component.value = context.componentsCubit.state[widget.index].transform;
    _originalPosition.value = event.position;
    _originalTransform.value = tControl().value;
    _originalComponent.value = _component.value;
  }

  /// basically save data
  void handlePointerUp(PointerUpEvent event) {
    if (event.buttons == kMiddleMouseButton) return;
    print('UP');
    removeResizeEvents();
    context.read<CanvasEventsCubit>()
      ..remove(CanvasEvent.draggingComponent)
      ..remove(CanvasEvent.resizingComponent)
      ..remove(CanvasEvent.rotatingComponent);
    _component.value = _visualComponent.value;
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      removeResizeEvents();
    });
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
      Alignment.topLeft || Alignment.topCenter => topRight,
      Alignment.topRight => rotatedEdges.tr,
      Alignment.bottomLeft => rotatedEdges.bl,
      Alignment.bottomRight => rotatedEdges.br,
      //
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

    final debugEdgeColor = switch (alignment) {
      Alignment.topLeft => Colors.red,
      Alignment.topRight => Colors.green,
      Alignment.bottomLeft => Colors.blue,
      Alignment.bottomRight => Colors.orange,
      //
      _ => Colors.transparent,
    };

    final flipX = component.flipX;
    final flipY = component.flipY;

    final rotateFlipXTransform = !rotate ? 0.0 : kGestureSize * edgeScale * .25;
    final rotateFlipYTransform = !rotate ? 0.0 : kGestureSize * edgeScale * .25;

    final rotateOffset = switch (alignment) {
      Alignment.topLeft => Offset(-rotateFlipXTransform, -rotateFlipYTransform),
      Alignment.topRight => Offset(rotateFlipXTransform, -rotateFlipYTransform),
      Alignment.bottomLeft =>
        Offset(-rotateFlipXTransform, rotateFlipYTransform),
      Alignment.bottomRight =>
        Offset(rotateFlipXTransform, rotateFlipYTransform),
      //
      _ => Offset.zero,
    };

    final edgeSize =
        const Offset(kGestureSize, kGestureSize) * (rotate ? 2 : 1);

    return Positioned(
      // this is for the whole widget
      left: rotatedEdge.dx,
      top: rotatedEdge.dy,
      child: Transform.translate(
        offset: -edgeSize / 2,
        child: Transform.rotate(
          angle: component.angle,
          child: Transform.flip(
            flipX: rotate ? flipX : false,
            flipY: rotate ? flipY : false,
            child: Transform.translate(
              offset: rotateOffset,
              child: buildEdgeResizeRotateHandle(
                alignment,
                rotate,
                resize,
                selected,
                edgeScale,
                debugEdgeColor,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Listener buildEdgeResizeRotateHandle(
    Alignment? alignment,
    bool rotate,
    bool resize,
    Offset selected,
    int edgeScale,
    Color debugEdgeColor,
  ) {
    return Listener(
      onPointerDown: (event) {
        if (event.buttons == kMiddleMouseButton) return;
        final canvasEvent = switch (alignment) {
          Alignment.topLeft => CanvasEvent.resizeControllerTopLeft,
          Alignment.topRight => CanvasEvent.resizeControllerTopRight,
          Alignment.bottomLeft => CanvasEvent.resizeControllerBottomLeft,
          Alignment.bottomRight => CanvasEvent.resizeControllerBottomRight,
          _ => null,
        };
        if (canvasEvent != null) {
          context.read<CanvasEventsCubit>().add(canvasEvent);
        }
        if (rotate) {
          context.read<CanvasEventsCubit>().add(CanvasEvent.rotateCursor);
        }
        context.read<CanvasEventsCubit>().add(
              rotate
                  ? CanvasEvent.rotatingComponent
                  : CanvasEvent.resizingComponent,
            );
        handlePointerDownGlobal(event);
      },
      onPointerMove: (event) {
        if (event.buttons == kMiddleMouseButton) return;
        context.read<CanvasEventsCubit>().add(
              rotate
                  ? CanvasEvent.rotatingComponent
                  : CanvasEvent.resizingComponent,
            );
        if (resize && alignment != null) {
          handleResize(event, alignment, selected);
        } else if (rotate) {
          handleRotate(event);
        }
      },
      onPointerUp: handlePointerUp,
      child: MouseRegion(
        onEnter: (_) {
          if (context.read<CanvasEventsCubit>().containsAny({
            CanvasEvent.resizingComponent,
            CanvasEvent.draggingComponent,
            CanvasEvent.rotatingComponent,
          })) {
            return;
          }
          if (rotate) {
            context.read<CanvasEventsCubit>().add(CanvasEvent.rotateCursor);
          }
          handleCustomPointerEnter(alignment);
        },
        onExit: (_) {
          if (context.read<CanvasEventsCubit>().containsAny({
            CanvasEvent.resizingComponent,
            CanvasEvent.draggingComponent,
            CanvasEvent.rotatingComponent,
          })) {
            return;
          }
          removeResizeEvents();
        },
        child: Container(
          width: kGestureSize * edgeScale,
          height: kGestureSize * edgeScale,
          decoration: rotate
              ? BoxDecoration(
                  color: debugEdgeColor,
                  borderRadius: switch (alignment) {
                    Alignment.topLeft => const BorderRadius.only(
                        topLeft: Radius.circular(12),
                      ),
                    Alignment.topRight => const BorderRadius.only(
                        topRight: Radius.circular(12),
                      ),
                    Alignment.bottomLeft => const BorderRadius.only(
                        bottomLeft: Radius.circular(12),
                      ),
                    Alignment.bottomRight => const BorderRadius.only(
                        bottomRight: Radius.circular(12),
                      ),
                    _ => null,
                  },
                )
              : BoxDecoration(
                  // color: Colors.white,
                  color: debugEdgeColor,
                  border: Border.all(color: Colors.blueAccent),
                  borderRadius: BorderRadius.circular(2),
                ),
        ),
      ),
    );
  }

  void handleCustomPointerEnter(Alignment? alignment) {
    print('enterenrreretereers');
    if (context.read<CanvasEventsCubit>().containsAny({
      CanvasEvent.resizingComponent,
      CanvasEvent.draggingComponent,
      CanvasEvent.rotatingComponent,
    })) {
      return;
    }
    final canvasEvent = switch (alignment) {
      Alignment.topLeft => CanvasEvent.resizeControllerTopLeft,
      Alignment.topCenter => CanvasEvent.resizeControllerTopCenter,
      Alignment.topRight => CanvasEvent.resizeControllerTopRight,
      Alignment.centerLeft => CanvasEvent.resizeControllerCenterLeft,
      Alignment.centerRight => CanvasEvent.resizeControllerCenterRight,
      Alignment.bottomLeft => CanvasEvent.resizeControllerBottomLeft,
      Alignment.bottomCenter => CanvasEvent.resizeControllerBottomCenter,
      Alignment.bottomRight => CanvasEvent.resizeControllerBottomRight,
      _ => null,
    };
    if (canvasEvent != null) {
      context.read<CanvasEventsCubit>().add(canvasEvent);
    }
  }

  /// Builds the side resizer
  Widget _buildResizer({required Alignment alignment}) {
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
        Offset(-width - margin * 2, -kGestureSize / 2),
      Alignment.topCenter => const Offset(0, -kGestureSize / 2),
      Alignment.centerLeft when tSize.height < 0 =>
        Offset(-kGestureSize / 2, tSize.height),
      Alignment.centerLeft => const Offset(-kGestureSize / 2, 0),
      Alignment.bottomCenter when tSize.width < 0 =>
        Offset(-width - margin * 2, tSize.height - kGestureSize / 2),
      Alignment.bottomCenter => Offset(0, tSize.height - kGestureSize / 2),
      Alignment.centerRight when tSize.height < 0 =>
        Offset(tSize.width - kGestureSize / 2, tSize.height),
      Alignment.centerRight => Offset(tSize.width - kGestureSize / 2, 0),
      _ => Offset.zero,
    };
    final topLeft = edges.tl;
    final bottomRight = edges.br;
    final rTopLeft = rotatedEdges.tl;

    final selectedSide = switch (alignment) {
      Alignment.topCenter || Alignment.centerLeft => topLeft,
      Alignment.bottomCenter || Alignment.centerRight => bottomRight,
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

              context.read<CanvasEventsCubit>().add(
                    CanvasEvent.resizingComponent,
                  );

              final canvasEvent = switch (alignment) {
                Alignment.topCenter => CanvasEvent.resizeControllerTopCenter,
                Alignment.centerLeft => CanvasEvent.resizeControllerCenterLeft,
                Alignment.centerRight =>
                  CanvasEvent.resizeControllerCenterRight,
                Alignment.bottomCenter =>
                  CanvasEvent.resizeControllerBottomCenter,
                _ => null,
              };
              if (canvasEvent != null) {
                context.read<CanvasEventsCubit>().add(canvasEvent);
              }
            },
            onPointerMove: (event) {
              if (event.buttons == kMiddleMouseButton) return;
              handleResize(event, alignment, selectedSide);
            },
            onPointerUp: handlePointerUp,
            child: MouseRegion(
              onEnter: (_) {
                handleCustomPointerEnter(alignment);
              },
              onExit: (_) {
                if (context.read<CanvasEventsCubit>().containsAny({
                  CanvasEvent.resizingComponent,
                  CanvasEvent.draggingComponent,
                  CanvasEvent.rotatingComponent,
                })) {
                  return;
                }
                removeResizeEvents();
              },
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

  void removeResizeEvents() {
    context.read<CanvasEventsCubit>().removeAll([
      CanvasEvent.rotateCursor,
      CanvasEvent.resizeControllerTopLeft,
      CanvasEvent.resizeControllerTopCenter,
      CanvasEvent.resizeControllerTopRight,
      CanvasEvent.resizeControllerCenterLeft,
      CanvasEvent.resizeControllerCenterRight,
      CanvasEvent.resizeControllerBottomLeft,
      CanvasEvent.resizeControllerBottomCenter,
      CanvasEvent.resizeControllerBottomRight,
    ]);
  }

  /// Handles movement
  void handleMove(PointerMoveEvent event) {
    context.read<CanvasEventsCubit>().add(CanvasEvent.draggingComponent);
    final delta = event.position - _originalPosition.value;
    _component.value = _originalComponent.value.copyWith(
      pos: _originalComponent.value.pos + delta * getScale(),
    );
  }

  /// Handles rotation from the center of the widget to the pointer
  void handleRotate(PointerMoveEvent event) {
    final center = MatrixUtils.transformPoint(
      context.read<CanvasTransformCubit>().state.value,
      _originalComponent.value.rect.center,
    );
    final originalAngle = atan2(
      _originalPosition.value.dx - kSidebarWidth - center.dx,
      _originalPosition.value.dy - kTopbarHeight - center.dy,
    );
    final newAngle = atan2(
      event.position.dx - kSidebarWidth - center.dx,
      event.position.dy - kTopbarHeight - center.dy,
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
    // this is for aspect ratio resize
    final pressedShift = keys.contains(LogicalKeyboardKey.shift) ||
        keys.contains(LogicalKeyboardKey.shiftLeft) ||
        keys.contains(LogicalKeyboardKey.shiftRight);

    final originalRect = tValue.rect;
    final angle = tValue.angle;

    final rectCenter = originalRect.center;
    final originalEdges = rotateRect(originalRect, 0, Offset.zero);

    final opposingOffset = getOffset(alignment, originalEdges, opposite: true);
    final selectedOffset = getOffset(alignment, originalEdges);

    final invertedComponentTransform = tControl().value.clone()..invert();

    final rotatedOriginalPoint = rotatePoint(
      MatrixUtils.transformPoint(
        invertedComponentTransform,
        _originalPosition.value,
      ),
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

    var cursorDelta = rotatedCursorPoint - rotatedOriginalPoint;
    Offset rotatedCursorDelta() => rotatePoint(cursorDelta, Offset.zero, angle);

    // handle resizing from sides, not edges
    if (alignment case Alignment.topCenter || Alignment.bottomCenter) {
      // Remove the horizontal delta if top/bottom side resize
      cursorDelta = Offset(0, cursorDelta.dy);
    } else if (alignment case Alignment.centerLeft || Alignment.centerRight) {
      // Remove the vertical delta if left/right side resize
      cursorDelta = Offset(cursorDelta.dx, 0);
    }

    // on resize, we get the new center origin by simple getting the middle
    // offset between the opposing point and the current cursor position
    final newCenter = getMiddleOffset(
      rotatedOpposingPoint + rotatedCursorDelta(),
      rotatedSelectedPoint,
    );

    // TODO(damywise): Found method to keep aspect ratio but rotate
    // final otherEdge1 = rotatePoint(rotatedSelectedPoint + originalCursorDelta, newCenter, -90);
    // final otherEdge2 = rotatePoint(rotatedOpposingPoint, newCenter, -90);

    // TODO(damywise): Explanation
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

    // if mirrored, the center origin does not move.
    final center = pressedAlt ? originalCenter : newCenter;
    if (pressedAlt) {
      // if mirrored (pressed alt/option), resize is twice as big to compensate
      // the opposing side
      pointModifier = pointModifier * 2;
    }

    // basic resizing for edges and sides
    var resizedRect = Rect.fromCenter(
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

    final flipX = resizedRect.edges.tr.dx < resizedRect.edges.tl.dx;
    final flipY = resizedRect.edges.tr.dy > resizedRect.edges.br.dy;

    if (pressedShift) {
      // handle aspect ratio resize

      final aspectRatio = originalRect.size.aspectRatio;
      // ignore: move-variable-closer-to-its-usage
      final newAspectRatio = resizedRect.size.aspectRatio;
      // print('old: $aspectRatio');
      // print('new: $newAspectRatio');

      var newWidth = resizedRect.size.width;
      var newHeight = resizedRect.size.height;

      if (alignment
          case Alignment.topCenter ||
              Alignment.bottomCenter ||
              Alignment.centerLeft ||
              Alignment.centerRight) {
        if (alignment case Alignment.topCenter || Alignment.bottomCenter) {
          newWidth = newHeight * aspectRatio;
          resizedRect =
              resizedRect.translate((newWidth - originalRect.width) / 2, 0);
          newWidth = newHeight * aspectRatio;
        } else {
          newHeight = newWidth / aspectRatio;
          resizedRect =
              resizedRect.translate(0, (newHeight - originalRect.height) / 2);
        }
      } else {
        final originallyFlipX = tValue.flipX;
        final originallyFlipY = tValue.flipY;

        if (aspectRatio.abs() > newAspectRatio.abs()) {
          newWidth = newHeight * aspectRatio;
          if (flipX != originallyFlipX) newWidth = -newWidth;
          if (flipY != originallyFlipY) newWidth = -newWidth;
        } else if (aspectRatio.abs() < newAspectRatio.abs()) {
          newHeight = newWidth / aspectRatio;
          if (flipX != originallyFlipX) newHeight = -newHeight;
          if (flipY != originallyFlipY) newHeight = -newHeight;
        }
      }

      // mirrored
      var aspectRatioRect =
          Rect.fromCenter(center: center, width: newWidth, height: newHeight);
      if (!pressedAlt) {
        // non-mirrored
        final rotatedResizedRect = rotateRect(resizedRect, angle, center);
        final rotatedResizedOpposingOffset =
            getOffset(alignment, rotatedResizedRect, opposite: true);

        final ratioOpposingOffset =
            getOffset(alignment, aspectRatioRect.edges, opposite: true);
        final rotatedRatioOpposingOffset =
            rotatePoint(ratioOpposingOffset, center, angle);

        final delta = rotatedRatioOpposingOffset - rotatedResizedOpposingOffset;
        aspectRatioRect = aspectRatioRect.translate(-delta.dx, -delta.dy);
      }
      resizedRect = aspectRatioRect;
    }

    final topLeft = resizedRect.topLeft;
    final size = resizedRect.size;

    _component.value = ComponentTransform(topLeft, size, angle, flipX, flipY);
  }

  Size getSize() => _visualComponent.value.size / getScale();

  double getScale() => toScene(const Offset(1, 0)).dx - toScene(Offset.zero).dx;
}
