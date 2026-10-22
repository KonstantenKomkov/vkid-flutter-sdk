part of '../library_vkid.dart';

/// A One Tap button that provides VKID login interface.
///
/// Example usage:
/// ```
/// final key = GlobalKey();
/// OneTap(
///   key: key,
///   onAuth: (oAuth, data) => print(data.token),
///   onError: (oAuth, error) => print(error),
///   oAuths: const {OneTapOAuth.ok, OneTapOAuth.mail},
///   style: const OneTapStyle(type: OneTapType.system),
///   fastAuthEnabled: false,
///   signInToAnotherAccountButtonEnabled: false,
///   authParams: UIAuthParamsBuilder().withScopes(const {"phone", "email"}).build(),
///   scenario: OneTapTitleScenario.order,
/// );
/// ```
class OneTap extends StatefulWidget {
  final Function(OneTapOAuth? oAuth, AuthData accessToken) _onAuth;
  final Function(AuthCodeData data, bool isCompletion) _onAuthCode;
  final Function(OneTapOAuth? oAuth, AuthError error) _onError;
  final Set<OneTapOAuth> _alternativeOAuths;
  final OneTapStyle _style;
  final bool _fastAuthEnabled;
  final bool _signInToAnotherAccountButtonEnabled;
  final UIAuthParams _authParams;
  final OneTapTitleScenario _scenario;

  /// Android platform-view composition. Ignored on iOS.
  ///
  /// Defaults to the existing texture-layer behavior. Use
  /// [OneTapAndroidCompositionMode.virtualDisplay] when Compose personalization
  /// is stale in texture-layer mode and Flutter transforms must be preserved.
  /// Give the widget a new key when switching modes at runtime.
  final OneTapAndroidCompositionMode androidCompositionMode;

  static _defaultOnAuthCode(AuthCodeData data, bool isCompletion) {}
  static _defaultOnError(OneTapOAuth? oAuth, AuthError error) {}

  /// Constructs a [OneTap] without alternative [OAuth]s.
  ///
  /// There are some parameters, that you can provide. [key] can be used to retrieve [State] of the widget.
  /// [onAuth] will be called after successful auth if you passed [PublicFlowData] to [authParams].
  /// [onAuthCode] will be called if you passed [ConfidentialFlowData] to [authParams].
  /// [onError] will be called if any error was encountered during auth.
  /// [style] allows to style the widget.
  /// [fastAuthEnabled] allows to disable user fetching on Android.
  /// [signInToAnotherAccountButtonEnabled] allows to hide a button for changing account.
  /// [authParams] specify auth flow and scopes. Read more about them in [UIAuthParamsBuilder].
  /// [scenario] allows to change text on the button.
  const OneTap({
    required Key key,
    required Function(OneTapOAuth? oAuth, AuthData accessToken) onAuth,
    Function(AuthCodeData data, bool isCompletion) onAuthCode =
        _defaultOnAuthCode,
    Function(OneTapOAuth? oAuth, AuthError error) onError = _defaultOnError,
    OneTapStyle style = const OneTapStyle(),
    bool fastAuthEnabled = true,
    bool signInToAnotherAccountButtonEnabled = true,
    UIAuthParams authParams = const UIAuthParams._(),
    OneTapTitleScenario scenario = OneTapTitleScenario.signIn,
    this.androidCompositionMode = OneTapAndroidCompositionMode.textureLayer,
  }) : _onAuth = onAuth,
       _onAuthCode = onAuthCode,
       _onError = onError,
       _alternativeOAuths = const {},
       _style = style,
       _fastAuthEnabled = fastAuthEnabled,
       _signInToAnotherAccountButtonEnabled =
           signInToAnotherAccountButtonEnabled,
       _authParams = authParams,
       _scenario = scenario,
       super(key: key);

  /// Constructs a [OneTap] with alternative [OAuth]s.
  /// The styling in this case is limited.
  ///
  /// There are some parameters, that you can provide. [key] can be used to retrieve [State] of the widget.
  /// [onAuth] will be called after successful auth if you passed [PublicFlowData] to [authParams].
  /// [onAuthCode] will be called if you passed [ConfidentialFlowData] to [authParams].
  /// [onError] will be called if any error was encountered during auth.
  /// [style] allows to style the widget.
  /// [fastAuthEnabled] allows to disable user fetching on Android.
  /// [signInToAnotherAccountButtonEnabled] allows to hide a button for changing account.
  /// [authParams] specify auth flow and scopes. Read more about them in [UIAuthParamsBuilder].
  /// [scenario] allows to change text on the button.
  OneTap.withOAuths({
    required Key key,
    required Function(OneTapOAuth? oAuth, AuthData accessToken) onAuth,
    Function(AuthCodeData data, bool isCompletion) onAuthCode =
        _defaultOnAuthCode,
    Function(OneTapOAuth? oAuth, AuthError error) onError = _defaultOnError,
    Set<OneTapOAuth> alternativeOAuths = const {},
    OneTapWithOAuthsStyle style = const OneTapWithOAuthsStyle(),
    bool fastAuthEnabled = true,
    bool signInToAnotherAccountButtonEnabled = true,
    UIAuthParams authParams = const UIAuthParams._(),
    OneTapTitleScenario scenario = OneTapTitleScenario.signIn,
    this.androidCompositionMode = OneTapAndroidCompositionMode.textureLayer,
  }) : _onAuth = onAuth,
       _onAuthCode = onAuthCode,
       _onError = onError,
       _alternativeOAuths = alternativeOAuths,
       _style = style.toOneTapStyle(),
       _fastAuthEnabled = fastAuthEnabled,
       _signInToAnotherAccountButtonEnabled =
           signInToAnotherAccountButtonEnabled,
       _authParams = authParams,
       _scenario = scenario,
       super(key: key);

  @override
  State<StatefulWidget> createState() => _OneTapState();
}

class _OneTapState extends State<OneTap> {
  int nativeHeight = 0;
  MethodChannel? _callbackChannel;

  @override
  Widget build(BuildContext context) {
    double height;
    final creationParams = [
      // ignore: sdk_version_since
      widget._alternativeOAuths.map((item) => item.name).toList(),
      // ignore: sdk_version_since
      widget._style.type.name,
      widget._style.cornersStyle._type,
      widget._style.cornersStyle is OneTapCornersCustom
          ? (widget._style.cornersStyle as OneTapCornersCustom).radius
          : 0.0,
      // ignore: sdk_version_since
      widget._style.size.name,
      widget._fastAuthEnabled,
      widget._signInToAnotherAccountButtonEnabled,
      widget._authParams._authFlowData is PublicFlowData
          ? (widget._authParams._authFlowData as PublicFlowData).state
          : (widget._authParams._authFlowData as ConfidentialFlowData).state,
      widget._authParams._authFlowData is PublicFlowData
          ? null
          : (widget._authParams._authFlowData as ConfidentialFlowData)
                .codeChallenge,
      widget._authParams._scopes.toList(),
      // ignore: sdk_version_since
      widget._scenario.name,
    ];
    Widget view;
    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
        view = UiKitView(
          viewType: "OneTap",
          creationParams: creationParams,
          creationParamsCodec: const StandardMessageCodec(),
          onPlatformViewCreated: (id) => _setCallback(id),
        );
        if (widget._alternativeOAuths.isEmpty) {
          height = widget._style.size.value.toDouble();
        } else {
          height = nativeHeight == 0 ? 1.0 : nativeHeight.toDouble();
        }
      case TargetPlatform.android:
        view = switch (widget.androidCompositionMode) {
          OneTapAndroidCompositionMode.hybrid => _AndroidOneTapHybridView(
            creationParams: creationParams,
            onPlatformViewCreated: _setCallback,
          ),
          OneTapAndroidCompositionMode.textureLayer ||
          OneTapAndroidCompositionMode.virtualDisplay => AndroidView(
            viewType:
                widget.androidCompositionMode ==
                    OneTapAndroidCompositionMode.virtualDisplay
                ? 'OneTapVirtualDisplay'
                : 'OneTap',
            creationParams: creationParams,
            creationParamsCodec: const StandardMessageCodec(),
            onPlatformViewCreated: _setCallback,
          ),
        };
        if (widget._alternativeOAuths.isEmpty &&
            !widget._signInToAnotherAccountButtonEnabled) {
          height = widget._style.size.value.toDouble();
        } else {
          height = nativeHeight == 0
              ? 1000.0
              : nativeHeight.toDouble() /
                    MediaQuery.of(context).devicePixelRatio;
        }
      default:
        throw UnsupportedError('Unsupported platform');
    }
    if (defaultTargetPlatform == TargetPlatform.android &&
        widget.androidCompositionMode ==
            OneTapAndroidCompositionMode.virtualDisplay) {
      view = OneTapResumeFrame(
        awaitSurfaceFrame: _awaitSurfaceFrame,
        child: view,
      );
    }
    return SizedBox(height: height, child: view);
  }

  Future<void> _awaitSurfaceFrame(RenderRepaintBoundary boundary) async {
    await _callbackChannel?.invokeMethod<void>('awaitSurfaceFrame');
    await OneTapTextureFrame.waitUntilReady(boundary);
  }

  @override
  void dispose() {
    _callbackChannel?.setMethodCallHandler(null);
    super.dispose();
  }

  void _setCallback(int id) {
    MethodChannel channel = MethodChannel("com.vk.id/onetap-$id");
    _callbackChannel?.setMethodCallHandler(null);
    _callbackChannel = channel;
    channel.setMethodCallHandler((call) async {
      if (!mounted) return null;
      if (call.method == "onHeight") {
        final int height = call.arguments as int;
        if (height != nativeHeight) {
          setState(() => nativeHeight = height);
        }
      } else {
        _handleMethod(
          widget._onAuth,
          widget._onAuthCode,
          widget._onError,
          call,
        );
      }
      return null;
    });
  }
}
