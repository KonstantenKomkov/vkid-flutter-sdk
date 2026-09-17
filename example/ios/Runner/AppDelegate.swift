import Flutter
import UIKit
@_spi(VKIDFlutterDebug) import vkid_flutter_sdk

@main
@objc class AppDelegate: FlutterAppDelegate {
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        VkidFlutterSdkPlugin.sslPinningEnabled = false
        GeneratedPluginRegistrant.register(with: self)
        guard let pluginRegistrar = self.registrar(forPlugin: "VkidFlutterSdkUtilsPlugin") else {
            return false
        }
        VkidFlutterSdkUtilsPlugin.register(with: pluginRegistrar)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    override func application(
        _ app: UIApplication,
        open url: URL,
        options: [UIApplication.OpenURLOptionsKey : Any] = [:]
    ) -> Bool {
        return VkidFlutterSdkPlugin.vkid.open(url: url)
    }
}
