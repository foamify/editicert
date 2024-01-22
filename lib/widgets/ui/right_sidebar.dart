part of '../../main.dart';

class RightSidebar extends StatelessWidget {
  const RightSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
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
                  canvasElements.add(ValueSignal(ElementModel()));
                },
                child: const Text('Add Box'),
              ),
              const SizedBox.square(dimension: 12),
              FilledButton(
                onPressed: () {
                  batch(() {
                    for (var i = 0; i < 50; i++) {
                      canvasElements.add(ValueSignal(ElementModel()));
                    }
                  });
                },
                child: const Text('Add 50 Box'),
              ),
              const SizedBox.square(dimension: 12),
              FilledButton(
                onPressed: () {
                  canvasElements.peek().lastOrNull?.dispose();
                  canvasElements.value = [...canvasElements()]..removeLast();
                },
                child: const Text('Remove Last Box'),
              ),
              const SizedBox.square(dimension: 12),
              FilledButton(
                onPressed: () {
                  canvasElements.forEach((element) => element.dispose());
                  canvasElements.clear();
                },
                child: const Text('Clear Box'),
              ),
              const SizedBox.square(dimension: 12),
              Watch.builder(
                builder: (_) {
                  final selectedId = idElements.indexed.firstWhereOrNull(
                    (e) => e.$2 == canvasSelectedElement(),
                  );
                  if (selectedId == null) {
                    return const SizedBox.shrink();
                  }
                  final selectedElement = canvasElements.select(
                    (e) => e().firstWhereOrNull(
                      (element) => element().id == selectedId.$2,
                    ),
                  )();
                  if (selectedElement == null) {
                    return const SizedBox.shrink();
                  }
                  final selected = selectedElement();
                  return Text(
                    [
                      'id: ${selected.id}',
                      'offset: ${selected.transform.rect.topLeft}',
                      'center: ${selected.transform.rect.center}',
                      'rect: ${selected.transform.rect}',
                      'flipX: ${selected.transform.flipX}',
                      'flipY: ${selected.transform.flipY}',
                    ].join('\n'),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
