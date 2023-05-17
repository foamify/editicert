import 'dart:math';

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
  int index = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          ResizableWidget(
            originalRect:
                ValueNotifier(const Rect.fromLTWH(150, 150, 100, 200)),
            visualRect: ValueNotifier(const Rect.fromLTWH(150, 150, 100, 200)),
            newRect: ValueNotifier(const Rect.fromLTWH(150, 150, 100, 200)),
            flip: ValueNotifier((x: false, y: false)),
            keys: ValueNotifier(<PhysicalKeyboardKey>{}),
            originalPosition: ValueNotifier(Offset.zero),
          ),
        ],
      ),
    );
  }
}

class ResizableWidget extends StatefulWidget {
  ResizableWidget(
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
      child: Stack(
        children: [
          ValueListenableBuilder(
              valueListenable: visualRect,
              builder: (context, rectValue, child) {
                return Positioned(
                  left: rectValue.left,
                  top: rectValue.top,
                  child: ValueListenableBuilder(
                      valueListenable: flip,
                      builder: (context, flipValue, child) {
                        return Transform.flip(
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
                        );
                      }),
                );
              }),
          AnimatedBuilder(
            animation: Listenable.merge([flip, visualRect, keys]),
            builder: (context, child) => Stack(
              children: [
                buildResizer(
                  flip.value,
                  visualRect.value,
                  gestureSize,
                  keys.value,
                  fromRight: true,
                ),
                buildResizer(
                  flip.value,
                  visualRect.value,
                  gestureSize,
                  keys.value,
                  fromBottom: true,
                ),
                buildResizer(
                  flip.value,
                  visualRect.value,
                  gestureSize,
                  keys.value,
                  fromRight: true,
                  fromBottom: true,
                ),
                buildResizer(
                  flip.value,
                  visualRect.value,
                  gestureSize,
                  keys.value,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildResizer(({bool x, bool y}) flipValue, Rect rectValue,
      double gestureSize, Set<PhysicalKeyboardKey> keys,
      {bool fromRight = false, bool fromBottom = false}) {
    print(keys);
    final pressedCmd = keys.contains(PhysicalKeyboardKey.metaLeft);
    return Positioned(
      left: switch ((flipValue.x, fromRight)) {
            (false, false) => rectValue.left,
            (true, false) => rectValue.right,
            (false, true) => rectValue.right,
            (true, true) => rectValue.left,
          } -
          gestureSize / 2,
      top: switch ((flipValue.y, fromBottom)) {
            (false, false) => rectValue.top,
            (true, false) => rectValue.bottom,
            (false, true) => rectValue.bottom,
            (true, true) => rectValue.top,
          } -
          gestureSize / 2,
      child: Align(
        child: MouseRegion(
          cursor: SystemMouseCursors.precise,
          child: Listener(
            onPointerDown: (event) {
              originalPosition.value =
                  event.position - Offset(gestureSize, gestureSize) / 2;
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
              newRect.value = Rect.fromPoints(
                position,
                switch ((fromRight, fromBottom)) {
                      (false, false) => rect.bottomRight,
                      (true, false) => rect.bottomLeft,
                      (false, true) => rect.topRight,
                      (true, true) => rect.topLeft
                    } -
                    (pressedCmd ? delta : Offset.zero),
              );
              visualRect.value = Rect.fromLTRB(
                snap(newRect.value.left, snapValue),
                snap(newRect.value.top, snapValue),
                snap(newRect.value.right, snapValue),
                snap(newRect.value.bottom, snapValue),
              );
            },
            child: ColoredBox(
              color: Colors.white30,
              child: SizedBox(width: gestureSize, height: gestureSize),
            ),
          ),
        ),
      ),
    );
  }

  double snap(double value, int snapValue) =>
      keys.value.contains(PhysicalKeyboardKey.altLeft)
          ? (value / snapValue).truncateToDouble() * snapValue
          : value;
}
