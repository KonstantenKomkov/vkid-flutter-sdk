import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'vkid_flutter_sdk_method_channel.dart';

abstract class VkidFlutterSdkPlatform extends PlatformInterface {
  /// Constructs a VkidFlutterSdkPlatform.
  VkidFlutterSdkPlatform() : super(token: _token);

  static final Object _token = Object();

  static VkidFlutterSdkPlatform _instance = MethodChannelVkidFlutterSdk();

  /// The default instance of [VkidFlutterSdkPlatform] to use.
  ///
  /// Defaults to [MethodChannelVkidFlutterSdk].
  static VkidFlutterSdkPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [VkidFlutterSdkPlatform] when
  /// they register themselves.
  static set instance(VkidFlutterSdkPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getClientID() {
    throw UnimplementedError('getClientId() has not been implemented.');
  }
}
