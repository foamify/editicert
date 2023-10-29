// ignore_for_file: avoid-unsafe-collection-methods, prefer-match-file-name

import 'dart:math';

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

  // TODO(damywise): use initialLocalPosition and localPosition for clamping
  Box resize(
    Offset delta,
    Alignment alignment, {
    bool mirrored = false,
    bool keepAspectRatio = true,
  }) {
    var rotatedDelta = rotatePoint(delta, Offset.zero, -angle);

    switch (alignment) {
      case Alignment.topCenter || Alignment.bottomCenter when keepAspectRatio:
        rotatedDelta = Offset(rotatedDelta.dy, rotatedDelta.dy);
      case Alignment.topCenter || Alignment.bottomCenter:
        rotatedDelta = Offset(0, rotatedDelta.dy);

      case Alignment.centerRight || Alignment.centerLeft when keepAspectRatio:
        rotatedDelta = Offset(rotatedDelta.dx, rotatedDelta.dx);
      case Alignment.centerLeft || Alignment.centerRight:
        rotatedDelta = Offset(rotatedDelta.dx, 0);
    }

    var originalOffsets = offsets;
    final resizedOffsets = originalOffsets.map((offset) {
      return offset + rotatedDelta;
    }).toList();

    if (mirrored) {
      originalOffsets = offsets.map((e) => e - rotatedDelta).toList();
    }

    final keepAspecRatioModifier = {
      Alignment.topCenter: [
        const Offset(.5, 1),
        const Offset(-.5, 1),
        const Offset(-.5, 0),
        const Offset(.5, 0),
      ],
      Alignment.centerRight: [
        const Offset(0, -.5),
        const Offset(1, -.5),
        const Offset(1, .5),
        const Offset(0, .5),
      ],
      Alignment.centerLeft: [
        const Offset(1, .5),
        const Offset(0, .5),
        const Offset(0, -.5),
        const Offset(1, -.5),
      ],
      Alignment.bottomCenter: [
        const Offset(-.5, 0),
        const Offset(.5, 0),
        const Offset(.5, 1),
        const Offset(-.5, 1),
      ],
      //
      Alignment.topLeft: [
        const Offset(1, 1),
        const Offset(1, 1),
        const Offset(0, 0),
        const Offset(1, 1),
      ]
    };

    void resizeOffsetAspectRatio() {
      for (var i = 0; i < 4; i++) {
        resizedOffsets[i] = Offset(
          originalOffsets[i].dx +
              rotatedDelta.dx * keepAspecRatioModifier[alignment]![i].dx,
          originalOffsets[i].dy +
              rotatedDelta.dy * keepAspecRatioModifier[alignment]![i].dy,
        );
      }
    }

    if (keepAspectRatio) {
      resizeOffsetAspectRatio();
    } else {
      switch (alignment) {
        // ----
        case Alignment.topLeft:
          // 0 is the top left
          resizedOffsets[1] =
              Offset(originalOffsets[1].dx, resizedOffsets[1].dy);
          resizedOffsets[2] = originalOffsets[2];
          resizedOffsets[3] =
              Offset(resizedOffsets[3].dx, originalOffsets[3].dy);
        case Alignment.topCenter:
          // 0 and 1 is the top
          resizedOffsets[2] = originalOffsets[2];
          resizedOffsets[3] = originalOffsets[3];
        case Alignment.topRight:
          // 1 is the top right
          resizedOffsets[0] =
              Offset(originalOffsets[0].dx, resizedOffsets[0].dy);
          resizedOffsets[3] = originalOffsets[3];
          resizedOffsets[2] =
              Offset(resizedOffsets[2].dx, originalOffsets[2].dy);
        case Alignment.centerLeft:
          // 0 and 3 is the left
          resizedOffsets[1] = originalOffsets[1];
          resizedOffsets[2] = originalOffsets[2];
        case Alignment.centerRight:
          // 1 and 2 is the right
          resizedOffsets[0] = originalOffsets[0];
          resizedOffsets[3] = originalOffsets[3];
        case Alignment.bottomLeft:
          // 3 is the bottom left
          resizedOffsets[2] =
              Offset(originalOffsets[2].dx, resizedOffsets[2].dy);
          resizedOffsets[1] = originalOffsets[1];
          resizedOffsets[0] =
              Offset(resizedOffsets[0].dx, originalOffsets[0].dy);
        case Alignment.bottomCenter:
          // 2 and 3 is the bottom
          resizedOffsets[0] = originalOffsets[0];
          resizedOffsets[1] = originalOffsets[1];
        case Alignment.bottomRight:
          // 2 is the bottom right
          resizedOffsets[3] =
              Offset(originalOffsets[3].dx, resizedOffsets[3].dy);
          resizedOffsets[0] = originalOffsets[0];
          resizedOffsets[1] =
              Offset(resizedOffsets[1].dx, originalOffsets[1].dy);
      }
    }

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
