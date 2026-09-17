import 'package:flutter/material.dart';
import 'package:vkid_flutter_sdk/library_vkid.dart';
import 'package:vkid_flutter_sdk_example/uikit/default_checkbox.dart';
import 'package:vkid_flutter_sdk_example/uikit/default_dropdown.dart';
import 'package:vkid_flutter_sdk_example/uikit/default_text_field.dart';
import 'package:vkid_flutter_sdk_example/uikit/enum_dropdown.dart';
import 'package:vkid_flutter_sdk_example/utils/exchange_code.dart';
import 'package:vkid_flutter_sdk_example/utils/show_snackbar.dart';
import 'package:vkid_flutter_sdk_example/widget/auth_data_widget.dart';
import 'package:vkid_flutter_sdk_example/utils/o_auth_mapping.dart';
import 'package:vkid_flutter_sdk_example/utils/corners_style_name.dart';

class SheetScreen extends StatefulWidget {
  final GlobalKey<ScaffoldMessengerState> messengerKey;
  final String clientID;
  const SheetScreen(this.messengerKey, this.clientID, {super.key});

  @override
  State<SheetScreen> createState() => _SheetScreenState();
}

class _SheetScreenState extends State<SheetScreen> {
  GlobalKey<OneTapBottomSheetState> sheetKey = GlobalKey();
  final oneTapCornersStyles = [
    const OneTapCornersDefault(),
    const OneTapCornersNone(),
    const OneTapCornersRounded(),
    const OneTapCornersRound(),
    const OneTapCornersCustom(radius: 4)
  ];

  AuthData? authData;
  OneTapOAuth? authOAuth;

  Set<OneTapOAuth> selectedOAuths = {};
  bool? autoHideOnSuccess;
  bool? fetchUserEnabled;
  OneTapBottomSheetScenario? sheetScenario;
  OneTapBottomSheetType? sheetType;
  OneTapSize? oneTapSize;
  OneTapCornersStyle? oneTapCornersStyle;
  String? serviceName;
  String? state;
  String? codeChallenge;
  String? scopes;
  String? codeVerifier;

  _setStateWithGlobalKey(VoidCallback action) {
    setState(() {
      sheetKey = GlobalKey();
      action();
    });
  }

  @override
  Widget build(BuildContext context) {
    AuthFlowData flow;
    if (codeChallenge == null) {
      flow = PublicFlowData(state);
    } else {
      flow = ConfidentialFlowData(state, codeChallenge!);
    }

    return SingleChildScrollView(
        child: Column(
      children: [
            // ignore: unnecessary_cast
            OneTapBottomSheet(
              key: sheetKey,
              onAuth: (oAuth, data) {
                setState(() {
                  authData = data;
                  authOAuth = oAuth;
                });
              },
              onAuthCode: (data, isCompletion) {
                setState(() {
                  authData = null;
                  exchangeCode(
                      data,
                      codeVerifier,
                      widget.clientID,
                      widget.messengerKey,
                      (data) => _setStateWithGlobalKey(() {
                            authData = data;
                          }));
                });
              },
              onError: (oAuth, error) {
                String text;
                switch (error) {
                  case AuthCancelledError():
                    text = "$oAuth Cancelled";
                    break;
                  case AuthOtherError(description: var description):
                    text = "$oAuth Other error: $description";
                    break;
                }
                showSnackbar(widget.messengerKey, text);
              },
              serviceName: serviceName ?? "VK ID",
              scenario: sheetScenario ?? OneTapBottomSheetScenario.enterService,
              autoHideOnSuccess: autoHideOnSuccess ?? true,
              alternativeOAuths: selectedOAuths,
              style: OneTapBottomSheetStyle(
                type: sheetType ?? OneTapBottomSheetType.system,
                buttonCornersStyle:
                    oneTapCornersStyle ?? const OneTapCornersDefault(),
                buttonSize: oneTapSize ?? OneTapSize.standard,
              ),
              authParams: UIAuthParamsBuilder()
                  .withAuthFlow(flow)
                  .withScopes(scopes?.split(" ").toSet() ?? const {})
                  .build(),
              fastAuthEnabled: fetchUserEnabled ?? true,
            ) as Widget,
            if (authData != null)
              AuthDataWidget(
                  oAuth: authOAuth?.toOAuth() ?? OAuth.vk, authData: authData!),
            ElevatedButton(
                onPressed: () async {
                  if (await sheetKey.currentState!.isVisible()) {
                    sheetKey.currentState!.hide();
                  } else {
                    sheetKey.currentState?.show();
                  }
                },
                child: const Text("Show sheet"))
          ] +
          OneTapOAuth.values
              .map((oAuth) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: DefaultCheckbox(
                      defaultValue: selectedOAuths.contains(oAuth),
                      onChanged: (item) {
                        _setStateWithGlobalKey(() {
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: DefaultCheckbox(
                defaultValue: fetchUserEnabled ?? true,
                onChanged: (item) {
                  _setStateWithGlobalKey(() {
                    fetchUserEnabled = item;
                  });
                },
                label: "Fetch user (android)",
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: DefaultCheckbox(
                defaultValue: autoHideOnSuccess ?? true,
                onChanged: (item) {
                  _setStateWithGlobalKey(() {
                    autoHideOnSuccess = item;
                  });
                },
                label: "Auto hide on success",
              ),
            ),
            EnumDropdown(
                sheetScenario,
                OneTapBottomSheetScenario.values,
                (item) => _setStateWithGlobalKey(() {
                      sheetScenario = item ?? sheetScenario;
                    }),
                "title"),
            EnumDropdown(
                sheetType,
                OneTapBottomSheetType.values,
                (item) => _setStateWithGlobalKey(() {
                      sheetType = item ?? OneTapBottomSheetType.system;
                    }),
                "type"),
            EnumDropdown(
                oneTapSize,
                OneTapSize.values,
                (item) => _setStateWithGlobalKey(() {
                      oneTapSize = item ?? oneTapSize;
                    }),
                "size"),
            DefaultDropdown(
                cornersStyleName(oneTapCornersStyle),
                oneTapCornersStyles
                    .map((item) => cornersStyleName(item))
                    .toList(),
                (item) => _setStateWithGlobalKey(() {
                      oneTapCornersStyle = oneTapCornersStyles.firstWhere(
                          (style) => cornersStyleName(style) == item);
                    }),
                "corners"),
            DefaultTextField(
                "Service name",
                (value) => _setStateWithGlobalKey(() {
                      serviceName = value;
                    })),
            const Padding(padding: EdgeInsets.only(bottom: 8)),
            DefaultTextField(
                "Scopes (space-seprated)",
                (value) => _setStateWithGlobalKey(() {
                      scopes = value;
                    })),
            const Padding(padding: EdgeInsets.only(bottom: 8)),
            DefaultTextField(
                "State (optional)",
                (value) => _setStateWithGlobalKey(() {
                      state = value;
                    })),
            const Padding(padding: EdgeInsets.only(bottom: 8)),
            DefaultTextField(
                "Code challenge (optional)",
                (value) => _setStateWithGlobalKey(() {
                      codeChallenge = value;
                    })),
            const Padding(padding: EdgeInsets.only(bottom: 8)),
            DefaultTextField(
                "Code verifier (optional)",
                (value) => _setStateWithGlobalKey(() {
                      codeVerifier = value;
                    })),
            const Padding(padding: EdgeInsets.only(bottom: 8)),
          ],
    ));
  }
}
