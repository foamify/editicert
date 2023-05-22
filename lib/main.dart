import 'package:editicert/widgets/resizable_widget.dart';
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
