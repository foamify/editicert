// This file is automatically generated, so please do not edit it.
// Generated by `flutter_rust_bridge`@ 2.0.0-dev.21.

// ignore_for_file: invalid_use_of_internal_member, unused_import, unnecessary_import

import '../frb_generated.dart';
import 'package:flutter_rust_bridge/flutter_rust_bridge_for_generated.dart';

Future<bool> isTwoLinesIntersecting(
        {required Line line1, required Line line2, dynamic hint}) =>
    RustLib.instance.api
        .isTwoLinesIntersecting(line1: line1, line2: line2, hint: hint);

Future<List<String>> getIntersectingIds(
        {required MarqueeRect rect,
        required List<Polygon> polygons,
        required List<double> matrixStorage,
        dynamic hint}) =>
    RustLib.instance.api.getIntersectingIds(
        rect: rect,
        polygons: polygons,
        matrixStorage: matrixStorage,
        hint: hint);

class CanvasPoint {
  final double x;
  final double y;

  const CanvasPoint({
    required this.x,
    required this.y,
  });

  @override
  int get hashCode => x.hashCode ^ y.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CanvasPoint &&
          runtimeType == other.runtimeType &&
          x == other.x &&
          y == other.y;
}

class Line {
  final CanvasPoint p1;
  final CanvasPoint p2;

  const Line({
    required this.p1,
    required this.p2,
  });

  @override
  int get hashCode => p1.hashCode ^ p2.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Line &&
          runtimeType == other.runtimeType &&
          p1 == other.p1 &&
          p2 == other.p2;
}

class MarqueeRect {
  final double x;
  final double y;
  final double width;
  final double height;

  const MarqueeRect({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
  });

  Future<bool> containsPoint({required CanvasPoint point, dynamic hint}) =>
      RustLib.instance.api.marqueeRectContainsPoint(
        that: this,
        point: point,
      );

  Future<List<Line>> lines({dynamic hint}) =>
      RustLib.instance.api.marqueeRectLines(
        that: this,
      );

  @override
  int get hashCode =>
      x.hashCode ^ y.hashCode ^ width.hashCode ^ height.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MarqueeRect &&
          runtimeType == other.runtimeType &&
          x == other.x &&
          y == other.y &&
          width == other.width &&
          height == other.height;
}

class Polygon {
  final String id;
  final List<Line> lines;

  const Polygon({
    required this.id,
    required this.lines,
  });

  @override
  int get hashCode => id.hashCode ^ lines.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Polygon &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          lines == other.lines;
}