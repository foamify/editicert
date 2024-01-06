// ignore_for_file: avoid-unsafe-collection-methods

import 'dart:math';

import 'package:collection/collection.dart';
import 'package:editicert/models/element_model.dart';
import 'package:editicert/models/snap_line.dart';
import 'package:editicert/state/signal_state.dart';
import 'package:editicert/util/extensions.dart';
import 'package:editicert/util/geometry.dart';
import 'package:editicert/widgets/canvas_interactive_viewer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:signals/signals_flutter.dart';
import 'package:transparent_pointer/transparent_pointer.dart';
import 'package:vector_math/vector_math_64.dart' hide Colors;

class MainPage extends StatefulWidget {
  const MainPage();
  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final _keyboardFocus = FocusNode();

  @override
  void dispose() {
    _keyboardFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print('rebuild');
    return ColoredBox(
      color: const Color(0xFF333333),
      child: CallbackShortcuts(
        bindings: {},
        child: KeyboardListener(
          autofocus: true,
          focusNode: _keyboardFocus,
          onKeyEvent: (key) {
            if (key is KeyDownEvent) {
              canvasLogicalKeys.add(key.logicalKey);
            } else if (key is KeyUpEvent) {
              canvasLogicalKeys.remove(key.logicalKey);
            }
          },
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              GestureDetector(
                onTap: () {
                  canvasSelectedElement.value = null;
                },
              ),
              // Watch.builder(
              //   builder: (cubitContext) {
              //     final state = canvasTransformCurrent;
              //     print('Container rebuilt');
              //     return Transform(
              //       transform: state.value,
              //       child:
              //           Container(width: 200, height: 200, color: Colors.red),
              //     );
              //   },
              // ),
              TransparentPointer(
                child: Listener(
                  onPointerDown: (event) {
                    _keyboardFocus.requestFocus();
                    pointerButton.value = event.buttons;
                  },
                  onPointerUp: (event) {
                    pointerButton.value = event.buttons;
                  },
                  child: MouseRegion(
                    child: Watch.builder(
                      builder: (cubitContext) {
                        final _ = canvasTransformCurrent.value;
                        return CanvasInteractiveViewer.builder(
                          minScale: .01,
                          boundaryMargin: const EdgeInsets.all(double.infinity),
                          clipBehavior: Clip.none,
                          // scaleEnabled: false,
                          transformationController: canvasTransformController(),
                          // onInteractionStart: (details) {
                          //   final button =
                          //       context.read<PointersCubit>().state;
                          //   if (button != PointerButton.middle &&
                          //       button != null) {
                          //     return;
                          //   }
                          //   context
                          //       .read<EventHandlerBloc>()
                          //       .add(PanCanvasInitial());
                          // },
                          // onInteractionUpdate: (details) {
                          //   final button =
                          //       context.read<PointersCubit>().state;
                          //   if (button != PointerButton.middle &&
                          //       button != null) {
                          //     return;
                          //   }
                          //   final eventHandlerBloc =
                          //       context.read<EventHandlerBloc>();
                          //   if (details.focalPointDelta != Offset.zero) {
                          //     eventHandlerBloc.add(
                          //       PanCanvasEvent(details.focalPointDelta),
                          //     );
                          //   } else if (details.scale != 0) {
                          //     print(details.)
                          //     print('Scale: ${details.scale}');
                          //     eventHandlerBloc.add(
                          //       ZoomCanvasEvent(
                          //         details.scale,
                          //         details.focalPoint,
                          //       ),
                          //     );
                          //   }
                          // },
                          // onInteractionEnd: (details) {
                          //   context
                          //       .read<EventHandlerBloc>()
                          //       .add(PanCanvasEnd());
                          // },
                          builder: (iVContext, viewport) {
                            return Container(
                              width: 200,
                              height: 200,
                              color: Colors.red,
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),
              ),

              Watch.builder(
                builder: (context) {
                  final keys = canvasLogicalKeys();
                  if (keys.contains(LogicalKeyboardKey.space)) {
                    return const SizedBox.shrink();
                  }
                  return GestureDetector(
                    onPanStart: (details) {
                      batch(() {
                        canvasTransformInitial.value =
                            canvasTransformCurrent()();
                        pointerPositionInitial.value =
                            details.globalPosition.toVector2();
                        isMarquee.value = true;
                      });
                    },
                    onPanUpdate: (details) {
                      pointerPositionCurrent.value =
                          details.globalPosition.toVector2();

                      final initialPoint = pointerPositionInitial();
                      final currentPoint = pointerPositionCurrent();

                      final initialTransform = canvasTransformInitial();
                      if (initialTransform == null) return;
                      final transform = canvasTransformCurrent()();

                      final delta = initialTransform.fromScene(Offset.zero) -
                          transform.fromScene(Offset.zero);

                      debugPoints.value = [
                        initialTransform
                                .toScene(
                                  initialTransform.fromScene(
                                    initialPoint.toOffset() + delta,
                                  ),
                                )
                                .toVector2() +
                            delta.toVector2(),
                        currentPoint,
                      ];
                    },
                    onPanEnd: (details) {
                      batch(() {
                        canvasTransformInitial.value = null;
                        isMarquee.value = false;
                      });
                      debugPoints.value = [];
                    },
                  );
                },
              ),

              TransparentPointer(
                child: Material(
                  color: Colors.transparent,
                  child: Watch.builder(
                    builder: (context) {
                      final elements = canvasElements();
                      print(elements.length);
                      final transform = canvasTransformCurrent()();
                      final scale = transform.getMaxScaleOnAxis();
                      final translate = transform.getTranslation();
                      return Stack(
                        clipBehavior: Clip.none,
                        children: [
                          for (var i = 0; i < elements.length; i++)
                            Watch.builder(
                              builder: (context) {
                                final hovered = canvasHoveredElement();
                                final selected = canvasSelectedElement();
                                final element = elements[i];
                                final hoveredMultiple =
                                    canvasHoveredMultipleElements()
                                        .contains(element.id);
                                final box = element.transform;
                                final alignmentIndex =
                                    switch ((box.flipX, box.flipY)) {
                                  (false, false) => 0,
                                  (true, false) => 1,
                                  (false, true) => 3,
                                  _ => 2,
                                };
                                final valueOffset =
                                    box.rotated.offsets[alignmentIndex] * scale;
                                final offset =
                                    Offset(translate.x, translate.y) +
                                        valueOffset;
                                return Positioned(
                                  left: offset.dx,
                                  top: offset.dy,
                                  child: Transform.scale(
                                    scale: transform.getMaxScaleOnAxis(),
                                    alignment: Alignment.topLeft,
                                    child: Transform.rotate(
                                      angle: box.angle * pi / 180,
                                      alignment: Alignment.topLeft,
                                      child: Transform.flip(
                                        flipX: box.flipX,
                                        flipY: box.flipY,
                                        child: MouseRegion(
                                          onEnter: (event) {
                                            canvasHoveredElement
                                                .setHover(element.id);
                                          },
                                          onExit: (event) =>
                                              canvasHoveredElement
                                                  .clearHover(element.id),
                                          child: GestureDetector(
                                            onTap: () {
                                              canvasSelectedElement.value =
                                                  element.id;
                                            },
                                            onPanStart: (details) {
                                              handleMoveStart(element, details);
                                            },
                                            onPanUpdate: (details) {
                                              handleMoveUpdate(
                                                element,
                                                details,
                                                elements,
                                                i,
                                              );
                                            },
                                            onPanEnd: (details) {
                                              handleMoveEnd(
                                                element,
                                                box,
                                                elements,
                                                i,
                                              );
                                            },
                                            child: Container(
                                              key: ValueKey(element.id),
                                              width: box.width,
                                              height: box.height,
                                              color: selected == element.id
                                                  ? Colors.blueAccent
                                                  : hovered == element.id ||
                                                          hoveredMultiple
                                                      ? Colors.blueAccent
                                                      : element.data.color,
                                              child: Text(element.id),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                        ],
                      );
                    },
                  ),
                ),
              ),
              buildTranslator(),
              for (var i = 0; i < 4; i++) buildEdgeRotators(i),
              for (var i = 0; i < 4; i++) buildSideResizers(i),
              for (var i = 0; i < 4; i++) buildEdgeResizers(i),
              const SnapLinePainter(),
              IgnorePointer(
                child: Watch.builder(
                  builder: (context) {
                    final state = debugPoints.value;
                    return Stack(
                      children: [
                        for (var i = 0; i < state.length; i++)
                          Positioned(
                            left: state[i].x,
                            top: state[i].y,
                            child: AnimatedSlide(
                              duration: Duration.zero,
                              offset: const Offset(-.5, -.5),
                              child: Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: colors[i].shade900,
                                    strokeAlign: BorderSide.strokeAlignOutside,
                                  ),
                                  shape: BoxShape.circle,
                                ),
                                foregroundDecoration: BoxDecoration(
                                  border: Border.all(
                                    color: colors[i].shade100,
                                  ),
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ),

              IgnorePointer(
                child: Watch.builder(
                  builder: (context) {
                    final marquee = marqueeRect();
                    if (marquee == null) return const SizedBox.shrink();
                    return Transform.translate(
                      offset: marquee.topLeft,
                      child: Container(
                        width: marquee.width,
                        height: marquee.height,
                        decoration: BoxDecoration(
                          color: Colors.blueAccent.withOpacity(.5),
                          border: Border.all(
                            color: Color.alphaBlend(
                              Colors.blueAccent.withOpacity(.5),
                              Colors.blueAccent.withOpacity(.5),
                            ),
                            strokeAlign: BorderSide.strokeAlignOutside,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              Positioned(
                top: 0,
                right: 0,
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      children: [
                        FilledButton(
                          onPressed: () {
                            canvasElements.add(ElementModel());
                          },
                          child: const Text('Add Box'),
                        ),
                        const SizedBox.square(dimension: 12),
                        FilledButton(
                          onPressed: () {
                            canvasElements.value = [...canvasElements()]
                              ..removeLast();
                          },
                          child: const Text('Remove Last Box'),
                        ),
                        const SizedBox.square(dimension: 12),
                        Watch.builder(
                          builder: (context) {
                            final selected = canvasSelectedElement();
                            final elements = canvasElements();
                            final element = elements.firstWhereOrNull(
                              (element) => element.id == selected,
                            );
                            if (element == null) return const SizedBox.shrink();
                            return Text(
                              [
                                'id: ${element.id}',
                                'offset: ${element.transform.rect.topLeft}',
                                'center: ${element.transform.rect.center}',
                                'rect: ${element.transform.rect}',
                                'flipX: ${element.transform.flipX}',
                                'flipY: ${element.transform.flipY}',
                              ].join('\n'),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 0,
                left: 0,
                width: 240,
                bottom: 0,
                child: Card(
                  shape: RoundedRectangleBorder(
                    // Make sure it corresponds to window border
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Watch.builder(
                    builder: (context) {
                      final elements = canvasElements();
                      return ReorderableListView.builder(
                        proxyDecorator: (child, index, animation) {
                          return child;
                        },
                        itemCount: elements.length,
                        itemBuilder: (context, index) {
                          return [
                            ...elements.map(
                              (e) => Watch.builder(
                                key: ValueKey(e.id),
                                builder: (context) {
                                  final hovered = canvasHoveredElement() ==
                                      elements[index].id;
                                  final selected = canvasSelectedElement() ==
                                      elements[index].id;
                                  return MouseRegion(
                                    onEnter: (event) =>
                                        canvasHoveredElement.value = e.id,
                                    onExit: (event) =>
                                        canvasHoveredElement.value = null,
                                    child: Padding(
                                      padding: const EdgeInsets.all(2.0),
                                      child: GestureDetector(
                                        onTap: () =>
                                            canvasSelectedElement.value = e.id,
                                        child: DecoratedBox(
                                          position:
                                              DecorationPosition.foreground,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            border: Border.all(
                                              color: selected
                                                  ? Colors.blueAccent
                                                  : Colors.transparent,
                                            ),
                                          ),
                                          child: Card(
                                            color: Color.alphaBlend(
                                              Colors.blueAccent.withOpacity(
                                                hovered ? .5 : .1,
                                              ),
                                              Theme.of(context).cardColor,
                                            ),
                                            margin: EdgeInsets.zero,
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: SizedBox(
                                                width: double.infinity,
                                                child: Text(e.id.split('-')[1]),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ][index];
                        },
                        onReorder: (int oldIndex, int newIndex) {
                          if (oldIndex == newIndex) return;
                          if (oldIndex < newIndex) {
                            newIndex -= 1;
                          }
                          canvasElements.value = [...elements]
                            ..removeAt(oldIndex)
                            ..insert(newIndex, elements[oldIndex]);
                        },
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // handlers

  void handleMoveEnd(
    ElementModel element,
    Box box,
    List<ElementModel> elements,
    int index,
  ) {
    element
      ..transform = Box(
        quad: box.quad,
        angle: box.angle,
        origin: box.rect.center,
      )
      ..transform = element.transform.translate(
        -element.transform.rotated.rect.center + box.rotated.rect.center,
      );
    canvasElements.value = [...elements]..[index] = element;
  }

  void handleMoveUpdate(
    ElementModel element,
    DragUpdateDetails details,
    List<ElementModel> elements,
    int index,
  ) {
    final initialBox = element.initialTransform!;
    final flipX = initialBox.flipX ? -1.0 : 1.0;
    final flipY = initialBox.flipY ? -1.0 : 1.0;
    element.transform = initialBox.translate(details.delta.scale(flipX, flipY));
    print(canvasElements.value.map((e) => e.id));
    print(canvasElements.value.map((e) => e.transform.offset0));

    final lines = snapLines();

    if (lines.isNotEmpty) {
      final shortestLineX = lines.where((element) => element.isSnapX).fold(
            lines.first,
            (value, element) => value.length < element.length ? value : element,
          );

      final shortestLineY = lines.where((element) => element.isSnapY).fold(
            lines.first,
            (value, element) => value.length < element.length ? value : element,
          );

      element.transform.translate(shortestLineX.delta.toOffset() / 2);
      element.transform.translate(shortestLineY.delta.toOffset() / 2);
    }

    canvasElements.value = [...elements]..[index] = element;
  }

  void handleMoveStart(ElementModel element, DragStartDetails details) {
    element.initialTransform = element.transform;
    pointerPositionInitial.value = details.globalPosition.toVector2();
  }

  // handlers end
  // controllers start

  Widget buildTranslator() {
    return Watch.builder(
      builder: (context) {
        final elements = canvasElements();
        final selected = canvasSelectedElement();
        final element = elements.firstWhereOrNull(
          (element) => element.id == selected,
        );
        if (element == null) return const SizedBox.shrink();
        final transform = canvasTransformCurrent()();
        final scale = transform.getMaxScaleOnAxis();
        final translate = transform.getTranslation();
        final box = element.transform;
        final alignmentIndex = switch ((box.flipX, box.flipY)) {
          (false, false) => 0,
          (true, false) => 1,
          (false, true) => 3,
          _ => 2,
        };
        final elementIndex = elements.indexOf(element);
        final valueOffset = box.rotated.offsets[alignmentIndex] * scale;
        final offset = Offset(translate.x, translate.y) + valueOffset;
        return Positioned(
          left: offset.dx,
          top: offset.dy,
          child: Transform.scale(
            scale: transform.getMaxScaleOnAxis(),
            alignment: Alignment.topLeft,
            child: Transform.rotate(
              angle: box.angle * pi / 180,
              alignment: Alignment.topLeft,
              child: Transform.flip(
                flipX: box.flipX,
                flipY: box.flipY,
                child: MouseRegion(
                  onEnter: (event) {
                    canvasHoveredElement.setHover(element.id);
                  },
                  onExit: (event) =>
                      canvasHoveredElement.clearHover(element.id),
                  child: GestureDetector(
                    onPanStart: (details) {
                      canvasIsMovingSelected.value = true;
                      handleMoveStart(element, details);
                    },
                    onPanUpdate: (details) {
                      handleMoveUpdate(
                        element,
                        details,
                        elements,
                        elementIndex,
                      );
                    },
                    onPanEnd: (details) {
                      canvasIsMovingSelected.value = false;
                      handleMoveEnd(element, box, elements, elementIndex);
                    },
                    child: Container(
                      key: ValueKey(element.id),
                      width: box.width,
                      height: box.height,
                      color: Colors.transparent,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget buildEdgeRotators(int i) {
    return Watch.builder(
      builder: (context) {
        final isMoving = canvasIsMovingSelected();
        if (isMoving) return const SizedBox.shrink();
        final elements = canvasElements();
        final selected = canvasSelectedElement();
        final elementIndexed = elements.indexed.firstWhereOrNull(
          (element) => element.$2.id == selected,
        );
        if (elementIndexed == null) return const SizedBox.shrink();
        final (index, element) = elementIndexed;
        final box = element.transform;
        //--
        final canvasTransform = canvasTransformCurrent()();
        final scale = canvasTransform.getMaxScaleOnAxis();
        final translate = canvasTransform.getTranslation();
        final valueOffset = box.rotated.offsets[i] * scale;
        final offset = Offset(translate.x, translate.y) + valueOffset;
        return Positioned(
          left: offset.dx,
          top: offset.dy,
          child: Watch.builder(
            builder: (_) {
              final transform = canvasTransformController.value;
              final alignment = switch (i) {
                0 => Alignment.topLeft,
                1 => Alignment.topRight,
                2 => Alignment.bottomRight,
                _ => Alignment.bottomLeft,
              };
              return AnimatedSlide(
                duration: Duration.zero,
                offset: const Offset(-.5, -.5),
                child: Transform.rotate(
                  angle: box.angle * pi / 180,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onPanUpdate: (event) {
                      element.transform = box.rotateByPan(
                        transform.toScene(event.globalPosition),
                        alignment,
                      );
                      canvasElements.value = [...elements]..[index] = element;
                    },
                    child: Container(
                      width: 20,
                      height: 20,
                      color: colors[i].withOpacity(.25),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget buildEdgeResizers(int i) {
    return Watch.builder(
      builder: (context) {
        final isMoving = canvasIsMovingSelected();
        if (isMoving) return const SizedBox.shrink();
        final elements = canvasElements();
        final selected = canvasSelectedElement();
        final elementIndexed = elements.indexed.firstWhereOrNull(
          (element) => element.$2.id == selected,
        );
        if (elementIndexed == null) return const SizedBox.shrink();
        final (index, element) = elementIndexed;
        final box = element.transform;
        //--
        final canvasTransform = canvasTransformCurrent()();
        final scale = canvasTransform.getMaxScaleOnAxis();
        final translate = canvasTransform.getTranslation();
        final valueOffset = box.rotated.offsets[i] * scale;
        final offset = Offset(translate.x, translate.y) + valueOffset;
        return Positioned(
          left: offset.dx,
          top: offset.dy,
          child: Watch.builder(
            builder: (_) {
              final transform = canvasTransformController.value;
              final alignment = switch (i) {
                0 => Alignment.topLeft,
                1 => Alignment.topRight,
                2 => Alignment.bottomRight,
                _ => Alignment.bottomLeft,
              };
              return AnimatedSlide(
                duration: Duration.zero,
                offset: const Offset(-.5, -.5),
                child: Transform.rotate(
                  angle: box.angle * pi / 180,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onPanStart: (details) => setState(() {
                      element.initialTransform = element.transform;
                      pointerPositionInitial.value =
                          transform.toScene(details.localPosition).toVector2();
                    }),
                    onPanUpdate: (details) {
                      final keys = canvasLogicalKeys.value;

                      final pressedShift = keys.containsAny([
                        LogicalKeyboardKey.shift,
                        LogicalKeyboardKey.shiftLeft,
                        LogicalKeyboardKey.shiftRight,
                      ]);

                      final pressedAlt = keys.containsAny([
                        LogicalKeyboardKey.alt,
                        LogicalKeyboardKey.altLeft,
                        LogicalKeyboardKey.altRight,
                      ]);

                      final initialBox = element.initialTransform!;
                      final initialPosition =
                          pointerPositionInitial().toOffset();

                      if (pressedShift && pressedAlt) {
                        element.transform = box.resizeSymmetricScaled(
                          initialBox,
                          initialPosition,
                          transform.toScene(details.localPosition),
                          alignment,
                        );
                      } else if (pressedShift) {
                        element.transform = box.resizeScaled(
                          initialBox,
                          initialPosition,
                          transform.toScene(details.localPosition),
                          alignment,
                        );
                      } else if (pressedAlt) {
                        element.transform = box.resizeSymmetric(
                          initialBox,
                          initialPosition,
                          transform.toScene(details.localPosition),
                          alignment,
                        );
                      } else {
                        element.transform = box.resize(
                          initialBox,
                          initialPosition,
                          transform.toScene(details.localPosition),
                          alignment,
                        );
                      }
                      canvasElements.value = [...elements]..[index] = element;
                    },
                    onPanEnd: (details) {
                      element
                        ..transform = Box(
                          quad: box.quad,
                          angle: box.angle,
                          origin: box.rect.center,
                        )
                        ..transform = element.transform.translate(
                          -element.transform.rotated.rect.center +
                              box.rotated.rect.center,
                        );
                      canvasElements.value = [...elements]..[index] = element;
                    },
                    child: Container(width: 10, height: 10, color: colors[i]),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget buildSideResizers(int i) {
    return Watch.builder(
      builder: (context) {
        final isMoving = canvasIsMovingSelected();
        if (isMoving) return const SizedBox.shrink();
        final elements = canvasElements();
        final selected = canvasSelectedElement();
        final elementIndexed = elements.indexed.firstWhereOrNull(
          (element) => element.$2.id == selected,
        );
        if (elementIndexed == null) return const SizedBox.shrink();
        final (index, element) = elementIndexed;
        final box = element.transform;
        //--
        final canvasTransform = canvasTransformCurrent()();
        final scale = canvasTransform.getMaxScaleOnAxis();
        final translate = canvasTransform.getTranslation();
        final valueOffset = box.rotated.offsets[i] * scale;
        final offset = Offset(translate.x, translate.y) + valueOffset;
        return Positioned(
          left: offset.dx,
          top: offset.dy,
          child: Watch.builder(
            builder: (_) {
              final transform = canvasTransformController.value;
              final alignment = switch (i) {
                0 => Alignment.centerLeft,
                1 => Alignment.topCenter,
                2 => Alignment.centerRight,
                _ => Alignment.bottomCenter,
              };
              return Transform.rotate(
                angle: box.angle * pi / 180,
                alignment: Alignment.topLeft,
                child: Transform.translate(
                  offset: switch (i) {
                    0 => Offset(
                        -5,
                        box.flipY ? -box.rect.height * scale + 5 : 5,
                      ),
                    1 =>
                      Offset(box.flipX ? 5 : -box.rect.width * scale + 5, -5),
                    2 => Offset(
                        -5,
                        box.flipY ? 5 : -box.rect.height * scale + 5,
                      ),
                    _ =>
                      Offset(box.flipX ? -box.rect.width * scale + 5 : 5, -5),
                  },
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onPanStart: (details) => setState(() {
                      element.initialTransform = element.transform;
                      canvasElements.value = [...elements]..[index] = element;
                      pointerPositionInitial.value =
                          transform.toScene(details.localPosition).toVector2();
                    }),
                    onPanUpdate: (details) {
                      final keys = canvasLogicalKeys.value;

                      final pressedShift = keys.containsAny([
                        LogicalKeyboardKey.shift,
                        LogicalKeyboardKey.shiftLeft,
                        LogicalKeyboardKey.shiftRight,
                      ]);

                      final pressedAlt = keys.containsAny([
                        LogicalKeyboardKey.alt,
                        LogicalKeyboardKey.altLeft,
                        LogicalKeyboardKey.altRight,
                      ]);

                      final initialBox = element.initialTransform!;
                      final initialPosition =
                          pointerPositionInitial().toOffset();

                      if (pressedShift && pressedAlt) {
                        element.transform = box.resizeSymmetricScaled(
                          initialBox,
                          initialPosition,
                          transform.toScene(details.localPosition),
                          alignment,
                        );
                      } else if (pressedShift) {
                        element.transform = box.resizeScaled(
                          initialBox,
                          initialPosition,
                          transform.toScene(details.localPosition),
                          alignment,
                        );
                      } else if (pressedAlt) {
                        element.transform = box.resizeSymmetric(
                          initialBox,
                          initialPosition,
                          transform.toScene(details.localPosition),
                          alignment,
                        );
                      } else {
                        element.transform = box.resize(
                          initialBox,
                          initialPosition,
                          transform.toScene(details.localPosition),
                          alignment,
                        );
                      }
                      canvasElements.value = [...elements]..[index] = element;
                    },
                    onPanEnd: (details) {
                      element
                        ..transform = Box(
                          quad: box.quad,
                          angle: box.angle,
                          origin: box.rect.center,
                        )
                        ..transform = element.transform.translate(
                          -element.transform.rotated.rect.center +
                              box.rotated.rect.center,
                        );
                      canvasElements.value = [...elements]..[index] = element;
                    },
                    child: Container(
                      width: switch (i) {
                        0 || 2 => 10,
                        _ => max(0, box.rect.width * scale - 10),
                      },
                      height: switch (i) {
                        1 || 3 => 10,
                        _ => max(0, box.rect.height * scale - 10),
                      },
                      color: colors[i].withOpacity(.5),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  // controllers end
}

final colors = [Colors.red, Colors.green, Colors.blue, Colors.yellow];

// ignore: prefer-single-widget-per-file
class SnapLinePainter extends StatelessWidget {
  const SnapLinePainter({super.key});

  @override
  Widget build(BuildContext context) {
    return Watch.builder(
      builder: (context) {
        final lines = [...snapLines()];

        if (lines.isEmpty) {
          return const SizedBox();
        }

        final shortestLineX = lines.where((element) => element.isSnapX).fold(
              lines.first,
              (value, element) =>
                  value.length < element.length ? value : element,
            );

        final shortestLineY = lines.where((element) => element.isSnapY).fold(
              lines.first,
              (value, element) =>
                  value.length < element.length ? value : element,
            );

        final transform = canvasTransformCurrent()();
        return CustomPaint(
          painter: _SnapLinePainter([shortestLineX, shortestLineY], transform),
        );
      },
    );
  }
}

class _SnapLinePainter extends CustomPainter {
  const _SnapLinePainter(this.lines, this.transform);

  final List<SnapLine> lines;

  final Matrix4 transform;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.redAccent
      ..strokeWidth = .5;

    for (final line in lines) {
      canvas.drawLine(
        transform.fromScene(line.pos1.toOffset()),
        transform.fromScene(line.pos2.toOffset()),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
