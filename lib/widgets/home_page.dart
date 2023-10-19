part of '../main.dart';

// ignore: public_member_api_docs
class HomePage extends StatefulWidget {
  // ignore: public_member_api_docs
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final oMatrix = ValueNotifier(Matrix4.identity());
  var _isShowColorPicker = false;

  @override
  void dispose() {
    oMatrix.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final canvasEvents = context.canvasEventsCubitWatch;
    //

    final leftClick = context.canvasEventsCubitSelect(
      (value) => value.state.contains(CanvasEvent.leftClick),
    );

    final middleClick = context.canvasEventsCubitSelect(
      (value) => value.state.contains(CanvasEvent.middleClick),
    );

    final isCreateTooling = context.canvasEventsCubitSelect(
      (value) => value.containsAny({
        CanvasEvent.creatingRectangle,
        CanvasEvent.creatingFrame,
        CanvasEvent.creatingText,
      }),
    );
    final isComponentTooling = context.canvasEventsCubitSelect(
      (value) => value.containsAny({
        CanvasEvent.draggingComponent,
        CanvasEvent.resizingComponent,
        CanvasEvent.rotatingComponent,
      }),
    );
    final isNotCanvasTooling = isComponentTooling || isCreateTooling;
    final isCanvasTooling = context.canvasEventsCubitSelect(
      (value) => value.containsAny({
        CanvasEvent.panningCanvas,
        CanvasEvent.zoomingCanvas,
      }),
    );
    final isZooming = context.canvasEventsCubitSelect(
      (value) => value.containsAny({CanvasEvent.zoomingCanvas}),
    );

    final transformationController =
        context.canvasTransformCubitSelect((value) => value.state);
    final tool = context.toolCubitSelect((value) => value.state);
    final isToolHand =
        context.toolCubitSelect((value) => value.state == ToolType.hand);
    //
    final components = context.componentsCubitSelect((value) => value.state);
    final selected = context.selectedCubitSelect((value) => value.state);
    final hovered = context.hoveredCubitSelect((value) => value.state);
    //
    final keys = context.watch<KeysCubit>().state;
    keys;
    final pressedMeta = keys.contains(LogicalKeyboardKey.metaLeft) ||
        keys.contains(LogicalKeyboardKey.metaRight) ||
        keys.contains(LogicalKeyboardKey.meta);

    final mqSize = MediaQuery.sizeOf(context);
    final colorScheme = Theme.of(context).colorScheme;

    late final SystemMouseCursor mouseCursor;

    if (isToolHand || middleClick) {
      if (kIsWeb || !Platform.isWindows) {
        if (canvasEvents.state.contains(CanvasEvent.panningCanvas)) {
          mouseCursor = SystemMouseCursors.grabbing;
        } else {
          mouseCursor = SystemMouseCursors.grab;
        }
      } else {
        mouseCursor = SystemMouseCursors.click;
      }
    } else {
      mouseCursor = SystemMouseCursors.none;
    }

    final canvasState = context.canvasCubitWatch.state;

    return RawKeyboardListener(
      focusNode: FocusNode(),
      autofocus: true,
      onKey: (event) {
        final key = event.logicalKey;
        event.isKeyPressed(key)
            ? context.read<KeysCubit>().add(event.logicalKey)
            : context.read<KeysCubit>().remove(event.logicalKey);
        final shortcuts = {
          const SingleActivator(LogicalKeyboardKey.keyV):
              VoidCallbackIntent(context.read<ToolCubit>().setMove),
          const SingleActivator(LogicalKeyboardKey.keyF):
              VoidCallbackIntent(context.read<ToolCubit>().setFrame),
          const SingleActivator(LogicalKeyboardKey.keyR):
              VoidCallbackIntent(context.read<ToolCubit>().setRectangle),
          const SingleActivator(LogicalKeyboardKey.keyH):
              VoidCallbackIntent(context.read<ToolCubit>().setHand),
          const SingleActivator(LogicalKeyboardKey.keyT):
              VoidCallbackIntent(context.read<ToolCubit>().setText),
          const SingleActivator(LogicalKeyboardKey.delete): VoidCallbackIntent(
            selected.isEmpty
                // ignore: no-empty-block
                ? () {}
                : context.deleteSelectedComponent,
          ),
          const SingleActivator(LogicalKeyboardKey.bracketLeft):
              VoidCallbackIntent(
            // ignore: no-empty-block
            selected.isEmpty ? () {} : context.handleGoBackward,
          ),
          const SingleActivator(LogicalKeyboardKey.bracketRight):
              VoidCallbackIntent(
            // ignore: no-empty-block
            selected.isEmpty ? () {} : context.handleGoForward,
          ),
        };
        var i = 0;
        while (i < shortcuts.length) {
          if (ShortcutActivator.isActivatedBy(
            shortcuts.keys.elementAt(i),
            event,
          )) {
            shortcuts.values.elementAt(i).callback();
          }
          i++;
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF333333),
        body: Stack(
          clipBehavior: Clip.none,
          children: [
            /// Canvas Background
            ValueListenableBuilder(
              valueListenable: transformationController,
              builder: (_, transform, child) {
                return Positioned(
                  left: transform.getTranslation().x + kSidebarWidth,
                  top: transform.getTranslation().y + kTopbarHeight,
                  child: Container(
                    width:
                        canvasState.size.width * transform.getMaxScaleOnAxis(),
                    height:
                        canvasState.size.height * transform.getMaxScaleOnAxis(),
                    foregroundDecoration: BoxDecoration(
                      border: !canvasState.hidden
                          ? null
                          : Border.all(
                              color: Colors.grey,
                              strokeAlign: BorderSide.strokeAlignOutside,
                              width: 2,
                            ),
                      borderRadius: BorderRadius.circular(1),
                    ),
                    decoration: BoxDecoration(
                      color: canvasState.hidden ? null : canvasState.color,
                      border: !canvasState.hidden
                          ? null
                          : Border.all(
                              color: Colors.grey,
                              strokeAlign: BorderSide.strokeAlignOutside,
                            ),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black45,
                          blurRadius: 24,
                          blurStyle: BlurStyle.outer,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            /// Components and Controllers
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: kSidebarWidth)
                  .copyWith(top: kTopbarHeight),
              // Canvas
              child: Stack(
                children: [
                  // Background/canvas
                  ValueListenableBuilder(
                    valueListenable: transformationController,
                    builder: (context2, transform, child) => Stack(
                      clipBehavior: Clip.none,
                      children: [
                        // unselect all
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              context.selectedCubit.clear();
                              context.hoveredCubit.clear();
                              _isShowColorPicker = false;
                            });
                          },
                          child: Container(
                            width: mqSize.width,
                            height: mqSize.height,
                            color: Colors.transparent,
                          ),
                        ),
                        // components label
                        ...components
                            .where(
                          (element) => element.type == ComponentType.frame,
                        )
                            .map((e) {
                          return buildComponentLabel(
                            e,
                            canvasState.color,
                          );
                        }),

                        // components
                        ValueListenableBuilder(
                          valueListenable: transformationController,
                          builder: (_, transform2, __) => Stack(
                            clipBehavior: Clip.none,
                            children: [
                              ...components.mapIndexed((i, component) {
                                return component.hidden ||
                                        (component.type == ComponentType.text &&
                                            selected.contains(i) &&
                                            canvasEvents.containsAny(
                                              {CanvasEvent.editingText},
                                            ))
                                    ? const SizedBox.shrink()
                                    : buildComponentWidget(
                                        i,
                                        component,
                                        transform2,
                                      );
                              }),
                            ],
                          ),
                        ),

                        // controller for selections
                        BlocBuilder<ComponentsCubit, List<ComponentData>>(
                          builder: (context, state) => Stack(
                            children: state
                                .mapIndexed((i, e) => ControllerWidget(i))
                                .toList(),
                          ),
                        ),

                        // selected controller(s) (should be at the front of every
                        // controllers)
                        BlocBuilder<SelectedCubit, Set<int>>(
                          builder: (context, state) {
                            return Stack(
                              children: state
                                  .mapIndexed((i, e) => ControllerWidget(e))
                                  .toList(),
                            );
                          },
                        ),
                        // components
                        if (canvasEvents.containsAny({CanvasEvent.editingText}))
                          BlocBuilder<ComponentsCubit, List<ComponentData>>(
                            builder: (context, components) {
                              return BlocBuilder<SelectedCubit, Set<int>>(
                                builder: (context, state) {
                                  return ValueListenableBuilder(
                                    valueListenable: transformationController,
                                    builder: (_, transform2, __) => Stack(
                                      clipBehavior: Clip.none,
                                      children: [
                                        ...state
                                            .where(
                                          (e) =>
                                              // ignore: avoid-unsafe-collection-methods
                                              components[e].type ==
                                              ComponentType.text,
                                        )
                                            .mapIndexed((i, e) {
                                          // ignore: avoid-unsafe-collection-methods
                                          final component = components[e];

                                          return component.hidden
                                              ? const SizedBox.shrink()
                                              : buildComponentWidget(
                                                  e,
                                                  component,
                                                  transform2,
                                                  editText: true,
                                                );
                                        }),
                                      ],
                                    ),
                                  );
                                },
                              );
                            },
                          ),

                        if (kDebugMode)
                          BlocBuilder<DebugPointCubit, List<Offset>>(
                            builder: (_, state) => Stack(
                              children: [
                                ...state.map((e) {
                                  final component = e;
                                  final scale = transform.getMaxScaleOnAxis();
                                  return Positioned(
                                    left: transform.getTranslation().x +
                                        component.dx * scale,
                                    top: transform.getTranslation().y +
                                        component.dy * scale,
                                    child: Container(
                                      width: 5,
                                      height: 5,
                                      color: Colors.red,
                                    ),
                                  );
                                }),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),

                  //

                  if (isCreateTooling ||
                      tool == ToolType.rectangle ||
                      tool == ToolType.frame ||
                      tool == ToolType.text)
                    const CreatorWidget(),

                  // camera (kinda)
                  TransparentPointer(
                    transparent: !isToolHand,
                    child: Listener(
                      onPointerDown: (event) {
                        final state = (event.kind == PointerDeviceKind.mouse &&
                                event.buttons == kMiddleMouseButton)
                            ? CanvasEvent.middleClick
                            : CanvasEvent.leftClick;
                        if (state == CanvasEvent.middleClick) {
                          context.read<CanvasEventsCubit>().add(state);
                        }
                      },
                      onPointerUp: (event) {
                        final canvasEvent =
                            context.read<CanvasEventsCubit>().state;
                        if (canvasEvent.contains(CanvasEvent.middleClick)) {
                          canvasEvent.remove(CanvasEvent.middleClick);
                        }
                      },
                      onPointerHover: (event) {
                        context
                            .read<CanvasEventsCubit>()
                            .remove(CanvasEvent.normalCursor);
                        context.read<PointerCubit>().update(event.position);
                      },
                      onPointerMove: (event) {
                        context
                            .read<CanvasEventsCubit>()
                            .remove(CanvasEvent.normalCursor);
                        context.read<PointerCubit>().update(event.position);
                      },
                      onPointerPanZoomStart: (event) {
                        late final CanvasEvent canvasEvent;
                        if (pressedMeta) {
                          canvasEvent = CanvasEvent.zoomingCanvas;
                        } else {
                          canvasEvent = CanvasEvent.panningCanvas;
                        }
                        context.read<CanvasEventsCubit>().add(canvasEvent);
                      },
                      onPointerPanZoomEnd: (event) {
                        context.read<CanvasEventsCubit>().removeAll([
                          CanvasEvent.zoomingCanvas,
                          CanvasEvent.panningCanvas,
                        ]);
                      },
                      child: MouseRegion(
                        cursor: mouseCursor,
                        onEnter: (event) {
                          WidgetsBinding.instance
                              .addPostFrameCallback((timeStamp) {
                            context
                                .read<CanvasEventsCubit>()
                                .remove(CanvasEvent.normalCursor);
                          });
                        },
                        onExit: (event) {
                          print('$mounted onExitCalled');
                          WidgetsBinding.instance
                              .addPostFrameCallback((timeStamp) {
                            context
                                .read<CanvasEventsCubit>()
                                .add(CanvasEvent.normalCursor);
                          });
                        },
                        child: InteractiveViewer.builder(
                          transformationController: transformationController,
                          panEnabled: middleClick ||
                              (isToolHand &&
                                  (!isNotCanvasTooling || isCanvasTooling)) ||
                              (isCanvasTooling && !leftClick && !isZooming),
                          onInteractionStart: (details) {
                            if (pressedMeta) {
                              context.read<CanvasEventsCubit>().add(
                                    CanvasEvent.zoomingCanvas,
                                  );
                            } else if (middleClick ||
                                (isToolHand &&
                                    (!isNotCanvasTooling || isCanvasTooling)) ||
                                (isCanvasTooling && !leftClick && !isZooming)) {
                              context.read<CanvasEventsCubit>().add(
                                    CanvasEvent.panningCanvas,
                                  );
                            }
                          },
                          onInteractionUpdate: (details) {
                            if (middleClick ||
                                (isToolHand &&
                                    (!isNotCanvasTooling || isCanvasTooling)) ||
                                (isCanvasTooling && !leftClick && !isZooming)) {
                              context
                                  .read<CanvasTransformCubit>()
                                  .update(transformationController.value);
                              if (details.scale == 1 && !pressedMeta) {
                                context.read<CanvasEventsCubit>().add(
                                      CanvasEvent.panningCanvas,
                                    );
                              }
                            }
                          },
                          onInteractionEnd: (details) =>
                              context.read<CanvasEventsCubit>()
                                ..remove(CanvasEvent.panningCanvas)
                                ..remove(CanvasEvent.zoomingCanvas),
                          maxScale: 256,
                          minScale: .01,
                          trackpadScrollCausesScale:
                              (pressedMeta || isZooming) &&
                                  !canvasEvents
                                      .containsAny({CanvasEvent.panningCanvas}),
                          interactionEndFrictionCoefficient: 0.000135,
                          boundaryMargin: const EdgeInsets.all(double.infinity),
                          builder: (_, viewport) => const SizedBox(),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            /// Top bar, side bars
            Column(
              children: [
                /// Top bar
                const TopBar(),
                Expanded(
                  child: Row(
                    children: [
                      /// Left Sidebar
                      const LeftSidebar(),
                      const Expanded(child: SizedBox.shrink()),
                      RightSidebar(
                        toggleColorPicker: () {
                          setState(() {
                            _isShowColorPicker = !_isShowColorPicker;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),

            /// Color picker
            if (_isShowColorPicker)
              Positioned(
                top: kTopbarHeight + 4,
                right: kSidebarWidth + 4,
                child: Container(
                  width: 240,
                  height: 320,
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      children: [
                        Expanded(
                          child: ColorPicker(
                            color: canvasState.color,
                            onColorChanged: (value) {
                              context.canvasCubit.update(
                                backgroundColor: value,
                              );
                            },
                            padding: EdgeInsets.zero,
                            wheelSquarePadding: 24,
                            columnSpacing: 0,
                            opacityTrackHeight: 10,
                            opacityThumbRadius: 12,
                            wheelWidth: 8,
                            colorCodeHasColor: true,
                            showColorCode: true,
                            enableOpacity: true,
                            enableShadesSelection: false,
                            pickersEnabled: const {
                              ColorPickerType.wheel: true,
                              ColorPickerType.accent: false,
                              ColorPickerType.primary: false,
                              ColorPickerType.both: false,
                              ColorPickerType.bw: false,
                              ColorPickerType.custom: false,
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            /// Handle pointer outside canvas
            Positioned(
              left: 0,
              width: kSidebarWidth,
              top: 0,
              bottom: 0,
              child: TransparentPointer(
                child: MouseRegion(
                  onEnter: (event) {
                    context
                        .read<CanvasEventsCubit>()
                        .add(CanvasEvent.normalCursor);
                  },
                  onHover: (event) {
                    context
                        .read<CanvasEventsCubit>()
                        .add(CanvasEvent.normalCursor);
                  },
                ),
              ),
            ),
            Positioned(
              right: kSidebarWidth,
              left: kSidebarWidth,
              top: 0,
              height: kTopbarHeight,
              child: TransparentPointer(
                child: MouseRegion(
                  onEnter: (event) {
                    context
                        .read<CanvasEventsCubit>()
                        .add(CanvasEvent.normalCursor);
                  },
                  onHover: (event) {
                    context
                        .read<CanvasEventsCubit>()
                        .add(CanvasEvent.normalCursor);
                  },
                ),
              ),
            ),
            Positioned(
              right: 0,
              width: kSidebarWidth,
              top: 0,
              bottom: 0,
              child: TransparentPointer(
                child: MouseRegion(
                  onEnter: (event) {
                    context
                        .read<CanvasEventsCubit>()
                        .add(CanvasEvent.normalCursor);
                  },
                  onHover: (event) {
                    context
                        .read<CanvasEventsCubit>()
                        .add(CanvasEvent.normalCursor);
                  },
                ),
              ),
            ),

            /// Custom pointer
            IgnorePointer(
              child: CustomCursorWidget(
                isToolHand: isToolHand,
                isNotCanvasTooling: isNotCanvasTooling,
                isCanvasTooling: isCanvasTooling,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildComponentLabel(ComponentData e, Color backgroundColor) {
    return ValueListenableBuilder(
      valueListenable: context.read<CanvasTransformCubit>().state,
      builder: (context, matrix, child) {
        final component = e.transform;
        final tWidth = component.size.width;
        final tHeight = component.size.height;

        final edges = component.rotatedEdges;
        final topLeft = edges.tl;
        final topRight = edges.tr;
        final bottomLeft = edges.bl;
        final bottomRight = edges.br;

        var edge = switch ((tWidth < 0, tHeight < 0)) {
          (true, false) => switch ((component.angle / pi * 180 + 90) % 360) {
              < 45 => bottomLeft,
              < 135 => topLeft,
              < 225 => topRight,
              < 315 => bottomRight,
              // ignore: no-equal-switch-expression-cases
              < 360 => bottomLeft,
              // ignore: no-equal-switch-expression-cases
              _ => topLeft,
            },
          (true, true) => switch ((component.angle / pi * 180 + 90) % 360) {
              < 45 => topLeft,
              < 135 => bottomLeft,
              < 225 => bottomRight,
              < 315 => topRight,
              // ignore: no-equal-switch-expression-cases
              < 360 => topLeft,
              // ignore: no-equal-switch-expression-cases
              _ => topLeft,
            },
          (false, true) => switch ((component.angle / pi * 180 + 90) % 360) {
              < 45 => bottomRight,
              < 135 => bottomLeft,
              < 225 => topLeft,
              < 315 => topRight,
              // ignore: no-equal-switch-expression-cases
              < 360 => bottomRight,
              // ignore: no-equal-switch-expression-cases
              _ => topLeft,
            },
          _ => switch ((component.angle / pi * 180 + 90) % 360) {
              < 45 => topRight,
              < 135 => topLeft,
              < 225 => bottomLeft,
              < 315 => bottomRight,
              // ignore: no-equal-switch-expression-cases
              < 360 => topRight,
              // ignore: no-equal-switch-expression-cases
              _ => topLeft,
            },
        };
        final newAngle = switch ((tWidth < 0, tHeight < 0)) {
          (true, false) => switch ((component.angle / pi * 180 + 90) % 360) {
              < 45 => pi / 2,
              < 135 => 0,
              < 225 => -pi / 2,
              < 315 => pi,
              // ignore: no-equal-switch-expression-cases
              < 360 => pi / 2,
              _ => 0.0,
            },
          // ignore: no-equal-switch-expression-cases
          (true, true) => switch ((component.angle / pi * 180 + 90) % 360) {
              < 45 => pi / 2,
              < 135 => 0,
              < 225 => -pi / 2,
              < 315 => pi,
              // ignore: no-equal-switch-expression-cases
              < 360 => pi / 2,
              _ => 0.0,
            },
          // ignore: no-equal-switch-expression-cases
          _ => switch ((component.angle / pi * 180 + 90) % 360) {
              < 45 => pi / 2,
              < 135 => 0,
              < 225 => -pi / 2,
              < 315 => pi,
              // ignore: no-equal-switch-expression-cases
              < 360 => pi / 2,
              _ => 0.0,
            },
        };

        // ignore: avoid-unnecessary-reassignment
        edge = MatrixUtils.transformPoint(matrix, edge);

        final scale = matrix.getMaxScaleOnAxis();

        return Positioned(
          left: edge.dx,
          top: edge.dy,
          child: Transform.rotate(
            angle: component.angle + newAngle,
            alignment: Alignment.topLeft,
            child: AnimatedSlide(
              offset: Offset(tWidth < 0 ? -1 : 0, -1),
              duration: Duration.zero,
              child: SizedBox(
                width: (tWidth * scale).abs(),
                height: 24,
                child: Text(
                  e.name,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: backgroundColor.computeLuminance() > 0.5
                        ? Colors.black.withOpacity(.5)
                        : Colors.white.withOpacity(.5),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget buildComponentWidget(
    int index,
    ComponentData e,
    Matrix4 transform, {
    bool editText = false,
  }) {
    final component = e.transform;
    final scale = transform.getMaxScaleOnAxis();
    final tWidth = component.size.width;
    final tHeight = component.size.height;

    final child = e.type == ComponentType.text
        ? SizedBox(
            width: tWidth < 0 ? -tWidth : tWidth,
            height: tHeight < 0 ? -tHeight : tHeight,
            child: !editText
                ? Text(
                    e.name,
                    style: Theme.of(context).textTheme.bodyMedium,
                  )
                : TextField(
                    autofocus: true,
                    controller: e.textController,
                    onChanged: (value) {
                      context.componentsCubit
                          .replaceCopyWith(index, name: value);

                      final textStyle = Theme.of(context).textTheme.bodyMedium;

                      final textSpan = TextSpan(
                        text: value,
                        style: textStyle,
                      );

                      final textPainter = TextPainter(
                        text: textSpan,
                        textDirection: TextDirection.ltr,
                      )..layout(
                          maxWidth: tWidth.abs(),
                        );

                      final newHeight = textPainter.height;

                      if (newHeight != component.size.height) {
                        final newRect = rotateRect(
                          Rect.fromLTWH(
                            component.rect.topLeft.dx,
                            component.rect.topLeft.dy,
                            component.size.width,
                            newHeight,
                          ),
                          component.angle,
                          component.rect.center,
                        );

                        context.componentsCubit.replaceCopyWith(
                          index,
                          transform: ComponentTransform(
                            newRect.unrotated.topLeft,
                            Size(component.size.width, newHeight),
                            component.angle,
                            component.flipX,
                            component.flipY,
                            // keepOrigin: true,
                          ),
                        );
                      }
                    },
                    onTapOutside: (event) {
                      print('TAPOUTSIDE');
                      context
                          .read<CanvasEventsCubit>()
                          .remove(CanvasEvent.editingText);
                      e.textController?.dispose();
                    },
                    expands: true,
                    maxLines: null,
                    style: Theme.of(context).textTheme.bodyMedium,
                    cursorHeight:
                        Theme.of(context).textTheme.bodyMedium?.fontSize,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 3),
                    ),
                  ),
          )
        : Container(
            width: tWidth < 0 ? -tWidth : tWidth,
            height: tHeight < 0 ? -tHeight : tHeight,
            decoration: BoxDecoration(
              borderRadius: e.borderRadius,
              border: e.border,
              color: e.color,
            ),
          );

    return Positioned(
      left: transform.getTranslation().x +
          (component.pos.dx + (tWidth < 0 ? tWidth : 0)) * scale,
      top: transform.getTranslation().y +
          (component.pos.dy + (tHeight < 0 ? tHeight : 0)) * scale,
      child: Transform.scale(
        scale: scale,
        alignment: Alignment.topLeft,
        child: Transform.rotate(
          angle: component.angle,
          child: Transform.flip(
            flipX: component.flipX,
            flipY: component.flipY,
            child: child,
          ),
        ),
      ),
    );
  }
}
