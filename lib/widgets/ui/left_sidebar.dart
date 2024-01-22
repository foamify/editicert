part of '../../main.dart';

class LeftSidebar extends StatelessWidget {
  const LeftSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
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
              builder: (_) => Text(idElements.length.toString()),
            ),
            Expanded(
              child: Watch.builder(
                builder: (_) {
                  // Only rebuild if the length and ordering is different
                  canvasElements.listen(context, () {
                    untracked(() {
                      final elements =
                          canvasElements().map((e) => e().id).toList();
                      if (!elements.equals(idElements())) {
                        idElements.forceUpdate(elements);
                      }
                    });
                  });
                  final elements = idElements();
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
                              final selected = canvasSelectedElement() == e;
                              final isHovered =
                                  canvasHoveredMultipleElements.select(
                                        (hover) => hover().contains(e),
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
                                    onTap: () =>
                                        canvasSelectedElement.value = e,
                                    child: ReorderableDragStartListener(
                                      enabled: kIsWeb ||
                                          (!Platform.isAndroid &&
                                              !Platform.isIOS),
                                      index: index,
                                      child: DecoratedBox(
                                        position: DecorationPosition.foreground,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          border: Border.all(
                                            color: isHovered
                                                ? Colors.blueAccent
                                                : Colors.transparent,
                                          ),
                                        ),
                                        child: Card(
                                          color: Color.alphaBlend(
                                            Colors.blueAccent.withOpacity(
                                              selected ? .5 : .1,
                                            ),
                                            Theme.of(context).cardColor,
                                          ),
                                          margin: EdgeInsets.zero,
                                          child: Padding(
                                            padding: const EdgeInsets.all(8),
                                            child: SizedBox(
                                              width: double.infinity,
                                              child: Text(e.split('-')[1]),
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
                      ].elementAtOrNull(index)!;
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
    );
  }
}
