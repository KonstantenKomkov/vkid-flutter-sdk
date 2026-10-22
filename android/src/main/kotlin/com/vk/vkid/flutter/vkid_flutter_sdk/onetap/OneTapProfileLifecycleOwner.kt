package com.vk.vkid.flutter.vkid_flutter_sdk.onetap

import androidx.lifecycle.Lifecycle
import androidx.lifecycle.LifecycleEventObserver
import androidx.lifecycle.LifecycleOwner
import androidx.lifecycle.LifecycleRegistry

/**
 * One Tap 2.6 fetches and animates its profile on every ON_RESUME. Keep that profile for the
 * lifetime of the mounted button. This owner is provided only to the One Tap composition;
 * the window Recomposer and VK authorization still use the real Activity lifecycle.
 */
internal class OneTapProfileLifecycleOwner : LifecycleOwner, LifecycleEventObserver {
    private val registry = LifecycleRegistry(this)
    private var hasResumed = false

    override val lifecycle: Lifecycle = registry

    override fun onStateChanged(source: LifecycleOwner, event: Lifecycle.Event) {
        if (registry.currentState == Lifecycle.State.DESTROYED) return
        if (event == Lifecycle.Event.ON_DESTROY) {
            dispose()
        } else if (!hasResumed) {
            hasResumed = event == Lifecycle.Event.ON_RESUME
            registry.handleLifecycleEvent(event)
        }
    }

    fun dispose() {
        // LifecycleRegistry cannot move directly from INITIALIZED to DESTROYED.
        if (registry.currentState == Lifecycle.State.INITIALIZED) {
            registry.currentState = Lifecycle.State.CREATED
        }
        registry.currentState = Lifecycle.State.DESTROYED
    }
}
