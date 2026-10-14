package com.vk.vkid.flutter.vkid_flutter_sdk.onetap

import android.content.Context
import android.view.SurfaceView
import android.view.View
import android.widget.FrameLayout
import androidx.lifecycle.findViewTreeLifecycleOwner
import androidx.lifecycle.findViewTreeViewModelStoreOwner
import androidx.lifecycle.setViewTreeLifecycleOwner
import androidx.lifecycle.setViewTreeViewModelStoreOwner
import androidx.savedstate.findViewTreeSavedStateRegistryOwner
import androidx.savedstate.setViewTreeSavedStateRegistryOwner
import io.flutter.plugin.platform.PlatformView

/// Gives Compose its own Android rendering target while Flutter composites the resulting texture.
/// TLHC redirects draw() to another canvas and leaves VK's asynchronous content stale on some
/// devices. Virtual Display renders the complete native tree, including updated Compose layers.
internal class OneTapVirtualDisplayPlatformView(
    context: Context,
    private val delegate: PlatformView,
) : PlatformView, View.OnAttachStateChangeListener {
    private val container: FrameLayout = FrameLayout(context)

    init {
        container.addOnAttachStateChangeListener(this)
        // Flutter's initAndroidView selects Virtual Display for trees containing a SurfaceView.
        // There is no Dart flag to select VD directly. This invisible marker allocates no surface;
        // keep initAndroidView (not initSurfaceAndroidView, whose fallback is Hybrid Composition).
        container.addView(SurfaceView(context).apply { visibility = View.GONE }, FrameLayout.LayoutParams(0, 0))
        // Cache getView(): the VK plugin calls setContent() every time that method is invoked.
        container.addView(delegate.view, FrameLayout.LayoutParams(
            FrameLayout.LayoutParams.MATCH_PARENT,
            FrameLayout.LayoutParams.MATCH_PARENT,
        ))
    }

    override fun getView(): View = container

    override fun onViewAttachedToWindow(view: View) {
        // Compose creates its window Recomposer above our container, at the Presentation's
        // content root. That root also needs owners before Compose's children are attached.
        view.rootView.setViewTreeLifecycleOwner(view.findViewTreeLifecycleOwner())
        view.rootView.setViewTreeSavedStateRegistryOwner(view.findViewTreeSavedStateRegistryOwner())
        view.rootView.setViewTreeViewModelStoreOwner(view.findViewTreeViewModelStoreOwner())
    }

    override fun onViewDetachedFromWindow(view: View) = Unit

    override fun onFlutterViewAttached(flutterView: View) {
        // A Presentation has no Activity view-tree owners. Share the Flutter host's owners so
        // Compose observes the real Activity lifecycle and can save state across configuration changes.
        container.setViewTreeLifecycleOwner(flutterView.findViewTreeLifecycleOwner())
        container.setViewTreeSavedStateRegistryOwner(flutterView.findViewTreeSavedStateRegistryOwner())
        container.setViewTreeViewModelStoreOwner(flutterView.findViewTreeViewModelStoreOwner())
        delegate.onFlutterViewAttached(flutterView)
    }

    override fun onFlutterViewDetached() {
        delegate.onFlutterViewDetached()
        container.setViewTreeLifecycleOwner(null)
        container.setViewTreeSavedStateRegistryOwner(null)
        container.setViewTreeViewModelStoreOwner(null)
    }

    override fun onInputConnectionLocked() = delegate.onInputConnectionLocked()

    override fun onInputConnectionUnlocked() = delegate.onInputConnectionUnlocked()

    override fun dispose() {
        container.removeOnAttachStateChangeListener(this)
        container.removeAllViews()
        delegate.dispose()
        container.setViewTreeLifecycleOwner(null)
        container.setViewTreeSavedStateRegistryOwner(null)
        container.setViewTreeViewModelStoreOwner(null)
    }
}
