// ignore_for_file: public_member_api_docs, prefer-match-file-name

part of '../event_handler_bloc.dart';

class ZoomCanvasEvent extends EventHandlerEvent {
  ZoomCanvasEvent(this.scale, this.localFocalPoint);

  final double scale;
  final Offset localFocalPoint;
}
