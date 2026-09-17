import Flutter

class VkidFlutterSdkUtilsPlugin: NSObject, FlutterPlugin {
    private static let clientId = {
        guard let infoPlistClientId = Bundle.main.infoDictionary?["VK_APP_CLIENT_ID"] as? String,
        !infoPlistClientId.isEmpty, infoPlistClientId != "YOUR_CLIENT_ID" else {
            preconditionFailure("Info.plist does not contain correct value for VK_APP_CLIENT_ID key")
        }
        return infoPlistClientId
    }()

    static func register(with registrar: any FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "com.vk.id/vkidutils", binaryMessenger: registrar.messenger())
        let instance = VkidFlutterSdkUtilsPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "getClientId":
            result(VkidFlutterSdkUtilsPlugin.clientId)
        default:
            result(FlutterMethodNotImplemented)
        }
    }
}


