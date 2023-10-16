import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CanvasTransformCubit extends Cubit<TransformationController> {
  CanvasTransformCubit() : super(TransformationController());

  void change(TransformationController value) => emit(value);

  void update(Matrix4 value) => emit(TransformationController(value));
}
