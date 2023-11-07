// ignore_for_file: avoid-unsafe-collection-methods, prefer-match-file-name

import 'dart:math';

import 'package:editicert/util/extensions.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:vector_math/vector_math_64.dart';

class Box extends Equatable {
  const Box({required this.quad, required this.origin, required this.angle});

  final Quad quad;
  final Offset origin;
  final double angle;

  static Box fromRect(Rect rect, {Offset? origin, double angle = 0}) {
    return Box(
      quad: Quad.points(
        Vector3(rect.left, rect.top, 0),
        Vector3(rect.right, rect.top, 0),
        Vector3(rect.right, rect.bottom, 0),
        Vector3(rect.left, rect.bottom, 0),
      ),
      origin: origin ?? rect.center,
      angle: angle,
    );
  }

  @override
  // TODO: implement props
  List<Object?> get props => [quad, origin, angle];
}

extension BoxExtension on Box {
  bool get flipX => offset0.dx > offset2.dx;

  bool get flipY => offset0.dy > offset2.dy;

  Offset get localOrigin => origin - pointToOffset(quad.point0);

  Offset pointToOffset(Vector3 vector3) => Offset(vector3.x, vector3.y);

  Offset get offset0 => pointToOffset(quad.point0);

  Offset get offset1 => pointToOffset(quad.point1);

  Offset get offset2 => pointToOffset(quad.point2);

  Offset get offset3 => pointToOffset(quad.point3);

  List<Offset> get offsets => [offset0, offset1, offset2, offset3];

  List<Vector3> get points => [
        quad.point0,
        quad.point1,
        quad.point2,
        quad.point3,
      ];

  Vector3 offsetToPoint(Offset offset) => Vector3(offset.dx, offset.dy, 0);

  Quad quadFromPoints(List<Vector3> points) {
    return Quad.points(points[0], points[1], points[2], points[3]);
  }

  Quad quadFromOffsets(List<Offset> offsets) {
    return Quad.points(
      offsetToPoint(offsets[0]),
      offsetToPoint(offsets[1]),
      offsetToPoint(offsets[2]),
      offsetToPoint(offsets[3]),
    );
  }

  Rect get rect => Rect.fromPoints(offset0, offset2);

  Box get rotated {
    final rotatedPoints = offsets.map((offset) {
      return rotatePoint(offset, origin, angle);
    }).toList();

    return Box(
      quad: quadFromOffsets(rotatedPoints),
      angle: this.angle,
      origin: origin,
    );
  }

  Box rotate(double angle) {
    return Box(quad: quad, angle: this.angle + angle, origin: origin);
  }

  Box rotateByPan(Offset offset) {
    final rotation = getAngleFromPoints(offset, origin) + pi;

    return Box(quad: quad, angle: rotation / pi * 180, origin: origin);
  }

  Box translate(Offset offset) {
    return Box(
      quad: quad..translate(offsetToPoint(offset)),
      angle: angle,
      origin: origin + offset,
    );
  }

  Box resize(
    Box initialBox,
    Offset initialLocalPosition,
    Offset localPosition,
    Alignment alignment,
  ) {
    // init vars
    final delta = localPosition - initialLocalPosition;
    final initialOffsets = initialBox.offsets;
    final originalOffsets = initialOffsets;
    var rotatedDelta = rotatePoint(delta, Offset.zero, -angle);

    // start handling

    switch (alignment) {
      case Alignment.topCenter || Alignment.bottomCenter:
        rotatedDelta = Offset(0, rotatedDelta.dy);

      case Alignment.centerLeft || Alignment.centerRight:
        rotatedDelta = Offset(rotatedDelta.dx, 0);
    }

    final resizedOffsets = [...originalOffsets];

    final indexes = switch (alignment) {
      Alignment.topLeft => [0, 1, 2, 3],
      Alignment.topRight => [1, 0, 3, 2],
      Alignment.bottomLeft => [3, 2, 1, 0],
      Alignment.bottomRight => [2, 3, 0, 1],
      Alignment.topCenter => [0, 1],
      Alignment.bottomCenter => [2, 3],
      Alignment.centerLeft => [0, 3],
      Alignment.centerRight => [1, 2],
      _ => [0],
    };

    switch (alignment) {
      case Alignment.topLeft ||
            Alignment.topRight ||
            Alignment.bottomLeft ||
            Alignment.bottomRight:
        {
          final [index0, index1, _, index3] = indexes;

          resizedOffsets[index0] += rotatedDelta;
          resizedOffsets[index1] += Offset(0, rotatedDelta.dy);
          resizedOffsets[index3] += Offset(rotatedDelta.dx, 0);
        }
      case Alignment.topCenter ||
            Alignment.bottomCenter ||
            Alignment.centerLeft ||
            Alignment.centerRight:
        {
          final [index0, index2] = indexes;

          resizedOffsets[index0] += rotatedDelta;
          resizedOffsets[index2] += rotatedDelta;
        }
    }

    // return

    return Box(
      quad: quadFromOffsets(resizedOffsets),
      angle: angle,
      origin: origin,
    );
  }

  Box resizeSymmetric(
    Box initialBox,
    Offset initialLocalPosition,
    Offset localPosition,
    Alignment alignment,
  ) {
    // init vars
    final delta = localPosition - initialLocalPosition;
    final initialOffsets = initialBox.offsets;
    final originalOffsets = initialOffsets;
    var rotatedDelta = rotatePoint(delta, Offset.zero, -angle);

    // start handling

    switch (alignment) {
      case Alignment.topCenter || Alignment.bottomCenter:
        rotatedDelta = Offset(0, rotatedDelta.dy);

      case Alignment.centerLeft || Alignment.centerRight:
        rotatedDelta = Offset(rotatedDelta.dx, 0);
    }

    final invertedDelta = Offset(-rotatedDelta.dx, -rotatedDelta.dy);

    final resizedOffsets = [...originalOffsets];

    final indexes = switch (alignment) {
      Alignment.topRight => [1, 0, 3, 2],
      Alignment.centerRight => [2, 3, 0, 1],
      Alignment.bottomLeft => [3, 2, 1, 0],
      _ => [0, 1, 2, 3],
    };

    final [offset0, offset1, offset2, offset3] = indexes;

    resizedOffsets[offset0] += rotatedDelta;

    resizedOffsets[offset1] += Offset(invertedDelta.dx, rotatedDelta.dy);

    resizedOffsets[offset2] += invertedDelta;

    resizedOffsets[offset3] += Offset(rotatedDelta.dx, invertedDelta.dy);

    return Box(
      quad: quadFromOffsets(resizedOffsets),
      angle: angle,
      origin: origin,
    );
  }

  /// Resize but retain aspect ratio
  // TODO(damywise): this is calculated twice, need optimization
  Box resizeScaled(
    Box initialBox,
    Offset initialLocalPosition,
    Offset localPosition,
    Alignment alignment,
  ) {
    // init vars
    final delta = localPosition - initialLocalPosition;
    var rotatedDelta = rotatePoint(delta, Offset.zero, -angle);

    // start handling

    final resizedBox =
        resize(initialBox, initialLocalPosition, localPosition, alignment);
    final resizedOffsets = [...resizedBox.offsets];

    final initialRatio = initialBox.rect.size.aspectRatio;

    switch (alignment) {
      case Alignment.topCenter || Alignment.bottomCenter:
        if (alignment == Alignment.bottomCenter) {
          rotatedDelta = Offset(0, -rotatedDelta.dy);
        }
        resizedOffsets[0] += Offset(rotatedDelta.dy * initialRatio, 0) / 2;
        resizedOffsets[3] += Offset(rotatedDelta.dy * initialRatio, 0) / 2;

        resizedOffsets[2] -= Offset(rotatedDelta.dy * initialRatio, 0) / 2;
        resizedOffsets[1] -= Offset(rotatedDelta.dy * initialRatio, 0) / 2;
      case Alignment.centerLeft || Alignment.centerRight:
        if (alignment == Alignment.centerRight && !initialBox.flipY) {
          rotatedDelta = Offset(-rotatedDelta.dx, 0);
        }
        resizedOffsets[0] += Offset(0, rotatedDelta.dx / initialRatio) / 2;
        resizedOffsets[1] += Offset(0, rotatedDelta.dx / initialRatio) / 2;

        resizedOffsets[2] -= Offset(0, rotatedDelta.dx / initialRatio) / 2;
        resizedOffsets[3] -= Offset(0, rotatedDelta.dx / initialRatio) / 2;

      case Alignment.topLeft ||
            Alignment.topRight ||
            Alignment.bottomLeft ||
            Alignment.bottomRight:
        final resizedWidth = resizedBox.rect.size.width;
        final resizedHeight = resizedBox.rect.size.height;

        final resizedRatio = resizedBox.rect.size.aspectRatio;

        final isWidthShortest = resizedRatio < initialRatio;

        final goalSize = isWidthShortest
            ? Offset(resizedHeight * initialRatio, resizedHeight)
            : Offset(resizedWidth, resizedWidth / initialRatio);

        final indexes = switch (alignment) {
          Alignment.topLeft => [0, 1, 2, 3],
          Alignment.topRight => [1, 0, 3, 2],
          Alignment.bottomLeft => [3, 2, 1, 0],
          Alignment.bottomRight => [2, 3, 0, 1],
          _ => [0],
        };

        final negative = switch (alignment) {
          Alignment.topLeft => const Offset(1, 1),
          Alignment.topRight => const Offset(-1, 1),
          Alignment.bottomLeft => const Offset(1, -1),
          Alignment.bottomRight => const Offset(-1, -1),
          _ => Offset.zero,
        };

        final [index0, index1, index2, index3] = indexes;

        resizedOffsets[index0] =
            resizedOffsets[index2] - goalSize.multiply(negative);
        resizedOffsets[index1] =
            resizedOffsets[index2] - Offset(0, goalSize.dy).multiply(negative);
        resizedOffsets[index3] =
            resizedOffsets[index2] - Offset(goalSize.dx, 0).multiply(negative);
    }

    // return

    return Box(
      quad: quadFromOffsets(resizedOffsets),
      angle: angle,
      origin: origin,
    );
  }

  Offset rotatePoint(Offset point, Offset origin, double angle) {
    final cosTheta = cos(angle * pi / 180);
    final sinTheta = sin(angle * pi / 180);

    final oPoint = point - origin;
    final x = oPoint.dx;
    final y = oPoint.dy;

    final newX = x * cosTheta - y * sinTheta;
    final newY = x * sinTheta + y * cosTheta;

    return Offset(newX, newY) + origin;
  }

  double getAngleFromPoints(Offset point1, Offset point2) {
    return atan2(point2.dy - point1.dy, point2.dx - point1.dx);
  }
}
