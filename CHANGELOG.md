## Unreleased

### Added
- Opt-in Android One Tap composition modes, including a Virtual Display workaround for stale Compose personalization.
- Standalone Android rendering reproduction comparing texture-layer, hybrid and Virtual Display composition.

### Fixed
- Keep the Android One Tap profile when returning from cancelled authorization, instead of fetching and animating it on every Activity resume.
- Release One Tap callback handlers on disposal and ignore redundant native height updates.

### Changed
- Migrated Android plugin and sample Maven repositories to VK Nexus (`https://nexus-external.vkteam.ru/repository/maven/`).
- Migrated to AGP 9 built-in Kotlin: the plugin no longer applies the Kotlin Gradle Plugin.
- Minimum supported SDK is Flutter 3.44 / Dart 3.12.

## 1.0.3
- Support for vk.ru
- Support of horizontal `OneTapBottomSheet`
- Updated VKID Android SDK to 2.6.0
- Updated VKID iOS SDK to 2.9.2

## 1.0.2

### Fixed
- Fixed crash caused by uninitilized context.

### Changed
- Kotlin version updated to 2.0.20.

## 1.0.1

### Added
- Added support for obfuscation on Flutter side.

### Fixed
- Fixed crash when accessing VKID.currentAuthData on iOS, now it returns actual auth data instead.
- Fixed getting user data after authorization, now you can get new values in callback.

## 1.0.0

### Added
- [Multibranding](https://id.vk.ru/about/business/go/docs/en/vkid/latest/vk-id/connection/elements/widget-3-1/three-in-one-flutter).

### Changed
 - Added SizedBox wrapper for bottom sheet.

## 1.0.0-alpha.2

### Changed
- Updated version requirement for Dart SDK.

## 1.0.0-alpha.1

### Changed
- Updated VK ID icon in README.md.

## 1.0.0-alpha

### Added
- [One Tap button](https://id.vk.ru/about/business/go/docs/en/vkid/latest/vk-id/connection/elements/onetap-button/onetap-flutter)
- [One Tap popup](https://id.vk.ru/about/business/go/docs/en/vkid/latest/vk-id/connection/elements/onetap-drawer/floating-onetap-flutter)
- [Basic auth](https://id.vk.ru/about/business/go/docs/en/vkid/latest/vk-id/connection/elements/custom-button/custom-button-flutter)
