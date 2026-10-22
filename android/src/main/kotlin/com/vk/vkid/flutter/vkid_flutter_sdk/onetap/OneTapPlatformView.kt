package com.vk.vkid.flutter.vkid_flutter_sdk.onetap

import android.content.Context
import android.view.View
import androidx.compose.foundation.layout.wrapContentHeight
import androidx.compose.runtime.Composable
import androidx.compose.runtime.CompositionLocalProvider
import androidx.compose.runtime.DisposableEffect
import androidx.compose.runtime.Recomposer
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.ui.ExperimentalComposeUiApi
import androidx.compose.ui.Modifier
import androidx.compose.ui.layout.onGloballyPositioned
import androidx.compose.ui.platform.ComposeView
import androidx.compose.ui.platform.LocalLifecycleOwner
import androidx.compose.ui.platform.ViewCompositionStrategy
import androidx.compose.ui.platform.createLifecycleAwareWindowRecomposer
import com.vk.id.VKIDAuthFail
import com.vk.id.auth.VKIDAuthUiParams
import com.vk.id.onetap.common.OneTapOAuth
import com.vk.id.onetap.common.OneTapStyle
import com.vk.id.onetap.compose.onetap.OneTap
import com.vk.id.onetap.compose.onetap.OneTapTitleScenario
import com.vk.vkid.flutter.vkid_flutter_sdk.common.capitalize
import com.vk.vkid.flutter.vkid_flutter_sdk.common.parseCornersStyle
import com.vk.vkid.flutter.vkid_flutter_sdk.common.parseOneTapOAuths
import com.vk.vkid.flutter.vkid_flutter_sdk.common.parseSize
import com.vk.vkid.flutter.vkid_flutter_sdk.common.pack
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.platform.PlatformView

internal class OneTapPlatformView(
    private val context: Context,
    private val methodChannel: MethodChannel,
    private val arguments: List<Any?>,
) : PlatformView {
    private val composeView = ComposeView(context)
    private var hostView: View? = null
    private var hostRecomposer: Recomposer? = null

    private var hasParams = mutableStateOf(false)

    private lateinit var oAuths: Set<OneTapOAuth>
    private lateinit var style: OneTapStyle
    private var fastAuthEnabled = true
    private var signInToAnotherAccountEnabled = false
    private var state: String? = null
    private var codeChallenge: String? = null
    private lateinit var scopes: Set<String>
    private lateinit var scenario: OneTapTitleScenario

    init {
        initParams()
        // Virtual Display temporarily detaches its Presentation when its surface is recreated.
        // The default detach strategy discards the profile and starts the loading animation again.
        composeView.setViewCompositionStrategy(ViewCompositionStrategy.DisposeOnViewTreeLifecycleDestroyed)
        composeView.setContent { Content() }
    }

    private fun initParams() {
        oAuths = parseOneTapOAuths(arguments[0] as List<String>)
        val cornersStyle = parseCornersStyle(arguments[2] as String, arguments[3] as Double?) ?: return
        val sizeStyle = parseSize(arguments[4] as String) ?: return
        style = when (arguments[1]) {
            "light" -> OneTapStyle.Light(
                cornersStyle = cornersStyle,
                sizeStyle = sizeStyle,
            )

            "dark" -> OneTapStyle.Dark(
                cornersStyle = cornersStyle,
                sizeStyle = sizeStyle,
            )

            "transparentLight" -> OneTapStyle.TransparentLight(
                cornersStyle = cornersStyle,
                sizeStyle = sizeStyle,
            )

            "transparentDark" -> OneTapStyle.TransparentDark(
                cornersStyle = cornersStyle,
                sizeStyle = sizeStyle,
            )

            "icon" -> OneTapStyle.Icon(
                cornersStyle = cornersStyle,
                sizeStyle = sizeStyle,
            )

            "system" -> OneTapStyle.system(
                context,
                cornersStyle = cornersStyle,
                sizeStyle = sizeStyle,
            )

            "transparentSystem" -> OneTapStyle.transparentSystem(
                context,
                cornersStyle = cornersStyle,
                sizeStyle = sizeStyle,
            )

            else -> return
        }
        fastAuthEnabled = arguments[5] as Boolean
        signInToAnotherAccountEnabled = arguments[6] as Boolean
        state = arguments[7] as String?
        codeChallenge = arguments[8] as String?
        scopes = (arguments[9] as List<String>).toSet()
        scenario = OneTapTitleScenario.valueOf((arguments[10] as String).capitalize())
        hasParams.value = true
    }

    @Composable
    private fun Content() {
        if (!hasParams.value) return
        val hostLifecycle = LocalLifecycleOwner.current.lifecycle
        val profileOwner = remember(hostLifecycle) { OneTapProfileLifecycleOwner() }
        DisposableEffect(hostLifecycle, profileOwner) {
            hostLifecycle.addObserver(profileOwner)
            onDispose {
                hostLifecycle.removeObserver(profileOwner)
                profileOwner.dispose()
            }
        }
        CompositionLocalProvider(LocalLifecycleOwner provides profileOwner) {
            OneTap(
                modifier = Modifier.wrapContentHeight().onGloballyPositioned {
                    methodChannel.invokeMethod("onHeight", it.size.height)
                },
                onAuth = { oAuth, token ->
                    methodChannel.invokeMethod("onAuth", token.pack { error("No id token") }?.let { it + listOf(oAuth?.name?.lowercase()) })
                },
                onAuthCode = { data, isCompletion ->
                    if (isCompletion) methodChannel.invokeMethod("onAuthCode", data.pack(context))
                },
                onFail = { oAuth, fail ->
                    val code = if (fail is VKIDAuthFail.Canceled) "cancelled" else fail::class.java.name
                    methodChannel.invokeMethod("onError", listOf(code, fail.description, oAuth?.name?.lowercase()))
                },
                signInAnotherAccountButtonEnabled = signInToAnotherAccountEnabled,
                oAuths = oAuths,
                style = style,
                fastAuthEnabled = fastAuthEnabled,
                authParams = VKIDAuthUiParams {
                    state = this@OneTapPlatformView.state
                    codeChallenge = this@OneTapPlatformView.codeChallenge
                    scopes = this@OneTapPlatformView.scopes
                },
                scenario = scenario,
            )
        }
    }

    override fun getView(): View = composeView

    @OptIn(ExperimentalComposeUiApi::class)
    override fun onFlutterViewAttached(flutterView: View) {
        if (hostView === flutterView) return
        releaseComposition()
        hostView = flutterView
        // A Presentation's window Recomposer is cancelled on Virtual Display surface replacement.
        // Own a Recomposer bound to the real host instead, so remembered click coroutines remain live.
        hostRecomposer = flutterView.createLifecycleAwareWindowRecomposer()
        composeView.setParentCompositionContext(hostRecomposer)
    }

    override fun onFlutterViewDetached() {
        releaseComposition()
    }

    override fun dispose() {
        releaseComposition()
    }

    private fun releaseComposition() {
        composeView.disposeComposition()
        hostRecomposer?.cancel()
        hostRecomposer = null
        hostView = null
        composeView.setParentCompositionContext(null)
    }
}
