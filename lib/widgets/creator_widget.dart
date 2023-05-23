import 'package:editicert/providers/component.dart';
import 'package:editicert/utils.dart';
import 'package:editicert/widgets/controller_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CreatorWidget extends ConsumerStatefulWidget {
  const CreatorWidget({super.key});

  @override
  ConsumerState<CreatorWidget> createState() => _CreatorWidgetState();
}

class _CreatorWidgetState extends ConsumerState<CreatorWidget> {
  final oTriangle = ValueNotifier(Triangle(Offset.zero, Size.zero, 0));

  final oPosition = ValueNotifier(Offset.zero);

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: handlePointerDown,
      onPointerMove: handlePointerMove,
      onPointerUp: handlePointerUp,
      child: MouseRegion(
        cursor: SystemMouseCursors.precise,
        child: Container(
          width: double.infinity,
          height: double.infinity,
          color: Colors.transparent,
        ),
      ),
    );
  }

  void handlePointerDown(PointerDownEvent event) {
    oPosition.value = event.position;
    final index = ref.read(componentsProvider).length;
    ref.read(componentsProvider.notifier).add((
      triangle: oTriangle.value,
      name: 'Triangle ${index + 1}',
    ));
  }

  void handlePointerMove(PointerMoveEvent event) {
    final index = ref.read(componentsProvider).length - 1;
    ref.read(hoveredProvider.notifier).clear();
    ref.read(selectedProvider.notifier)
      ..clear()
      ..add(index);
    final newRect = Rect.fromPoints(oPosition.value, event.position);
    final newTriangle = oTriangle.value.copyWith(
      pos: newRect.topLeft + const Offset(-sidebarWidth, -36),
      size: newRect.size,
    );
    ref.read(componentsProvider.notifier).replace(index, triangle: newTriangle);
  }

  void handlePointerUp(PointerUpEvent event) {
    final index = ref.read(componentsProvider).length - 1;
    final triangle = ref.read(componentsProvider)[index].triangle;
    if (triangle.size.width == 0 || triangle.size.height == 0) {
      ref.read(componentsProvider.notifier).removeAt(index);
    }
    ref.read(toolProvider.notifier).setPointer();
  }
}
