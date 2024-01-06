import 'package:collection/collection.dart';
import 'package:editicert/models/canvas_data.dart';
import 'package:editicert/models/element_model.dart';
import 'package:editicert/models/snap_line.dart';
import 'package:editicert/util/constants.dart';
import 'package:editicert/util/extensions.dart';
import 'package:editicert/util/geometry.dart';
import 'package:editicert/util/utils.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart' hide Colors;
import 'package:flutter/services.dart';
import 'package:signals/signals_flutter.dart';
import 'package:vector_math/vector_math_64.dart';

part 'signal_state.dart';
part 'signals/canvas.dart';
part 'signals/pointer.dart';
part 'signals/marquee.dart';
