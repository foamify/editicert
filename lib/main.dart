import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:collection/collection.dart';
import 'package:editicert/logic/canvas_service.dart';
import 'package:editicert/logic/component_index_service.dart';
import 'package:editicert/logic/component_service.dart';
import 'package:editicert/logic/global_state_service.dart';
import 'package:editicert/logic/services.dart';
import 'package:editicert/logic/tool_service.dart';
import 'package:editicert/utils.dart';
import 'package:editicert/widgets/controller_widget.dart';
import 'package:editicert/widgets/creator_widget.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:get_it_mixin/get_it_mixin.dart';
import 'package:macos_window_utils/macos/ns_window_delegate.dart';
import 'package:macos_window_utils/macos_window_utils.dart';
import 'package:transparent_pointer/transparent_pointer.dart';
import 'package:window_manager/window_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();

  if (Platform.isMacOS) {
    await WindowManipulator.initialize(enableWindowDelegate: true);
    setup();
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
    globalStateNotifier.add(GlobalStates.fullscreen);
    WindowManipulator.removeToolbar();
    super.windowDidEnterFullScreen();
  }

  @override
  void windowWillExitFullScreen() {
    globalStateNotifier.remove(GlobalStates.fullscreen);
    WindowManipulator.addToolbar();
    super.windowWillExitFullScreen();
  }
}

void setup() {
  final register = GetIt.I.registerSingleton;

  register<Components>(Components());
  register<TransformationControllerData>(TransformationControllerData());
  register<Tool>(Tool());
  register<Keys>(Keys());
  register<Selected>(Selected());
  register<Hovered>(Hovered());
  register<GlobalState>(GlobalState());
  register<CanvasState>(CanvasState());
  register<Services>(Services());
}

class Main extends StatelessWidget with GetItMixin {
  Main({super.key});

  @override
  Widget build(BuildContext context) {
    final selectedProvider = watchX((Selected selected) => selected.state);

    final selected = selectedProvider.isEmpty;

    return PlatformMenuBar(
      menus: [
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
              PlatformProvidedMenuItem(type: PlatformProvidedMenuItemType.hide),
              PlatformProvidedMenuItem(
                type: PlatformProvidedMenuItemType.hideOtherApplications,
              ),
              PlatformProvidedMenuItem(
                type: PlatformProvidedMenuItemType.toggleFullScreen,
              ),
              PlatformProvidedMenuItem(type: PlatformProvidedMenuItemType.quit),
            ]),
          ],
        ),
        const PlatformMenu(
          label: 'File',
          menus: [
            PlatformMenuItem(
              label: 'New Project',
              shortcut: SingleActivator(LogicalKeyboardKey.keyN, meta: true),
            ),
            PlatformMenuItem(
              label: 'Open Project',
              shortcut: SingleActivator(LogicalKeyboardKey.keyO, meta: true),
            ),
            PlatformMenuItem(
              label: 'Save',
              shortcut: SingleActivator(LogicalKeyboardKey.keyS, meta: true),
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
              shortcut: SingleActivator(LogicalKeyboardKey.keyW, meta: true),
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
              onSelected: () => toolNotifier.setMove(),
            ),
            PlatformMenuItem(
              label: 'Frame',
              shortcut: const SingleActivator(LogicalKeyboardKey.keyF),
              onSelected: () => toolNotifier.setFrame(),
            ),
            PlatformMenuItem(
              label: 'Rectangle',
              shortcut: const SingleActivator(LogicalKeyboardKey.keyR),
              onSelected: () => toolNotifier.setRectangle(),
            ),
            PlatformMenuItem(
              label: 'Hand',
              shortcut: const SingleActivator(LogicalKeyboardKey.keyH),
              onSelected: () => toolNotifier.setHand(),
            ),
            PlatformMenuItem(
              label: 'Text',
              shortcut: const SingleActivator(LogicalKeyboardKey.keyT),
              onSelected: () => toolNotifier.setText(),
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
              onSelected:
                  selected ? null : () => componentsNotifier.removeSelected(),
            ),
            PlatformMenuItem(
              label: 'Bring Backward',
              shortcut: const SingleActivator(LogicalKeyboardKey.bracketLeft),
              onSelected: selected ? null : () => handleGoBackward(),
            ),
            PlatformMenuItem(
              label: 'Bring Forward',
              shortcut: const SingleActivator(LogicalKeyboardKey.bracketRight),
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
        home: HomePage(),
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
    final globalStateProvider =
        watchX((GlobalState globalState) => globalState.state);

    final leftClick =
        globalStateProvider.states.contains(GlobalStates.leftClick);
    final isCreateTooling = globalStateProvider.containsAny({
      GlobalStates.creatingRectangle,
      GlobalStates.creatingFrame,
      GlobalStates.creatingText,
    });
    final isComponentTooling = globalStateProvider.containsAny({
      GlobalStates.draggingComponent,
      GlobalStates.resizingComponent,
      GlobalStates.rotatingComponent,
    });
    final isNotCanvasTooling = isComponentTooling || isCreateTooling;
    final isCanvasTooling = globalStateProvider.containsAny({
      GlobalStates.panningCanvas,
      GlobalStates.zoomingCanvas,
    });
    final isZooming = globalStateProvider.containsAny(
      {GlobalStates.zoomingCanvas},
    );

    final transformationController = watchX((
      TransformationControllerData data,
    ) =>
        data.state);
    //
    final tool = watchX((Tool tool) => tool.tool);
    final isToolHand = tool == ToolType.hand;
    tool;
    //
    final components = watchX((Components components) => components.state);
    final selected = watchX((Selected selected) => selected.state);
    final hovered = watchX((Hovered hovered) => hovered.state);
    //
    final keysProvider = watchX((Keys keys) => keys.state);
    keysProvider;
    final pressedMeta = keysProvider.contains(LogicalKeyboardKey.metaLeft) ||
        keysProvider.contains(LogicalKeyboardKey.metaRight) ||
        keysProvider.contains(LogicalKeyboardKey.meta);

    final mqSize = MediaQuery.of(context).size;
    final colorScheme = Theme.of(context).colorScheme;

    return RawKeyboardListener(
      focusNode: FocusNode(),
      autofocus: true,
      onKey: (value) {
        value.isKeyPressed(value.logicalKey)
            ? keysNotifier.add(value.logicalKey)
            : keysNotifier.remove(value.logicalKey);
        // if (value.isKeyPressed(LogicalKeyboardKey.keyV)) {
        //   toolNotifier.setMove();
        // }
        // if (value.isKeyPressed(LogicalKeyboardKey.keyR)) {
        //   toolNotifier.setCreate();
        // }
        // if (value.isKeyPressed(LogicalKeyboardKey.keyH)) {
        //   toolNotifier.setHand();
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
                  // unselect all
                  GestureDetector(
                    onTap: () {
                      selectedNotifier.clear();
                      hoveredNotifier.clear();
                    },
                    child: Container(
                      width: mqSize.width,
                      height: mqSize.height,
                      color: Colors.transparent,
                    ),
                  ),
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
                                              globalStateProvider.containsAny(
                                                  {GlobalStates.editingText}))
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
                        if (globalStateProvider
                            .containsAny({GlobalStates.editingText}))
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
                      onPointerDown: (event) => globalStateNotifier.update(
                        globalStateProvider + GlobalStates.leftClick,
                      ),
                      onPointerUp: (event) => globalStateNotifier.update(
                        globalStateProvider - GlobalStates.leftClick,
                      ),
                      child: MouseRegion(
                        cursor: switch ((
                          globalStateNotifier.state.value.states
                              .contains(GlobalStates.leftClick),
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
                              globalStateNotifier.update(
                                globalStateProvider +
                                    GlobalStates.zoomingCanvas,
                              );
                            } else if (isToolHand) {
                              globalStateNotifier.update(
                                globalStateProvider +
                                    GlobalStates.panningCanvas,
                              );
                            }
                          },
                          onInteractionUpdate: (details) {
                            services.mousePosition.value = details.focalPoint;
                            canvasTransform
                                .update(transformationController.value);
                            if (details.scale == 1 && !pressedMeta) {
                              globalStateNotifier.update(
                                globalStateProvider +
                                    GlobalStates.panningCanvas,
                              );
                            }
                          },
                          onInteractionEnd: (details) =>
                              globalStateNotifier.update(globalStateProvider -
                                  GlobalStates.panningCanvas -
                                  GlobalStates.zoomingCanvas),
                          maxScale: 256,
                          minScale: .01,
                          trackpadScrollCausesScale: (pressedMeta ||
                                  isZooming) &&
                              !globalStateProvider
                                  .containsAny({GlobalStates.panningCanvas}),
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
                Container(
                  height: topbarHeight,
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    border: Border(
                      bottom: BorderSide(
                        color: Colors.grey.withOpacity(.375),
                        width: 1,
                      ),
                    ),
                  ),
                  padding: EdgeInsets.only(
                    left: 8 +
                        (Platform.isMacOS &&
                                !globalStateNotifier.state.value.states
                                    .contains(GlobalStates.fullscreen)
                            ? 80
                            : 0),
                    right: 8,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ...[
                        (
                          text: 'Move',
                          shortcut: 'V',
                          tool: ToolType.move,
                          onTap: () {
                            toolNotifier.setMove();
                          },
                          icon: Transform.rotate(
                            angle: -pi / 5,
                            alignment: const Alignment(-0.2, 0.3),
                            child: const Icon(
                              Icons.navigation_outlined,
                              size: 18,
                            ),
                          )
                        ),
                        (
                          text: 'Frame',
                          shortcut: 'F',
                          tool: ToolType.frame,
                          onTap: () {
                            toolNotifier.setFrame();
                          },
                          icon: const Icon(
                            CupertinoIcons.grid,
                            size: 18,
                          )
                        ),
                        (
                          text: 'Rectangle',
                          shortcut: 'R',
                          tool: ToolType.rectangle,
                          onTap: () {
                            toolNotifier.setRectangle();
                          },
                          icon: const Icon(
                            CupertinoIcons.square,
                            size: 18,
                          )
                        ),
                        (
                          text: 'Hand',
                          shortcut: 'H',
                          tool: ToolType.hand,
                          onTap: () {
                            toolNotifier.setHand();
                          },
                          icon: const Icon(
                            CupertinoIcons.hand_raised,
                            size: 18,
                          )
                        ),
                        (
                          text: 'Text',
                          shortcut: 'T',
                          tool: ToolType.text,
                          onTap: () {
                            toolNotifier.setText();
                          },
                          icon: const Icon(
                            CupertinoIcons.textbox,
                            size: 18,
                          )
                        ),
                      ].map(
                        (e) => Tooltip(
                          richMessage: TextSpan(
                            children: [
                              TextSpan(
                                text: '${e.text} ',
                              ),
                              TextSpan(
                                text: ' ${e.shortcut}',
                                style: TextStyle(
                                  fontWeight: FontWeight.w900,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                          child: Card(
                            margin: EdgeInsets.zero,
                            color: tool == e.tool
                                ? colorScheme.onSurface.withOpacity(.125)
                                : colorScheme.surface,
                            elevation: 0,
                            clipBehavior: Clip.hardEdge,
                            shape: const RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(4)),
                            ),
                            child: InkWell(
                              onTap: e.onTap,
                              child: Padding(
                                padding: const EdgeInsets.all(17.0),
                                child: e.icon,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const Spacer(),
                      TextButton.icon(
                        style: ButtonStyle(
                          shape: MaterialStateProperty.all(
                            ContinuousRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                        onPressed: () {
                          transformationController.value =
                              Matrix4.identity().scaled(
                            transformationController.value.getMaxScaleOnAxis(),
                            transformationController.value.getMaxScaleOnAxis(),
                          );
                        },
                        icon: const Icon(
                          Icons.navigation_rounded,
                          size: 16,
                        ),
                        label: const Text('Recenter'),
                      ),
                      const SizedBox(width: 8),
                      ValueListenableBuilder(
                        valueListenable: transformationController,
                        builder: (context, value, child) {
                          return Text(
                            '${(value.getMaxScaleOnAxis() * 100).truncate()}%',
                          );
                        },
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Row(
                    children: [
                      /// Left Sidebar
                      Container(
                        width: sidebarWidth,
                        color: colorScheme.surface,
                        child: ListView(
                          children: components
                              .mapIndexed(
                                (i, e) => Container(
                                  padding: const EdgeInsets.only(right: 8),
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: selected.contains(i)
                                        ? colorScheme.surfaceVariant
                                        : null,
                                    border: Border.all(
                                      strokeAlign: BorderSide.strokeAlignInside,
                                      color: !hovered.contains(i) ||
                                              selected.contains(i)
                                          ? Colors.transparent
                                          : Colors.blueAccent.withOpacity(.5),
                                    ),
                                  ),
                                  // color: Colors.transparent,
                                  child: MouseRegion(
                                    onEnter: (event) => hoveredNotifier.add(i),
                                    onExit: (event) =>
                                        hoveredNotifier.remove(i),
                                    child: InkWell(
                                      onTap: () {
                                        selectedNotifier
                                          ..clear()
                                          ..add(i);
                                      },
                                      child: Row(
                                        children: [
                                          const Padding(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 8.0,
                                            ),
                                            child: Icon(
                                              Icons.rectangle_outlined,
                                              size: 12,
                                            ),
                                          ),
                                          Expanded(
                                            child: Text(
                                              e.name.replaceAll('\n', ' '),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodySmall,
                                            ),
                                          ),
                                          if (hovered.contains(i))
                                            SizedBox(
                                              width: 18 * 2,
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  IconButton(
                                                    hoverColor:
                                                        Colors.transparent,
                                                    splashColor:
                                                        Colors.transparent,
                                                    focusColor:
                                                        Colors.transparent,
                                                    highlightColor:
                                                        Colors.transparent,
                                                    padding: EdgeInsets.zero,
                                                    constraints:
                                                        BoxConstraints.tight(
                                                      Size(
                                                        e.locked ? 14 : 18,
                                                        double.infinity,
                                                      ),
                                                    ),
                                                    onPressed: () =>
                                                        componentsNotifier
                                                            .replace(
                                                      i,
                                                      locked: !e.locked,
                                                    ),
                                                    icon: Icon(
                                                      e.locked
                                                          ? CupertinoIcons
                                                              .lock_fill
                                                          : CupertinoIcons
                                                              .lock_open_fill,
                                                      size: 14,
                                                    ),
                                                  ),
                                                  IconButton(
                                                    hoverColor:
                                                        Colors.transparent,
                                                    splashColor:
                                                        Colors.transparent,
                                                    focusColor:
                                                        Colors.transparent,
                                                    highlightColor:
                                                        Colors.transparent,
                                                    padding: EdgeInsets.zero,
                                                    constraints:
                                                        BoxConstraints.tight(
                                                      const Size(
                                                        18,
                                                        double.infinity,
                                                      ),
                                                    ),
                                                    onPressed: () =>
                                                        componentsNotifier
                                                            .replace(
                                                      i,
                                                      hidden: !e.hidden,
                                                    ),
                                                    icon: Icon(
                                                      e.hidden
                                                          ? CupertinoIcons
                                                              .eye_slash
                                                          : CupertinoIcons.eye,
                                                      size: 14,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                    // child: ListTile(
                                    //   textColor: e.hidden ? Colors.grey : null,
                                    //   iconColor: e.hidden ? Colors.grey : null,
                                    //   onTap: () {
                                    // selected
                                    //       ..clear()
                                    //       ..add(i);
                                    //   },
                                    //   hoverColor: Colors.transparent,
                                    //   // selected: selected.contains(i),
                                    //   horizontalTitleGap: 4,
                                    //   title: Text(
                                    //     e.name,
                                    //     style: const TextStyle(fontSize: 12),
                                    //   ),
                                    //   leading: const Icon(
                                    //     CupertinoIcons.square,
                                    //     size: 16,
                                    //   ),
                                    //   contentPadding: const EdgeInsets.only(
                                    //       left: 4, right: 6),
                                    //   trailing: hovered.contains(i)
                                    //       ? SizedBox(
                                    //           width: 18 * 2,
                                    //           child: Row(
                                    //             mainAxisAlignment:
                                    //                 MainAxisAlignment
                                    //                     .spaceBetween,
                                    //             children: [
                                    //               IconButton(
                                    //                 hoverColor:
                                    //                     Colors.transparent,
                                    //                 splashColor:
                                    //                     Colors.transparent,
                                    //                 focusColor:
                                    //                     Colors.transparent,
                                    //                 highlightColor:
                                    //                     Colors.transparent,
                                    //                 padding: EdgeInsets.zero,
                                    //                 constraints: BoxConstraints
                                    //                     .tight(Size(
                                    //                         e.locked ? 14 : 18,
                                    //                         double.infinity)),
                                    //                 onPressed: () =>
                                    //                     .read(componentsProvider
                                    //                         .notifier)
                                    //                     .replace(i,
                                    //                         locked: !e.locked),
                                    //                 icon: Icon(
                                    //                   e.locked
                                    //                       ? CupertinoIcons
                                    //                           .lock_fill
                                    //                       : CupertinoIcons
                                    //                           .lock_open_fill,
                                    //                   size: 14,
                                    //                 ),
                                    //               ),
                                    //               IconButton(
                                    //                 hoverColor:
                                    //                     Colors.transparent,
                                    //                 splashColor:
                                    //                     Colors.transparent,
                                    //                 focusColor:
                                    //                     Colors.transparent,
                                    //                 highlightColor:
                                    //                     Colors.transparent,
                                    //                 padding: EdgeInsets.zero,
                                    //                 constraints:
                                    //                     BoxConstraints.tight(
                                    //                         const Size(
                                    //                             18,
                                    //                             double
                                    //                                 .infinity)),
                                    //                 onPressed: () =>
                                    //                     .read(componentsProvider
                                    //                         .notifier)
                                    //                     .replace(i,
                                    //                         hidden: !e.hidden),
                                    //                 icon: Icon(
                                    //                   e.hidden
                                    //                       ? CupertinoIcons
                                    //                           .eye_slash
                                    //                       : CupertinoIcons.eye,
                                    //                   size: 14,
                                    //                 ),
                                    //               ),
                                    //             ],
                                    //           ),
                                    //         )
                                    //       : null,
                                    // ),
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ),
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
                            enableBrightness: false,
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
                child: AnimatedBuilder(
                  animation: Listenable.merge([
                    globalStateNotifier.state,
                  ]),
                  builder: (context, child) {
                    var leftClick = globalStateNotifier.state.value.states
                        .contains(GlobalStates.leftClick);

                    return MouseRegion(
                      cursor: switch (leftClick) {
                        true
                            when globalStateNotifier.state.value.containsAny(
                              {
                                GlobalStates.resizingComponent,
                                GlobalStates.rotatingComponent
                              },
                            ) =>
                          SystemMouseCursors.none,
                        _ => MouseCursor.defer
                      },
                      onHover: (event) =>
                          services.mousePosition.value = event.position,
                    );
                  },
                ),
              ),
            ),

            /// Custom pointer
            AnimatedBuilder(
              animation: Listenable.merge([
                services.mousePosition,
                globalStateNotifier.state,
                toolNotifier.tool,
                componentsNotifier.state,
                selectedNotifier.state,
              ]),
              builder: (context, child) {
                final stateContains =
                    globalStateNotifier.state.value.containsAny;

                final isRotating = globalStateNotifier.state.value.states
                    .contains(GlobalStates.rotatingComponent);

                final enabled = stateContains({
                  GlobalStates.rotatingComponent,
                  GlobalStates.resizingComponent
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
                        offset: services.mousePosition.value,
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
      valueListenable: canvasTransform.state.value,
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

                      print(value);

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

                      final height = textPainter.height;
                      final newRect = rotateRect(
                        Rect.fromLTWH(
                          component.rect.topLeft.dx,
                          component.rect.topLeft.dy,
                          component.size.width,
                          height,
                        ),
                        component.angle,
                        component.rect.center,
                      );
                      if (height != component.size.height) {
                        componentsNotifier.replace(
                          index,
                          transform: Component.fromEdges(
                            (
                              tl: newRect.tl,
                              tr: newRect.tr,
                              bl: newRect.bl,
                              br: newRect.br,
                            ),
                            flipX: tWidth < 0,
                            flipY: tHeight < 0,
                            keepOrigin: true,
                          ),
                        );
                      }
                    },
                    onTapOutside: (event) {
                      print('TAPOUTSIDE');
                      globalStateNotifier.remove(GlobalStates.editingText);
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
            flipX: tWidth < 0,
            flipY: tHeight < 0,
            child: child,
          ),
        ),
      ),
    );
  }
}

class RightSidebar extends StatefulWidget with GetItStatefulWidgetMixin {
  RightSidebar({
    super.key,
    required this.toggleColorPicker,
  });

  final VoidCallback toggleColorPicker;

  @override
  State<RightSidebar> createState() => _RightSidebarState();
}

class _RightSidebarState extends State<RightSidebar> with GetItStateMixin {
  late final TextEditingController backgroundColorController;
  late final TextEditingController backgroundWidthController;
  late final TextEditingController backgroundHeightController;

  @override
  void initState() {
    backgroundColorController = TextEditingController(
      text: canvasStateNotifier.state.value.color.value
          .toRadixString(16)
          .toUpperCase()
          .substring(2),
    );
    backgroundWidthController = TextEditingController(
      text: canvasStateNotifier.state.value.size.width.toString(),
    );
    backgroundHeightController = TextEditingController(
      text: canvasStateNotifier.state.value.size.height.toString(),
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final selected = watchX((Selected selected) => selected.state);
    final canvasStateProvider =
        watchX((CanvasState canvasState) => canvasState.state);
    final component = selected.firstOrNull == null
        ? null
        : componentsNotifier.state.value[selected.first].component;
    final textTheme = Theme.of(context).textTheme;

    final controls = component == null
        ? null
        : [
            (
              children: [
                (
                  prefix: Text(
                    'X',
                    style: textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                  keyboardType: TextInputType.number,
                  controller: TextEditingController(
                    text: component.pos.dx.toStringAsFixed(1),
                  ),
                ),
                (
                  prefix: Text(
                    'Y',
                    style: textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                  keyboardType: TextInputType.number,
                  controller: TextEditingController(
                    text: component.pos.dy.toStringAsFixed(1),
                  ),
                ),
              ]
            ),
            (
              children: [
                (
                  prefix: Text(
                    'W',
                    style: textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                  keyboardType: TextInputType.number,
                  controller: TextEditingController(
                    text: component.size.width.toStringAsFixed(1),
                  ),
                ),
                (
                  prefix: Text(
                    'H',
                    style: textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                  keyboardType: TextInputType.number,
                  controller: TextEditingController(
                    text: component.size.height.toStringAsFixed(1),
                  ),
                ),
              ]
            ),
            (
              children: [
                (
                  prefix: Transform.translate(
                    offset: const Offset(0, -1),
                    child: const Icon(
                      size: 14,
                      CupertinoIcons.rotate_right,
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  controller: TextEditingController(
                    text:
                        '${((component.angle % (pi * 2)) / pi * 180).toStringAsFixed(1)}°',
                  ),
                ),
                (
                  prefix: Transform.translate(
                    offset: const Offset(0, 1),
                    child: const Icon(
                      Icons.rounded_corner_rounded,
                      size: 12,
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  controller: TextEditingController(
                    text: '0',
                  ),
                ),
              ]
            ),
          ];

    final backgroundControl = SizedBox(
      height: 16,
      child: Row(
        children: [
          SizedBox(
            width: textFieldWidth,
            child: Row(
              children: [
                Container(
                  width: 16,
                  height: 16,
                  margin: const EdgeInsets.only(right: 6),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(2),
                    color: canvasStateProvider.color,
                  ),
                  child: InkWell(
                    onTap: widget.toggleColorPicker,
                    child: const SizedBox.shrink(),
                  ),
                ),
                Expanded(
                  child: TextField(
                    maxLength: 6,
                    onChanged: (value) => canvasStateNotifier.update(
                      backgroundColor: value.toColor,
                    ),
                    controller: backgroundColorController,
                    style: textTheme.bodySmall,
                    decoration: const InputDecoration(
                      hintText: '',
                      counter: SizedBox.shrink(),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.only(top: 32),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: Text(
              '${(canvasStateProvider.color.opacity * 100).truncate()}%',
              style: textTheme.bodySmall,
            ),
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  hoverColor: Colors.transparent,
                  splashColor: Colors.transparent,
                  focusColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  padding: EdgeInsets.zero,
                  constraints:
                      BoxConstraints.tight(const Size(18, double.infinity)),
                  onPressed: () => canvasStateNotifier.update(
                    backgroundHidden: !canvasStateProvider.hidden,
                  ),
                  icon: Icon(
                    canvasStateProvider.hidden
                        ? CupertinoIcons.eye_slash
                        : CupertinoIcons.eye,
                    size: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    final canvasSizeControl = [
      (
        children: [
          (
            prefix: Text(
              'W',
              style: textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
            keyboardType: TextInputType.number,
            controller: backgroundWidthController,
            onChanged: (text) {
              print('test');
              print(canvasStateProvider.size);
              canvasStateNotifier.update(
                  backgroundSize: Size(
                double.parse(text),
                canvasStateProvider.size.height,
              ));
              print(canvasStateProvider.size);
            }
          ),
          (
            prefix: Text(
              'H',
              style: textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
            keyboardType: TextInputType.number,
            controller: backgroundHeightController,
            onChanged: (text) => canvasStateNotifier.update(
                    backgroundSize: Size(
                  canvasStateProvider.size.width,
                  double.parse(text),
                ))
          ),
        ]
      ),
    ].map(
      (e) => SizedBox(
        height: 32,
        child: Row(
          children: [
            ...e.children.map(
              (e) => SizedBox(
                width: textFieldWidth,
                child: Row(
                  children: [
                    // w: 24
                    Container(
                      width: 16,
                      height: 16,
                      margin: const EdgeInsets.only(right: 6),
                      child: e.prefix,
                    ),
                    // w: 72
                    Expanded(
                      child: TextField(
                        onChanged: e.onChanged,
                        cursorHeight: 12,
                        style: textTheme.bodySmall,
                        decoration: const InputDecoration.collapsed(
                          hintText: '',
                        ),
                        keyboardType: e.keyboardType,
                        controller: e.controller,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );

    return Container(
      width: sidebarWidth,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
      ),
      child: ListView(
        children: [
          ...[
            (
              title: Text(
                'Background',
                style: textTheme.labelMedium,
              ),
              contents: [
                backgroundControl,
                const SizedBox(
                  height: 8,
                ),
                ...canvasSizeControl,
              ]
            ),
            if (component != null)
              (
                title: Text(
                  'Component',
                  style: textTheme.labelMedium,
                ),
                contents: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ...controls!.mapIndexed(
                        (i, e) => Padding(
                          padding: EdgeInsets.only(
                              bottom: i == controls.length - 1 ? 8 : 16.0),
                          child: SizedBox(
                            height: 16,
                            child: Row(
                              children: [
                                ...e.children.map(
                                  (e) => SizedBox(
                                    width: textFieldWidth,
                                    child: Row(
                                      children: [
                                        // w: 24
                                        Container(
                                          width: 16,
                                          height: 16,
                                          margin:
                                              const EdgeInsets.only(right: 6),
                                          child: e.prefix,
                                        ),
                                        // w: 72
                                        Expanded(
                                          child: TextField(
                                            cursorHeight: 12,
                                            style: textTheme.bodySmall,
                                            decoration:
                                                const InputDecoration.collapsed(
                                              hintText: '',
                                            ),
                                            keyboardType: e.keyboardType,
                                            controller: e.controller,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ]
              ),
          ].map(
            (e) {
              final title = e.title;
              return Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: Colors.grey.withOpacity(.5),
                      width: 1,
                    ),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (title != null) SizedBox(height: 32, child: title),
                    ...e.contents.map((e) => e),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
