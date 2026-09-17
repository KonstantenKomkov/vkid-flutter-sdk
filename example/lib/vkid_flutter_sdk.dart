import 'vkid_flutter_sdk_platform_interface.dart';

class VkidFlutterSdk {
  Future<String?> getClientID() {
    return VkidFlutterSdkPlatform.instance.getClientID();
  }
}
