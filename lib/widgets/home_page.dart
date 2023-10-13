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
                      child: Listener(
                        onPointerHover: (event) {
                          context
                              .read<CanvasEventsCubit>()
                              .remove(CanvasEvent.normalCursor);
                          context.read<PointerCubit>().update(event.position);
                        },
                        child: MouseRegion(
                          cursor: SystemMouseCursors.none,
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
                              } else if (isToolHand || middleClick) {
                                context.read<CanvasEventsCubit>().add(
                                      CanvasEvent.panningCanvas,
                                    );
                              }
                            },
                            onInteractionUpdate: (details) {
                              context
                                  .read<PointerCubit>()
                                  .update(details.focalPoint);
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
                            trackpadScrollCausesScale: (pressedMeta ||
                                    isZooming) &&
                                !canvasEvents
                                    .containsAny({CanvasEvent.panningCanvas}),
                            interactionEndFrictionCoefficient: 0.000135,
                            boundaryMargin:
                                const EdgeInsets.all(double.infinity),
                            builder: (_, viewport) => const SizedBox(),
                          ),
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

            /// Custom pointer handler
            // Positioned(
            //   left: kSidebarWidth,
            //   right: kSidebarWidth,
            //   top: kTopbarHeight,
            //   bottom: 0,
            //   child: TransparentPointer(
            //     child: Builder(
            //       builder: (context2) {
            //         return MouseRegion(
            //           cursor: SystemMouseCursors.none,
            //           onHover: (event) {
            //             print('${DateTime.now()} update');
            //             context2
            //                 .read<CanvasEventsCubit>()
            //                 .remove(CanvasEvent.normalCursor);
            //             context2.read<PointerCubit>().update(event.position);
            //           },
            //         );
            //       },
            //     ),
            //   ),
            // ),

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

// ignore: prefer-single-widget-per-file
class CustomCursorWidget extends StatelessWidget {
  const CustomCursorWidget({
    super.key,
    required this.isToolHand,
    required this.isNotCanvasTooling,
    required this.isCanvasTooling,
  });

  final bool isToolHand;
  final bool isNotCanvasTooling;
  final bool isCanvasTooling;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        componentsNotifier.state,
        selectedNotifier.state,
      ]),
      builder: (context2, child) {
        var canvasEvents = context2.watch<CanvasEventsCubit>();
        final stateContains = canvasEvents.state.contains;

        if (stateContains(CanvasEvent.normalCursor)) {
          return const SizedBox.shrink();
        }

        final stateContainsAny = canvasEvents.containsAny;

        final enabled = stateContainsAny({
          CanvasEvent.rotatingComponent,
          CanvasEvent.resizingComponent,
        });

        var angle = 0.0;
        if (selectedNotifier.state.value.isNotEmpty) {
          // ignore: avoid-unsafe-collection-methods
          angle = componentsNotifier
              .state
              // ignore: avoid-unsafe-collection-methods
              .value[selectedNotifier.state.value.first]
              .component
              .angle;
        }

        final alignments = {
          Alignment.topLeft: CanvasEvent.resizeControllerTopLeft,
          Alignment.topCenter: CanvasEvent.resizeControllerTopCenter,
          Alignment.topRight: CanvasEvent.resizeControllerTopRight,
          Alignment.centerLeft: CanvasEvent.resizeControllerCenterLeft,
          Alignment.centerRight: CanvasEvent.resizeControllerCenterRight,
          Alignment.bottomLeft: CanvasEvent.resizeControllerBottomLeft,
          Alignment.bottomCenter: CanvasEvent.resizeControllerBottomCenter,
          Alignment.bottomRight: CanvasEvent.resizeControllerBottomRight,
        };

        Alignment? alignment = null;
        for (var MapEntry(:key, :value) in alignments.entries) {
          if (context2.read<CanvasEventsCubit>().state.contains(value)) {
            alignment = key;
            break;
          }
        }
        print(alignment);

        final grab = switch ((
          context
              .read<CanvasEventsCubit>()
              .state
              .contains(CanvasEvent.leftClick),
          isToolHand && (!isNotCanvasTooling || isCanvasTooling),
        )) {
          (false, true) => SystemMouseCursors.grab,
          (true, true) => SystemMouseCursors.grabbing,
          _ => MouseCursor.defer,
        };

        Widget child = const SizedBox.shrink();

        if (alignment != null) {
          final rotations = {
            Alignment.topLeft: 45.0,
            Alignment.topCenter: 90,
            Alignment.topRight: 135,
            Alignment.centerLeft: 0,
            // Alignment.center: ,
            Alignment.centerRight: 0,
            Alignment.bottomRight: 225,
            Alignment.bottomCenter: 90,
            Alignment.bottomLeft: 315,
          };

          final rotate = stateContains(CanvasEvent.rotateCursor);

          final icon =
              rotate ? Icons.rotate_right : CupertinoIcons.arrow_left_right;

          child = Transform.translate(
            offset: const Offset(-6, -6),
            child: Transform.rotate(
              angle: angle + rotations[alignment]! / 180 * pi,
              child: SizedBox(
                width: 24,
                height: 24,
                child: Icon(
                  icon,
                  size: 14,
                  color: Colors.black,
                  shadows: [
                    Shadow(
                      color: Colors.white,
                      blurRadius: 1,
                    )
                  ],
                  // color: colorScheme.onPrimary,
                ),
              ),
            ),
          );
        } else {
          child = Transform.rotate(
            angle: -pi / 5,
            alignment: const Alignment(-0.2, 0.3),
            child: Stack(
              children: [
                const Icon(
                  Icons.navigation,
                  size: 18,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      blurRadius: 2,
                      color: Colors.black45,
                      offset: Offset(-.5, 0),
                    ),
                  ],
                ),
                Transform.translate(
                  offset: const Offset(2, 2),
                  child: const Icon(
                    Icons.navigation,
                    size: 14,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          );
        }

        return BlocBuilder<PointerCubit, Offset>(
          builder: (context, state) {
            return Transform.translate(
              offset: state + const Offset(-4, -5),
              child: child,
            );
          },
        );
      },
    );
  }
}
