// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'component.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$canvasTransformHash() => r'5ce65bc7f824bfe4de113e78ee33eaa013ed7fab';

/// See also [canvasTransform].
@ProviderFor(canvasTransform)
final canvasTransformProvider = AutoDisposeProvider<Matrix4>.internal(
  canvasTransform,
  name: r'canvasTransformProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$canvasTransformHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef CanvasTransformRef = AutoDisposeProviderRef<Matrix4>;
String _$componentsHash() => r'960ee645bf083f66e4753e3cd1cc6eac09249f8e';

/// See also [Components].
@ProviderFor(Components)
final componentsProvider =
    AutoDisposeNotifierProvider<Components, List<ComponentData>>.internal(
  Components.new,
  name: r'componentsProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$componentsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$Components = AutoDisposeNotifier<List<ComponentData>>;
String _$keysHash() => r'7b6effe0574f4369547330a966d4566095d68373';

/// See also [Keys].
@ProviderFor(Keys)
final keysProvider =
    AutoDisposeNotifierProvider<Keys, Set<PhysicalKeyboardKey>>.internal(
  Keys.new,
  name: r'keysProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$keysHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$Keys = AutoDisposeNotifier<Set<PhysicalKeyboardKey>>;
String _$selectedHash() => r'ba038842de4461d31b7ed70c316435834b147be7';

/// See also [Selected].
@ProviderFor(Selected)
final selectedProvider =
    AutoDisposeNotifierProvider<Selected, Set<int>>.internal(
  Selected.new,
  name: r'selectedProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$selectedHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$Selected = AutoDisposeNotifier<Set<int>>;
String _$hoveredHash() => r'6e99f7abcfcfb0626b27e23e0f832bfa27e53a1f';

/// See also [Hovered].
@ProviderFor(Hovered)
final hoveredProvider = AutoDisposeNotifierProvider<Hovered, Set<int>>.internal(
  Hovered.new,
  name: r'hoveredProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$hoveredHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$Hovered = AutoDisposeNotifier<Set<int>>;
String _$toolHash() => r'727281369b2ea85070f6d30e8a614934e8d12e8e';

/// See also [Tool].
@ProviderFor(Tool)
final toolProvider = AutoDisposeNotifierProvider<Tool, ToolData>.internal(
  Tool.new,
  name: r'toolProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$toolHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$Tool = AutoDisposeNotifier<ToolData>;
String _$transformationControllerDataHash() =>
    r'5e490ff2d2f7e0d48187401663236fe196941602';

/// See also [TransformationControllerData].
@ProviderFor(TransformationControllerData)
final transformationControllerDataProvider = AutoDisposeNotifierProvider<
    TransformationControllerData, TransformationController>.internal(
  TransformationControllerData.new,
  name: r'transformationControllerDataProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$transformationControllerDataHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$TransformationControllerData
    = AutoDisposeNotifier<TransformationController>;
// ignore_for_file: unnecessary_raw_strings, subtype_of_sealed_class, invalid_use_of_internal_member, do_not_use_environment, prefer_const_constructors, public_member_api_docs, avoid_private_typedef_functions
