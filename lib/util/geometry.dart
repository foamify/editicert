// ignore_for_file: avoid-unsafe-collection-methods, prefer-match-file-name

import 'dart:math';

import 'package:editicert/util/extensions.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:vector_math/vector_math_64.dart';

/// A box in 2D space.
/// The origin is relative to the top left of the box.
/// The angle is in degrees.
/// Normally the quad is unrotated. To get the rotated quad, use [rotated].
class Box extends Equatable {
  /// A box in 2D space.
  /// The origin is relative to the top left of the box.
  /// The angle is in degrees.
  /// Normally the quad is unrotated. To get the rotated quad, use [rotated].
  const Box({required this.quad, required this.origin, required this.angle});

  /// The 4 points of the box in the global coordinate system in clockwise order
  final Quad quad;

  /// The rotation origin of the box in the global coordinate system.
  /// To get the origin relative to the top left of the box, use [localOrigin].
  final Offset origin;

  /// The rotation angle of the box in degrees.
  final double angle;

  @override
  List<Object?> get props => [quad, origin, angle];

  /// Create box from a rectangle
  // ignore: prefer_constructors_over_static_methods
  static Box fromRect(Rect rect, {Offset? boxOrigin, double boxAngle = 0}) {
    return Box(
      quad: Quad.points(
        Vector3(rect.left, rect.top, 0),
        Vector3(rect.right, rect.top, 0),
        Vector3(rect.right, rect.bottom, 0),
        Vector3(rect.left, rect.bottom, 0),
      ),
      origin: boxOrigin ?? rect.center,
      angle: boxAngle,
    );
  }
}

/// Extensions for [Box]
/// This is horrible and need to be refactored someday
extension BoxExtension on Box {
  /// Whether the box is flipped horizontally
  bool get flipX => offset0.dx > offset2.dx;

  /// Whether the box is flipped vertically
  bool get flipY => offset0.dy > offset2.dy;

  /// Rotation origin of the box relative to the top left of the box
  Offset get localOrigin => origin - pointToOffset(quad.point0);

  /// Convert quad point to offset
  Offset pointToOffset(Vector3 vector3) => Offset(vector3.x, vector3.y);

  /// Top left offset of the quad points
  Offset get offset0 => pointToOffset(quad.point0);

  /// Top right offset of the quad points
  Offset get offset1 => pointToOffset(quad.point1);

  /// Bottom right offset of the quad points
  Offset get offset2 => pointToOffset(quad.point2);

  /// Bottom left offset of the quad points
  Offset get offset3 => pointToOffset(quad.point3);

  /// The offset of the quad points
  /// 0 = top left
  /// 1 = top right
  /// 2 = bottom right
  /// 3 = bottom left
  List<Offset> get offsets => [offset0, offset1, offset2, offset3];

  /// The points of the quad
  List<Vector3> get points => [
        quad.point0,
        quad.point1,
        quad.point2,
        quad.point3,
      ];

  /// Convert offset to point
  Vector3 offsetToPoint(Offset offset) => Vector3(offset.dx, offset.dy, 0);

  /// Convert offsets to points
  Quad quadFromPoints(List<Vector3> points) {
    return Quad.points(points[0], points[1], points[2], points[3]);
  }

  /// Convert offsets to points
  Quad quadFromOffsets(List<Offset> offsets) {
    return Quad.points(
      offsetToPoint(offsets[0]),
      offsetToPoint(offsets[1]),
      offsetToPoint(offsets[2]),
      offsetToPoint(offsets[3]),
    );
  }

  /// The rect of the quad
  Rect get rect => Rect.fromPoints(offset0, offset2);

  /// The width of the rect
  double get width => rect.width;

  /// The height of the rect
  double get height => rect.height;

  /// Top left x coordinate
  double get x => rect.topLeft.dx;

  /// Top left y coordinate
  double get y => rect.topLeft.dy;

  /// The box with the quad rotated by the given angle relative to the origin
  Box get rotated {
    final rotatedPoints = offsets.map((offset) {
      return rotatePoint(offset, origin, angle);
    }).toList();

    return Box(
      quad: quadFromOffsets(rotatedPoints),
      angle: angle,
      origin: origin,
    );
  }

  /// Adds the given angle to the box without rotating the quad
  Box rotate(double angle) {
    return Box(quad: quad, angle: this.angle + angle, origin: origin);
  }

  /// Adds the angle, which is determined by the given offset relative to origin
  /// to the box without rotating the quad
  Box rotateByPan(Offset offset, [Alignment alignment = Alignment.center]) {
    final rotation = getAngleFromPoints(offset, rect.center) + pi;
    final double additionalAngle;
    if (alignment != Alignment.center) {
      final (double x, double y) = (flipX ? -1 : 1, flipY ? -1 : 1);
      final edge = alignment.alongSize(rect.size);
      additionalAngle = getAngleFromPoints(edge.scale(x, y), localOrigin) + pi;
    } else {
      additionalAngle = 0;
    }

    return Box(
      quad: quad,
      angle: (rotation - additionalAngle) / pi * 180,
      origin: origin,
    );
  }

  /// Translate the quad by the given offset
  Box translate(Offset offset) {
    return Box(
      quad: quad..translate(offsetToPoint(offset)),
      angle: angle,
      origin: origin + offset,
    );
  }

  /// Resizes the box normally
  Box resize(
    Box initialBox,
    Offset initialLocalPosition,
    Offset localPosition,
    Alignment alignment, {
    bool rotate = false,
  }) {
    // init vars
    final delta = localPosition - initialLocalPosition;
    final initialOffsets = initialBox.offsets;
    final originalOffsets = initialOffsets;
    var rotatedDelta = rotate ? rotatePoint(delta, Offset.zero, -angle) : delta;

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

  /// Resize but symmetric to the given alignment
  Box resizeSymmetric(
    Box initialBox,
    Offset initialLocalPosition,
    Offset localPosition,
    Alignment alignment, {
    bool rotate = false,
  }) {
    // init vars
    final delta = localPosition - initialLocalPosition;
    final initialOffsets = initialBox.offsets;
    final originalOffsets = initialOffsets;
    var rotatedDelta = rotate ? rotatePoint(delta, Offset.zero, -angle) : delta;

    // start handling

    switch (alignment) {
      case Alignment.topCenter:
        rotatedDelta = Offset(0, rotatedDelta.dy);
      case Alignment.bottomCenter:
        rotatedDelta = Offset(0, -rotatedDelta.dy);

      case Alignment.centerLeft || Alignment.centerRight:
        rotatedDelta = Offset(delta.dx, 0);
    }

    final invertedDelta = Offset(-rotatedDelta.dx, -rotatedDelta.dy);

    final resizedOffsets = [...originalOffsets];

    final indexes = switch (alignment) {
      Alignment.topLeft ||
      Alignment.centerLeft ||
      Alignment.topCenter ||
      Alignment.bottomCenter =>
        [0, 1, 2, 3],
      Alignment.topRight => [1, 0, 3, 2],
      Alignment.centerRight || Alignment.bottomRight => [2, 3, 0, 1],
      _ => [3, 2, 1, 0], // bottomLeft
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
  Box resizeScaled(
    Box initialBox,
    Offset initialLocalPosition,
    Offset localPosition,
    Alignment alignment, {
    bool rotate = false,
  }) {
    // start handling

    final resizedBox = resize(
      initialBox,
      initialLocalPosition,
      localPosition,
      alignment,
      rotate: rotate,
    );
    final resizedOffsets = [...resizedBox.offsets];

    final initialRatio = initialBox.rect.size.aspectRatio;

    switch (alignment) {
      case Alignment.topCenter ||
            Alignment.bottomCenter ||
            Alignment.centerLeft ||
            Alignment.centerRight:
        final indexes = {
          Alignment.topCenter: [1, 2, 3, 0],
          Alignment.bottomCenter: [1, 2, 3, 0],
          Alignment.centerLeft: [2, 3, 0, 1],
          Alignment.centerRight: [2, 3, 0, 1],
        };
        final [index0, index1, index2, index3] = indexes[alignment]!;

        final resizedSize = switch (alignment) {
          Alignment.topCenter ||
          Alignment.bottomCenter =>
            resizedBox.rect.size.height,
          Alignment.centerLeft ||
          Alignment.centerRight =>
            resizedBox.rect.size.width,
          _ => 0.0,
        };

        final isHorizontal = alignment == Alignment.centerLeft ||
            alignment == Alignment.centerRight;

        final goalOtherSideSize = isHorizontal
            ? resizedSize / initialRatio
            : resizedSize * initialRatio;

        var goalSize = isHorizontal
            ? Offset(0, goalOtherSideSize - resizedBox.rect.size.height)
            : Offset(goalOtherSideSize - resizedBox.rect.size.width, 0);

        if (initialBox.flipX) goalSize = Offset(-goalSize.dx, goalSize.dy);
        if (initialBox.flipY) goalSize = Offset(goalSize.dx, -goalSize.dy);

        resizedOffsets[index0] += goalSize / 2;
        resizedOffsets[index1] += goalSize / 2;

        resizedOffsets[index2] -= goalSize / 2;
        resizedOffsets[index3] -= goalSize / 2;

      case Alignment.topLeft ||
            Alignment.topRight ||
            Alignment.bottomLeft ||
            Alignment.bottomRight:
        final resizedWidth = resizedBox.rect.size.width;
        final resizedHeight = resizedBox.rect.size.height;

        final resizedRatio = resizedBox.rect.size.aspectRatio;

        final isWidthShortest = resizedRatio < initialRatio;

        var goalSize = isWidthShortest
            ? Offset(resizedHeight * initialRatio, resizedHeight)
            : Offset(resizedWidth, resizedWidth / initialRatio);

        final resizeFlipX = resizedBox.flipX;
        final resizeFlipY = resizedBox.flipY;

        if (resizeFlipX) goalSize = Offset(-goalSize.dx, goalSize.dy);
        if (resizeFlipY) goalSize = Offset(goalSize.dx, -goalSize.dy);

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

  Box resizeSymmetricScaled(
    Box initialBox,
    Offset initialLocalPosition,
    Offset localPosition,
    Alignment alignment, {
    bool rotate = false,
  }) {
    final resizedBox = resizeSymmetric(
      initialBox,
      initialLocalPosition,
      localPosition,
      alignment,
      rotate: rotate,
    );
    var resizedOffsets = [...resizedBox.offsets];

    final initialRatio = initialBox.rect.size.aspectRatio;

    final resizedRatio = resizedBox.rect.size.aspectRatio;

    final isWidthShortest = resizedRatio < initialRatio;

    final isEdgeResize = [
      Alignment.topLeft,
      Alignment.topRight,
      Alignment.bottomLeft,
      Alignment.bottomRight,
    ].contains(alignment);

    var goalSize = isWidthShortest
        ? Offset(
            resizedBox.rect.size.height * initialRatio,
            resizedBox.rect.size.height,
          )
        : Offset(
            resizedBox.rect.size.width,
            resizedBox.rect.size.width / initialRatio,
          );
    if (!isEdgeResize) {
      switch (alignment) {
        case Alignment.topCenter || Alignment.bottomCenter:
          goalSize = Offset(
            resizedBox.rect.size.height * initialRatio,
            resizedBox.rect.size.height,
          );
        case _:
          goalSize = Offset(
            resizedBox.rect.size.width,
            resizedBox.rect.size.width / initialRatio,
          );
      }
    }

    final initialFlipX = initialBox.flipX;
    final initialFlipY = initialBox.flipY;

    if (initialFlipX) goalSize = Offset(-goalSize.dx, goalSize.dy);
    if (initialFlipY) goalSize = Offset(goalSize.dx, -goalSize.dy);

    final resizedCenter = resizedBox.rect.center;

    resizedOffsets[0] = resizedCenter - goalSize / 2;
    resizedOffsets[1] = resizedCenter - Offset(-goalSize.dx, goalSize.dy) / 2;

    resizedOffsets[3] = resizedCenter - Offset(goalSize.dx, -goalSize.dy) / 2;
    resizedOffsets[2] = resizedCenter + goalSize / 2;

    final resizeFlipX = resizedBox.flipX;
    final resizeFlipY = resizedBox.flipY;

    if (isEdgeResize && resizeFlipX != initialFlipX ||
        (!isEdgeResize && resizeFlipX != initialFlipX)) {
      resizedOffsets = [
        resizedOffsets[1],
        resizedOffsets[0],
        resizedOffsets[3],
        resizedOffsets[2],
      ];
    }

    if (isEdgeResize && resizeFlipY != initialFlipY ||
        (!isEdgeResize && resizeFlipY != initialFlipY)) {
      resizedOffsets = [
        resizedOffsets[3],
        resizedOffsets[2],
        resizedOffsets[1],
        resizedOffsets[0],
      ];
    }

    return Box(
      quad: quadFromOffsets(resizedOffsets),
      angle: angle,
      origin: origin,
    );
  }

  /// Rotate a point around an origin by an angle
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

  /// Get the angle between two points
  double getAngleFromPoints(Offset point1, Offset point2) {
    return atan2(point2.dy - point1.dy, point2.dx - point1.dx);
  }

  Box clone() => Box(quad: quad, angle: angle, origin: origin);
}
