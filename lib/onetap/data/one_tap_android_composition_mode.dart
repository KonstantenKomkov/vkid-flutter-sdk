part of '../../library_vkid.dart';

/// How Android renders One Tap inside the Flutter scene.
enum OneTapAndroidCompositionMode {
  /// Flutter's default texture-layer composition. Supports Flutter transforms,
  /// but some devices can show stale Compose content after user fetching.
  textureLayer,

  /// A native view in the Activity window. Useful for comparison, but Flutter
  /// image filters (including stretching overscroll) do not apply to this layer.
  hybrid,

  /// An Android virtual display composited as a Flutter texture. Opt-in
  /// workaround for stale Compose rendering, with an additional display cost.
  virtualDisplay,
}
