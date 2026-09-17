import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'vkid_flutter_sdk_platform_interface.dart';

/// An implementation of [VkidFlutterSdkPlatform] that uses method channels.
class MethodChannelVkidFlutterSdk extends VkidFlutterSdkPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('com.vk.id/vkidutils');

  @override
  Future<String?> getClientID() async {
    final clientID = await methodChannel.invokeMethod<String>('getClientId');
    return clientID;
  }
}
