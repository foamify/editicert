import 'dart:math';

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
      triangle: ValueNotifier(Triangle(
        const Offset(0, 0),
        const Size(200, 200),
        0,
        const Offset(0, 0),
      )),
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
                                  triangle: e.triangle,
                                  keys: e.keys,
                                ))
                            .toList()),
                  ),
                  SizedBox(
                    width: 240,
                    child: ValueListenableBuilder(
                        valueListenable: components.first.triangle,
                        builder: (context, triangle, child) {
                          return ListView(
                            children: [
                              TextField(
                                decoration: const InputDecoration(
                                  label: Text('x'),
                                ),
                                keyboardType: TextInputType.number,
                                controller: TextEditingController(
                                    text: triangle.pos.dx.toStringAsFixed(1)),
                              ),
                              TextField(
                                decoration: const InputDecoration(
                                  label: Text('y'),
                                ),
                                keyboardType: TextInputType.number,
                                controller: TextEditingController(
                                    text: triangle.pos.dy.toStringAsFixed(1)),
                              ),
                              TextField(
                                decoration: const InputDecoration(
                                  label: Text('width'),
                                ),
                                keyboardType: TextInputType.number,
                                controller: TextEditingController(
                                    text:
                                        triangle.size.width.toStringAsFixed(1)),
                              ),
                              TextField(
                                decoration: const InputDecoration(
                                  label: Text('height'),
                                ),
                                keyboardType: TextInputType.number,
                                controller: TextEditingController(
                                    text: triangle.size.height
                                        .toStringAsFixed(1)),
                              ),
                              TextField(
                                decoration: const InputDecoration(
                                  label: Text('rotation'),
                                ),
                                keyboardType: TextInputType.number,
                                controller: TextEditingController(
                                    text: (triangle.angle / pi * 180).toStringAsFixed(1)),
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
