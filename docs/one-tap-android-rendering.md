# One Tap Android composition workaround

`OneTap` and `OneTap.withOAuths` accept `androidCompositionMode`:

- `textureLayer` preserves the existing `AndroidView` behavior.
- `hybrid` uses Flutter's expensive native composition, primarily useful for
  diagnosis when texture-layer rendering is stale.
- `virtualDisplay` opts into a workaround that preserves both native Compose
  rendering and Flutter texture transforms.

See the [standalone reproduction](../examples/one_tap_rendering/README.md).

## Implementation

The new native factory delegates to the same `OneTapViewFactory`; authentication
parameters, method-channel names, callbacks and VK styling are unchanged. The
library can call its internal factory directly, unlike an application-level Java
bridge to the plugin's Kotlin-internal class.

Flutter does not expose a Dart flag to explicitly request Virtual Display.
`initAndroidView` (used by `AndroidView`) falls back to VD for a native hierarchy
containing a `SurfaceView`. The wrapper contains a `GONE`, zero-size SurfaceView
marker, which allocates no separate surface. Do not use `initSurfaceAndroidView`
here: that controller chooses HC as its fallback. This implementation detail is
verified against Flutter 3.47.4 and should be rechecked on engine upgrades.

The outer FrameLayout retains the mutable context Flutter supplies for its
Presentation. The inner VK view keeps the original Activity context for theme
and auth UI resolution. The wrapper caches the delegate view because the current
plugin calls Compose `setContent` on every `getView()`.

A Presentation lacks Activity view-tree owners. The wrapper propagates the host's
lifecycle, saved-state and ViewModelStore owners to the container and, on attach,
to the Presentation root **before** attaching Compose descendants. Setting owners
only on the container is insufficient: Compose's window Recomposer searches
above it at the window content root and otherwise throws
`ViewTreeLifecycleOwner not found`.

The wrapper delegates platform-view lifecycle/input hooks and removes its content
on dispose. Dart removes the corresponding callback handler on dispose and avoids
redundant `onHeight` rebuilds. Tests cover mode selection, backward-compatible
defaults, iOS behavior, OAuth parameters, auth-code forwarding and late callbacks.

## Validation

Reproduced on a physical Huawei CLT-L29, Android 10 / API 29, with Flutter
3.47.4 / Dart 3.13.3, VK ID Android SDK 2.6.0 and Compose UI 1.7.4:

| Mode | Observed personalization |
| --- | --- |
| Texture layer | Pixels remain `Войти с VK ID` without an avatar; Android accessibility already reports `Продолжить`. |
| Hybrid | Avatar and personalized caption become visible. |
| Virtual Display | Avatar and personalized caption become visible, including after recreation and background/resume. |

The standalone sample also exercises scrolling off-screen and back and pulling
past the scroll boundary. The full display name is not asserted: the native SDK
may shorten its caption to fit the available width. Font and caption sizing are
not modified by this workaround.

Seven library widget tests pass. The sample analyzes cleanly and builds in debug
and release. Library analysis reports only existing `prefer_initializing_formals`
infos. The release sample keeps `com.vk.dto.common.id.UserId`, as the original SDK
example does, so R8 does not break the fast-auth Parcelable lookup.

## Scope and limitations

VD adds a native display/render target and is opt-in. This change does not prove
whether the original stale-pixel defect belongs to the Flutter engine, Compose,
the VK Android SDK, or their interaction. A VK-independent Compose reproduction
would be required before assigning the root cause to Flutter/Compose upstream.
The different HC overscroll behavior is a separate composition limitation.

Rendering and lifecycle checks do not constitute a completed authentication-flow
test. The reproduction intentionally disables login taps and does not exchange
codes or tokens. iOS composition is unchanged and is covered at widget-test level,
not by a physical iOS-device run.
