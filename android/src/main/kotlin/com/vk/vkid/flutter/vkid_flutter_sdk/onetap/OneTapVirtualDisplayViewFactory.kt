package com.vk.vkid.flutter.vkid_flutter_sdk.onetap

import android.content.Context
import android.content.MutableContextWrapper
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory

internal class OneTapVirtualDisplayViewFactory(
    binaryMessenger: BinaryMessenger,
) : PlatformViewFactory(StandardMessageCodec.INSTANCE) {
    private val delegate = OneTapViewFactory(binaryMessenger)

    override fun create(context: Context, viewId: Int, args: Any?): PlatformView {
        // Flutter replaces the outer context with a Presentation context. Keep
        // the Activity context for VK's authentication UI and theme resolution.
        val authContext = (context as? MutableContextWrapper)?.baseContext ?: context
        return OneTapVirtualDisplayPlatformView(context, delegate.create(authContext, viewId, args))
    }
}
