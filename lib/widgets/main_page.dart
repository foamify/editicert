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
                    builder: (context) {
                      final elements = canvasElements();
                      return Stack(
                        clipBehavior: Clip.none,
                        children: [
                          for (var i = 0; i < elements.length; i++)
                            ElementTranslator(
                              index: i,
                              builder: (
                                context,
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
                  context,
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
              const DebugPoints(),
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
                        buildDefaultDragHandles: false,
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
                                                    const EdgeInsets.all(8.0),
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
            ],
          ),
        ),
      ),
    );
  }
}
