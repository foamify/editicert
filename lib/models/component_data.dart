import 'package:editicert/models/component_transform.dart';
import 'package:editicert/models/component_type.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';

@immutable
// ignore: public_member_api_docs
class ComponentData extends Equatable {
  // ignore: public_member_api_docs
  const ComponentData({
    this.name = 'Component',
    this.component = const ComponentTransform(
      Offset.zero,
      Size(100, 100),
      0,
      false,
      false,
    ),
    this.color = const Color(0xFF9E9E9E),
    this.borderRadius = BorderRadius.zero,
    this.border = const Border(),
    this.shadow = const [],
    this.content = const SizedBox.shrink(),
    this.hidden = false,
    this.locked = false,
    this.type = ComponentType.frame,
    this.textController,
  });

  final String name;
  final ComponentTransform component;
  final Color color;
  final BorderRadius borderRadius;
  final Border border;
  final List<BoxShadow> shadow;
  final Widget content;
  final bool hidden;
  final bool locked;
  final ComponentType type;
  final TextEditingController? textController;

  ComponentData copyWith({
    required String? name,
    required ComponentTransform? component,
    required Color? color,
    required BorderRadius? borderRadius,
    required Border? border,
    required List<BoxShadow>? shadow,
    required Widget? content,
    required bool? hidden,
    required bool? locked,
    required ComponentType? type,
    required TextEditingController? textController,
  }) =>
      ComponentData(
        name: name ?? this.name,
        component: component ?? this.component,
        color: color ?? this.color,
        borderRadius: borderRadius ?? this.borderRadius,
        border: border ?? this.border,
        shadow: shadow ?? this.shadow,
        content: content ?? this.content,
        hidden: hidden ?? this.hidden,
        locked: locked ?? this.locked,
        type: type ?? this.type,
        textController: textController ?? this.textController,
      );

  @override
  // TODO: implement props
  List<Object?> get props => [
        name,
        component,
        color,
        borderRadius,
        border,
        shadow,
        content,
        hidden,
        locked,
        type,
        textController?.text,
      ];
}
