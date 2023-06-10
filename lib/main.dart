import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:editicert/providers/components.dart';
import 'package:editicert/utils.dart';
import 'package:editicert/widgets/controller_widget.dart';
import 'package:collection/collection.dart';
import 'package:editicert/widgets/creator_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:macos_window_utils/macos_window_utils.dart';
import 'package:transparent_pointer/transparent_pointer.dart';
import 'package:window_manager/window_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();
  await WindowManipulator.initialize();

  await WindowManipulator.makeTitlebarTransparent();
  await WindowManipulator.enableFullSizeContentView();
  await WindowManipulator.hideTitle();
  await WindowManipulator.addToolbar();
  await WindowManipulator.setToolbarStyle(
    toolbarStyle: NSWindowToolbarStyle.unified,
  );

  await windowManager.waitUntilReadyToShow();

  runApp(const ProviderScope(child: Main()));

  unawaited(windowManager.show());
  unawaited(windowManager.focus());
}

class Main extends ConsumerWidget {
  const Main({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PlatformMenuBar(
      menus: const [
        PlatformMenu(
          label: 'Application',
          menus: [
            PlatformMenuItemGroup(members: [
              PlatformMenuItem(label: 'About Editicert'),
            ]),
            PlatformMenuItemGroup(members: [
              PlatformMenuItem(label: 'Preferences'),
            ]),
            PlatformMenuItemGroup(members: [
              PlatformMenuItem(label: 'Quit Editicert'),
            ]),
          ],
        ),
        PlatformMenu(
          label: 'File',
          menus: [
            PlatformMenuItem(
              label: 'New Project',
            ),
            PlatformMenuItem(
              label: 'Open Project',
            ),
            PlatformMenuItem(
              label: 'Save',
            ),
            PlatformMenuItem(
              label: 'Save As',
            ),
            PlatformMenuItem(
              label: 'Close Project',
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
        home: const HomePage(),
        shortcuts: {
          LogicalKeySet(LogicalKeyboardKey.keyV):
              const ActivateToolIntent(ToolData.move),
          LogicalKeySet(LogicalKeyboardKey.keyR):
              const ActivateToolIntent(ToolData.create),
          LogicalKeySet(LogicalKeyboardKey.keyH):
              const ActivateToolIntent(ToolData.hand),
          LogicalKeySet(LogicalKeyboardKey.backspace):
              ActivateShortcutIntent({LogicalKeyboardKey.backspace}),
          LogicalKeySet(LogicalKeyboardKey.delete):
              ActivateShortcutIntent({LogicalKeyboardKey.delete}),
          LogicalKeySet(LogicalKeyboardKey.bracketLeft):
              ActivateShortcutIntent({LogicalKeyboardKey.bracketLeft}),
          LogicalKeySet(LogicalKeyboardKey.bracketRight):
              ActivateShortcutIntent({LogicalKeyboardKey.bracketRight}),
        },
        actions: {
          ActivateToolIntent: ActivateToolAction(ref),
          ActivateShortcutIntent: ActivateShortcutAction(ref),
        },
      ),
    );
  }
}

class ActivateShortcutIntent extends Intent {
  const ActivateShortcutIntent(this.shortcuts);

  final Set<LogicalKeyboardKey> shortcuts;
}

class ActivateShortcutAction extends Action<ActivateShortcutIntent> {
  ActivateShortcutAction(this.ref);

  final WidgetRef ref;

  @override
  void invoke(ActivateShortcutIntent intent) {
    final singleKey = intent.shortcuts.singleOrNull;
    switch (singleKey) {
      case LogicalKeyboardKey.bracketLeft:
        handleGoBackward();
      case LogicalKeyboardKey.bracketRight:
        handleGoForward();
      case LogicalKeyboardKey.backspace when Platform.isMacOS:
        ref.read(componentsProvider.notifier).deleteSelected();
      case LogicalKeyboardKey.delete when !Platform.isMacOS:
        ref.read(componentsProvider.notifier).deleteSelected();
      case _:
    }
  }

  void handleGoBackward() {
    final index = ref.read(selectedProvider).singleOrNull;
    if (index == null || index == 0) return;
    ref.read(componentsProvider.notifier).reorder(index, index - 1);
  }

  void handleGoForward() {
    final index = ref.read(selectedProvider).singleOrNull;
    if (index == null || index == ref.read(componentsProvider).length - 1) {
      return;
    }
    ref.read(componentsProvider.notifier).reorder(index, index + 1);
  }
}

class ActivateToolIntent extends Intent {
  const ActivateToolIntent(this.tool);

  final ToolData tool;
}

class ActivateToolAction extends Action<ActivateToolIntent> {
  ActivateToolAction(this.ref);

  final WidgetRef ref;

  @override
  void invoke(ActivateToolIntent intent) {
    final notifier = ref.read(toolProvider.notifier);
    switch (intent.tool) {
      case ToolData.move:
        notifier.setMove();
      case ToolData.create:
        notifier.setCreate();
      case ToolData.hand:
        notifier.setHand();
    }
  }
}

class HomePage extends ConsumerStatefulWidget {
  const HomePage({
    super.key,
  });

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  @override
  void initState() {
    super.initState();
  }

  final oMatrix = ValueNotifier(Matrix4.identity());

  @override
  Widget build(BuildContext context) {
    final (
      transform: _,
      :backgroundColor,
      backgroundHidden: _,
      backgroundOpacity: _,
    ) = ref.watch(canvasStateProvider);

    //
    final globalStateData = ref.watch(globalStateProvider);
    final globalStateNotifier = ref.watch(globalStateProvider.notifier);
    final leftClick = ref.watch(globalStateProvider
        .select((value) => value.states.contains(GlobalStates.leftClick)));
    final isCreateTooling =
        ref.watch(globalStateProvider.select((value) => value.containsAny({
              GlobalStates.creating,
            })));
    final isComponentTooling =
        ref.watch(globalStateProvider.select((value) => value.containsAny({
              GlobalStates.draggingComponent,
              GlobalStates.resizingComponent,
              GlobalStates.rotatingComponent,
            })));
    final isNotCanvasTooling = isComponentTooling || isCreateTooling;
    final isCanvasTooling =
        ref.watch(globalStateProvider.select((value) => value.containsAny({
              GlobalStates.panningCanvas,
              GlobalStates.zoomingCanvas,
            })));
    final isZooming = ref.watch(globalStateProvider
        .select((value) => value.containsAny({GlobalStates.zoomingCanvas})));

    final transformationController =
        ref.watch(transformationControllerDataProvider);
    //
    final tool = ref.watch(toolProvider);
    final isToolHand = tool == ToolData.hand;
    final toolNotifier = ref.watch(toolProvider.notifier);
    //
    final components = ref.watch(componentsProvider);
    final selected = ref.watch(selectedProvider);
    final hovered = ref.watch(hoveredProvider);
    //
    final keys = ref.watch(keysProvider);
    final keysNotifier = ref.watch(keysProvider.notifier);
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
        backgroundColor: backgroundColor,
        body: Stack(
          clipBehavior: Clip.none,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: sidebarWidth)
                  .copyWith(top: topbarHeight),
              child: Stack(
                children: [
                  // unselect all
                  GestureDetector(
                    onTap: () {
                      ref.read(selectedProvider.notifier).clear();
                      ref.read(hoveredProvider.notifier).clear();
                    },
                    child: Container(
                      width: mqSize.width,
                      height: mqSize.height,
                      color: Colors.transparent,
                    ),
                  ),
                  // components
                  ValueListenableBuilder(
                    valueListenable: transformationController,
                    builder: (context, value, child) {
                      return Transform(
                        transform: value,
                        child: Stack(clipBehavior: Clip.none, children: [
                          ...components.mapIndexed(
                            (i, e) {
                              return e.hidden
                                  ? const SizedBox.shrink()
                                  : buildComponentWidget(e);
                            },
                          ),
                          const SizedBox.shrink(),
                        ]),
                      );
                    },
                  ),
                  // components label
                  ...components.mapIndexed(
                    (i, e) {
                      return buildComponentLabel(e, backgroundColor);
                    },
                  ),
                  // controller for selections
                  ...components.mapIndexed((i, e) {
                    return ControllerWidget(i);
                  }),
                  // selected controller (at the front of every controllers)
                  ...components.mapIndexed((i, e) {
                    return !selected.contains(i)
                        ? const SizedBox.shrink()
                        : ControllerWidget(i);
                  }),
                  //
                  if (tool == ToolData.create || isCreateTooling)
                    const CreatorWidget(),

                  // camera (kinda). workaround
                  TransparentPointer(
                    transparent: !isToolHand,
                    child: Listener(
                      onPointerDown: (event) => globalStateNotifier.update(
                        ref.read(globalStateProvider) + GlobalStates.leftClick,
                      ),
                      onPointerUp: (event) => globalStateNotifier.update(
                        ref.read(globalStateProvider) - GlobalStates.leftClick,
                      ),
                      child: MouseRegion(
                        cursor: switch ((
                          leftClick,
                          isToolHand && (!isNotCanvasTooling || isCanvasTooling)
                        )) {
                          (false, true) => SystemMouseCursors.grab,
                          (true, true) => SystemMouseCursors.grabbing,
                          _
                              when globalStateData.containsAny(
                                {GlobalStates.resizingComponent},
                              ) =>
                            SystemMouseCursors.precise,
                          _
                              when globalStateData.containsAny(
                                {GlobalStates.rotatingComponent},
                              ) =>
                            SystemMouseCursors.grabbing,
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
                                  globalStateData + GlobalStates.zoomingCanvas);
                            } else if (isToolHand) {
                              globalStateNotifier.update(
                                  globalStateData + GlobalStates.panningCanvas);
                            }
                          },
                          onInteractionUpdate: (details) {
                            if (details.scale == 1 && !pressedMeta) {
                              globalStateNotifier.update(
                                  globalStateData + GlobalStates.panningCanvas);
                            }
                          },
                          onInteractionEnd: (details) =>
                              globalStateNotifier.update(globalStateData -
                                  GlobalStates.panningCanvas -
                                  GlobalStates.zoomingCanvas),
                          maxScale: 256,
                          minScale: .01,
                          trackpadScrollCausesScale: (pressedMeta ||
                                  isZooming) &&
                              !globalStateData
                                  .containsAny({GlobalStates.panningCanvas}),
                          boundaryMargin: const EdgeInsets.all(double.infinity),
                          builder: (context, viewport) => const SizedBox(),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Column(
              children: [
                Container(
                  height: topbarHeight,
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceVariant,
                    border: Border(
                      bottom: BorderSide(
                        color: Colors.grey.withOpacity(.375),
                        width: 1,
                      ),
                    ),
                  ),
                  padding: EdgeInsets.only(
                    left: 8 + (Platform.isMacOS ? 80 : 0),
                    right: 8,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ...[
                        (
                          text: 'Move',
                          shortcut: 'V',
                          tool: ToolData.move,
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
                          text: 'Rectangle',
                          shortcut: 'R',
                          tool: ToolData.create,
                          onTap: () {
                            toolNotifier.setCreate();
                          },
                          icon: const Icon(
                            CupertinoIcons.square,
                            size: 18,
                          )
                        ),
                        (
                          text: 'Hand',
                          shortcut: 'H',
                          tool: ToolData.hand,
                          onTap: () {
                            toolNotifier.setHand();
                          },
                          icon: const Icon(
                            CupertinoIcons.hand_raised,
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
                                ? colorScheme.onInverseSurface
                                : colorScheme.surfaceVariant,
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
                      Container(
                        width: sidebarWidth,
                        color: colorScheme.surfaceVariant,
                        child: ListView(
                          children: components
                              .mapIndexed(
                                (i, e) => Container(
                                  padding: const EdgeInsets.only(right: 8),
                                  height: 32,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      strokeAlign: BorderSide.strokeAlignInside,
                                      color: switch ((
                                        selected.contains(i),
                                        hovered.contains(i),
                                      )) {
                                        (false, false) => Colors.transparent,
                                        (false, true) =>
                                          Colors.blueAccent.withOpacity(.5),
                                        (true, _) => Colors.blueAccent
                                      },
                                    ),
                                  ),
                                  // color: Colors.transparent,
                                  child: MouseRegion(
                                    onEnter: (event) => ref
                                        .read(hoveredProvider.notifier)
                                        .add(i),
                                    onExit: (event) => ref
                                        .read(hoveredProvider.notifier)
                                        .remove(i),
                                    child: InkWell(
                                      onTap: () {
                                        ref.read(selectedProvider.notifier)
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
                                          Text(
                                            e.name,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall,
                                          ),
                                          const Spacer(),
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
                                                    onPressed: () => ref
                                                        .read(componentsProvider
                                                            .notifier)
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
                                                    onPressed: () => ref
                                                        .read(componentsProvider
                                                            .notifier)
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
                                    //     ref.read(selectedProvider.notifier)
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
                                    //                 onPressed: () => ref
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
                                    //                 onPressed: () => ref
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
                      const RightSidebar(),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  ValueListenableBuilder<Matrix4> buildComponentLabel(
    ComponentData e,
    Color backgroundColor,
  ) {
    return ValueListenableBuilder(
      valueListenable: ref.watch(transformationControllerDataProvider),
      builder: (context, matrix, child) {
        final triangle = e.triangle;
        final tWidth = triangle.size.width;
        final tHeight = triangle.size.height;

        final edges = triangle.rotatedEdges;
        final topLeft = edges.tl;
        final topRight = edges.tr;
        final bottomLeft = edges.bl;
        final bottomRight = edges.br;

        var edge = switch ((tWidth < 0, tHeight < 0)) {
          (true, false) => switch ((triangle.angle / pi * 180 + 90) % 360) {
              < 45 => bottomLeft,
              < 135 => topLeft,
              < 225 => topRight,
              < 315 => bottomRight,
              < 360 => bottomLeft,
              _ => topLeft,
            },
          (true, true) => switch ((triangle.angle / pi * 180 + 90) % 360) {
              < 45 => topLeft,
              < 135 => bottomLeft,
              < 225 => bottomRight,
              < 315 => topRight,
              < 360 => topLeft,
              _ => topLeft,
            },
          (false, true) => switch ((triangle.angle / pi * 180 + 90) % 360) {
              < 45 => bottomRight,
              < 135 => bottomLeft,
              < 225 => topLeft,
              < 315 => topRight,
              < 360 => bottomRight,
              _ => topLeft,
            },
          _ => switch ((triangle.angle / pi * 180 + 90) % 360) {
              < 45 => topRight,
              < 135 => topLeft,
              < 225 => bottomLeft,
              < 315 => bottomRight,
              < 360 => topRight,
              _ => topLeft,
            }
        };
        final newAngle = switch ((tWidth < 0, tHeight < 0)) {
          (true, false) => switch ((triangle.angle / pi * 180 + 90) % 360) {
              < 45 => pi / 2,
              < 135 => 0,
              < 225 => -pi / 2,
              < 315 => pi,
              < 360 => pi / 2,
              _ => 0.0,
            },
          (true, true) => switch ((triangle.angle / pi * 180 + 90) % 360) {
              < 45 => pi / 2,
              < 135 => 0,
              < 225 => -pi / 2,
              < 315 => pi,
              < 360 => pi / 2,
              _ => 0.0,
            },
          _ => switch ((triangle.angle / pi * 180 + 90) % 360) {
              < 45 => pi / 2,
              < 135 => 0,
              < 225 => -pi / 2,
              < 315 => pi,
              < 360 => pi / 2,
              _ => 0.0,
            }
        };

        edge = MatrixUtils.transformPoint(matrix, edge);

        return Positioned(
          left: edge.dx,
          top: edge.dy,
          child: Transform.rotate(
            angle: triangle.angle + newAngle,
            alignment: Alignment.topLeft,
            child: AnimatedSlide(
              offset: Offset(tWidth < 0 ? -1 : 0, -1),
              duration: Duration.zero,
              child: Text(
                e.name,
                style: TextStyle(
                  color: backgroundColor.computeLuminance() > 0.5
                      ? Colors.black.withOpacity(.5)
                      : Colors.white.withOpacity(.5),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget buildComponentWidget(ComponentData e) {
    final triangle = e.triangle;
    final tWidth = triangle.size.width;
    final tHeight = triangle.size.height;

    final child = Container(
      width: tWidth < 0 ? -tWidth : tWidth,
      height: tHeight < 0 ? -tHeight : tHeight,
      decoration: BoxDecoration(
        borderRadius: e.borderRadius,
        border: e.border,
        color: e.color,
      ),
      child: const Text('testfasd fa sdf'),
    );

    return Positioned(
      left: triangle.pos.dx + (tWidth < 0 ? tWidth : 0),
      top: triangle.pos.dy + (tHeight < 0 ? tHeight : 0),
      child: Transform.rotate(
        angle: triangle.angle,
        child: Transform.flip(
          flipX: tWidth < 0,
          flipY: tHeight < 0,
          child: child,
        ),
      ),
    );
  }
}

class RightSidebar extends ConsumerWidget {
  const RightSidebar({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(selectedProvider);
    final (
      transform: _,
      :backgroundColor,
      :backgroundOpacity,
      :backgroundHidden,
    ) = ref.watch(canvasStateProvider);
    final triangle = ref.watch(componentsProvider.select((value) =>
        selected.firstOrNull == null ? null : value[selected.first].triangle));
    final textTheme = Theme.of(context).textTheme;

    final controls = triangle == null
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
                    text: triangle.pos.dx.toStringAsFixed(1),
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
                    text: triangle.pos.dy.toStringAsFixed(1),
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
                    text: triangle.size.width.toStringAsFixed(1),
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
                    text: triangle.size.height.toStringAsFixed(1),
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
                        '${((triangle.angle % (pi * 2)) / pi * 180).toStringAsFixed(1)}°',
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
                    borderRadius: BorderRadius.circular(1),
                    color: backgroundColor,
                  ),
                ),
                Expanded(
                  child: TextField(
                    controller: TextEditingController(
                      text: backgroundColor.value
                          .toRadixString(16)
                          .toUpperCase()
                          .substring(2),
                    ),
                    style: textTheme.bodySmall,
                    decoration: const InputDecoration.collapsed(hintText: ''),
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${(backgroundOpacity * 100).truncate()}%',
            style: textTheme.bodySmall,
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
                  onPressed: () => ref
                      .read(canvasStateProvider.notifier)
                      .update(backgroundHidden: !backgroundHidden),
                  icon: Icon(
                    backgroundHidden
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

    return Container(
      width: sidebarWidth,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
      ),
      child: ListView(
        children: [
          ...[
            (
              title: Text(
                'Background',
                style: textTheme.labelMedium,
              ),
              contents: [backgroundControl]
            ),
            if (triangle != null)
              (
                title: null,
                contents: [
                  Transform.translate(
                    // offset: const Offset(0, -8),
                    offset: Offset.zero,
                    child: Column(
                      children: [
                        ...controls!.map(
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
                      ],
                    ),
                  ),
                ]
              ),
          ].map((e) {
            final title = e.title;

            return Container(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
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
          }),
        ],
      ),
    );
  }
}
