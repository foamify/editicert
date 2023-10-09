import 'dart:math';

import 'package:collection/collection.dart';
import 'package:editicert/logic/canvas_service.dart';
import 'package:editicert/logic/component_index_service.dart';
import 'package:editicert/utils.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it_mixin/get_it_mixin.dart';

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
                    border: Border.all(
                      color: Colors.white,
                      width: .5,
                    ),
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

    final canvasSizeControlData = [
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
    ];

    final canvasSizeControl = canvasSizeControlData.map(
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
                    SizedBox(height: 32, child: title),
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