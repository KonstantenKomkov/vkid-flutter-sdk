package com.vk.vkid.flutter.vkid_flutter_sdk.onetap

import androidx.arch.core.executor.ArchTaskExecutor
import androidx.arch.core.executor.TaskExecutor
import androidx.lifecycle.Lifecycle
import androidx.lifecycle.LifecycleEventObserver
import androidx.lifecycle.LifecycleOwner
import androidx.lifecycle.LifecycleRegistry
import kotlin.test.AfterTest
import kotlin.test.BeforeTest
import kotlin.test.Test
import kotlin.test.assertEquals

internal class OneTapProfileLifecycleOwnerTest {
    @BeforeTest
    fun setUp() {
        ArchTaskExecutor.getInstance().setDelegate(object : TaskExecutor() {
            override fun executeOnDiskIO(runnable: Runnable) = runnable.run()
            override fun postToMainThread(runnable: Runnable) = runnable.run()
            override fun isMainThread(): Boolean = true
        })
    }

    @AfterTest
    fun tearDown() {
        ArchTaskExecutor.getInstance().setDelegate(null)
    }

    @Test
    fun returningFromAuthorizationDoesNotTriggerAnotherProfileFetch() {
        val host = Host()
        val profile = OneTapProfileLifecycleOwner()
        val events = mutableListOf<Lifecycle.Event>()
        host.registry.addObserver(profile)
        profile.lifecycle.addObserver(LifecycleEventObserver { _, event -> events.add(event) })
        host.registry.currentState = Lifecycle.State.RESUMED

        repeat(3) {
            host.registry.currentState = Lifecycle.State.CREATED
            host.registry.currentState = Lifecycle.State.RESUMED
        }

        assertEquals(1, events.count { it == Lifecycle.Event.ON_RESUME })
        assertEquals(Lifecycle.State.RESUMED, profile.lifecycle.currentState)
        host.registry.currentState = Lifecycle.State.DESTROYED
        assertEquals(Lifecycle.State.DESTROYED, profile.lifecycle.currentState)
        assertEquals(1, events.count { it == Lifecycle.Event.ON_DESTROY })
    }

    @Test
    fun mountingWhileHostIsResumedFetchesOnceAndNewButtonCanFetchAgain() {
        val host = Host()
        host.registry.currentState = Lifecycle.State.RESUMED
        repeat(2) {
            val profile = OneTapProfileLifecycleOwner()
            host.registry.addObserver(profile)
            var fetches = 0
            profile.lifecycle.addObserver(LifecycleEventObserver { _, event ->
                if (event == Lifecycle.Event.ON_RESUME) fetches++
            })
            assertEquals(1, fetches)
            host.registry.removeObserver(profile)
            profile.dispose()
            assertEquals(Lifecycle.State.DESTROYED, profile.lifecycle.currentState)
        }
    }

    @Test
    fun disposalBeforeFirstResumeIsSafeAndDoesNotFetch() {
        val profile = OneTapProfileLifecycleOwner()
        profile.dispose()
        profile.dispose()
        profile.onStateChanged(Host(), Lifecycle.Event.ON_RESUME)
        assertEquals(Lifecycle.State.DESTROYED, profile.lifecycle.currentState)
    }

    private class Host : LifecycleOwner {
        val registry = LifecycleRegistry(this)
        override val lifecycle: Lifecycle = registry
    }
}
