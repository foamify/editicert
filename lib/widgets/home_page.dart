part of '../main.dart';

class HomePage extends StatefulWidget with GetItStatefulWidgetMixin {
  HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with GetItStateMixin {
  final oMatrix = ValueNotifier(Matrix4.identity());
  var isShowColorPicker = false;

  @override
  void dispose() {
    oMatrix.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final canvasStateProvider =
        watchX((CanvasService canvasState) => canvasState.state);
    //
    final canvasEvents = context.watch<CanvasEventsCubit>();

    final leftClick = canvasEvents.state.contains(CanvasEvent.leftClick);

    final middleClick = canvasEvents.state.contains(CanvasEvent.middleClick);

    final isCreateTooling = canvasEvents.containsAny({
      CanvasEvent.creatingRectangle,
      CanvasEvent.creatingFrame,
      CanvasEvent.creatingText,
    });
    final isComponentTooling = canvasEvents.containsAny({
      CanvasEvent.draggingComponent,
      CanvasEvent.resizingComponent,
      CanvasEvent.rotatingComponent,
    });
    final isNotCanvasTooling = isComponentTooling || isCreateTooling;
    final isCanvasTooling = canvasEvents.containsAny({
      CanvasEvent.panningCanvas,
      CanvasEvent.zoomingCanvas,
    });
    final isZooming = canvasEvents.containsAny({CanvasEvent.zoomingCanvas});

    final transformationController =
        context.watch<CanvasTransformCubit>().state;
    final tool = context.watch<ToolCubit>().state;
    final isToolHand = tool == ToolType.hand;
    //
    final components =
        watchX((ComponentService componentsState) => componentsState.state);
    final selected = watchX((Selected selectedState) => selectedState.state);
    // final hovered = watchX((Hovered hoveredState) => hoveredState.state);
    //
    final keys = context.watch<KeysCubit>().state;
    keys;
    final pressedMeta = keys.contains(LogicalKeyboardKey.metaLeft) ||
        keys.contains(LogicalKeyboardKey.metaRight) ||
        keys.contains(LogicalKeyboardKey.meta);

    final mqSize = MediaQuery.sizeOf(context);
    final colorScheme = Theme.of(context).colorScheme;

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
          const SingleActivator(LogicalKeyboardKey.delete):
              VoidCallbackIntent(selected.isEmpty
                  // ignore: no-empty-block
                  ? () {}
                  : () => componentsNotifier.removeSelected()),
          const SingleActivator(LogicalKeyboardKey.bracketLeft):
              VoidCallbackIntent(
            // ignore: no-empty-block
            selected.isEmpty ? () {} : () => handleGoBackward(),
          ),
          const SingleActivator(LogicalKeyboardKey.bracketRight):
              VoidCallbackIntent(
            // ignore: no-empty-block
            selected.isEmpty ? () {} : () => handleGoForward(),
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
                    width: canvasStateProvider.size.width *
                        transform.getMaxScaleOnAxis(),
                    height: canvasStateProvider.size.height *
                        transform.getMaxScaleOnAxis(),
                    foregroundDecoration: BoxDecoration(
                      border: !canvasStateProvider.hidden
                          ? null
                          : Border.all(
                              color: Colors.grey,
                              strokeAlign: BorderSide.strokeAlignOutside,
                              width: 2,
                            ),
                      borderRadius: BorderRadius.circular(1),
                    ),
                    decoration: BoxDecoration(
                      color: canvasStateProvider.hidden
                          ? null
                          : canvasStateProvider.color,
                      border: !canvasStateProvider.hidden
                          ? null
                          : Border.all(
                              color: Colors.grey,
                              strokeAlign: BorderSide.strokeAlignOutside,
                              width: 1,
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
                              selectedNotifier.clear();
                              hoveredNotifier.clear();
                              isShowColorPicker = false;
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
                            .where((element) =>
                                element.type == ComponentType.frame)
                            .map((e) {
                          return buildComponentLabel(
                            e,
                            canvasStateProvider.color,
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
                        AnimatedBuilder(
                          animation: Listenable.merge([
                            componentsNotifier.state,
                            selectedNotifier.state,
                          ]),
                          builder: (_, __) => Stack(
                            children: componentsNotifier.state.value
                                .mapIndexed((i, e) => ControllerWidget(i))
                                .toList(),
                          ),
                        ),

                        // selected controller(s) (should be at the front of every
                        // controllers)
                        AnimatedBuilder(
                          animation: Listenable.merge([
                            componentsNotifier.state,
                            selectedNotifier.state,
                          ]),
                          builder: (_, __) => Stack(
                            children: selectedNotifier.state.value
                                .mapIndexed((i, e) => ControllerWidget(e))
                                .toList(),
                          ),
                        ),
                        // components
                        if (canvasEvents.containsAny({CanvasEvent.editingText}))
                          ValueListenableBuilder(
                            valueListenable: transformationController,
                            builder: (_, transform2, __) => Stack(
                              clipBehavior: Clip.none,
                              children: [
                                ...selectedNotifier.state.value
                                    .where((e) =>
                                        // ignore: avoid-unsafe-collection-methods
                                        components[e].type ==
                                        ComponentType.text)
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
                          ),

                        if (kDebugMode)
                          ...context2
                              .watch<DebugPointCubit>()
                              .state
                              .map((e) => Builder(builder: (_) {
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
                                  })),
                      ],
                    ),
                  ),

                  //

                  if (tool == ToolType.rectangle ||
                      isCreateTooling ||
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
                        context.read<CanvasEventsCubit>().add(state);
                      },
                      onPointerUp: (event) {
                        (event.kind == PointerDeviceKind.mouse &&
                                event.buttons == kMiddleMouseButton)
                            ? CanvasEvent.middleClick
                            : CanvasEvent.leftClick;
                        context.read<CanvasEventsCubit>().remove(
                              CanvasEvent.leftClick,
                            );
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
                      child: MouseRegion(
                        cursor: isToolHand
                            ? Platform.isWindows
                                ? SystemMouseCursors.click
                                : canvasEvents.state.contains(
                                    CanvasEvent.panningCanvas,
                                  )
                                    ? SystemMouseCursors.grabbing
                                    : SystemMouseCursors.grab
                            : SystemMouseCursors.none,
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
                          panEnabled: (isToolHand &&
                                  (!isNotCanvasTooling || isCanvasTooling)) ||
                              (isCanvasTooling && !leftClick && !isZooming),
                          onInteractionStart: (details) {
                            if (pressedMeta) {
                              context.read<CanvasEventsCubit>().add(
                                    CanvasEvent.zoomingCanvas,
                                  );
                            } else {
                              context.read<CanvasEventsCubit>().add(
                                    CanvasEvent.panningCanvas,
                                  );
                            }
                          },
                          onInteractionUpdate: (details) {
                            context
                                .read<CanvasTransformCubit>()
                                .update(transformationController.value);
                            if (details.scale == 1 && !pressedMeta) {
                              context.read<CanvasEventsCubit>().add(
                                    CanvasEvent.panningCanvas,
                                  );
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
                TopBar(),
                Expanded(
                  child: Row(
                    children: [
                      /// Left Sidebar
                      LeftSidebar(),
                      const Expanded(child: SizedBox.shrink()),
                      RightSidebar(
                        toggleColorPicker: () {
                          setState(() {
                            isShowColorPicker = !isShowColorPicker;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),

            /// Color picker
            if (isShowColorPicker)
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
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Expanded(
                          child: ColorPicker(
                            color: canvasStateProvider.color,
                            onColorChanged: (value) {
                              canvasStateNotifier.update(
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
                            enableTonalPalette: false,
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
        final component = e.component;
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
    final component = e.component;
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
                      componentsNotifier.replace(index, name: value);

                      final textStyle = Theme.of(context).textTheme.bodyMedium;

                      final textSpan = TextSpan(
                        text: value,
                        style: textStyle,
                      );

                      final textPainter = TextPainter(
                        text: textSpan,
                        textDirection: TextDirection.ltr,
                      );

                      textPainter.layout(
                        minWidth: 0,
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

                        componentsNotifier.replace(
                          index,
                          transform: Component(
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
