// ignore_for_file: avoid-shadowing

import 'dart:math';
import 'dart:ui';

import 'package:editicert/util/utils.dart';

class Component {
  final Offset pos;
  final Size size;
  final double angle;
  final bool flipX;
  final bool flipY;

  const Component(this.pos, this.size, this.angle, this.flipX, this.flipY);

  static Component fromEdges(
    Edges edges, {
    bool flipX = false,
    bool flipY = false,
  }) =>
      Component(edges.tl, edges.size, edges.angle, flipX, flipY);

  static Component fromEdgesOld(
    ({Offset bl, Offset br, Offset tl, Offset tr}) edges, {
    bool flipX = false,
    bool flipY = false,
    bool keepOrigin = false,
  }) {
    final topLeft = edges.tl;
    final size = Size(
      (topLeft - edges.tr).distance,
      (topLeft - edges.bl).distance,
    );
    final angle = atan2(edges.tr.dy - topLeft.dy, edges.tr.dx - topLeft.dx);
    final newEdges = !keepOrigin
        ? rotateRect(
            Rect.fromLTWH(topLeft.dx, topLeft.dy, size.width, size.height),
            0,
            Offset.zero,
          )
        : rotateRect(
            Rect.fromLTWH(0, 0, size.width, size.height),
            0,
            Offset.zero,
          );
    var newComponent = Component(
      newEdges.tl,
      size,
      angle + (flipX ? pi : 0),
      flipX,
      flipY,
    );
    if (keepOrigin) {
      final difference = topLeft - newComponent.rotatedEdges.tl;
      newComponent = Component(
        newEdges.tl + difference,
        size,
        angle + (flipX ? pi : 0),
        flipX,
        flipY,
      );
    }
    print('CORRECTEDRECT:');
    print(newComponent.rotatedEdges.tl);

    ///----------------------------------------
    print(
      Rect.fromLTWH(topLeft.dx, topLeft.dy, size.width, size.height).topLeft,
    );
    print(newEdges.tl);

    ///----------------------------------------
    return newComponent;
  }

  Rect get rect => Rect.fromLTWH(pos.dx, pos.dy, size.width, size.height);

  ({Offset bl, Offset br, Offset tl, Offset tr}) get rotatedEdges => rotateRect(
        rect,
        angle,
        pos + Offset(size.width / 2, size.height / 2),
      );

  ({Offset bl, Offset br, Offset tl, Offset tr}) get edges => rotateRect(
        rect,
        angle,
        pos,
      );

  Component copyWith({
    Offset? pos,
    Size? size,
    double? angle,
    bool? flipX,
    bool? flipY,
  }) {
    return Component(
      pos ?? this.pos,
      size ?? this.size,
      angle ?? this.angle,
      flipX ?? this.flipX,
      flipY ?? this.flipY,
    );
  }

  @override
  String toString() {
    return 'Component{pos: $pos, size: $size, angle: $angle, flipX: $flipX, flipY: $flipY}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Component &&
          runtimeType == other.runtimeType &&
          pos == other.pos &&
          size == other.size &&
          angle == other.angle &&
          flipX == other.flipX &&
          flipY == other.flipY;

  @override
  int get hashCode => pos.hashCode ^ size.hashCode ^ angle.hashCode;
}
