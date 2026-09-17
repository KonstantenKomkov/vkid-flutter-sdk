package com.vk.vkid.flutter.vkid_flutter_sdk_example

import android.annotation.SuppressLint
import android.content.ComponentName
import android.content.Context
import android.content.pm.ActivityInfo
import android.content.pm.PackageManager
import android.content.pm.PackageManager.ComponentInfoFlags
import android.os.Build
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

/** VkidFlutterSdkUtilsPlugin */
class VkidFlutterSdkUtilsPlugin : FlutterPlugin, MethodCallHandler {
    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    private lateinit var channel: MethodChannel
    private lateinit var context: Context

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "com.vk.id/vkidutils")
        channel.setMethodCallHandler(this)
        context = flutterPluginBinding.applicationContext
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        if (call.method == "getClientId") {
            result.success(getActivityInfo(context).metaData.getInt("VKIDClientID").toString())
        }
    }

    @SuppressLint("WrongConstant")
    private fun getActivityInfo(context: Context): ActivityInfo {
        val componentName = ComponentName(context, Class.forName("com.vk.id.internal.auth.AuthActivity"))
        val flags = PackageManager.GET_META_DATA or PackageManager.GET_ACTIVITIES
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            context.packageManager.getActivityInfo(componentName, ComponentInfoFlags.of(flags.toLong()))
        } else {
            context.packageManager.getActivityInfo(componentName, flags)
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }
}
