import 'dart:math';

import 'package:editicert/providers/component.dart';
import 'package:editicert/utils.dart';
import 'package:editicert/utils.dart';
import 'package:editicert/widgets/component_widget.dart';
import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
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
      home: HomePage(),
    );
  }
}

class HomePage extends ConsumerWidget {
  HomePage({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final components = ref.watch(componentsProvider);
    if (components.isEmpty) {
      final components = ref.read(componentsProvider.notifier);
      components.add((
        name: 'Triangle 1',
        triangle: Triangle(Offset.zero, const Size(200, 200), 0)
      ));
      components.add((
        name: 'Triangle 1',
        triangle: Triangle(Offset.zero, const Size(200, 200), 0)
      ));
      components.add((
        name: 'Triangle 1',
        triangle: Triangle(Offset.zero, const Size(200, 200), 0)
      ));
      components.add((
        name: 'Triangle 1',
        triangle: Triangle(Offset.zero, const Size(200, 200), 0)
      ));
      components.add((
        name: 'Triangle 1',
        triangle: Triangle(Offset.zero, const Size(200, 200), 0)
      ));
      components.add((
        name: 'Triangle 1',
        triangle: Triangle(Offset.zero, const Size(200, 200), 0)
      ));
      components.add((
        name: 'Triangle 1',
        triangle: Triangle(Offset.zero, const Size(200, 200), 0)
      ));
      components.add((
        name: 'Triangle 1',
        triangle: Triangle(Offset.zero, const Size(200, 200), 0)
      ));
    }
    final selected = ref.watch(selectedProvider);
    final hovered = ref.watch(hoveredProvider);
    return Scaffold(
      body: Column(
        children: [
          Container(
            color: Theme.of(context).colorScheme.surfaceVariant,
            child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
              Tooltip(
                richMessage: TextSpan(
                  children: [
                    const TextSpan(
                      text: 'Move ',
                    ),
                    TextSpan(
                      text: ' V',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        color: Colors.grey.shade600,
                      ),
                    )
                  ],
                ),
                child: Card(
                  color: Theme.of(context).colorScheme.surfaceVariant,
                  elevation: 0,
                  clipBehavior: Clip.hardEdge,
                  child: InkWell(
                    onTap: () {},
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Transform.rotate(
                        angle: -pi / 4,
                        alignment: const Alignment(-0.2, 0),
                        child: const Icon(Icons.navigation_outlined, size: 18),
                      ),
                    ),
                  ),
                ),
              ),
              Tooltip(
                richMessage: TextSpan(
                  children: [
                    const TextSpan(
                      text: 'Rectangle ',
                    ),
                    TextSpan(
                      text: ' R',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        color: Colors.grey.shade600,
                      ),
                    )
                  ],
                ),
                child: Card(
                  clipBehavior: Clip.hardEdge,
                  color: Theme.of(context).colorScheme.surfaceVariant,
                  elevation: 0,
                  child: InkWell(
                    onTap: () {},
                    child: const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Icon(
                        CupertinoIcons.square,
                        size: 18,
                      ),
                    ),
                  ),
                ),
              ),
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
                            color: switch ((
                              selected.contains(i),
                              hovered.contains(i),
                            )) {
                              (false, false) => Colors.transparent,
                              (false, true) =>
                                Theme.of(context).primaryColor.withOpacity(.5),
                              (true, _) => Theme.of(context).primaryColor,
                            },
                            // color: Colors.transparent,
                            margin: EdgeInsets.zero
                                .copyWith(top: 1, left: 2, right: 1),
                            child: MouseRegion(
                              onEnter: (event) =>
                                  ref.read(hoveredProvider.notifier).add(i),
                              onExit: (event) =>
                                  ref.read(hoveredProvider.notifier).remove(i),
                              child: ListTile(
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
                                contentPadding: EdgeInsets.only(left: 4, right: 6),
                                trailing: hovered.contains(i)
                                    ? const SizedBox(
                                        width: 18 * 2,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Icon(
                                              CupertinoIcons.lock_open_fill,
                                              size: 14,
                                            ),
                                            Icon(
                                              CupertinoIcons.eye,
                                              size: 14,
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
                Expanded(
                  child: Stack(children: [
                    GestureDetector(
                      onTap: () {
                        ref.read(selectedProvider.notifier).clear();
                      },
                      child: Container(
                        width: double.infinity,
                        height: double.infinity,
                        color: Colors.transparent,
                      ),
                    ),
                    ...components.mapIndexed((i, e) => ComponentWidget(
                          index: i,
                        )),
                  ]),
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
                                      text: triangle.pos.dx.toStringAsFixed(1)),
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
                                      text: triangle.pos.dy.toStringAsFixed(1)),
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
                                    border: OutlineInputBorder(gapPadding: 2),
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
    );
  }
}
