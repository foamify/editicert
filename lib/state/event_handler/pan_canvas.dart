// ignore_for_file: public_member_api_docs, prefer-match-file-name

part of '../event_handler_bloc.dart';

class PanCanvasInitial extends EventHandlerEvent {
  PanCanvasInitial();
}

class PanCanvasEvent extends EventHandlerEvent {
  PanCanvasEvent(this.offset);

  final Offset offset;
}

class PanCanvasEnd extends PanCanvasInitial {
  PanCanvasEnd();
}
