import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CanvasTransformCubit extends Cubit<TransformationController> {
  CanvasTransformCubit() : super(TransformationController());

  void changeController(TransformationController value) => emit(value);

  void updateValue(Matrix4 value) => emit(TransformationController(value));
}
