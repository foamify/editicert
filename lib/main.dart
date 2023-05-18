import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
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
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // selected component index
  final index = ValueNotifier(0);
  final components = ValueNotifier([
    (
      originalRect: ValueNotifier(const Rect.fromLTWH(150, 150, 100, 200)),
      visualRect: ValueNotifier(const Rect.fromLTWH(150, 150, 100, 200)),
      newRect: ValueNotifier(const Rect.fromLTWH(150, 150, 100, 200)),
      flip: ValueNotifier((x: false, y: false)),
      keys: ValueNotifier(<PhysicalKeyboardKey>{}),
      originalPosition: ValueNotifier(Offset.zero),
    ),
  ]);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ValueListenableBuilder(
          valueListenable: components,
          builder: (context, components, child) => Row(
                children: [
                  Expanded(
                    child: Stack(
                        children: components
                            .map((e) => ResizableWidget(
                                  originalRect: e.originalRect,
                                  visualRect: e.visualRect,
                                  newRect: e.newRect,
                                  flip: e.flip,
                                  keys: e.keys,
                                  originalPosition: e.originalPosition,
                                ))
                            .toList()),
                  ),
                  SizedBox(
                    width: 240,
                    child: ValueListenableBuilder(
                        valueListenable: components.first.visualRect,
                        builder: (context, value, child) {
                          final rect = value;
                          return ListView(
                            children: [
                              TextField(
                                decoration: const InputDecoration(
                                  label: Text('x'),
                                ),
                                keyboardType: TextInputType.number,
                                controller: TextEditingController(
                                    text: rect.left.toStringAsFixed(1)),
                              ),
                              TextField(
                                decoration: const InputDecoration(
                                  label: Text('y'),
                                ),
                                keyboardType: TextInputType.number,
                                controller: TextEditingController(
                                    text: rect.top.toStringAsFixed(1)),
                              ),
                              TextField(
                                decoration: const InputDecoration(
                                  label: Text('width'),
                                ),
                                keyboardType: TextInputType.number,
                                controller: TextEditingController(
                                    text: rect.width.toStringAsFixed(1)),
                              ),
                              TextField(
                                decoration: const InputDecoration(
                                  label: Text('height'),
                                ),
                                keyboardType: TextInputType.number,
                                controller: TextEditingController(
                                    text: rect.height.toStringAsFixed(1)),
                              ),
                            ],
                          );
                        }),
                  )
                ],
              )),
    );
  }
}

class ResizableWidget extends StatefulWidget {
  const ResizableWidget(
      {super.key,
      required this.originalRect,
      required this.visualRect,
      required this.newRect,
      required this.flip,
      required this.keys,
      required this.originalPosition});

  final ValueNotifier<Rect> originalRect;
  final ValueNotifier<Rect> visualRect;
  final ValueNotifier<Rect> newRect;
  final ValueNotifier<({bool x, bool y})> flip;
  final ValueNotifier<Set<PhysicalKeyboardKey>> keys;
  final ValueNotifier<Offset> originalPosition;

  @override
  State<ResizableWidget> createState() => _ResizableWidgetState();
}

class _ResizableWidgetState extends State<ResizableWidget> {
  ValueNotifier<Rect> get originalRect => widget.originalRect;

  ValueNotifier<Rect> get visualRect => widget.visualRect;

  ValueNotifier<Rect> get newRect => widget.newRect;

  ValueNotifier<({bool x, bool y})> get flip => widget.flip;

  ValueNotifier<Set<PhysicalKeyboardKey>> get keys => widget.keys;

  ValueNotifier<Offset> get originalPosition => widget.originalPosition;

  @override
  Widget build(BuildContext context) {
    /// rect, but all values are positive numbers
    final borderRadius = BorderRadius.circular(8);
    const gestureSize = 12.0;
    return RawKeyboardListener(
      focusNode: FocusNode(),
      autofocus: true,
      onKey: (value) => value.isKeyPressed(value.logicalKey)
          ? keys.value.add(value.physicalKey)
          : keys.value.remove(value.physicalKey),
      child: AnimatedBuilder(
          animation: Listenable.merge([flip, visualRect, keys]),
          builder: (context, child) {
            final flipValue = flip.value;
            final rectValue = visualRect.value;
            final keysValue = keys.value;
            return Stack(
              children: [
                Positioned(
                  left: rectValue.left,
                  top: rectValue.top,
                  child: Transform.flip(
                    flipX: flipValue.x,
                    flipY: flipValue.y,
                    child: Container(
                      width: rectValue.width,
                      height: rectValue.height,
                      decoration: BoxDecoration(
                        borderRadius: borderRadius,
                        color: Colors.red,
                      ),
                      child: const Text('testfasd fa sdf'),
                    ),
                  ),
                ),
                // Positioned(
                //   left: rectValue.left,
                //   top: rectValue.top,
                //   child: Container(
                //     width: rectValue.width,
                //     height: rectValue.height,
                //     decoration:
                //         BoxDecoration(border: Border.all(color: Colors.white)),
                //   ),
                // ),
                buildResizer(
                  flipValue,
                  rectValue,
                  gestureSize,
                  keysValue,
                  fromLeft: true,
                  edge: false,
                ),
                buildResizer(
                  flipValue,
                  rectValue,
                  gestureSize,
                  keysValue,
                  fromTop: true,
                  edge: false,
                ),
                buildResizer(
                  flipValue,
                  rectValue,
                  gestureSize,
                  keysValue,
                  fromRight: true,
                  edge: false,
                ),
                buildResizer(
                  flipValue,
                  rectValue,
                  gestureSize,
                  keysValue,
                  fromBottom: true,
                  edge: false,
                ),
                buildResizer(
                  flipValue,
                  rectValue,
                  gestureSize,
                  keysValue,
                  fromRight: true,
                ),
                buildResizer(
                  flipValue,
                  rectValue,
                  gestureSize,
                  keysValue,
                  fromBottom: true,
                ),
                buildResizer(
                  flipValue,
                  rectValue,
                  gestureSize,
                  keysValue,
                  fromRight: true,
                  fromBottom: true,
                ),
                buildResizer(
                  flipValue,
                  rectValue,
                  gestureSize,
                  keysValue,
                ),
              ],
            );
          }),
    );
  }

  Widget buildResizer(
    ({bool x, bool y}) flipValue,
    Rect rectValue,
    double gestureSize,
    Set<PhysicalKeyboardKey> keys, {
    bool fromTop = false,
    bool fromLeft = false,
    bool fromRight = false,
    bool fromBottom = false,
    bool edge = true,
  }) {
    final pressedCmd = keys.contains(PhysicalKeyboardKey.metaLeft);
    return Positioned(
      left: edge
          ? (switch ((flipValue.x, fromRight)) {
                (false, false) => rectValue.left,
                (true, false) => rectValue.right,
                (false, true) => rectValue.right,
                (true, true) => rectValue.left,
              } -
              gestureSize / 2)
          : switch ((fromLeft, fromTop, fromRight, fromBottom)) {
              (false, false, true, false) => rectValue.right,
              _ => rectValue.left,
            },
      top: edge
          ? (switch ((flipValue.y, fromBottom)) {
                (false, false) => rectValue.top,
                (true, false) => rectValue.bottom,
                (false, true) => rectValue.bottom,
                (true, true) => rectValue.top,
              } -
              gestureSize / 2)
          : switch ((fromLeft, fromTop, fromRight, fromBottom)) {
              (false, false, false, true) => rectValue.bottom,
              _ => rectValue.top,
            },
      child: MouseRegion(
        cursor: SystemMouseCursors.precise,
        child: Listener(
          onPointerDown: (event) {
            originalPosition.value = event.position -
                (edge ? Offset(gestureSize, gestureSize) / 2 : Offset.zero);
          },
          onPointerUp: (event) {
            originalRect.value = visualRect.value;
          },
          onPointerMove: (event) {
            final delta = event.position - originalPosition.value;
            const snapValue = 20;
            final position = Offset(
              snap(event.position.dx, snapValue),
              snap(event.position.dy, snapValue),
            );

            flip.value = (
              x: switch ((x: flip.value.x, fromRight: fromRight)) {
                (x: false, fromRight: false)
                    when position.dx > visualRect.value.right =>
                  true,
                (x: false, fromRight: true)
                    when position.dx < visualRect.value.left =>
                  true,
                (x: true, fromRight: false)
                    when position.dx < visualRect.value.left =>
                  false,
                (x: true, fromRight: true)
                    when position.dx > visualRect.value.right =>
                  false,
                _ => flip.value.x // should never be used
              },
              y: switch ((y: flip.value.y, fromBottom: fromBottom)) {
                (y: false, fromBottom: false)
                    when position.dy > visualRect.value.bottom =>
                  true,
                (y: false, fromBottom: true)
                    when position.dy < visualRect.value.top =>
                  true,
                (y: true, fromBottom: false)
                    when position.dy < visualRect.value.top =>
                  false,
                (y: true, fromBottom: true)
                    when position.dy > visualRect.value.bottom =>
                  false,
                _ => flip.value.y // should never be used
              }
            );
            final rect = originalRect.value;
            newRect.value = edge
                ? Rect.fromPoints(
                    position,
                    switch ((fromRight, fromBottom)) {
                          (false, false) => rect.bottomRight,
                          (true, false) => rect.bottomLeft,
                          (false, true) => rect.topRight,
                          (true, true) => rect.topLeft
                        } -
                        (pressedCmd ? delta : Offset.zero),
                  )
                : Rect.fromPoints(
                    Offset(
                        switch ((fromLeft, fromRight)) {
                          (true, false) => position.dx,
                          (false, true) => position.dx,
                          _ => rect.right,
                        },
                        switch ((fromTop, fromBottom)) {
                          (true, false) => position.dy,
                          (false, true) => position.dy,
                          _ => rect.top,
                        }),
                    switch ((fromRight, fromBottom)) {
                          (false, false) => rect.bottomRight,
                          (true, false) => rect.bottomLeft,
                          (false, true) => rect.topRight,
                          (true, true) => rect.topLeft
                        } -
                        (pressedCmd
                            ? Offset(
                                switch ((fromLeft, fromRight)) {
                                  (true, false) => delta.dx,
                                  (false, true) => delta.dx,
                                  _ => 0
                                },
                                switch ((fromTop, fromBottom)) {
                                  (true, false) => delta.dy,
                                  (false, true) => delta.dy,
                                  _ => 0
                                },
                              )
                            : Offset.zero),
                  );
            visualRect.value = Rect.fromLTRB(
              snap(newRect.value.left, snapValue),
              snap(newRect.value.top, snapValue),
              snap(newRect.value.right, snapValue),
              snap(newRect.value.bottom, snapValue),
            );
          },
          child: ColoredBox(
            color: Colors.white,
            child: SizedBox(
              width: switch ((
                edge,
                fromLeft,
                fromTop,
                fromRight,
                fromBottom
              )) {
                (false, false, _, false, _) => rectValue.width,
                (false, _, _, _, _) => 2,
                _ => gestureSize,
              },
              height: switch ((
                edge,
                fromLeft,
                fromTop,
                fromRight,
                fromBottom
              )) {
                (false, _, false, _, false) => rectValue.height,
                (false, _, _, _, _) => 2,
                _ => gestureSize,
              },
            ),
          ),
        ),
      ),
    );
  }

  double snap(double value, int snapValue) =>
      keys.value.contains(PhysicalKeyboardKey.altLeft)
          ? (value / snapValue).truncateToDouble() * snapValue
          : (value / 0.1).truncateToDouble() * 0.1;
}
