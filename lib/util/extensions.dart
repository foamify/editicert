import 'package:editicert/models/component_data.dart';
import 'package:editicert/state/state.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// An extension of [BuildContext].
extension BuildContextExt on BuildContext {
  // ----------------------Read Methods----------------------

  /// Reads the [CanvasCubit] of this context.
  CanvasCubit get canvasCubit => read<CanvasCubit>();

  /// Reads the [CanvasEventsCubit] of this context.
  CanvasEventsCubit get canvasEventsCubit => read<CanvasEventsCubit>();

  /// Reads the [CanvasTransformCubit] of this context.
  CanvasTransformCubit get canvasTransformCubit => read<CanvasTransformCubit>();

  /// Reads the [ComponentIndexCubit] of this context.
  SelectedCubit get selectedCubit => read<SelectedCubit>();

  /// Reads the [ComponentsCubit] of this context.
  HoveredCubit get hoveredCubit => read<HoveredCubit>();

  /// Reads the [ComponentsCubit] of this context.
  ComponentsCubit get componentsCubit => read<ComponentsCubit>();

  /// Reads the [DebugPointCubit] of this context.
  DebugPointCubit get debugPointCubit => read<DebugPointCubit>();

  /// Reads the [KeysCubit] of this context.
  KeysCubit get keysCubit => read<KeysCubit>();

  /// Reads the [PointerCubit] of this context.
  PointerCubit get pointerCubit => read<PointerCubit>();

  /// Reads the [ToolCubit] of this context.
  ToolCubit get toolCubit => read<ToolCubit>();

  // ----------------------Watch Methods----------------------

  /// Reads the [CanvasCubit] of this context.
  CanvasCubit get canvasCubitWatch => watch<CanvasCubit>();

  /// Reads the [CanvasEventsCubit] of this context.
  CanvasEventsCubit get canvasEventsCubitWatch => watch<CanvasEventsCubit>();

  /// Reads the [CanvasTransformCubit] of this context.
  CanvasTransformCubit get canvasTransformCubitWatch =>
      watch<CanvasTransformCubit>();

  /// Reads the [ComponentIndexCubit] of this context.
  SelectedCubit get selectedCubitWatch => watch<SelectedCubit>();

  /// Reads the [ComponentsCubit] of this context.
  HoveredCubit get hoveredCubitWatch => watch<HoveredCubit>();

  /// Reads the [ComponentsCubit] of this context.
  ComponentsCubit get componentsCubitWatch => watch<ComponentsCubit>();

  /// Reads the [DebugPointCubit] of this context.
  DebugPointCubit get debugPointCubitWatch => watch<DebugPointCubit>();

  /// Reads the [KeysCubit] of this context.
  KeysCubit get keysCubitWatch => watch<KeysCubit>();

  /// Reads the [PointerCubit] of this context.
  PointerCubit get pointerCubitWatch => watch<PointerCubit>();

  /// Reads the [ToolCubit] of this context.
  ToolCubit get toolCubitWatch => watch<ToolCubit>();

  // ----------------------Select Methods----------------------

  R canvasCubitSelect<R>(R Function(CanvasCubit value) function) =>
      select<CanvasCubit, R>(function);

  R canvasEventsCubitSelect<R>(R Function(CanvasEventsCubit value) function) =>
      select<CanvasEventsCubit, R>(function);

  R canvasTransformCubitSelect<R>(
    R Function(CanvasTransformCubit value) function,
  ) =>
      select<CanvasTransformCubit, R>(function);

  R selectedCubitSelect<R>(R Function(SelectedCubit value) function) =>
      select<SelectedCubit, R>(function);

  R hoveredCubitSelect<R>(R Function(HoveredCubit value) function) =>
      select<HoveredCubit, R>(function);

  R componentsCubitSelect<R>(R Function(ComponentsCubit value) function) =>
      select<ComponentsCubit, R>(function);

  R debugPointCubitSelect<R>(R Function(DebugPointCubit value) function) =>
      select<DebugPointCubit, R>(function);

  R keysCubitSelect<R>(R Function(KeysCubit value) function) =>
      select<KeysCubit, R>(function);

  R pointerCubitSelect<R>(R Function(PointerCubit value) function) =>
      select<PointerCubit, R>(function);

  R toolCubitSelect<R>(R Function(ToolCubit value) function) =>
      select<ToolCubit, R>(function);

  ComponentData componentAt(int index) => componentsCubit.state[index];

  /// Delete all selected components from the [ComponentsCubit], and clear
  /// [SelectedCubit] and [HoveredCubit].
  void deleteSelectedComponent() {
    final selectedComponentIndexes = selectedCubit.state;
    componentsCubit.remove(selectedComponentIndexes.first);
    selectedCubit.clear();
    hoveredCubit.clear();
  }

  /// Reorder the selected components to be below the component below it.
  void handleGoBackward() {
    final index = selectedCubit.state.singleOrNull;
    if (index == null || index == 0) return;
    componentsCubit.reorder(index, index - 1);
  }

  /// Reorder the selected components to be above the component above it.
  void handleGoForward() {
    final index = selectedCubit.state.singleOrNull;
    if (index == null || index == componentsCubit.state.length - 1) {
      return;
    }
    componentsCubit.reorder(index, index + 1);
  }
}
