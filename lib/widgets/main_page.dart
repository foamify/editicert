// ignore_for_file: avoid-unsafe-collection-methods

import 'dart:math';
import 'dart:ui';

import 'package:editicert/state/event_handler_bloc.dart';
import 'package:editicert/state/pointers_cubit.dart';
import 'package:editicert/state/state.dart';
import 'package:editicert/util/extensions.dart';
import 'package:editicert/util/geometry.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:transparent_pointer/transparent_pointer.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final _keyboardFocus = FocusNode();

  var initialBox = Box.fromRect(Rect.zero);
  var initialPosition = Offset.zero;

  final box = ValueNotifier(
    Box.fromRect(
      Rect.fromCenter(
        center: const Offset(200, 200),
        width: 200,
        height: 200,
      ),
      origin: const Offset(200 + 50, 200 + 100),
    ),
  );

  @override
  void dispose() {
    _keyboardFocus.dispose();
    box.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final transformControl = context.watch<CanvasTransformCubit>().state;
    return ColoredBox(
      color: const Color(0xFF333333),
      child: MultiBlocListener(
        listeners: [
          BlocListener<EventHandlerBloc, EventHandlerState>(
            listener: (listenerContext, state) {
              if (state.canvasMatrix.currentMatrix !=
                      state.canvasMatrix.initialMatrix &&
                  state.canvasMatrix.currentMatrix != null) {
                context.read<CanvasTransformCubit>().updateValue(
                      state.canvasMatrix.currentMatrix!,
                    );
              }
            },
          ),
        ],
        child: CallbackShortcuts(
          bindings: {},
          child: RawKeyboardListener(
            autofocus: true,
            focusNode: _keyboardFocus,
            onKey: (key) {
              if (key is RawKeyDownEvent) {
                context.read<KeysCubit>().add(key.logicalKey);
              } else if (key is RawKeyUpEvent) {
                context.read<KeysCubit>().remove(key.logicalKey);
              }
            },
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                BlocBuilder<DebugPointCubit, List<Offset>>(
                  builder: (blocContext, state) {
                    return Stack(
                      children: [
                        for (var i = 0; i < state.length; i++)
                          Positioned(
                            left: state[i].dx,
                            top: state[i].dy,
                            child: Container(
                              width: 10,
                              height: 10,
                              color: colors[i],
                            ),
                          ),
                      ],
                    );
                  },
                ),
                // BlocBuilder<CanvasTransformCubit, TransformationController>(
                //   builder: (cubitContext, state) {
                //     print('Container rebuilt');
                //     return Transform(
                //       transform: state.value,
                //       child: Container(width: 200, height: 200, color: Colors.red),
                //     );
                //   },
                // ),
                TransparentPointer(
                  child: Listener(
                    onPointerDown: (event) {
                      _keyboardFocus.requestFocus();

                      final buttons = <PointerButton>[];
                      if (event.kind == PointerDeviceKind.mouse) {
                        if (event.buttons == kMiddleMouseButton) {
                          buttons.add(PointerButton.middle);
                        }
                        if (event.buttons == kPrimaryMouseButton) {
                          buttons.add(PointerButton.left);
                        }
                        if (event.buttons == kSecondaryMouseButton) {
                          buttons.add(PointerButton.right);
                        }
                      }
                      context.read<PointersCubit>().update(buttons);
                    },
                    onPointerUp: (event) {
                      print('UP!');
                      final buttons = <PointerButton>[];
                      if (event.kind == PointerDeviceKind.mouse) {
                        if (event.buttons == kMiddleMouseButton) {
                          buttons.add(PointerButton.middle);
                        }
                        if (event.buttons == kPrimaryMouseButton) {
                          buttons.add(PointerButton.left);
                        }
                        if (event.buttons == kSecondaryMouseButton) {
                          buttons.add(PointerButton.right);
                        }
                      }
                      context.read<PointersCubit>().update(buttons);
                    },
                    child: MouseRegion(
                      child: BlocBuilder<CanvasTransformCubit,
                          TransformationController>(
                        builder: (cubitContext, state) {
                          return InteractiveViewer.builder(
                            clipBehavior: Clip.none,
                            scaleEnabled: false,
                            transformationController: transformControl,
                            onInteractionStart: (details) {
                              final buttons =
                                  context.read<PointersCubit>().state;
                              if (!buttons.contains(PointerButton.middle) &&
                                  buttons.isNotEmpty) {
                                return;
                              }
                              context
                                  .read<EventHandlerBloc>()
                                  .add(PanCanvasInitial());
                            },
                            onInteractionUpdate: (details) {
                              final buttons =
                                  context.read<PointersCubit>().state;
                              if (!buttons.contains(PointerButton.middle) &&
                                  buttons.isNotEmpty) {
                                return;
                              }
                              final eventHandlerBloc =
                                  context.read<EventHandlerBloc>();
                              if (details.focalPointDelta != Offset.zero) {
                                eventHandlerBloc.add(
                                  PanCanvasEvent(details.focalPointDelta),
                                );
                              } else if (details.scale != 0) {
                                eventHandlerBloc.add(
                                  ZoomCanvasEvent(
                                    details.scale,
                                    details.focalPoint,
                                  ),
                                );
                              }
                            },
                            onInteractionEnd: (details) {
                              context
                                  .read<EventHandlerBloc>()
                                  .add(PanCanvasEnd());
                            },
                            builder: (iVContext, viewport) {
                              // return Container(
                              //   width: 200,
                              //   height: 200,
                              //   color: Colors.red,
                              // );
                              return ValueListenableBuilder(
                                valueListenable: box,
                                builder: (context, value, child) {
                                  return SizedBox.square(
                                    dimension: 400,
                                    child: Stack(
                                      clipBehavior: Clip.none,
                                      children: [
                                        Positioned(
                                          left: value.flipX
                                              ? value.offset1.dx
                                              : value.offset0.dx,
                                          top: value.flipY
                                              ? value.offset2.dy
                                              : value.offset0.dy,
                                          child: Transform.rotate(
                                            angle: value.angle * pi / 180,
                                            origin: Offset(
                                                  value.rect.width /
                                                      (value.flipX ? 2 : -2),
                                                  value.rect.height /
                                                      (value.flipY ? 2 : -2),
                                                ) +
                                                value.localOrigin,
                                            child: Transform.flip(
                                              flipX: value.flipX,
                                              flipY: value.flipY,
                                              child: Container(
                                                width: value.rect.width,
                                                height: value.rect.height,
                                                color: Colors.blueGrey,
                                              ),
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          left: value.origin.dx,
                                          top: value.origin.dy,
                                          child: Container(
                                            width: 10,
                                            height: 10,
                                            color: Colors.black,
                                          ),
                                        ),
                                        Positioned(
                                          left: value.rect.topLeft.dx,
                                          top: value.rect.topLeft.dy,
                                          child: Container(
                                            width: 14,
                                            height: 14,
                                            color: colors[0].withOpacity(.25),
                                          ),
                                        ),
                                        Positioned(
                                          left: value.rect.topRight.dx,
                                          top: value.rect.topRight.dy,
                                          child: Container(
                                            width: 14,
                                            height: 14,
                                            color: colors[1].withOpacity(.25),
                                          ),
                                        ),
                                        Positioned(
                                          left: value.rect.bottomRight.dx,
                                          top: value.rect.bottomRight.dy,
                                          child: Container(
                                            width: 14,
                                            height: 14,
                                            color: colors[2].withOpacity(.25),
                                          ),
                                        ),
                                        Positioned(
                                          left: value.rect.bottomLeft.dx,
                                          top: value.rect.bottomLeft.dy,
                                          child: Container(
                                            width: 14,
                                            height: 14,
                                            color: colors[3].withOpacity(.25),
                                          ),
                                        ),
                                        for (var i = 0;
                                            i < value.offsets.length;
                                            i++)
                                          Positioned(
                                            left: value.rotated.offsets[i].dx,
                                            top: value.rotated.offsets[i].dy,
                                            child: Container(
                                              width: 10,
                                              height: 10,
                                              color: colors[i],
                                            ),
                                          ),
                                      ],
                                    ),
                                  );
                                },
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ),
                ),
                BlocBuilder<CanvasTransformCubit, TransformationController>(
                  builder: (_, transform) {
                    final matrix = transform.value;
                    return Positioned(
                      right: 0,
                      top: 0,
                      bottom: 0,
                      width: 200,
                      child: ListView(
                        children: [
                          ValueListenableBuilder(
                            valueListenable: box,
                            builder: (context, box, _) => Card(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  children: [
                                    Text(
                                      'rotation: ${box.angle.toStringAsFixed(4)}\n'
                                      'origin: ${box.origin}\n'
                                      'localOrigin: ${box.localOrigin}\n'
                                      'offset0: ${box.offset0}\n'
                                      'offset1: ${box.offset1}\n'
                                      'offset2: ${box.offset2}\n'
                                      'offset3: ${box.offset3}\n'
                                      'flipX: ${box.flipX}\n'
                                      'flipY: ${box.flipY}\n'
                                      'ratio: ${box.rect.size.aspectRatio.toStringAsFixed(4)}\n',
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              box.value = box.value.rotate(180 / 12);
                            },
                            child:
                                const Text('Rotate box by ${180 / 12} degrees'),
                          ),
                          GestureDetector(
                            onPanUpdate: (event) {
                              box.value = box.value.rotateByPan(
                                transform.toScene(event.globalPosition),
                              );
                            },
                            child: const Card(
                              child: Padding(
                                padding: EdgeInsets.all(8),
                                child: Text('Rotate box relative to origin'),
                              ),
                            ),
                          ),
                          GestureDetector(
                            onPanUpdate: (event) {
                              box.value = box.value.translate(
                                event.delta / matrix.getMaxScaleOnAxis(),
                              );
                            },
                            child: const Card(
                              child: Padding(
                                padding: EdgeInsets.all(8),
                                child: Text('Translate box'),
                              ),
                            ),
                          ),
                          ...[
                            ('topLeft', Alignment.topLeft),
                            ('topCenter', Alignment.topCenter),
                            ('topRight', Alignment.topRight),
                            ('centerLeft', Alignment.centerLeft),
                            ('centerRight', Alignment.centerRight),
                            ('bottomLeft', Alignment.bottomLeft),
                            ('bottomCenter', Alignment.bottomCenter),
                            ('bottomRight', Alignment.bottomRight),
                          ].map(
                            (alignment) => GestureDetector(
                              onPanStart: (details) => setState(() {
                                initialBox = box.value;
                                initialPosition =
                                    transform.toScene(details.localPosition);
                              }),
                              onPanUpdate: (details) {
                                final keys = context.read<KeysCubit>().state;

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

                                if (pressedShift) {
                                  box.value = box.value.resizeScaled(
                                    initialBox,
                                    initialPosition,
                                    transform.toScene(details.localPosition),
                                    alignment.$2,
                                  );
                                } else if (pressedAlt) {
                                  box.value = box.value.resizeSymmetric(
                                    initialBox,
                                    initialPosition,
                                    transform.toScene(details.localPosition),
                                    alignment.$2,
                                  );
                                } else {
                                  box.value = box.value.resize(
                                    initialBox,
                                    initialPosition,
                                    transform.toScene(details.localPosition),
                                    alignment.$2,
                                  );
                                }
                              },
                              child: Card(
                                child: Padding(
                                  padding: const EdgeInsets.all(8),
                                  child: Text('Resize box: ${alignment.$1}'),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

final colors = [Colors.red, Colors.green, Colors.blue, Colors.yellow];
