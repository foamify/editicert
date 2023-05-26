import 'dart:math';

import 'package:editicert/providers/component.dart';
import 'package:editicert/utils.dart';
import 'package:editicert/widgets/controller_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CreatorWidget extends ConsumerStatefulWidget {
  const CreatorWidget({super.key});

  @override
  ConsumerState<CreatorWidget> createState() => _CreatorWidgetState();
}

class _CreatorWidgetState extends ConsumerState<CreatorWidget> {
  final oTriangle = ValueNotifier(const Triangle(Offset.zero, Size.zero, 0));

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
    ref
        .read(globalStateProvider.notifier)
        .update(ref.read(globalStateProvider) + GlobalStates.creating);
    final tController = ref.read(transformationControllerDataProvider);
    oPosition.value = tController
        .toScene(event.position + const Offset(-sidebarWidth, -topbarHeight));
    final index = ref.read(componentsProvider).length;
    ref.read(componentsProvider.notifier).add(ComponentData(
          triangle: oTriangle.value,
          name: 'Rectangle ${index + 1}',
        ));
  }

  void handlePointerMove(PointerMoveEvent event) {
    final tController = ref.read(transformationControllerDataProvider);
    final keys = ref.read(keysProvider);
    final shift = pressedShift(keys);

    final index = ref.read(componentsProvider).length - 1;
    ref.read(hoveredProvider.notifier).clear();
    ref.read(selectedProvider.notifier)
      ..clear()
      ..add(index);

    final pos = tController
        .toScene(event.position + const Offset(-sidebarWidth, -topbarHeight));
    final deltaX = (oPosition.value.dx - pos.dx) > 0;
    final deltaY = (oPosition.value.dy - pos.dy) > 0;

    final longestSide = max((oPosition.value.dx - pos.dx).abs(),
        (oPosition.value.dy - pos.dy).abs());

    final newRect = Rect.fromPoints(
      oPosition.value,
      shift
          ? oPosition.value +
              Offset(
                longestSide * (deltaX ? -1 : 1),
                longestSide * (deltaY ? -1 : 1),
              )
          : Offset(
              pos.dx,
              pos.dy,
            ),
    );
    final newTriangle = oTriangle.value.copyWith(
      pos: newRect.topLeft,
      size: newRect.size,
    );
    ref.read(componentsProvider.notifier).replace(index, triangle: newTriangle);
  }

  bool pressedShift(Set<PhysicalKeyboardKey> keys) {
    return keys.contains(PhysicalKeyboardKey.shiftLeft) ||
        keys.contains(PhysicalKeyboardKey.shiftRight);
  }

  void handlePointerUp(PointerUpEvent event) {
    ref
        .read(globalStateProvider.notifier)
        .update(ref.read(globalStateProvider) - GlobalStates.creating);

    final index = ref.read(componentsProvider).length - 1;
    final triangle = ref.read(componentsProvider)[index].triangle;
    if (triangle.size.width == 0 || triangle.size.height == 0) {
      ref.read(componentsProvider.notifier).removeAt(index);
      ref.read(selectedProvider.notifier).remove(index);
    }
    ref.read(toolProvider.notifier).setMove();
  }
}
