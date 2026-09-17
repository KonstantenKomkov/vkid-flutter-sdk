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
import 'package:vkid_flutter_sdk_example/utils/o_auth_mapping.dart';
import 'package:vkid_flutter_sdk_example/utils/corners_style_name.dart';

class OneTapScreen extends StatefulWidget {
  final GlobalKey<ScaffoldMessengerState> messengerKey;
  final String clientID;
  const OneTapScreen(this.messengerKey, this.clientID, {super.key});

  @override
  State<OneTapScreen> createState() => _OneTapScreenState();
}

class _OneTapScreenState extends State<OneTapScreen> {
  AuthData? authData;
  OneTapOAuth? authOAuth;

  bool? changeAccountEnabled;
  bool? fetchUserEnabled;
  Set<OneTapOAuth> selectedOAuths = {};
  OneTapType? oneTapType;
  OneTapWithOAuthsType? oneTapWithOAuthsType;
  OneTapSize? oneTapSize;
  OneTapCornersStyle? oneTapCornersStyle;
  double oneTapRoundingValue = 0;
  double oneTapWidth = 300;
  OneTapTitleScenario? oneTapTitleScenario;
  String? state;
  String? codeChallenge;
  String? scopes;
  String? codeVerifier;

  final oneTapCornersStyles = [
    const OneTapCornersDefault(),
    const OneTapCornersNone(),
    const OneTapCornersRounded(),
    const OneTapCornersRound(),
    const OneTapCornersCustom(radius: 4)
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
                      width: oneTapWidth,
                      child: _createOneTap(),
                    ),
                  ),
                  if (authData != null)
                    AuthDataWidget(
                        oAuth: authOAuth?.toOAuth() ?? OAuth.vk,
                        authData: authData!),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: DefaultCheckbox(
                      defaultValue: changeAccountEnabled ?? true,
                      onChanged: (item) {
                        setState(() {
                          changeAccountEnabled = item;
                        });
                      },
                      label: "Change account",
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: DefaultCheckbox(
                      defaultValue: fetchUserEnabled ?? true,
                      onChanged: (item) {
                        setState(() {
                          fetchUserEnabled = item;
                        });
                      },
                      label: "Fetch user (android)",
                    ),
                  ),
                ] +
                OneTapOAuth.values
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
                      oneTapTitleScenario,
                      OneTapTitleScenario.values,
                      (item) => setState(() {
                            oneTapTitleScenario = item ?? oneTapTitleScenario;
                          }),
                      "title"),
                  if (selectedOAuths.isEmpty)
                    EnumDropdown(
                        oneTapType,
                        OneTapType.values,
                        (item) => setState(() {
                              oneTapType = item ?? oneTapType;
                            }),
                        "type"),
                  if (selectedOAuths.isNotEmpty)
                    EnumDropdown(
                        oneTapWithOAuthsType,
                        OneTapWithOAuthsType.values,
                        (item) => setState(() {
                              oneTapWithOAuthsType =
                                  item ?? oneTapWithOAuthsType;
                            }),
                        "type"),
                  EnumDropdown(
                      oneTapSize,
                      OneTapSize.values,
                      (item) => setState(() {
                            oneTapSize = item ?? oneTapSize;
                          }),
                      "size"),
                  DefaultDropdown(
                      cornersStyleName(oneTapCornersStyle),
                      oneTapCornersStyles
                          .map((item) => cornersStyleName(item))
                          .toList(),
                      (item) => setState(() {
                            oneTapCornersStyle = oneTapCornersStyles.firstWhere(
                                (style) => cornersStyleName(style) == item);
                          }),
                      "corners"),
                  DefaultSlider(
                      defaultValue: oneTapWidth,
                      minValue: 0,
                      maxValue: MediaQuery.sizeOf(context).width - 50,
                      onChanged: (value) => setState(() {
                            oneTapWidth = value;
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

  _onAuth(OneTapOAuth? oAuth, data) {
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

  _onError(OneTapOAuth? oAuth, AuthError error) {
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

  OneTap _createOneTap() {
    AuthFlowData flow;
    if (codeChallenge == null) {
      flow = PublicFlowData(state);
    } else {
      flow = ConfidentialFlowData(state, codeChallenge!);
    }
    final key = GlobalKey();
    final cornersStyle = oneTapCornersStyle ?? const OneTapCornersDefault();
    final size = oneTapSize ?? OneTapSize.standard;
    final fastAuthEnabled = fetchUserEnabled ?? true;
    final signInToAnotherAccountButtonEnabled = changeAccountEnabled ?? true;
    final scenario = oneTapTitleScenario ?? OneTapTitleScenario.signIn;
    final authParams = UIAuthParamsBuilder()
        .withAuthFlow(flow)
        .withScopes(scopes?.split(" ").toSet() ?? const {})
        .build();
    if (selectedOAuths.isEmpty) {
      return OneTap(
        key: key,
        onAuth: _onAuth,
        onAuthCode: _onAuthCode,
        onError: _onError,
        style: OneTapStyle(
          type: oneTapType ?? OneTapType.system,
          cornersStyle: cornersStyle,
          size: size,
        ),
        fastAuthEnabled: fastAuthEnabled,
        signInToAnotherAccountButtonEnabled:
            signInToAnotherAccountButtonEnabled,
        authParams: authParams,
        scenario: scenario,
      );
    } else {
      return OneTap.withOAuths(
        key: GlobalKey(),
        onAuth: _onAuth,
        onAuthCode: _onAuthCode,
        onError: _onError,
        alternativeOAuths: selectedOAuths,
        style: OneTapWithOAuthsStyle(
          type: oneTapWithOAuthsType ?? OneTapWithOAuthsType.system,
          cornersStyle: cornersStyle,
          size: size,
        ),
        fastAuthEnabled: fastAuthEnabled,
        signInToAnotherAccountButtonEnabled:
            signInToAnotherAccountButtonEnabled,
        authParams: authParams,
        scenario: scenario,
      );
    }
  }
}
