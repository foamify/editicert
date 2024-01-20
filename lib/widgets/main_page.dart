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
                              builder: (_, element) => Container(
                                key: ValueKey(element.id),
                                width: element.transform.width,
                                height: element.transform.height,
                                color: element.data.color,
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
                builder: (_, element) => Container(
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
                  child: Column(
                    children: [
                      Watch.builder(
                        builder: (_) => Text(sidebarElements.length.toString()),
                      ),
                      Expanded(
                        child: Watch.builder(
                          builder: (_) {
                            // Only rebuild if the length and ordering is different
                            canvasElements.listen(context, () {
                              untracked(() {
                                final elements =
                                    canvasElements().map((e) => e.id).toList();
                                if (!elements.equals(sidebarElements())) {
                                  sidebarElements.forceUpdate(elements);
                                }
                              });
                            });
                            final elements = sidebarElements();
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
                                      key: ValueKey(e),
                                      builder: (_) {
                                        final selected =
                                            canvasSelectedElement() == e;
                                        final isHovered =
                                            canvasHoveredMultipleElements
                                                    .select(
                                                  (hover) =>
                                                      hover().contains(e),
                                                )() ||
                                                canvasHoveredElement.sig.select(
                                                  (hover) => hover() == e,
                                                )();
                                        return MouseRegion(
                                          onEnter: (event) =>
                                              canvasHoveredElement.value = e,
                                          onExit: (event) =>
                                              canvasHoveredElement.value = null,
                                          child: Padding(
                                            padding: const EdgeInsets.all(2),
                                            child: GestureDetector(
                                              onTap: () => canvasSelectedElement
                                                  .value = e,
                                              child:
                                                  ReorderableDragStartListener(
                                                enabled: kIsWeb ||
                                                    (!Platform.isAndroid &&
                                                        !Platform.isIOS),
                                                index: index,
                                                child: DecoratedBox(
                                                  position: DecorationPosition
                                                      .foreground,
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12),
                                                    border: Border.all(
                                                      color: isHovered
                                                          ? Colors.blueAccent
                                                          : Colors.transparent,
                                                    ),
                                                  ),
                                                  child: Card(
                                                    color: Color.alphaBlend(
                                                      Colors.blueAccent
                                                          .withOpacity(
                                                        selected ? .5 : .1,
                                                      ),
                                                      Theme.of(context)
                                                          .cardColor,
                                                    ),
                                                    margin: EdgeInsets.zero,
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8),
                                                      child: SizedBox(
                                                        width: double.infinity,
                                                        child: Text(
                                                            e.split('-')[1]),
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
                                final elems = canvasElements();
                                canvasElements.value = [...elems]
                                  ..removeAt(oldIndex)
                                  ..insert(newIndex, elems[oldIndex]);
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned.fill(
                child: IgnorePointer(
                  child: Watch.builder(
                    builder: (_) {
                      final hovered = sidebarElements.select(
                        (e) => e().indexed.firstWhereOrNull(
                              (element) => element.$2 == canvasHoveredElement(),
                            ),
                      )();

                      final hoveredMultiple = sidebarElements.select(
                        (e) => e().indexed.where(
                              (element) => canvasHoveredMultipleElements
                                  .contains(element.$2),
                            ),
                      )();

                      final transform = canvasTransformCurrent()();

                      final points = hoveredMultiple.map(
                        (e) => canvasElements()[e.$1]
                            .transform
                            .pointsAsFloat32List(transform),
                      );

                      return CustomPaint(
                        painter: HoverPainter([
                          ...points,
                          if (hovered != null)
                            canvasElements()[hovered.$1]
                                .transform
                                .pointsAsFloat32List(transform),
                        ]),
                      );
                    },
                  ),
                ),
              ),
              const DebugPoints(),
            ],
          ),
        ),
      ),
    );
  }
}
