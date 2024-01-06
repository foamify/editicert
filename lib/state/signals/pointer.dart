part of '../state.dart';

/// Pointer buttons, see [kMiddleMouseButton] and the like;
final pointerButton = signal(0);

/// The initial position of the pointer
/// Used for calculating the delta during operations
final pointerPositionInitial = signal(Vector2.zero());

/// The current position of the pointer
/// Used for calculating the delta during operations
final pointerPositionCurrent = signal(Vector2.zero());
