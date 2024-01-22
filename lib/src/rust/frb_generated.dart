// This file is automatically generated, so please do not edit it.
// Generated by `flutter_rust_bridge`@ 2.0.0-dev.21.

// ignore_for_file: unused_import, unused_element, unnecessary_import, duplicate_ignore, invalid_use_of_internal_member, annotate_overrides, non_constant_identifier_names, curly_braces_in_flow_control_structures, prefer_const_literals_to_create_immutables, unused_field

import 'api/canvas.dart';
import 'api/simple.dart';
import 'dart:async';
import 'dart:convert';
import 'frb_generated.io.dart' if (dart.library.html) 'frb_generated.web.dart';
import 'package:flutter_rust_bridge/flutter_rust_bridge_for_generated.dart';

/// Main entrypoint of the Rust API
class RustLib extends BaseEntrypoint<RustLibApi, RustLibApiImpl, RustLibWire> {
  @internal
  static final instance = RustLib._();

  RustLib._();

  /// Initialize flutter_rust_bridge
  static Future<void> init({
    RustLibApi? api,
    BaseHandler? handler,
    ExternalLibrary? externalLibrary,
  }) async {
    await instance.initImpl(
      api: api,
      handler: handler,
      externalLibrary: externalLibrary,
    );
  }

  /// Dispose flutter_rust_bridge
  ///
  /// The call to this function is optional, since flutter_rust_bridge (and everything else)
  /// is automatically disposed when the app stops.
  static void dispose() => instance.disposeImpl();

  @override
  ApiImplConstructor<RustLibApiImpl, RustLibWire> get apiImplConstructor =>
      RustLibApiImpl.new;

  @override
  WireConstructor<RustLibWire> get wireConstructor =>
      RustLibWire.fromExternalLibrary;

  @override
  Future<void> executeRustInitializers() async {
    await api.initApp();
  }

  @override
  ExternalLibraryLoaderConfig get defaultExternalLibraryLoaderConfig =>
      kDefaultExternalLibraryLoaderConfig;

  @override
  String get codegenVersion => '2.0.0-dev.21';

  static const kDefaultExternalLibraryLoaderConfig =
      ExternalLibraryLoaderConfig(
    stem: 'rust_lib',
    ioDirectory: 'rust/target/release/',
    webPrefix: 'pkg/',
  );
}

abstract class RustLibApi extends BaseApi {
  Future<bool> marqueeRectContainsPoint(
      {required MarqueeRect that, required CanvasPoint point, dynamic hint});

  Future<List<Line>> marqueeRectLines(
      {required MarqueeRect that, dynamic hint});

  Future<List<String>> getIntersectingIds(
      {required MarqueeRect rect,
      required List<Polygon> polygons,
      required List<double> matrixStorage,
      dynamic hint});

  Future<bool> isTwoLinesIntersecting(
      {required Line line1, required Line line2, dynamic hint});

  Future<void> initApp({dynamic hint});
}

class RustLibApiImpl extends RustLibApiImplPlatform implements RustLibApi {
  RustLibApiImpl({
    required super.handler,
    required super.wire,
    required super.generalizedFrbRustBinding,
    required super.portManager,
  });

  @override
  Future<bool> marqueeRectContainsPoint(
      {required MarqueeRect that, required CanvasPoint point, dynamic hint}) {
    return handler.executeNormal(NormalTask(
      callFfi: (port_) {
        final serializer = SseSerializer(generalizedFrbRustBinding);
        sse_encode_box_autoadd_marquee_rect(that, serializer);
        sse_encode_box_autoadd_canvas_point(point, serializer);
        pdeCallFfi(generalizedFrbRustBinding, serializer,
            funcId: 3, port: port_);
      },
      codec: SseCodec(
        decodeSuccessData: sse_decode_bool,
        decodeErrorData: null,
      ),
      constMeta: kMarqueeRectContainsPointConstMeta,
      argValues: [that, point],
      apiImpl: this,
      hint: hint,
    ));
  }

  TaskConstMeta get kMarqueeRectContainsPointConstMeta => const TaskConstMeta(
        debugName: "MarqueeRect_contains_point",
        argNames: ["that", "point"],
      );

  @override
  Future<List<Line>> marqueeRectLines(
      {required MarqueeRect that, dynamic hint}) {
    return handler.executeNormal(NormalTask(
      callFfi: (port_) {
        final serializer = SseSerializer(generalizedFrbRustBinding);
        sse_encode_box_autoadd_marquee_rect(that, serializer);
        pdeCallFfi(generalizedFrbRustBinding, serializer,
            funcId: 4, port: port_);
      },
      codec: SseCodec(
        decodeSuccessData: sse_decode_list_line,
        decodeErrorData: null,
      ),
      constMeta: kMarqueeRectLinesConstMeta,
      argValues: [that],
      apiImpl: this,
      hint: hint,
    ));
  }

  TaskConstMeta get kMarqueeRectLinesConstMeta => const TaskConstMeta(
        debugName: "MarqueeRect_lines",
        argNames: ["that"],
      );

  @override
  Future<List<String>> getIntersectingIds(
      {required MarqueeRect rect,
      required List<Polygon> polygons,
      required List<double> matrixStorage,
      dynamic hint}) {
    return handler.executeNormal(NormalTask(
      callFfi: (port_) {
        final serializer = SseSerializer(generalizedFrbRustBinding);
        sse_encode_box_autoadd_marquee_rect(rect, serializer);
        sse_encode_list_polygon(polygons, serializer);
        sse_encode_list_prim_f_64_loose(matrixStorage, serializer);
        pdeCallFfi(generalizedFrbRustBinding, serializer,
            funcId: 2, port: port_);
      },
      codec: SseCodec(
        decodeSuccessData: sse_decode_list_String,
        decodeErrorData: null,
      ),
      constMeta: kGetIntersectingIdsConstMeta,
      argValues: [rect, polygons, matrixStorage],
      apiImpl: this,
      hint: hint,
    ));
  }

  TaskConstMeta get kGetIntersectingIdsConstMeta => const TaskConstMeta(
        debugName: "get_intersecting_ids",
        argNames: ["rect", "polygons", "matrixStorage"],
      );

  @override
  Future<bool> isTwoLinesIntersecting(
      {required Line line1, required Line line2, dynamic hint}) {
    return handler.executeNormal(NormalTask(
      callFfi: (port_) {
        final serializer = SseSerializer(generalizedFrbRustBinding);
        sse_encode_box_autoadd_line(line1, serializer);
        sse_encode_box_autoadd_line(line2, serializer);
        pdeCallFfi(generalizedFrbRustBinding, serializer,
            funcId: 1, port: port_);
      },
      codec: SseCodec(
        decodeSuccessData: sse_decode_bool,
        decodeErrorData: null,
      ),
      constMeta: kIsTwoLinesIntersectingConstMeta,
      argValues: [line1, line2],
      apiImpl: this,
      hint: hint,
    ));
  }

  TaskConstMeta get kIsTwoLinesIntersectingConstMeta => const TaskConstMeta(
        debugName: "is_two_lines_intersecting",
        argNames: ["line1", "line2"],
      );

  @override
  Future<void> initApp({dynamic hint}) {
    return handler.executeNormal(NormalTask(
      callFfi: (port_) {
        final serializer = SseSerializer(generalizedFrbRustBinding);
        pdeCallFfi(generalizedFrbRustBinding, serializer,
            funcId: 5, port: port_);
      },
      codec: SseCodec(
        decodeSuccessData: sse_decode_unit,
        decodeErrorData: null,
      ),
      constMeta: kInitAppConstMeta,
      argValues: [],
      apiImpl: this,
      hint: hint,
    ));
  }

  TaskConstMeta get kInitAppConstMeta => const TaskConstMeta(
        debugName: "init_app",
        argNames: [],
      );

  @protected
  String dco_decode_String(dynamic raw) {
    // Codec=Dco (DartCObject based), see doc to use other codecs
    return raw as String;
  }

  @protected
  bool dco_decode_bool(dynamic raw) {
    // Codec=Dco (DartCObject based), see doc to use other codecs
    return raw as bool;
  }

  @protected
  CanvasPoint dco_decode_box_autoadd_canvas_point(dynamic raw) {
    // Codec=Dco (DartCObject based), see doc to use other codecs
    return dco_decode_canvas_point(raw);
  }

  @protected
  Line dco_decode_box_autoadd_line(dynamic raw) {
    // Codec=Dco (DartCObject based), see doc to use other codecs
    return dco_decode_line(raw);
  }

  @protected
  MarqueeRect dco_decode_box_autoadd_marquee_rect(dynamic raw) {
    // Codec=Dco (DartCObject based), see doc to use other codecs
    return dco_decode_marquee_rect(raw);
  }

  @protected
  CanvasPoint dco_decode_canvas_point(dynamic raw) {
    // Codec=Dco (DartCObject based), see doc to use other codecs
    final arr = raw as List<dynamic>;
    if (arr.length != 2)
      throw Exception('unexpected arr length: expect 2 but see ${arr.length}');
    return CanvasPoint(
      x: dco_decode_f_64(arr[0]),
      y: dco_decode_f_64(arr[1]),
    );
  }

  @protected
  double dco_decode_f_64(dynamic raw) {
    // Codec=Dco (DartCObject based), see doc to use other codecs
    return raw as double;
  }

  @protected
  Line dco_decode_line(dynamic raw) {
    // Codec=Dco (DartCObject based), see doc to use other codecs
    final arr = raw as List<dynamic>;
    if (arr.length != 2)
      throw Exception('unexpected arr length: expect 2 but see ${arr.length}');
    return Line(
      p1: dco_decode_canvas_point(arr[0]),
      p2: dco_decode_canvas_point(arr[1]),
    );
  }

  @protected
  List<String> dco_decode_list_String(dynamic raw) {
    // Codec=Dco (DartCObject based), see doc to use other codecs
    return (raw as List<dynamic>).map(dco_decode_String).toList();
  }

  @protected
  List<Line> dco_decode_list_line(dynamic raw) {
    // Codec=Dco (DartCObject based), see doc to use other codecs
    return (raw as List<dynamic>).map(dco_decode_line).toList();
  }

  @protected
  List<Polygon> dco_decode_list_polygon(dynamic raw) {
    // Codec=Dco (DartCObject based), see doc to use other codecs
    return (raw as List<dynamic>).map(dco_decode_polygon).toList();
  }

  @protected
  List<double> dco_decode_list_prim_f_64_loose(dynamic raw) {
    // Codec=Dco (DartCObject based), see doc to use other codecs
    return raw as List<double>;
  }

  @protected
  Float64List dco_decode_list_prim_f_64_strict(dynamic raw) {
    // Codec=Dco (DartCObject based), see doc to use other codecs
    return raw as Float64List;
  }

  @protected
  Uint8List dco_decode_list_prim_u_8_strict(dynamic raw) {
    // Codec=Dco (DartCObject based), see doc to use other codecs
    return raw as Uint8List;
  }

  @protected
  MarqueeRect dco_decode_marquee_rect(dynamic raw) {
    // Codec=Dco (DartCObject based), see doc to use other codecs
    final arr = raw as List<dynamic>;
    if (arr.length != 4)
      throw Exception('unexpected arr length: expect 4 but see ${arr.length}');
    return MarqueeRect(
      x: dco_decode_f_64(arr[0]),
      y: dco_decode_f_64(arr[1]),
      width: dco_decode_f_64(arr[2]),
      height: dco_decode_f_64(arr[3]),
    );
  }

  @protected
  Polygon dco_decode_polygon(dynamic raw) {
    // Codec=Dco (DartCObject based), see doc to use other codecs
    final arr = raw as List<dynamic>;
    if (arr.length != 2)
      throw Exception('unexpected arr length: expect 2 but see ${arr.length}');
    return Polygon(
      id: dco_decode_String(arr[0]),
      lines: dco_decode_list_line(arr[1]),
    );
  }

  @protected
  int dco_decode_u_8(dynamic raw) {
    // Codec=Dco (DartCObject based), see doc to use other codecs
    return raw as int;
  }

  @protected
  void dco_decode_unit(dynamic raw) {
    // Codec=Dco (DartCObject based), see doc to use other codecs
    return;
  }

  @protected
  String sse_decode_String(SseDeserializer deserializer) {
    // Codec=Sse (Serialization based), see doc to use other codecs
    var inner = sse_decode_list_prim_u_8_strict(deserializer);
    return utf8.decoder.convert(inner);
  }

  @protected
  bool sse_decode_bool(SseDeserializer deserializer) {
    // Codec=Sse (Serialization based), see doc to use other codecs
    return deserializer.buffer.getUint8() != 0;
  }

  @protected
  CanvasPoint sse_decode_box_autoadd_canvas_point(
      SseDeserializer deserializer) {
    // Codec=Sse (Serialization based), see doc to use other codecs
    return (sse_decode_canvas_point(deserializer));
  }

  @protected
  Line sse_decode_box_autoadd_line(SseDeserializer deserializer) {
    // Codec=Sse (Serialization based), see doc to use other codecs
    return (sse_decode_line(deserializer));
  }

  @protected
  MarqueeRect sse_decode_box_autoadd_marquee_rect(
      SseDeserializer deserializer) {
    // Codec=Sse (Serialization based), see doc to use other codecs
    return (sse_decode_marquee_rect(deserializer));
  }

  @protected
  CanvasPoint sse_decode_canvas_point(SseDeserializer deserializer) {
    // Codec=Sse (Serialization based), see doc to use other codecs
    var var_x = sse_decode_f_64(deserializer);
    var var_y = sse_decode_f_64(deserializer);
    return CanvasPoint(x: var_x, y: var_y);
  }

  @protected
  double sse_decode_f_64(SseDeserializer deserializer) {
    // Codec=Sse (Serialization based), see doc to use other codecs
    return deserializer.buffer.getFloat64();
  }

  @protected
  Line sse_decode_line(SseDeserializer deserializer) {
    // Codec=Sse (Serialization based), see doc to use other codecs
    var var_p1 = sse_decode_canvas_point(deserializer);
    var var_p2 = sse_decode_canvas_point(deserializer);
    return Line(p1: var_p1, p2: var_p2);
  }

  @protected
  List<String> sse_decode_list_String(SseDeserializer deserializer) {
    // Codec=Sse (Serialization based), see doc to use other codecs

    var len_ = sse_decode_i_32(deserializer);
    var ans_ = <String>[];
    for (var idx_ = 0; idx_ < len_; ++idx_) {
      ans_.add(sse_decode_String(deserializer));
    }
    return ans_;
  }

  @protected
  List<Line> sse_decode_list_line(SseDeserializer deserializer) {
    // Codec=Sse (Serialization based), see doc to use other codecs

    var len_ = sse_decode_i_32(deserializer);
    var ans_ = <Line>[];
    for (var idx_ = 0; idx_ < len_; ++idx_) {
      ans_.add(sse_decode_line(deserializer));
    }
    return ans_;
  }

  @protected
  List<Polygon> sse_decode_list_polygon(SseDeserializer deserializer) {
    // Codec=Sse (Serialization based), see doc to use other codecs

    var len_ = sse_decode_i_32(deserializer);
    var ans_ = <Polygon>[];
    for (var idx_ = 0; idx_ < len_; ++idx_) {
      ans_.add(sse_decode_polygon(deserializer));
    }
    return ans_;
  }

  @protected
  List<double> sse_decode_list_prim_f_64_loose(SseDeserializer deserializer) {
    // Codec=Sse (Serialization based), see doc to use other codecs
    var len_ = sse_decode_i_32(deserializer);
    return deserializer.buffer.getFloat64List(len_);
  }

  @protected
  Float64List sse_decode_list_prim_f_64_strict(SseDeserializer deserializer) {
    // Codec=Sse (Serialization based), see doc to use other codecs
    var len_ = sse_decode_i_32(deserializer);
    return deserializer.buffer.getFloat64List(len_);
  }

  @protected
  Uint8List sse_decode_list_prim_u_8_strict(SseDeserializer deserializer) {
    // Codec=Sse (Serialization based), see doc to use other codecs
    var len_ = sse_decode_i_32(deserializer);
    return deserializer.buffer.getUint8List(len_);
  }

  @protected
  MarqueeRect sse_decode_marquee_rect(SseDeserializer deserializer) {
    // Codec=Sse (Serialization based), see doc to use other codecs
    var var_x = sse_decode_f_64(deserializer);
    var var_y = sse_decode_f_64(deserializer);
    var var_width = sse_decode_f_64(deserializer);
    var var_height = sse_decode_f_64(deserializer);
    return MarqueeRect(
        x: var_x, y: var_y, width: var_width, height: var_height);
  }

  @protected
  Polygon sse_decode_polygon(SseDeserializer deserializer) {
    // Codec=Sse (Serialization based), see doc to use other codecs
    var var_id = sse_decode_String(deserializer);
    var var_lines = sse_decode_list_line(deserializer);
    return Polygon(id: var_id, lines: var_lines);
  }

  @protected
  int sse_decode_u_8(SseDeserializer deserializer) {
    // Codec=Sse (Serialization based), see doc to use other codecs
    return deserializer.buffer.getUint8();
  }

  @protected
  void sse_decode_unit(SseDeserializer deserializer) {
    // Codec=Sse (Serialization based), see doc to use other codecs
  }

  @protected
  int sse_decode_i_32(SseDeserializer deserializer) {
    // Codec=Sse (Serialization based), see doc to use other codecs
    return deserializer.buffer.getInt32();
  }

  @protected
  void sse_encode_String(String self, SseSerializer serializer) {
    // Codec=Sse (Serialization based), see doc to use other codecs
    sse_encode_list_prim_u_8_strict(utf8.encoder.convert(self), serializer);
  }

  @protected
  void sse_encode_bool(bool self, SseSerializer serializer) {
    // Codec=Sse (Serialization based), see doc to use other codecs
    serializer.buffer.putUint8(self ? 1 : 0);
  }

  @protected
  void sse_encode_box_autoadd_canvas_point(
      CanvasPoint self, SseSerializer serializer) {
    // Codec=Sse (Serialization based), see doc to use other codecs
    sse_encode_canvas_point(self, serializer);
  }

  @protected
  void sse_encode_box_autoadd_line(Line self, SseSerializer serializer) {
    // Codec=Sse (Serialization based), see doc to use other codecs
    sse_encode_line(self, serializer);
  }

  @protected
  void sse_encode_box_autoadd_marquee_rect(
      MarqueeRect self, SseSerializer serializer) {
    // Codec=Sse (Serialization based), see doc to use other codecs
    sse_encode_marquee_rect(self, serializer);
  }

  @protected
  void sse_encode_canvas_point(CanvasPoint self, SseSerializer serializer) {
    // Codec=Sse (Serialization based), see doc to use other codecs
    sse_encode_f_64(self.x, serializer);
    sse_encode_f_64(self.y, serializer);
  }

  @protected
  void sse_encode_f_64(double self, SseSerializer serializer) {
    // Codec=Sse (Serialization based), see doc to use other codecs
    serializer.buffer.putFloat64(self);
  }

  @protected
  void sse_encode_line(Line self, SseSerializer serializer) {
    // Codec=Sse (Serialization based), see doc to use other codecs
    sse_encode_canvas_point(self.p1, serializer);
    sse_encode_canvas_point(self.p2, serializer);
  }

  @protected
  void sse_encode_list_String(List<String> self, SseSerializer serializer) {
    // Codec=Sse (Serialization based), see doc to use other codecs
    sse_encode_i_32(self.length, serializer);
    for (final item in self) {
      sse_encode_String(item, serializer);
    }
  }

  @protected
  void sse_encode_list_line(List<Line> self, SseSerializer serializer) {
    // Codec=Sse (Serialization based), see doc to use other codecs
    sse_encode_i_32(self.length, serializer);
    for (final item in self) {
      sse_encode_line(item, serializer);
    }
  }

  @protected
  void sse_encode_list_polygon(List<Polygon> self, SseSerializer serializer) {
    // Codec=Sse (Serialization based), see doc to use other codecs
    sse_encode_i_32(self.length, serializer);
    for (final item in self) {
      sse_encode_polygon(item, serializer);
    }
  }

  @protected
  void sse_encode_list_prim_f_64_loose(
      List<double> self, SseSerializer serializer) {
    // Codec=Sse (Serialization based), see doc to use other codecs
    sse_encode_i_32(self.length, serializer);
    serializer.buffer.putFloat64List(
        self is Float64List ? self : Float64List.fromList(self));
  }

  @protected
  void sse_encode_list_prim_f_64_strict(
      Float64List self, SseSerializer serializer) {
    // Codec=Sse (Serialization based), see doc to use other codecs
    sse_encode_i_32(self.length, serializer);
    serializer.buffer.putFloat64List(self);
  }

  @protected
  void sse_encode_list_prim_u_8_strict(
      Uint8List self, SseSerializer serializer) {
    // Codec=Sse (Serialization based), see doc to use other codecs
    sse_encode_i_32(self.length, serializer);
    serializer.buffer.putUint8List(self);
  }

  @protected
  void sse_encode_marquee_rect(MarqueeRect self, SseSerializer serializer) {
    // Codec=Sse (Serialization based), see doc to use other codecs
    sse_encode_f_64(self.x, serializer);
    sse_encode_f_64(self.y, serializer);
    sse_encode_f_64(self.width, serializer);
    sse_encode_f_64(self.height, serializer);
  }

  @protected
  void sse_encode_polygon(Polygon self, SseSerializer serializer) {
    // Codec=Sse (Serialization based), see doc to use other codecs
    sse_encode_String(self.id, serializer);
    sse_encode_list_line(self.lines, serializer);
  }

  @protected
  void sse_encode_u_8(int self, SseSerializer serializer) {
    // Codec=Sse (Serialization based), see doc to use other codecs
    serializer.buffer.putUint8(self);
  }

  @protected
  void sse_encode_unit(void self, SseSerializer serializer) {
    // Codec=Sse (Serialization based), see doc to use other codecs
  }

  @protected
  void sse_encode_i_32(int self, SseSerializer serializer) {
    // Codec=Sse (Serialization based), see doc to use other codecs
    serializer.buffer.putInt32(self);
  }
}