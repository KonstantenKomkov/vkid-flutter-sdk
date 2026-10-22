package com.vk.vkid.flutter.vkid_flutter_sdk.onetap

import android.os.Build
import android.os.Handler
import android.os.Looper
import android.view.View
import android.view.ViewTreeObserver
import io.flutter.plugin.common.MethodChannel

/** Acknowledges a frame submitted by the restored Virtual Display window. */
internal class OneTapSurfaceFrame(private val view: View) : View.OnAttachStateChangeListener {
    private val handler = Handler(Looper.getMainLooper())
    private var result: MethodChannel.Result? = null
    private var observer: ViewTreeObserver? = null
    private var commitCallback: Runnable? = null
    private var drawListener: ViewTreeObserver.OnDrawListener? = null
    private var generation = 0
    private val timeout = Runnable { finish(false) }

    fun awaitFrame(result: MethodChannel.Result) {
        finish(false)
        this.result = result
        view.addOnAttachStateChangeListener(this)
        handler.postDelayed(timeout, 1500)
        if (view.isAttachedToWindow) observeFrame()
    }

    override fun onViewAttachedToWindow(view: View) = observeFrame()

    override fun onViewDetachedFromWindow(view: View) = clearObserver()

    private fun observeFrame() {
        clearObserver()
        val currentObserver = view.viewTreeObserver
        observer = currentObserver
        val currentGeneration = generation
        if (Build.VERSION.SDK_INT >= 29 && view.isHardwareAccelerated) {
            val callback = Runnable {
                handler.post { if (currentGeneration == generation) finish(true) }
            }
            commitCallback = callback
            currentObserver.registerFrameCommitCallback(callback)
        } else {
            // Older Android has no frame-commit API. Wait for draw and a further
            // vsync; never remove an OnDrawListener from inside its callback.
            val listener = ViewTreeObserver.OnDrawListener {
                view.postOnAnimation { if (currentGeneration == generation) finish(true) }
            }
            drawListener = listener
            currentObserver.addOnDrawListener(listener)
        }
        view.invalidate()
    }

    private fun clearObserver() {
        generation++
        observer?.takeIf { it.isAlive }?.let { current ->
            if (Build.VERSION.SDK_INT >= 29) {
                commitCallback?.let { current.unregisterFrameCommitCallback(it) }
            }
            drawListener?.let { current.removeOnDrawListener(it) }
        }
        observer = null
        commitCallback = null
        drawListener = null
    }

    private fun finish(drawn: Boolean) {
        clearObserver()
        handler.removeCallbacks(timeout)
        view.removeOnAttachStateChangeListener(this)
        val pending = result
        result = null
        if (drawn) pending?.success(null)
        else pending?.error("frame_unavailable", "One Tap surface has no committed frame", null)
    }

    fun dispose() = finish(false)
}
