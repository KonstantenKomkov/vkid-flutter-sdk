# Android One Tap rendering reproduction

A standalone Flutter app with one scroll view, one Flutter reference button and
one real VK One Tap button. No application backend, BLoC, routing or authentication
code exchange is involved. Native login taps are disabled; the SDK still performs
its normal fast-auth user lookup to personalize the button.

The three buttons at the top select:

| Mode | Native integration | What to compare |
| --- | --- | --- |
| TLHC | Existing `AndroidView` / `OneTap` factory | Does the initial picture remain after user lookup? |
| HC | `initExpensiveAndroidView` / same factory | Does the avatar appear, but the button ignore overscroll stretch? |
| VD | `AndroidView` / `OneTapVirtualDisplay` factory | Do personalization and Flutter overscroll both work? |

The mode change recreates only One Tap (a new key). `Recreate button` recreates it
in the same mode, so a second fetch/attach cycle can be checked without restarting
VK ID in the process. The default is TLHC, preserving the original reproduction.

## Run

Requirements: Flutter 3.47.4 / Dart 3.13.3 (the root `.fvmrc` pins the tested
version), JDK 17, Android SDK, and an Android device with a signed-in VK account
that can be found by VK ID fast auth. Check HC first: if **none** of the modes
shows an avatar, profile lookup is not working and this is not evidence of the
rendering defect.

From this directory:

```sh
fvm flutter pub get
```

Add your VK application settings to `android/local.properties` (ignored by Git):

```properties
VKIDClientID=YOUR_CLIENT_ID
VKIDClientSecret=YOUR_CLIENT_SECRET
```

Register the sample's package `com.example.vkid.one_tap_rendering` and signing
certificate with the VK application, or configure a registered application
identity using these optional local properties:

```properties
VKIDApplicationID=YOUR_REGISTERED_PACKAGE
VKIDStoreFile=/absolute/path/to/your/keystore
VKIDStorePassword=YOUR_STORE_PASSWORD
VKIDKeyAlias=YOUR_KEY_ALIAS
VKIDKeyPassword=YOUR_KEY_PASSWORD
```

The custom signing configuration applies to release builds. By default the
sample uses the Android debug key. Use a separate VK application/package for a
persistent demo installation. An APK with an existing application's package and
signing identity replaces that application; back up its APK and restore it after
an in-place reproduction, without clearing its data.

```sh
fvm flutter run --release -d DEVICE_ID
# Or build/install separately; choose a suitable version code if replacing an existing APK:
fvm flutter build apk --release --build-number=VERSION_CODE
```

Credentials and keystores must stay local. Do not attach an APK containing your
credentials to a public issue. The source is sufficient to reproduce with the
maintainer's own VK application.

## Reproduction steps

1. Start in **TLHC**, wait for fast-auth lookup to complete. Compare the visible
   caption/avatar with HC under the same account and client configuration.
2. Pull down while already at the scroll view's top. Compare the movement/stretch
   of the purple Flutter reference button and the blue native button.
3. Select **HC**, wait for personalization, repeat the pull. The buttons should
   occupy the same scroll view, but the native HC layer does not get Flutter's
   stretching image filter.
4. Select **VD**, wait for personalization, repeat the pull. The native button
   should update and stretch with the Flutter content.
5. Scroll the buttons off-screen and back. Press `Recreate button`. Background
   and resume the app. Check that the VD button still renders and no native
   lifecycle exception occurs.

For additional evidence, inspect Android accessibility while TLHC is selected:

```sh
adb -s DEVICE_ID shell uiautomator dump /sdcard/one-tap.xml
adb -s DEVICE_ID pull /sdcard/one-tap.xml
```

A personalized caption in accessibility alongside the initial visible caption
helps distinguish stale pixels from a failed profile lookup. Do not publish
account names, avatars or full authentication logs without redaction.

## Using the workaround in another app

```dart
OneTap(
  key: const ValueKey('one-tap'),
  androidCompositionMode: OneTapAndroidCompositionMode.virtualDisplay,
  signInToAnotherAccountButtonEnabled: false,
  onAuth: (provider, data) {
    // Handle authentication as before.
  },
)
```

The default remains `textureLayer`; iOS ignores this option. Text, font sizing,
VK ID account lookup and authentication callbacks are unchanged. If the SDK
chooses a short caption because the full name does not fit, that is a separate,
normal SDK behavior.
