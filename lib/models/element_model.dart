// ignore_for_file: public_member_api_docs

import 'package:editicert/util/geometry.dart';
import 'package:editicert/util/utils.dart';
import 'package:flutter/material.dart';

class ElementModel {
  ElementModel() {
    id = uuid.v4();
    parentId = '';
    childId = '';
    name = '';
    data = ElementData(
      name: '',
      shadow: [],
      border: const Border(),
      borderRadius: BorderRadius.zero,
      color: Colors.grey,
      hidden: false,
      locked: false,
      type: ElementType.shape,
    );
    transform = Box.fromRect(const Rect.fromLTWH(0, 0, 100, 100));
    textController = TextEditingController();
  }

  late String id;
  late String parentId;
  late String childId;
  late String name;
  late Box transform;
  Box? initialTransform;
  late ElementData data;
  late TextEditingController? textController;
}

class ElementData {
  ElementData({
    required this.name,
    required this.shadow,
    required this.border,
    required this.borderRadius,
    required this.color,
    required this.type,
    required this.hidden,
    required this.locked,
  });

  String name;
  List<BoxShadow> shadow;
  Border border;
  BorderRadius borderRadius;
  Color color;
  ElementType type;
  bool hidden;
  bool locked;
}

enum ElementType { frame, text, image, shape }
