import 'dart:math';

import 'package:editicert/providers/component.dart';
import 'package:editicert/utils.dart';
import 'package:editicert/widgets/controller_widget.dart';
import 'package:collection/collection.dart';
import 'package:editicert/widgets/creator_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:transparent_pointer/transparent_pointer.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'Editicert',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.cyan,
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
        LogicalKeySet(LogicalKeyboardKey.bracketLeft):
            ActivateShortcutIntent({LogicalKeyboardKey.bracketLeft}),
        LogicalKeySet(LogicalKeyboardKey.bracketRight):
            ActivateShortcutIntent({LogicalKeyboardKey.bracketRight}),
      },
      actions: {
        ActivateToolIntent: ActivateToolAction(ref),
        ActivateShortcutIntent: ActivateShortcutAction(ref),
      },
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
    final globalStateData = ref.watch(globalStateProvider);
    final globalStateNotifier = ref.watch(globalStateProvider.notifier);
    final leftClick = globalStateData.states.contains(GlobalStates.leftClick);
    final isCreateTooling = globalStateData.containsAny({
      GlobalStates.creating,
    });
    final isComponentTooling = globalStateData.containsAny({
      GlobalStates.draggingComponent,
      GlobalStates.resizingComponent,
      GlobalStates.rotatingComponent,
    });
    final isNotCanvasTooling = isComponentTooling || isCreateTooling;
    final isCanvasTooling = globalStateData.containsAny({
      GlobalStates.panningCanvas,
      GlobalStates.zoomingCanvas,
    });

    final transformationController =
        ref.watch(transformationControllerDataProvider);
    final tool = ref.watch(toolProvider);
    final toolNotifier = ref.watch(toolProvider.notifier);
    final components = ref.watch(componentsProvider);
    final selected = ref.watch(selectedProvider);
    final hovered = ref.watch(hoveredProvider);
    final keys = ref.watch(keysProvider);
    final keysNotifier = ref.watch(keysProvider.notifier);
    final isToolHand = ref.watch(toolProvider) == ToolData.hand;
    if (components.isEmpty) {
      final components = ref.read(componentsProvider.notifier);
      components.add(
        ComponentData(
          name: 'Rectangle 1',
          triangle: const Triangle(Offset.zero, Size(200, 200), 0),
          color: Colors.redAccent,
          borderRadius: BorderRadius.circular(180),
        ),
      );
      components.add(
        ComponentData(
          name: 'Rectangle 2',
          triangle: const Triangle(Offset.zero, Size(200, 200), 0),
          color: Colors.blueAccent,
          borderRadius: BorderRadius.circular(8),
        ),
      );
      components.add(
        ComponentData(
          name: 'Rectangle 3',
          triangle: const Triangle(Offset.zero, Size(200, 200), 0),
          color: Colors.greenAccent,
          borderRadius: BorderRadius.circular(32),
        ),
      );
      components.add(
        const ComponentData(
          name: 'Rectangle 4',
          triangle: Triangle(Offset.zero, Size(200, 200), 0),
          color: Colors.white30,
          borderRadius: BorderRadius.only(
              topRight: Radius.circular(16), bottomLeft: Radius.circular(16)),
        ),
      );
      components.add(
        const ComponentData(
          name: 'Rectangle 5',
          triangle: Triangle(Offset.zero, Size(200, 200), 0),
          color: Colors.cyan,
        ),
      );
      components.add(
        const ComponentData(
          name: 'Rectangle 6',
          triangle: Triangle(Offset.zero, Size(200, 200), 0),
          color: Colors.teal,
        ),
      );
      components.add(
        const ComponentData(
          name: 'Rectangle 7',
          triangle: Triangle(Offset.zero, Size(200, 200), 0),
          color: Colors.indigoAccent,
        ),
      );
      components.add(
        const ComponentData(
            name: 'Rectangle 8',
            triangle: Triangle(Offset.zero, Size(200, 200), 0),
            color: Colors.purpleAccent,
            shadow: [
              BoxShadow(
                offset: Offset(0, 4),
                blurRadius: 12,
                spreadRadius: 12,
              ),
            ]),
      );
    }
    final isZooming = globalStateData.containsAny({GlobalStates.zoomingCanvas});
    final pressedMeta = keys.contains(LogicalKeyboardKey.metaLeft) ||
        keys.contains(LogicalKeyboardKey.metaRight) ||
        keys.contains(LogicalKeyboardKey.meta);
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
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height,
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
                                    ? [const SizedBox.shrink()]
                                    : buildComponentWidget(e);
                              },
                            ).flattened,
                            const SizedBox.shrink(),
                          ]),
                        );
                      }),
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
                          ref.read(globalStateProvider) +
                              GlobalStates.leftClick),
                      onPointerUp: (event) => globalStateNotifier.update(
                          ref.read(globalStateProvider) -
                              GlobalStates.leftClick),
                      child: MouseRegion(
                        cursor: switch ((
                          leftClick,
                          isToolHand && (!isNotCanvasTooling || isCanvasTooling)
                        )) {
                          (false, true) => SystemMouseCursors.grab,
                          (true, true) => SystemMouseCursors.grabbing,
                          _
                              when globalStateData.containsAny(
                                  {GlobalStates.resizingComponent}) =>
                            SystemMouseCursors.precise,
                          _
                              when globalStateData.containsAny(
                                  {GlobalStates.rotatingComponent}) =>
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
                                globalStateNotifier.update(globalStateData +
                                    GlobalStates.zoomingCanvas);
                              } else if (isToolHand) {
                                globalStateNotifier.update(globalStateData +
                                    GlobalStates.panningCanvas);
                              }
                            },
                            onInteractionUpdate: (details) {
                              if (details.scale == 1 && !pressedMeta) {
                                globalStateNotifier.update(globalStateData +
                                    GlobalStates.panningCanvas);
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
                            boundaryMargin:
                                const EdgeInsets.all(double.infinity),
                            builder: (context, viewport) => const SizedBox()),
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
                  color: Theme.of(context).colorScheme.surfaceVariant,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
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
                              angle: -pi / 4,
                              alignment: const Alignment(-0.2, 0),
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
                        ].map((e) => Tooltip(
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
                                  )
                                ],
                              ),
                              child: Card(
                                margin: EdgeInsets.zero,
                                color: tool == e.tool
                                    ? Theme.of(context)
                                        .colorScheme
                                        .onInverseSurface
                                    : Theme.of(context)
                                        .colorScheme
                                        .surfaceVariant,
                                elevation: 0,
                                clipBehavior: Clip.hardEdge,
                                child: InkWell(
                                  onTap: e.onTap,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: e.icon,
                                  ),
                                ),
                              ),
                            )),
                      ]),
                ),
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        width: sidebarWidth,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surfaceVariant,
                          border: Border(
                            top: BorderSide(
                              color: Colors.grey.withOpacity(.5),
                              width: 1,
                            ),
                          ),
                        ),
                        child: ListView(
                          children: components
                              .mapIndexed(
                                (i, e) => Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      strokeAlign:
                                          BorderSide.strokeAlignOutside,
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
                                    child: ListTile(
                                      textColor: e.hidden ? Colors.grey : null,
                                      iconColor: e.hidden ? Colors.grey : null,
                                      onTap: () {
                                        ref.read(selectedProvider.notifier)
                                          ..clear()
                                          ..add(i);
                                      },
                                      hoverColor: Colors.transparent,
                                      // selected: selected.contains(i),
                                      horizontalTitleGap: 4,
                                      title: Text(
                                        e.name,
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                      leading: const Icon(
                                        CupertinoIcons.square,
                                        size: 16,
                                      ),
                                      contentPadding: const EdgeInsets.only(
                                          left: 4, right: 6),
                                      trailing: hovered.contains(i)
                                          ? SizedBox(
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
                                                    constraints: BoxConstraints
                                                        .tight(Size(
                                                            e.locked ? 14 : 18,
                                                            double.infinity)),
                                                    onPressed: () => ref
                                                        .read(componentsProvider
                                                            .notifier)
                                                        .replace(i,
                                                            locked: !e.locked),
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
                                                                double
                                                                    .infinity)),
                                                    onPressed: () => ref
                                                        .read(componentsProvider
                                                            .notifier)
                                                        .replace(i,
                                                            hidden: !e.hidden),
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
                                            )
                                          : null,
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ),
                      const Expanded(
                        child: SizedBox.shrink(),
                      ),
                      Container(
                        padding: const EdgeInsets.only(top: 12),
                        width: sidebarWidth,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surfaceVariant,
                          border: Border(
                            top: BorderSide(
                              color: Colors.grey.withOpacity(.5),
                              width: 1,
                            ),
                          ),
                        ),
                        child: Builder(builder: (context) {
                          if (selected.isEmpty) {
                            return const SizedBox.expand();
                          }
                          final triangle = components[selected.first].triangle;
                          return ListView(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 2.0, vertical: 2),
                                      child: TextField(
                                        style: const TextStyle(fontSize: 12),
                                        decoration: const InputDecoration(
                                          prefixText: 'X ',
                                          border: OutlineInputBorder(),
                                        ),
                                        keyboardType: TextInputType.number,
                                        controller: TextEditingController(
                                            text: triangle.pos.dx
                                                .toStringAsFixed(1)),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 2.0, vertical: 2),
                                      child: TextField(
                                        style: const TextStyle(fontSize: 12),
                                        decoration: const InputDecoration(
                                          prefixText: 'Y ',
                                          border: OutlineInputBorder(),
                                        ),
                                        keyboardType: TextInputType.number,
                                        controller: TextEditingController(
                                            text: triangle.pos.dy
                                                .toStringAsFixed(1)),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 2.0, vertical: 2),
                                      child: TextField(
                                        style: const TextStyle(fontSize: 12),
                                        decoration: const InputDecoration(
                                          prefixText: 'W ',
                                          border: OutlineInputBorder(),
                                        ),
                                        keyboardType: TextInputType.number,
                                        controller: TextEditingController(
                                            text: triangle.size.width
                                                .toStringAsFixed(1)),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 2.0, vertical: 2),
                                      child: TextField(
                                        style: const TextStyle(fontSize: 12),
                                        decoration: const InputDecoration(
                                          prefixText: 'H ',
                                          border: OutlineInputBorder(),
                                        ),
                                        keyboardType: TextInputType.number,
                                        controller: TextEditingController(
                                            text: triangle.size.height
                                                .toStringAsFixed(1)),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 2.0, vertical: 2),
                                      child: TextField(
                                        style: const TextStyle(fontSize: 12),
                                        decoration: const InputDecoration(
                                          prefix: Padding(
                                            padding: EdgeInsets.only(right: 6),
                                            child: Icon(
                                              size: 12,
                                              CupertinoIcons.rotate_right,
                                            ),
                                          ),
                                          border: OutlineInputBorder(),
                                        ),
                                        keyboardType: TextInputType.number,
                                        controller: TextEditingController(
                                          text:
                                              '${((triangle.angle % (pi * 2)) / pi * 180).toStringAsFixed(1)}°',
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 2.0, vertical: 2),
                                      child: TextField(
                                        style: const TextStyle(fontSize: 12),
                                        decoration: const InputDecoration(
                                          prefix: Padding(
                                            padding: EdgeInsets.only(right: 6),
                                            child: Icon(
                                              Icons.rounded_corner_rounded,
                                              size: 12,
                                            ),
                                          ),
                                          border:
                                              OutlineInputBorder(gapPadding: 2),
                                        ),
                                        keyboardType: TextInputType.number,
                                        controller: TextEditingController(
                                          text: '0',
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          );
                        }),
                      )
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

  List<Positioned> buildComponentWidget(ComponentData e) {
    final triangle = e.triangle;
    final child = Container(
      width:
          triangle.size.width < 0 ? -triangle.size.width : triangle.size.width,
      height: triangle.size.height < 0
          ? -triangle.size.height
          : triangle.size.height,
      decoration: BoxDecoration(
        borderRadius: e.borderRadius,
        border: e.border,
        color: e.color,
      ),
      child: const Text('testfasd fa sdf'),
    );
    final edges = triangle.rotatedEdges;
    final edge = switch ((triangle.size.width < 0, triangle.size.height < 0)) {
      (true, false) => switch ((triangle.angle / pi * 180 + 90) % 360) {
          < 45 => edges.bl,
          < 135 => edges.tl,
          < 225 => edges.tr,
          < 315 => edges.br,
          < 360 => edges.bl,
          _ => edges.tl,
        },
      (true, true) => switch ((triangle.angle / pi * 180 + 90) % 360) {
          < 45 => edges.tl,
          < 135 => edges.bl,
          < 225 => edges.br,
          < 315 => edges.tr,
          < 360 => edges.tl,
          _ => edges.tl,
        },
      (false, true) => switch ((triangle.angle / pi * 180 + 90) % 360) {
          < 45 => edges.br,
          < 135 => edges.bl,
          < 225 => edges.tl,
          < 315 => edges.tr,
          < 360 => edges.br,
          _ => edges.tl,
        },
      _ => switch ((triangle.angle / pi * 180 + 90) % 360) {
          < 45 => edges.tr,
          < 135 => edges.tl,
          < 225 => edges.bl,
          < 315 => edges.br,
          < 360 => edges.tr,
          _ => edges.tl,
        }
    };
    final newAngle =
        switch ((triangle.size.width < 0, triangle.size.height < 0)) {
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
    return [
      Positioned(
        left: edge.dx,
        top: edge.dy,
        child: Transform.rotate(
          angle: triangle.angle + newAngle,
          alignment: Alignment.topLeft,
          child: Transform.translate(
            offset: const Offset(0, -24),
            child: AnimatedSlide(
              offset: Offset(triangle.size.width < 0 ? -1 : 0, 0),
              duration: Duration.zero,
              child: Text(e.name),
            ),
          ),
        ),
      ),
      Positioned(
        left: triangle.pos.dx +
            (triangle.size.width < 0 ? triangle.size.width : 0),
        top: triangle.pos.dy +
            (triangle.size.height < 0 ? triangle.size.height : 0),
        child: Transform.rotate(
          angle: triangle.angle,
          child: Transform.flip(
            flipX: triangle.size.width < 0,
            flipY: triangle.size.height < 0,
            child: child,
          ),
        ),
      ),
    ];
  }
}
