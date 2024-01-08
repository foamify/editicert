// This file is automatically generated, so please do not edit it.
// Generated by `flutter_rust_bridge`@ 2.0.0-dev.14.

// ignore_for_file: unused_import, unused_element, unnecessary_import, duplicate_ignore, invalid_use_of_internal_member, annotate_overrides, non_constant_identifier_names, curly_braces_in_flow_control_structures, prefer_const_literals_to_create_immutables

import 'api/canvas.dart';
import 'api/simple.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:ffi' as ffi;
import 'frb_generated.dart';
import 'package:flutter_rust_bridge/flutter_rust_bridge_for_generated_io.dart';

abstract class RustLibApiImplPlatform extends BaseApiImpl<RustLibWire> {
  RustLibApiImplPlatform({
    required super.handler,
    required super.wire,
    required super.generalizedFrbRustBinding,
    required super.portManager,
  });

  @protected
  String dco_decode_String(dynamic raw);

  @protected
  bool dco_decode_bool(dynamic raw);

  @protected
  CanvasPoint dco_decode_box_autoadd_canvas_point(dynamic raw);

  @protected
  Line dco_decode_box_autoadd_line(dynamic raw);

  @protected
  MarqueeRect dco_decode_box_autoadd_marquee_rect(dynamic raw);

  @protected
  CanvasPoint dco_decode_canvas_point(dynamic raw);

  @protected
  double dco_decode_f_64(dynamic raw);

  @protected
  Line dco_decode_line(dynamic raw);

  @protected
  List<String> dco_decode_list_String(dynamic raw);

  @protected
  List<Line> dco_decode_list_line(dynamic raw);

  @protected
  List<Polygon> dco_decode_list_polygon(dynamic raw);

  @protected
  List<double> dco_decode_list_prim_f_64_loose(dynamic raw);

  @protected
  Float64List dco_decode_list_prim_f_64_strict(dynamic raw);

  @protected
  Uint8List dco_decode_list_prim_u_8_strict(dynamic raw);

  @protected
  MarqueeRect dco_decode_marquee_rect(dynamic raw);

  @protected
  Polygon dco_decode_polygon(dynamic raw);

  @protected
  int dco_decode_u_8(dynamic raw);

  @protected
  void dco_decode_unit(dynamic raw);

  @protected
  String sse_decode_String(SseDeserializer deserializer);

  @protected
  bool sse_decode_bool(SseDeserializer deserializer);

  @protected
  CanvasPoint sse_decode_box_autoadd_canvas_point(SseDeserializer deserializer);

  @protected
  Line sse_decode_box_autoadd_line(SseDeserializer deserializer);

  @protected
  MarqueeRect sse_decode_box_autoadd_marquee_rect(SseDeserializer deserializer);

  @protected
  CanvasPoint sse_decode_canvas_point(SseDeserializer deserializer);

  @protected
  double sse_decode_f_64(SseDeserializer deserializer);

  @protected
  Line sse_decode_line(SseDeserializer deserializer);

  @protected
  List<String> sse_decode_list_String(SseDeserializer deserializer);

  @protected
  List<Line> sse_decode_list_line(SseDeserializer deserializer);

  @protected
  List<Polygon> sse_decode_list_polygon(SseDeserializer deserializer);

  @protected
  List<double> sse_decode_list_prim_f_64_loose(SseDeserializer deserializer);

  @protected
  Float64List sse_decode_list_prim_f_64_strict(SseDeserializer deserializer);

  @protected
  Uint8List sse_decode_list_prim_u_8_strict(SseDeserializer deserializer);

  @protected
  MarqueeRect sse_decode_marquee_rect(SseDeserializer deserializer);

  @protected
  Polygon sse_decode_polygon(SseDeserializer deserializer);

  @protected
  int sse_decode_u_8(SseDeserializer deserializer);

  @protected
  void sse_decode_unit(SseDeserializer deserializer);

  @protected
  int sse_decode_i_32(SseDeserializer deserializer);

  @protected
  ffi.Pointer<wire_cst_list_prim_u_8_strict> cst_encode_String(String raw) {
    return cst_encode_list_prim_u_8_strict(utf8.encoder.convert(raw));
  }

  @protected
  ffi.Pointer<wire_cst_canvas_point> cst_encode_box_autoadd_canvas_point(
      CanvasPoint raw) {
    final ptr = wire.cst_new_box_autoadd_canvas_point();
    cst_api_fill_to_wire_canvas_point(raw, ptr.ref);
    return ptr;
  }

  @protected
  ffi.Pointer<wire_cst_line> cst_encode_box_autoadd_line(Line raw) {
    final ptr = wire.cst_new_box_autoadd_line();
    cst_api_fill_to_wire_line(raw, ptr.ref);
    return ptr;
  }

  @protected
  ffi.Pointer<wire_cst_marquee_rect> cst_encode_box_autoadd_marquee_rect(
      MarqueeRect raw) {
    final ptr = wire.cst_new_box_autoadd_marquee_rect();
    cst_api_fill_to_wire_marquee_rect(raw, ptr.ref);
    return ptr;
  }

  @protected
  ffi.Pointer<wire_cst_list_String> cst_encode_list_String(List<String> raw) {
    final ans = wire.cst_new_list_String(raw.length);
    for (var i = 0; i < raw.length; ++i) {
      ans.ref.ptr[i] = cst_encode_String(raw[i]);
    }
    return ans;
  }

  @protected
  ffi.Pointer<wire_cst_list_line> cst_encode_list_line(List<Line> raw) {
    final ans = wire.cst_new_list_line(raw.length);
    for (var i = 0; i < raw.length; ++i) {
      cst_api_fill_to_wire_line(raw[i], ans.ref.ptr[i]);
    }
    return ans;
  }

  @protected
  ffi.Pointer<wire_cst_list_polygon> cst_encode_list_polygon(
      List<Polygon> raw) {
    final ans = wire.cst_new_list_polygon(raw.length);
    for (var i = 0; i < raw.length; ++i) {
      cst_api_fill_to_wire_polygon(raw[i], ans.ref.ptr[i]);
    }
    return ans;
  }

  @protected
  ffi.Pointer<wire_cst_list_prim_f_64_loose> cst_encode_list_prim_f_64_loose(
      List<double> raw) {
    final ans = wire.cst_new_list_prim_f_64_loose(raw.length);
    ans.ref.ptr.asTypedList(raw.length).setAll(0, raw);
    return ans;
  }

  @protected
  ffi.Pointer<wire_cst_list_prim_f_64_strict> cst_encode_list_prim_f_64_strict(
      Float64List raw) {
    final ans = wire.cst_new_list_prim_f_64_strict(raw.length);
    ans.ref.ptr.asTypedList(raw.length).setAll(0, raw);
    return ans;
  }

  @protected
  ffi.Pointer<wire_cst_list_prim_u_8_strict> cst_encode_list_prim_u_8_strict(
      Uint8List raw) {
    final ans = wire.cst_new_list_prim_u_8_strict(raw.length);
    ans.ref.ptr.asTypedList(raw.length).setAll(0, raw);
    return ans;
  }

  @protected
  void cst_api_fill_to_wire_box_autoadd_canvas_point(
      CanvasPoint apiObj, ffi.Pointer<wire_cst_canvas_point> wireObj) {
    cst_api_fill_to_wire_canvas_point(apiObj, wireObj.ref);
  }

  @protected
  void cst_api_fill_to_wire_box_autoadd_line(
      Line apiObj, ffi.Pointer<wire_cst_line> wireObj) {
    cst_api_fill_to_wire_line(apiObj, wireObj.ref);
  }

  @protected
  void cst_api_fill_to_wire_box_autoadd_marquee_rect(
      MarqueeRect apiObj, ffi.Pointer<wire_cst_marquee_rect> wireObj) {
    cst_api_fill_to_wire_marquee_rect(apiObj, wireObj.ref);
  }

  @protected
  void cst_api_fill_to_wire_canvas_point(
      CanvasPoint apiObj, wire_cst_canvas_point wireObj) {
    wireObj.x = cst_encode_f_64(apiObj.x);
    wireObj.y = cst_encode_f_64(apiObj.y);
  }

  @protected
  void cst_api_fill_to_wire_line(Line apiObj, wire_cst_line wireObj) {
    cst_api_fill_to_wire_canvas_point(apiObj.p1, wireObj.p1);
    cst_api_fill_to_wire_canvas_point(apiObj.p2, wireObj.p2);
  }

  @protected
  void cst_api_fill_to_wire_marquee_rect(
      MarqueeRect apiObj, wire_cst_marquee_rect wireObj) {
    wireObj.x = cst_encode_f_64(apiObj.x);
    wireObj.y = cst_encode_f_64(apiObj.y);
    wireObj.width = cst_encode_f_64(apiObj.width);
    wireObj.height = cst_encode_f_64(apiObj.height);
  }

  @protected
  void cst_api_fill_to_wire_polygon(Polygon apiObj, wire_cst_polygon wireObj) {
    wireObj.id = cst_encode_String(apiObj.id);
    wireObj.lines = cst_encode_list_line(apiObj.lines);
  }

  @protected
  bool cst_encode_bool(bool raw);

  @protected
  double cst_encode_f_64(double raw);

  @protected
  int cst_encode_u_8(int raw);

  @protected
  void cst_encode_unit(void raw);

  @protected
  void sse_encode_String(String self, SseSerializer serializer);

  @protected
  void sse_encode_bool(bool self, SseSerializer serializer);

  @protected
  void sse_encode_box_autoadd_canvas_point(
      CanvasPoint self, SseSerializer serializer);

  @protected
  void sse_encode_box_autoadd_line(Line self, SseSerializer serializer);

  @protected
  void sse_encode_box_autoadd_marquee_rect(
      MarqueeRect self, SseSerializer serializer);

  @protected
  void sse_encode_canvas_point(CanvasPoint self, SseSerializer serializer);

  @protected
  void sse_encode_f_64(double self, SseSerializer serializer);

  @protected
  void sse_encode_line(Line self, SseSerializer serializer);

  @protected
  void sse_encode_list_String(List<String> self, SseSerializer serializer);

  @protected
  void sse_encode_list_line(List<Line> self, SseSerializer serializer);

  @protected
  void sse_encode_list_polygon(List<Polygon> self, SseSerializer serializer);

  @protected
  void sse_encode_list_prim_f_64_loose(
      List<double> self, SseSerializer serializer);

  @protected
  void sse_encode_list_prim_f_64_strict(
      Float64List self, SseSerializer serializer);

  @protected
  void sse_encode_list_prim_u_8_strict(
      Uint8List self, SseSerializer serializer);

  @protected
  void sse_encode_marquee_rect(MarqueeRect self, SseSerializer serializer);

  @protected
  void sse_encode_polygon(Polygon self, SseSerializer serializer);

  @protected
  void sse_encode_u_8(int self, SseSerializer serializer);

  @protected
  void sse_encode_unit(void self, SseSerializer serializer);

  @protected
  void sse_encode_i_32(int self, SseSerializer serializer);
}

// Section: wire_class

// ignore_for_file: camel_case_types, non_constant_identifier_names, avoid_positional_boolean_parameters, annotate_overrides, constant_identifier_names
// AUTO GENERATED FILE, DO NOT EDIT.
//
// Generated by `package:ffigen`.
// ignore_for_file: type=lint

/// generated by flutter_rust_bridge
class RustLibWire implements BaseWire {
  factory RustLibWire.fromExternalLibrary(ExternalLibrary lib) =>
      RustLibWire(lib.ffiDynamicLibrary);

  /// Holds the symbol lookup function.
  final ffi.Pointer<T> Function<T extends ffi.NativeType>(String symbolName)
      _lookup;

  /// The symbols are looked up in [dynamicLibrary].
  RustLibWire(ffi.DynamicLibrary dynamicLibrary)
      : _lookup = dynamicLibrary.lookup;

  /// The symbols are looked up with [lookup].
  RustLibWire.fromLookup(
      ffi.Pointer<T> Function<T extends ffi.NativeType>(String symbolName)
          lookup)
      : _lookup = lookup;

  void dart_fn_deliver_output(
    int call_id,
    ffi.Pointer<ffi.Uint8> ptr_,
    int rust_vec_len_,
    int data_len_,
  ) {
    return _dart_fn_deliver_output(
      call_id,
      ptr_,
      rust_vec_len_,
      data_len_,
    );
  }

  late final _dart_fn_deliver_outputPtr = _lookup<
      ffi.NativeFunction<
          ffi.Void Function(ffi.Int32, ffi.Pointer<ffi.Uint8>, ffi.Int32,
              ffi.Int32)>>('frbgen_editicert_dart_fn_deliver_output');
  late final _dart_fn_deliver_output = _dart_fn_deliver_outputPtr
      .asFunction<void Function(int, ffi.Pointer<ffi.Uint8>, int, int)>();

  void wire_MarqueeRect_contains_point(
    int port_,
    ffi.Pointer<wire_cst_marquee_rect> that,
    ffi.Pointer<wire_cst_canvas_point> point,
  ) {
    return _wire_MarqueeRect_contains_point(
      port_,
      that,
      point,
    );
  }

  late final _wire_MarqueeRect_contains_pointPtr = _lookup<
          ffi.NativeFunction<
              ffi.Void Function(ffi.Int64, ffi.Pointer<wire_cst_marquee_rect>,
                  ffi.Pointer<wire_cst_canvas_point>)>>(
      'frbgen_editicert_wire_MarqueeRect_contains_point');
  late final _wire_MarqueeRect_contains_point =
      _wire_MarqueeRect_contains_pointPtr.asFunction<
          void Function(int, ffi.Pointer<wire_cst_marquee_rect>,
              ffi.Pointer<wire_cst_canvas_point>)>();

  void wire_MarqueeRect_lines(
    int port_,
    ffi.Pointer<wire_cst_marquee_rect> that,
  ) {
    return _wire_MarqueeRect_lines(
      port_,
      that,
    );
  }

  late final _wire_MarqueeRect_linesPtr = _lookup<
          ffi.NativeFunction<
              ffi.Void Function(
                  ffi.Int64, ffi.Pointer<wire_cst_marquee_rect>)>>(
      'frbgen_editicert_wire_MarqueeRect_lines');
  late final _wire_MarqueeRect_lines = _wire_MarqueeRect_linesPtr
      .asFunction<void Function(int, ffi.Pointer<wire_cst_marquee_rect>)>();

  void wire_get_intersecting_ids(
    int port_,
    ffi.Pointer<wire_cst_marquee_rect> rect,
    ffi.Pointer<wire_cst_list_polygon> polygons,
    ffi.Pointer<wire_cst_list_prim_f_64_loose> matrix_storage,
  ) {
    return _wire_get_intersecting_ids(
      port_,
      rect,
      polygons,
      matrix_storage,
    );
  }

  late final _wire_get_intersecting_idsPtr = _lookup<
          ffi.NativeFunction<
              ffi.Void Function(
                  ffi.Int64,
                  ffi.Pointer<wire_cst_marquee_rect>,
                  ffi.Pointer<wire_cst_list_polygon>,
                  ffi.Pointer<wire_cst_list_prim_f_64_loose>)>>(
      'frbgen_editicert_wire_get_intersecting_ids');
  late final _wire_get_intersecting_ids =
      _wire_get_intersecting_idsPtr.asFunction<
          void Function(
              int,
              ffi.Pointer<wire_cst_marquee_rect>,
              ffi.Pointer<wire_cst_list_polygon>,
              ffi.Pointer<wire_cst_list_prim_f_64_loose>)>();

  void wire_is_two_lines_intersecting(
    int port_,
    ffi.Pointer<wire_cst_line> line1,
    ffi.Pointer<wire_cst_line> line2,
  ) {
    return _wire_is_two_lines_intersecting(
      port_,
      line1,
      line2,
    );
  }

  late final _wire_is_two_lines_intersectingPtr = _lookup<
          ffi.NativeFunction<
              ffi.Void Function(ffi.Int64, ffi.Pointer<wire_cst_line>,
                  ffi.Pointer<wire_cst_line>)>>(
      'frbgen_editicert_wire_is_two_lines_intersecting');
  late final _wire_is_two_lines_intersecting =
      _wire_is_two_lines_intersectingPtr.asFunction<
          void Function(
              int, ffi.Pointer<wire_cst_line>, ffi.Pointer<wire_cst_line>)>();

  void wire_init_app(
    int port_,
  ) {
    return _wire_init_app(
      port_,
    );
  }

  late final _wire_init_appPtr =
      _lookup<ffi.NativeFunction<ffi.Void Function(ffi.Int64)>>(
          'frbgen_editicert_wire_init_app');
  late final _wire_init_app =
      _wire_init_appPtr.asFunction<void Function(int)>();

  ffi.Pointer<wire_cst_canvas_point> cst_new_box_autoadd_canvas_point() {
    return _cst_new_box_autoadd_canvas_point();
  }

  late final _cst_new_box_autoadd_canvas_pointPtr = _lookup<
          ffi.NativeFunction<ffi.Pointer<wire_cst_canvas_point> Function()>>(
      'frbgen_editicert_cst_new_box_autoadd_canvas_point');
  late final _cst_new_box_autoadd_canvas_point =
      _cst_new_box_autoadd_canvas_pointPtr
          .asFunction<ffi.Pointer<wire_cst_canvas_point> Function()>();

  ffi.Pointer<wire_cst_line> cst_new_box_autoadd_line() {
    return _cst_new_box_autoadd_line();
  }

  late final _cst_new_box_autoadd_linePtr =
      _lookup<ffi.NativeFunction<ffi.Pointer<wire_cst_line> Function()>>(
          'frbgen_editicert_cst_new_box_autoadd_line');
  late final _cst_new_box_autoadd_line = _cst_new_box_autoadd_linePtr
      .asFunction<ffi.Pointer<wire_cst_line> Function()>();

  ffi.Pointer<wire_cst_marquee_rect> cst_new_box_autoadd_marquee_rect() {
    return _cst_new_box_autoadd_marquee_rect();
  }

  late final _cst_new_box_autoadd_marquee_rectPtr = _lookup<
          ffi.NativeFunction<ffi.Pointer<wire_cst_marquee_rect> Function()>>(
      'frbgen_editicert_cst_new_box_autoadd_marquee_rect');
  late final _cst_new_box_autoadd_marquee_rect =
      _cst_new_box_autoadd_marquee_rectPtr
          .asFunction<ffi.Pointer<wire_cst_marquee_rect> Function()>();

  ffi.Pointer<wire_cst_list_String> cst_new_list_String(
    int len,
  ) {
    return _cst_new_list_String(
      len,
    );
  }

  late final _cst_new_list_StringPtr = _lookup<
      ffi.NativeFunction<
          ffi.Pointer<wire_cst_list_String> Function(
              ffi.Int32)>>('frbgen_editicert_cst_new_list_String');
  late final _cst_new_list_String = _cst_new_list_StringPtr
      .asFunction<ffi.Pointer<wire_cst_list_String> Function(int)>();

  ffi.Pointer<wire_cst_list_line> cst_new_list_line(
    int len,
  ) {
    return _cst_new_list_line(
      len,
    );
  }

  late final _cst_new_list_linePtr = _lookup<
          ffi
          .NativeFunction<ffi.Pointer<wire_cst_list_line> Function(ffi.Int32)>>(
      'frbgen_editicert_cst_new_list_line');
  late final _cst_new_list_line = _cst_new_list_linePtr
      .asFunction<ffi.Pointer<wire_cst_list_line> Function(int)>();

  ffi.Pointer<wire_cst_list_polygon> cst_new_list_polygon(
    int len,
  ) {
    return _cst_new_list_polygon(
      len,
    );
  }

  late final _cst_new_list_polygonPtr = _lookup<
      ffi.NativeFunction<
          ffi.Pointer<wire_cst_list_polygon> Function(
              ffi.Int32)>>('frbgen_editicert_cst_new_list_polygon');
  late final _cst_new_list_polygon = _cst_new_list_polygonPtr
      .asFunction<ffi.Pointer<wire_cst_list_polygon> Function(int)>();

  ffi.Pointer<wire_cst_list_prim_f_64_loose> cst_new_list_prim_f_64_loose(
    int len,
  ) {
    return _cst_new_list_prim_f_64_loose(
      len,
    );
  }

  late final _cst_new_list_prim_f_64_loosePtr = _lookup<
      ffi.NativeFunction<
          ffi.Pointer<wire_cst_list_prim_f_64_loose> Function(
              ffi.Int32)>>('frbgen_editicert_cst_new_list_prim_f_64_loose');
  late final _cst_new_list_prim_f_64_loose = _cst_new_list_prim_f_64_loosePtr
      .asFunction<ffi.Pointer<wire_cst_list_prim_f_64_loose> Function(int)>();

  ffi.Pointer<wire_cst_list_prim_f_64_strict> cst_new_list_prim_f_64_strict(
    int len,
  ) {
    return _cst_new_list_prim_f_64_strict(
      len,
    );
  }

  late final _cst_new_list_prim_f_64_strictPtr = _lookup<
      ffi.NativeFunction<
          ffi.Pointer<wire_cst_list_prim_f_64_strict> Function(
              ffi.Int32)>>('frbgen_editicert_cst_new_list_prim_f_64_strict');
  late final _cst_new_list_prim_f_64_strict = _cst_new_list_prim_f_64_strictPtr
      .asFunction<ffi.Pointer<wire_cst_list_prim_f_64_strict> Function(int)>();

  ffi.Pointer<wire_cst_list_prim_u_8_strict> cst_new_list_prim_u_8_strict(
    int len,
  ) {
    return _cst_new_list_prim_u_8_strict(
      len,
    );
  }

  late final _cst_new_list_prim_u_8_strictPtr = _lookup<
      ffi.NativeFunction<
          ffi.Pointer<wire_cst_list_prim_u_8_strict> Function(
              ffi.Int32)>>('frbgen_editicert_cst_new_list_prim_u_8_strict');
  late final _cst_new_list_prim_u_8_strict = _cst_new_list_prim_u_8_strictPtr
      .asFunction<ffi.Pointer<wire_cst_list_prim_u_8_strict> Function(int)>();

  int dummy_method_to_enforce_bundling() {
    return _dummy_method_to_enforce_bundling();
  }

  late final _dummy_method_to_enforce_bundlingPtr =
      _lookup<ffi.NativeFunction<ffi.Int64 Function()>>(
          'dummy_method_to_enforce_bundling');
  late final _dummy_method_to_enforce_bundling =
      _dummy_method_to_enforce_bundlingPtr.asFunction<int Function()>();
}

final class wire_cst_marquee_rect extends ffi.Struct {
  @ffi.Double()
  external double x;

  @ffi.Double()
  external double y;

  @ffi.Double()
  external double width;

  @ffi.Double()
  external double height;
}

final class wire_cst_canvas_point extends ffi.Struct {
  @ffi.Double()
  external double x;

  @ffi.Double()
  external double y;
}

final class wire_cst_list_prim_u_8_strict extends ffi.Struct {
  external ffi.Pointer<ffi.Uint8> ptr;

  @ffi.Int32()
  external int len;
}

final class wire_cst_line extends ffi.Struct {
  external wire_cst_canvas_point p1;

  external wire_cst_canvas_point p2;
}

final class wire_cst_list_line extends ffi.Struct {
  external ffi.Pointer<wire_cst_line> ptr;

  @ffi.Int32()
  external int len;
}

final class wire_cst_polygon extends ffi.Struct {
  external ffi.Pointer<wire_cst_list_prim_u_8_strict> id;

  external ffi.Pointer<wire_cst_list_line> lines;
}

final class wire_cst_list_polygon extends ffi.Struct {
  external ffi.Pointer<wire_cst_polygon> ptr;

  @ffi.Int32()
  external int len;
}

final class wire_cst_list_prim_f_64_loose extends ffi.Struct {
  external ffi.Pointer<ffi.Double> ptr;

  @ffi.Int32()
  external int len;
}

final class wire_cst_list_String extends ffi.Struct {
  external ffi.Pointer<ffi.Pointer<wire_cst_list_prim_u_8_strict>> ptr;

  @ffi.Int32()
  external int len;
}

final class wire_cst_list_prim_f_64_strict extends ffi.Struct {
  external ffi.Pointer<ffi.Double> ptr;

  @ffi.Int32()
  external int len;
}
