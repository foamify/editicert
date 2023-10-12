import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:collection/collection.dart';
import 'package:editicert/logic/canvas_service.dart';
import 'package:editicert/logic/component_index_service.dart';
import 'package:editicert/logic/component_service.dart';
import 'package:editicert/models/component.dart';
import 'package:editicert/state/state.dart';
import 'package:editicert/util/utils.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:get_it_mixin/get_it_mixin.dart';
import 'package:macos_window_utils/macos/ns_window_delegate.dart';
import 'package:macos_window_utils/macos_window_utils.dart';
import 'package:transparent_pointer/transparent_pointer.dart';
import 'package:window_manager/window_manager.dart';

part 'widgets/canvas.dart';
part 'widgets/controller_widget.dart';
part 'widgets/creator_widget.dart';
part 'widgets/selector_widget.dart';
part 'widgets/left_sidebar.dart';
part 'widgets/right_sidebar.dart';
part 'widgets/top_bar.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();

  setup();

  if (Platform.isMacOS) {
    await WindowManipulator.initialize(enableWindowDelegate: true);
    final delegate = _MyDelegate();
    WindowManipulator.addNSWindowDelegate(
      delegate,
    );
    final options = NSAppPresentationOptions.from({
      NSAppPresentationOption.fullScreen,
      NSAppPresentationOption.autoHideToolbar,
      NSAppPresentationOption.autoHideMenuBar,
      NSAppPresentationOption.autoHideDock,
    });

    options.applyAsFullScreenPresentationOptions();

    await Future.wait([
      WindowManipulator.makeTitlebarTransparent(),
      WindowManipulator.enableFullSizeContentView(),
      WindowManipulator.hideTitle(),
      WindowManipulator.addToolbar(),
      WindowManipulator.setToolbarStyle(
        toolbarStyle: NSWindowToolbarStyle.unified,
      ),
    ]);
  }

  runApp(Main());
  await windowManager.waitUntilReadyToShow();

  unawaited(windowManager.show());
  unawaited(windowManager.focus());
}

class _MyDelegate extends NSWindowDelegate {
  @override
  void windowWillEnterFullScreen() {
    WindowManipulator.removeToolbar();
    super.windowDidEnterFullScreen();
  }

  @override
  void windowWillExitFullScreen() {
    WindowManipulator.addToolbar();
    super.windowWillExitFullScreen();
  }
}

void setup() {
  final register = GetIt.I.registerSingleton;

  register<Components>(Components());
  register<Selected>(Selected());
  register<Hovered>(Hovered());
  register<CanvasState>(CanvasState());
}

class Main extends StatelessWidget with GetItMixin {
  Main({super.key});

  @override
  Widget build(BuildContext context) {
    final selectedProvider = watchX((Selected selected) => selected.state);

    final selected = selectedProvider.isEmpty;

    return PlatformMenuBar(
      menus: Platform.isWindows
          ? []
          : [
              const PlatformMenu(
                label: 'Application',
                menus: [
                  PlatformMenuItemGroup(members: [
                    PlatformProvidedMenuItem(
                      type: PlatformProvidedMenuItemType.about,
                    ),
                  ]),
                  PlatformMenuItemGroup(members: [
                    PlatformMenuItem(label: 'Preferences'),
                  ]),
                  PlatformMenuItemGroup(members: [
                    PlatformProvidedMenuItem(
                      type: PlatformProvidedMenuItemType.minimizeWindow,
                    ),
                    PlatformProvidedMenuItem(
                      type: PlatformProvidedMenuItemType.zoomWindow,
                    ),
                    PlatformProvidedMenuItem(
                        type: PlatformProvidedMenuItemType.hide),
                    PlatformProvidedMenuItem(
                      type: PlatformProvidedMenuItemType.hideOtherApplications,
                    ),
                    PlatformProvidedMenuItem(
                      type: PlatformProvidedMenuItemType.toggleFullScreen,
                    ),
                    PlatformProvidedMenuItem(
                        type: PlatformProvidedMenuItemType.quit),
                  ]),
                ],
              ),
              const PlatformMenu(
                label: 'File',
                menus: [
                  PlatformMenuItem(
                    label: 'New Project',
                    shortcut:
                        SingleActivator(LogicalKeyboardKey.keyN, meta: true),
                  ),
                  PlatformMenuItem(
                    label: 'Open Project',
                    shortcut:
                        SingleActivator(LogicalKeyboardKey.keyO, meta: true),
                  ),
                  PlatformMenuItem(
                    label: 'Save',
                    shortcut:
                        SingleActivator(LogicalKeyboardKey.keyS, meta: true),
                  ),
                  PlatformMenuItem(
                    label: 'Save As',
                    shortcut: SingleActivator(
                      LogicalKeyboardKey.keyS,
                      meta: true,
                      shift: true,
                    ),
                  ),
                  PlatformMenuItem(
                    label: 'Close Project',
                    shortcut:
                        SingleActivator(LogicalKeyboardKey.keyW, meta: true),
                  ),
                ],
              ),
              const PlatformMenu(label: 'Assets', menus: [
                PlatformMenu(label: 'Import', menus: [
                  PlatformMenuItem(label: 'File'),
                ]),
              ]),
              PlatformMenu(
                label: 'Tools',
                menus: [
                  PlatformMenuItem(
                    label: 'Move',
                    shortcut: const SingleActivator(LogicalKeyboardKey.keyV),
                    onSelected: () => context.read<ToolCubit>().setMove(),
                  ),
                  PlatformMenuItem(
                    label: 'Frame',
                    shortcut: const SingleActivator(LogicalKeyboardKey.keyF),
                    onSelected: () => context.read<ToolCubit>().setFrame(),
                  ),
                  PlatformMenuItem(
                    label: 'Rectangle',
                    shortcut: const SingleActivator(LogicalKeyboardKey.keyR),
                    onSelected: () => context.read<ToolCubit>().setRectangle(),
                  ),
                  PlatformMenuItem(
                    label: 'Hand',
                    shortcut: const SingleActivator(LogicalKeyboardKey.keyH),
                    onSelected: () => context.read<ToolCubit>().setHand(),
                  ),
                  PlatformMenuItem(
                    label: 'Text',
                    shortcut: const SingleActivator(LogicalKeyboardKey.keyT),
                    onSelected: () => context.read<ToolCubit>().setText(),
                  ),
                ],
              ),
              PlatformMenu(
                label: 'Shortcuts',
                menus: [
                  PlatformMenuItem(
                    label: 'Remove Selected',
                    shortcut: Platform.isMacOS
                        ? const SingleActivator(LogicalKeyboardKey.backspace)
                        : const SingleActivator(LogicalKeyboardKey.delete),
                    onSelected: selected
                        ? null
                        : () => componentsNotifier.removeSelected(),
                  ),
                  PlatformMenuItem(
                    label: 'Bring Backward',
                    shortcut:
                        const SingleActivator(LogicalKeyboardKey.bracketLeft),
                    onSelected: selected ? null : () => handleGoBackward(),
                  ),
                  PlatformMenuItem(
                    label: 'Bring Forward',
                    shortcut:
                        const SingleActivator(LogicalKeyboardKey.bracketRight),
                    onSelected: selected ? null : () => handleGoForward(),
                  ),
                ],
              ),
            ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Editicert',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blueGrey,
            brightness: Brightness.dark,
          ),
          useMaterial3: true,
        ),
        home: MultiBlocProvider(providers: [
          BlocProvider(create: (_) => CanvasEventsCubit()),
          BlocProvider(create: (_) => CanvasTransformCubit()),
          BlocProvider(create: (_) => KeysCubit()),
          BlocProvider(create: (_) => PointerCubit(Offset.zero)),
          BlocProvider(create: (_) => ToolCubit(ToolType.move)),
          //
          BlocProvider(create: (_) => DebugPointCubit()),
        ], child: HomePage()),
      ),
    );
  }
}

void handleGoBackward() {
  final index = selectedNotifier.state.value.singleOrNull;
  if (index == null || index == 0) return;
  componentsNotifier.reorder(index, index - 1);
}

void handleGoForward() {
  final index = selectedNotifier.state.value.singleOrNull;
  if (index == null || index == componentsNotifier.state.value.length - 1) {
    return;
  }
  componentsNotifier.reorder(index, index + 1);
}

class HomePage extends StatefulWidget with GetItStatefulWidgetMixin {
  HomePage({
    super.key,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with GetItStateMixin {
  final oMatrix = ValueNotifier(Matrix4.identity());
  var isShowColorPicker = false;

  @override
  Widget build(BuildContext context) {
    final canvasStateProvider =
        watchX((CanvasState canvasState) => canvasState.state);
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
    final isZooming = canvasEvents.containsAny(
      {CanvasEvent.zoomingCanvas},
    );

    final transformationController =
        context.watch<CanvasTransformCubit>().state;
    final tool = context.watch<ToolCubit>().state;
    final isToolHand = tool == ToolType.hand;
    //
    final components = watchX((Components components) => components.state);
    final selected = watchX((Selected selected) => selected.state);
    final hovered = watchX((Hovered hovered) => hovered.state);
    //
    final keys = context.watch<KeysCubit>().state;
    keys;
    final pressedMeta = keys.contains(LogicalKeyboardKey.metaLeft) ||
        keys.contains(LogicalKeyboardKey.metaRight) ||
        keys.contains(LogicalKeyboardKey.meta);

    final mqSize = MediaQuery.of(context).size;
    final colorScheme = Theme.of(context).colorScheme;

    return RawKeyboardListener(
      focusNode: FocusNode(),
      autofocus: true,
      onKey: (value) {
        value.isKeyPressed(value.logicalKey)
            ? context.read<KeysCubit>().add(value.logicalKey)
            : context.read<KeysCubit>().remove(value.logicalKey);
        // if (value.isKeyPressed(LogicalKeyboardKey.keyV)) {
        //   context.read<ToolCubit>().setMove();
        // }
        // if (value.isKeyPressed(LogicalKeyboardKey.keyR)) {
        //   context.read<ToolCubit>().setCreate();
        // }
        // if (value.isKeyPressed(LogicalKeyboardKey.keyH)) {
        //   context.read<ToolCubit>().setHand();
        // }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF333333),
        body: Stack(
          clipBehavior: Clip.none,
          children: [
            /// Canvas Background
            ValueListenableBuilder(
              valueListenable: transformationController,
              builder: (context, transform, child) {
                return Positioned(
                  left: transform.getTranslation().x + sidebarWidth,
                  top: transform.getTranslation().y + topbarHeight,
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
                              width: 1),
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
              padding: const EdgeInsets.symmetric(horizontal: sidebarWidth)
                  .copyWith(top: topbarHeight),
              // Canvas
              child: Stack(
                children: [
                  // Background/canvas
                  ValueListenableBuilder(
                    valueListenable: transformationController,
                    builder: (context, transform, child) => Stack(
                      clipBehavior: Clip.none,
                      children: [
                        // unselect all
                        GestureDetector(
                          onTap: () {
                            selectedNotifier.clear();
                            hoveredNotifier.clear();
                            isShowColorPicker = false;
                            setState(() {});
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
                            .map(
                          (e) {
                            return buildComponentLabel(
                              e,
                              canvasStateProvider.color,
                            );
                          },
                        ),

                        // components
                        ValueListenableBuilder(
                          valueListenable: transformationController,
                          builder: (context, transform, child) => Stack(
                            clipBehavior: Clip.none,
                            children: [
                              ...components.mapIndexed(
                                (i, component) {
                                  return component.hidden ||
                                          (component.type ==
                                                  ComponentType.text &&
                                              selected.contains(i) &&
                                              canvasEvents.containsAny(
                                                  {CanvasEvent.editingText}))
                                      ? const SizedBox.shrink()
                                      : buildComponentWidget(
                                          i, component, transform);
                                },
                              ),
                            ],
                          ),
                        ),

                        // controller for selections
                        AnimatedBuilder(
                          animation: Listenable.merge([
                            componentsNotifier.state,
                            selectedNotifier.state,
                          ]),
                          builder: (context, child) => Stack(
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
                          builder: (context, child) => Stack(
                            children: selectedNotifier.state.value
                                .mapIndexed((i, e) => ControllerWidget(e))
                                .toList(),
                          ),
                        ),
                        // components
                        if (canvasEvents.containsAny({CanvasEvent.editingText}))
                          ValueListenableBuilder(
                            valueListenable: transformationController,
                            builder: (context, transform, child) => Stack(
                              clipBehavior: Clip.none,
                              children: [
                                ...selectedNotifier.state.value
                                    .where((e) =>
                                        components[e].type ==
                                        ComponentType.text)
                                    .mapIndexed(
                                  (i, e) {
                                    final component = components[e];

                                    return component.hidden
                                        ? const SizedBox.shrink()
                                        : buildComponentWidget(
                                            e, component, transform,
                                            editText: true);
                                  },
                                ),
                              ],
                            ),
                          ),

                        if (kDebugMode)
                          ...context
                              .watch<DebugPointCubit>()
                              .state
                              .map((e) => Builder(builder: (context) {
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
                                  }))
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
                        context.read<CanvasEventsCubit>().add(
                              state,
                            );
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
                      child: MouseRegion(
                        cursor: switch ((
                          context
                              .read<CanvasEventsCubit>()
                              .state
                              .contains(CanvasEvent.leftClick),
                          isToolHand && (!isNotCanvasTooling || isCanvasTooling)
                        )) {
                          (false, true) => SystemMouseCursors.grab,
                          (true, true) => SystemMouseCursors.grabbing,
                          _ => MouseCursor.defer
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
                          trackpadScrollCausesScale:
                              (pressedMeta || isZooming) &&
                                  !canvasEvents
                                      .containsAny({CanvasEvent.panningCanvas}),
                          interactionEndFrictionCoefficient: 0.000135,
                          boundaryMargin: const EdgeInsets.all(double.infinity),
                          builder: (context, viewport) => const SizedBox(),
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
                      const Expanded(
                        child: SizedBox.shrink(),
                      ),
                      RightSidebar(
                        toggleColorPicker: () {
                          isShowColorPicker = !isShowColorPicker;
                          setState(() {});
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
                top: topbarHeight + 4,
                right: sidebarWidth + 4,
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
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            /// Custom pointer handler
            Positioned.fill(
              child: TransparentPointer(
                child: Builder(
                  builder: (context) {
                    return MouseRegion(
                      cursor: switch (leftClick) {
                        true
                            when context.read<CanvasEventsCubit>().containsAny(
                              {
                                CanvasEvent.resizingComponent,
                                CanvasEvent.rotatingComponent
                              },
                            ) =>
                          SystemMouseCursors.none,
                        _ => MouseCursor.defer
                      },
                      onHover: (event) =>
                          context.read<PointerCubit>().update(event.position),
                    );
                  },
                ),
              ),
            ),

            /// Custom pointer
            AnimatedBuilder(
              animation: Listenable.merge([
                componentsNotifier.state,
                selectedNotifier.state,
              ]),
              builder: (context, child) {
                final stateContains =
                    context.read<CanvasEventsCubit>().containsAny;

                final isRotating = context
                    .read<CanvasEventsCubit>()
                    .state
                    .contains(CanvasEvent.rotatingComponent);

                final enabled = stateContains({
                  CanvasEvent.rotatingComponent,
                  CanvasEvent.resizingComponent
                });

                var angle = 0.0;
                if (selectedNotifier.state.value.isNotEmpty && enabled) {
                  angle = componentsNotifier
                          .state
                          .value[selectedNotifier.state.value.first]
                          .component
                          .angle +
                      (isRotating ? pi / 6 : 0);
                }

                return !enabled
                    ? const SizedBox.shrink()
                    : Transform.translate(
                        offset: context.read<PointerCubit>().state,
                        child: Transform.translate(
                          offset: const Offset(-12, -12),
                          child: Transform.rotate(
                            angle: angle,
                            child: IgnorePointer(
                              child: SizedBox(
                                width: 24,
                                height: 24,
                                child: Icon(
                                  isRotating
                                      ? CupertinoIcons.arrow_turn_up_right
                                      : CupertinoIcons.arrow_left_right,
                                  size: 14,
                                  color: colorScheme.onPrimary,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
              },
            )
          ],
        ),
      ),
    );
  }

  Widget buildComponentLabel(
    ComponentData e,
    Color backgroundColor,
  ) {
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
              < 360 => bottomLeft,
              _ => topLeft,
            },
          (true, true) => switch ((component.angle / pi * 180 + 90) % 360) {
              < 45 => topLeft,
              < 135 => bottomLeft,
              < 225 => bottomRight,
              < 315 => topRight,
              < 360 => topLeft,
              _ => topLeft,
            },
          (false, true) => switch ((component.angle / pi * 180 + 90) % 360) {
              < 45 => bottomRight,
              < 135 => bottomLeft,
              < 225 => topLeft,
              < 315 => topRight,
              < 360 => bottomRight,
              _ => topLeft,
            },
          _ => switch ((component.angle / pi * 180 + 90) % 360) {
              < 45 => topRight,
              < 135 => topLeft,
              < 225 => bottomLeft,
              < 315 => bottomRight,
              < 360 => topRight,
              _ => topLeft,
            }
        };
        final newAngle = switch ((tWidth < 0, tHeight < 0)) {
          (true, false) => switch ((component.angle / pi * 180 + 90) % 360) {
              < 45 => pi / 2,
              < 135 => 0,
              < 225 => -pi / 2,
              < 315 => pi,
              < 360 => pi / 2,
              _ => 0.0,
            },
          (true, true) => switch ((component.angle / pi * 180 + 90) % 360) {
              < 45 => pi / 2,
              < 135 => 0,
              < 225 => -pi / 2,
              < 315 => pi,
              < 360 => pi / 2,
              _ => 0.0,
            },
          _ => switch ((component.angle / pi * 180 + 90) % 360) {
              < 45 => pi / 2,
              < 135 => 0,
              < 225 => -pi / 2,
              < 315 => pi,
              < 360 => pi / 2,
              _ => 0.0,
            }
        };

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

  Widget buildComponentWidget(int index, ComponentData e, Matrix4 transform,
      {bool editText = false}) {
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
          component.pos.dx * scale +
          (tWidth < 0 ? tWidth : 0),
      top: transform.getTranslation().y +
          component.pos.dy * scale +
          (tHeight < 0 ? tHeight : 0),
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
