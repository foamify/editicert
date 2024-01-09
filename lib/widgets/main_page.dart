// ignore_for_file: avoid-unsafe-collection-methods

part of '../main.dart';

/// The main widget that contains the canvas, sidebars, top bar, controllers,
/// keyboard listener, etc.
class MainPage extends StatefulWidget {
  ///
  const MainPage({super.key});

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
    print(
      'Rebuild whole canvas page. This should not happen more than once or outside of changing the app theme',
    );
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
              CanvasWidget(keyboardFocus: _keyboardFocus),
              const MarqueeWidget(),
              TransparentPointer(
                child: Material(
                  color: Colors.transparent,
                  child: Watch.builder(
                    builder: (_) {
                      final elements = canvasElements();
                      return Stack(
                        clipBehavior: Clip.none,
                        children: [
                          for (var i = 0; i < elements.length; i++)
                            ElementTranslator(
                              index: i,
                              builder: (
                                _,
                                element, {
                                required isHovered,
                                required isSelected,
                              }) =>
                                  Container(
                                key: ValueKey(element.id),
                                width: element.transform.width,
                                height: element.transform.height,
                                color: isSelected
                                    ? Colors.blueAccent
                                    : isHovered
                                        ? Colors.blueAccent
                                        : element.data.color,
                                child: Text(element.id),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                ),
              ),
              ElementTranslator(
                builder: (
                  _,
                  element, {
                  required isHovered,
                  required isSelected,
                }) =>
                    Container(
                  key: ValueKey(element.id),
                  width: element.transform.width,
                  height: element.transform.height,
                  color: Colors.transparent,
                ),
              ),
              for (var i = 0; i < 4; i++) ElementRotator(i),
              for (var i = 0; i < 4; i++) ElementSideResizer(i),
              for (var i = 0; i < 4; i++) ElementEdgeResizer(i),
              const SnapLinePaint(),
              const MarqueePaint(),
              Positioned(
                top: 0,
                right: 0,
                width: 250,
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
                            batch(() {
                              for (var i = 0; i < 50; i++) {
                                canvasElements.add(ElementModel());
                              }
                            });
                          },
                          child: const Text('Add 50 Box'),
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
                        FilledButton(
                          onPressed: () {
                            canvasElements.value = [];
                          },
                          child: const Text('Clear Box'),
                        ),
                        const SizedBox.square(dimension: 12),
                        Watch.builder(
                          builder: (_) {
                            final selected = canvasSelectedElement();
                            final elements = canvasElements();
                            final element = elements.firstWhereOrNull(
                              (e) => e.id == selected,
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
                    builder: (_) {
                      final elements = canvasElements();
                      return ReorderableListView.builder(
                        buildDefaultDragHandles: false,
                        proxyDecorator: (child, index, animation) {
                          return child;
                        },
                        itemCount: elements.length,
                        itemBuilder: (_, index) {
                          return [
                            ...elements.map(
                              (e) => Watch.builder(
                                key: ValueKey(e.id),
                                builder: (_) {
                                  final hovered = canvasHoveredElement() ==
                                      elements[index].id;
                                  final multiHovered =
                                      canvasHoveredMultipleElements()
                                          .contains(elements[index].id);
                                  final isHovered = hovered || multiHovered;
                                  final selected = canvasSelectedElement() ==
                                      elements[index].id;
                                  return MouseRegion(
                                    onEnter: (event) =>
                                        canvasHoveredElement.value = e.id,
                                    onExit: (event) =>
                                        canvasHoveredElement.value = null,
                                    child: Padding(
                                      padding: const EdgeInsets.all(2),
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
                                              color: isHovered
                                                  ? Colors.blueAccent
                                                  : Colors.transparent,
                                            ),
                                          ),
                                          child: ReorderableDragStartListener(
                                            enabled: kIsWeb ||
                                                (!Platform.isAndroid &&
                                                    !Platform.isIOS),
                                            index: index,
                                            child: Card(
                                              color: Color.alphaBlend(
                                                Colors.blueAccent.withOpacity(
                                                  selected ? .5 : .1,
                                                ),
                                                Theme.of(context).cardColor,
                                              ),
                                              margin: EdgeInsets.zero,
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(8),
                                                child: SizedBox(
                                                  width: double.infinity,
                                                  child:
                                                      Text(e.id.split('-')[1]),
                                                ),
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
              Watch.builder(
                builder: (_) {
                  final imageRect = cropImage();
                  final boundRect = cropBound();

                  return Stack(
                    children: [
                      Positioned(
                        left: imageRect.left,
                        top: imageRect.top,
                        child: GestureDetector(
                          onPanStart: (details) {
                            pointerPositionInitial.value =
                                details.globalPosition.toVector2();
                            cropImageInitial.value = imageRect;
                          },
                          onPanUpdate: (details) {
                            final initialPoint = pointerPositionInitial();
                            final position = details.globalPosition;

                            final delta = position.toVector2() - initialPoint;

                            if (cropImageInitial().left + delta.x >
                                boundRect.left) {
                              delta.x =
                                  boundRect.left - cropImageInitial().left;
                            } else if (cropImageInitial().right + delta.x <
                                boundRect.right) {
                              delta.x =
                                  boundRect.right - cropImageInitial().right;
                            }

                            if (cropImageInitial().top + delta.y >
                                boundRect.top) {
                              delta.y = boundRect.top - cropImageInitial().top;
                            } else if (cropImageInitial().bottom + delta.y <
                                boundRect.bottom) {
                              delta.y =
                                  boundRect.bottom - cropImageInitial().bottom;
                            }

                            cropImage.value =
                                cropImageInitial().translate(delta.x, delta.y);
                          },
                          child: Container(
                            color: Colors.blue,
                            width: imageRect.size.width,
                            height: imageRect.size.height,
                          ),
                        ),
                      ),
                      Positioned(
                        left: boundRect.left,
                        top: boundRect.top,
                        child: IgnorePointer(
                          child: Container(
                            color: Colors.green,
                            width: boundRect.size.width,
                            height: boundRect.size.height,
                          ),
                        ),
                      ),
                      ...[0, 1, 2, 3].map((e) {
                        return Positioned(
                          left: switch (e) {
                            0 || 3 => boundRect.left,
                            _ => boundRect.right,
                          },
                          top: switch (e) {
                            0 || 1 => boundRect.top,
                            _ => boundRect.bottom,
                          },
                          child: GestureDetector(
                            onPanStart: (details) {
                              pointerPositionInitial.value =
                                  details.globalPosition.toVector2();
                              cropBoundInitial.value = boundRect;
                            },
                            onPanUpdate: (details) {
                              final initialPoint = pointerPositionInitial();
                              final position = details.globalPosition;

                              final initialBox =
                                  Box.fromRect(cropBoundInitial());

                              var selectedPoint = switch (e) {
                                0 => initialBox.quad.point0,
                                1 => initialBox.quad.point1,
                                2 => initialBox.quad.point2,
                                _ => initialBox.quad.point3,
                              };
                              final oppositePoint = switch (e) {
                                0 => initialBox.quad.point2,
                                1 => initialBox.quad.point3,
                                2 => initialBox.quad.point0,
                                _ => initialBox.quad.point1,
                              };

                              final rect = imageRect;

                              var point = details.globalPosition.toVector2();

                              if (point.y < rect.top) point.y = rect.top;

                              var snappedPoint = snapPointToLine(
                                selectedPoint.xy,
                                oppositePoint.xy,
                                point,
                              );

                              final conditionY = switch (e) {
                                0 || 1 => snappedPoint.y < rect.top,
                                _ => snappedPoint.y > rect.bottom,
                              };

                              final rectEdge = switch (e) {
                                0 => rect.topLeft,
                                1 => rect.topRight,
                                2 => rect.bottomRight,
                                _ => rect.bottomLeft,
                              }
                                  .toVector2();
                              if (conditionY) {
                                snappedPoint = getTriangleFromLineAndTwoAngle(
                                  oppositePoint.xy,
                                  rectEdge,
                                  getAngleFromPoints(
                                    selectedPoint.xy.toOffset(),
                                    oppositePoint.xy.toOffset(),
                                  ),
                                  true,
                                );
                              }

                              final conditionX = switch (e) {
                                0 || 3 => snappedPoint.x < rect.left,
                                _ => snappedPoint.x > rect.right,
                              };
                              if (conditionX) {
                                snappedPoint = getTriangleFromLineAndTwoAngle(
                                  oppositePoint.xy,
                                  rectEdge,
                                  getAngleFromPoints(
                                    selectedPoint.xy.toOffset(),
                                    oppositePoint.xy.toOffset(),
                                  ),
                                  false,
                                );
                              }

                              cropBound.value = Rect.fromPoints(
                                snappedPoint.toOffset(),
                                oppositePoint.xy.toOffset(),
                              );
                            },
                            child: Container(
                              color: kColorList[0],
                              width: 10,
                              height: 10,
                            ),
                          ),
                        );
                      }),
                      ...[0, 1, 2, 3].map((e) {
                        return Positioned(
                          left: switch (e) {
                            0 || 3 => imageRect.left,
                            _ => imageRect.right,
                          },
                          top: switch (e) {
                            0 || 1 => imageRect.top,
                            _ => imageRect.bottom,
                          },
                          child: GestureDetector(
                            onPanStart: (details) {
                              pointerPositionInitial.value =
                                  details.globalPosition.toVector2();
                              cropImageInitial.value = imageRect;
                            },
                            onPanUpdate: (details) {
                              final initialPoint = pointerPositionInitial();
                              final position = details.globalPosition;

                              final initialBox =
                                  Box.fromRect(cropImageInitial());

                              var selectedPoint = switch (e) {
                                0 => initialBox.quad.point0,
                                1 => initialBox.quad.point1,
                                2 => initialBox.quad.point2,
                                _ => initialBox.quad.point3,
                              };
                              final oppositePoint = switch (e) {
                                0 => initialBox.quad.point2,
                                1 => initialBox.quad.point3,
                                2 => initialBox.quad.point0,
                                _ => initialBox.quad.point1,
                              };

                              final rect = boundRect;

                              var point = details.globalPosition.toVector2();

                              var snappedPoint = snapPointToLine(
                                selectedPoint.xy,
                                oppositePoint.xy,
                                point,
                              );

                              final conditionY = switch (e) {
                                0 || 1 => snappedPoint.y > rect.top,
                                _ => snappedPoint.y < rect.bottom,
                              };

                              final rectEdge = switch (e) {
                                0 => rect.topLeft,
                                1 => rect.topRight,
                                2 => rect.bottomRight,
                                _ => rect.bottomLeft,
                              }
                                  .toVector2();
                              if (conditionY) {
                                snappedPoint = getTriangleFromLineAndTwoAngle(
                                  oppositePoint.xy,
                                  rectEdge,
                                  getAngleFromPoints(
                                    selectedPoint.xy.toOffset(),
                                    oppositePoint.xy.toOffset(),
                                  ),
                                  true,
                                );
                              }

                              final conditionX = switch (e) {
                                0 || 3 => snappedPoint.x > rect.left,
                                _ => snappedPoint.x < rect.right,
                              };
                              if (conditionX) {
                                snappedPoint = getTriangleFromLineAndTwoAngle(
                                  oppositePoint.xy,
                                  rectEdge,
                                  getAngleFromPoints(
                                    selectedPoint.xy.toOffset(),
                                    oppositePoint.xy.toOffset(),
                                  ),
                                  false,
                                );
                              }

                              cropImage.value = Rect.fromPoints(
                                snappedPoint.toOffset(),
                                oppositePoint.xy.toOffset(),
                              );
                            },
                            child: Container(
                              color: kColorList[0],
                              width: 10,
                              height: 10,
                            ),
                          ),
                        );
                      }),
                    ],
                  );
                },
              ),
              const DebugPoints(),
            ],
          ),
        ),
      ),
    );
  }
}

final cropImageInitial = signal(
  Rect.fromCenter(center: const Offset(300, 300), width: 300, height: 500),
);

final cropImage = signal(
  Rect.fromCenter(center: const Offset(300, 300), width: 300, height: 500),
);

final cropBoundInitial = signal(
  Rect.fromCenter(center: const Offset(300, 300), width: 200, height: 400),
);

final cropBound = signal(
  Rect.fromCenter(center: const Offset(300, 300), width: 200, height: 400),
);

Quad quadFromLine(Vector2 a, Vector2 c, double angle) {
  final center = (a + c) / 2;
  final unrotatedA = rotatePoint(a.toOffset(), center.toOffset(), -angle);
  final unrotatedC = rotatePoint(c.toOffset(), center.toOffset(), -angle);
  final rect = Rect.fromPoints(unrotatedA, unrotatedC);

  return Quad.points(
    rect.topLeft.toVector2().xyy,
    rect.topRight.toVector2().xyy,
    rect.bottomRight.toVector2().xyy,
    rect.bottomLeft.toVector2().xyy,
  )..transform(Matrix4.identity()..rotateZ(angle));
}

Vector2 snapPointToLine(Vector2 end1, Vector2 end2, Vector2 point) {
  final angle =
      getAngleFromPoints(end1.toOffset(), end2.toOffset()) + 90 / 180 * pi;
  final end1Unrotated = rotatePoint(
    end1.toOffset(),
    end2.toOffset(),
    -angle,
  );
  final pointUnrotated = rotatePoint(
    point.toOffset(),
    end2.toOffset(),
    -angle,
  );
  return rotatePoint(
    Vector2(end1Unrotated.dx, pointUnrotated.dy).toOffset(),
    end2.toOffset(),
    angle,
  ).toVector2();
}

/// Calculate the third point of the triangle from two points and two angles
/// https://math.stackexchange.com/questions/1725790/calculate-third-point-of-triangle-from-two-points-and-angles
Vector2 getTriangleFromLineAndTwoAngle(
  Vector2 end2,
  Vector2 end1,
  double angle,
  bool isYOutOfBound,
) {
  final x1 = end2.x;
  final y1 = end2.y;
  final x2 = !isYOutOfBound ? end1.x : end2.x;
  final y2 = !isYOutOfBound ? end2.y : end1.y;
  final alp1 = !isYOutOfBound ? angle : angle + pi / 2;
  const alp2 = pi / 2;
  final u = x2 - x1;
  final v = y2 - y1;
  final a3 = sqrt(pow(u, 2) + pow(v, 2));

  final alp3 = pi - alp1 - alp2;

  final a2 = a3 * sin(alp2) / sin(alp3);

  final RHS1 = x1 * u + y1 * v + a2 * a3 * cos(alp1);

  final RHS2 = y2 * u - x2 * v - a2 * a3 * sin(alp1);

  var x3 = (1 / pow(a3, 2)) * (u * RHS1 - v * RHS2);
  x3 = isYOutOfBound ? x1 + x2 - x3 : x3;

  var y3 = (1 / pow(a3, 2)) * (v * RHS1 + u * RHS2);
  y3 = !isYOutOfBound ? y1 + y2 - y3 : y3;

  debugPoints.value = [Vector2(x1, y1), Vector2(x2, y2), Vector2(x3, y3)];

  return Vector2(x3, y3);
}
