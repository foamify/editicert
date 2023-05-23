import 'dart:math';

import 'package:editicert/widgets/component_widget.dart';
import 'package:flutter/cupertino.dart';
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
                            .map((e) => ComponentWidget(
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
                                              Icons.rotate_90_degrees_ccw,
                                              size: 12,
                                            ),
                                          ),
                                          border: OutlineInputBorder(),
                                        ),
                                        keyboardType: TextInputType.number,
                                        controller: TextEditingController(
                                          text: '${(switch (triangle.angle) {
                                                > pi * 2 =>
                                                  triangle.angle - pi * 2,
                                                < 0 => pi * 2 - triangle.angle,
                                                _ => triangle.angle
                                              } / pi * 180).toStringAsFixed(1)}°',
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
              )),
    );
  }
}
