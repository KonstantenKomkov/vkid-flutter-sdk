import 'package:flutter/material.dart';
import 'package:vkid_flutter_sdk/library_vkid.dart';
import 'package:vkid_flutter_sdk_example/uikit/default_slider.dart';
import 'package:vkid_flutter_sdk_example/utils/exchange_code.dart';
import 'package:vkid_flutter_sdk_example/widget/auth_data_widget.dart';
import 'package:vkid_flutter_sdk_example/uikit/default_checkbox.dart';
import 'package:vkid_flutter_sdk_example/uikit/default_dropdown.dart';
import 'package:vkid_flutter_sdk_example/uikit/default_text_field.dart';
import 'package:vkid_flutter_sdk_example/uikit/enum_dropdown.dart';
import 'package:vkid_flutter_sdk_example/utils/show_snackbar.dart';
import 'package:vkid_flutter_sdk_example/utils/corners_style_name.dart';

typedef OAuthWidgetSize = OneTapSize;
typedef OAuthWidgetCornersStyle = OneTapCornersStyle;
typedef OAuthWidgetCornersDefault = OneTapCornersDefault;
typedef OAuthWidgetCornersNone = OneTapCornersNone;
typedef OAuthWidgetCornersRounded = OneTapCornersRounded;
typedef OAuthWidgetCornersRound = OneTapCornersRound;
typedef OAuthWidgetCornersCustom = OneTapCornersCustom;

class OAuthWidgetScreen extends StatefulWidget {
  final GlobalKey<ScaffoldMessengerState> messengerKey;
  final String clientID;
  const OAuthWidgetScreen(this.messengerKey, this.clientID, {super.key});

  @override
  State<OAuthWidgetScreen> createState() => _OAuthWidgetScreenState();
}

class _OAuthWidgetScreenState extends State<OAuthWidgetScreen> {
  AuthData? authData;
  OAuth? authOAuth;

  Set<OAuth> selectedOAuths = {OAuth.vk, OAuth.mail, OAuth.ok};
  OAuthWidgetTheme theme = OAuthWidgetTheme.system;
  OAuthWidgetSize? oAuthWidgetSize;
  OAuthWidgetCornersStyle? oAuthWidgetCornersStyle;
  double oAuthWidgetRoundingValue = 0;
  double oAuthWidgetWidth = 300;
  String? state;
  String? codeChallenge;
  String? scopes;
  String? codeVerifier;

  final oAuthWidgetCornersStyles = [
    const OAuthWidgetCornersDefault(),
    const OAuthWidgetCornersNone(),
    const OAuthWidgetCornersRounded(),
    const OAuthWidgetCornersRound(),
    const OAuthWidgetCornersCustom(radius: 4)
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: (<Widget>[
                  const SizedBox(height: 16, width: 1),
                  Center(
                    child: SizedBox(
                      width: oAuthWidgetWidth,
                      child: _createOAuthWidget(),
                    ),
                  ),
                  const SizedBox(height: 16, width: 1),
                  if (authData != null)
                    AuthDataWidget(
                        oAuth: authOAuth ?? OAuth.vk, authData: authData!),
                ] +
                OAuth.values
                    .map((oAuth) => Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: DefaultCheckbox(
                            defaultValue: selectedOAuths.contains(oAuth),
                            onChanged: (item) {
                              setState(() {
                                if (item) {
                                  selectedOAuths.add(oAuth);
                                } else {
                                  selectedOAuths.remove(oAuth);
                                }
                              });
                            },
                            label: oAuth.name,
                          ),
                        ))
                    .toList() +
                [
                  EnumDropdown(
                      oAuthWidgetSize,
                      OAuthWidgetSize.values,
                      (item) => setState(() {
                            oAuthWidgetSize = item ?? oAuthWidgetSize;
                          }),
                      "size"),
                  DefaultDropdown(
                      cornersStyleName(oAuthWidgetCornersStyle),
                      oAuthWidgetCornersStyles
                          .map((item) => cornersStyleName(item))
                          .toList(),
                      (item) => setState(() {
                            oAuthWidgetCornersStyle =
                                oAuthWidgetCornersStyles.firstWhere(
                                    (style) => cornersStyleName(style) == item);
                          }),
                      "corners"),
                  if (oAuthWidgetCornersStyle is OAuthWidgetCornersCustom &&
                      selectedOAuths.isNotEmpty)
                    DefaultSlider(
                        defaultValue: oAuthWidgetRoundingValue,
                        minValue: 0,
                        maxValue: (oAuthWidgetSize ?? OAuthWidgetSize.standard)
                                .value
                                .toDouble() /
                            2,
                        onChanged: (value) => setState(() {
                              oAuthWidgetRoundingValue = value;
                              oAuthWidgetCornersStyle =
                                  OAuthWidgetCornersCustom(
                                      radius: oAuthWidgetRoundingValue);
                            })),
                  EnumDropdown(
                      theme,
                      OAuthWidgetTheme.values,
                      (item) => setState(() {
                            theme = item ?? OAuthWidgetTheme.system;
                          }),
                      "theme"),
                  DefaultSlider(
                      defaultValue: oAuthWidgetWidth,
                      minValue: 0,
                      maxValue: MediaQuery.sizeOf(context).width - 50,
                      onChanged: (value) => setState(() {
                            oAuthWidgetWidth = value;
                          })),
                  DefaultTextField(
                      "Scopes (space-seprated)",
                      (value) => setState(() {
                            scopes = value;
                          })),
                  const Padding(padding: EdgeInsets.only(bottom: 8)),
                  DefaultTextField(
                      "State (optional)",
                      (value) => setState(() {
                            state = value;
                          })),
                  const Padding(padding: EdgeInsets.only(bottom: 8)),
                  DefaultTextField(
                      "Code challenge (optional)",
                      (value) => setState(() {
                            codeChallenge = value;
                          })),
                  const Padding(padding: EdgeInsets.only(bottom: 8)),
                  DefaultTextField(
                      "Code verifier (optional)",
                      (value) => setState(() {
                            codeVerifier = value;
                          })),
                  const Padding(padding: EdgeInsets.only(bottom: 8)),
                ])));
  }

  _onAuth(OAuth? oAuth, data) {
    setState(() {
      authData = data;
      authOAuth = oAuth;
    });
  }

  _onAuthCode(AuthCodeData data, bool isCompletion) {
    setState(() {
      authData = null;
      exchangeCode(
          data,
          codeVerifier,
          widget.clientID,
          widget.messengerKey,
          (data) => setState(() {
                authData = data;
              }));
    });
  }

  _onError(OAuth? oAuth, AuthError error) {
    String text = "";
    switch (error) {
      case AuthCancelledError():
        text = "$oAuth Cancelled";
        break;
      case AuthOtherError(description: var description):
        text = "$oAuth Other error: $description";
        break;
    }
    showSnackbar(widget.messengerKey, text);
  }

  _createOAuthWidget() {
    if (selectedOAuths.isEmpty) {
      return const Text("Select one or more OAuths");
    }
    AuthFlowData flow;
    if (codeChallenge == null) {
      flow = PublicFlowData(state);
    } else {
      flow = ConfidentialFlowData(state, codeChallenge!);
    }
    final key = GlobalKey();
    final cornersStyle =
        oAuthWidgetCornersStyle ?? const OAuthWidgetCornersDefault();
    final size = oAuthWidgetSize ?? OAuthWidgetSize.standard;
    final authParams = UIAuthParamsBuilder()
        .withAuthFlow(flow)
        .withScopes(scopes?.split(" ").toSet() ?? const {})
        .build();
    return OAuthWidget(
      key: key,
      onAuth: _onAuth,
      onAuthCode: _onAuthCode,
      onError: _onError,
      oAuths: selectedOAuths,
      buttonConfig:
          OAuthButtonConfiguration(cornersStyle: cornersStyle, size: size),
      theme: theme,
      authParams: authParams,
    );
  }
}
