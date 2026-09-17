import 'package:flutter/material.dart';
import 'package:vkid_flutter_sdk_example/utils/exchange_code.dart';
import 'package:vkid_flutter_sdk_example/widget/auth_data_widget.dart';
import 'package:vkid_flutter_sdk_example/uikit/default_dropdown.dart';
import 'package:vkid_flutter_sdk_example/uikit/default_text_field.dart';
import 'package:vkid_flutter_sdk_example/uikit/enum_dropdown.dart';
import 'package:vkid_flutter_sdk_example/uikit/expandable_card.dart';
import 'package:vkid_flutter_sdk/library_vkid.dart';
import 'package:vkid_flutter_sdk_example/utils/show_snackbar.dart';

class AuthWidget extends StatefulWidget {
  final GlobalKey<ScaffoldMessengerState> messengerKey;
  final String clientID;
  const AuthWidget(this.messengerKey, this.clientID, {super.key});

  @override
  State<AuthWidget> createState() => AuthWidgetState();
}

class AuthWidgetState extends State<AuthWidget> {
  AuthData? authData;
  AuthLocale? authLocale;
  AuthTheme? authTheme;
  bool useOAuthProviderIfPossible = true;
  OAuth? oAuth;
  String? state;
  String? codeChallenge;
  String? scopes;
  String? codeVerifier;

  @override
  Widget build(BuildContext context) {
    return ExpandableCard(
      "auth",
      [
        EnumDropdown<AuthLocale>(
          null,
          AuthLocale.values,
          (item) => authLocale = item,
          "locale",
        ),
        const Padding(padding: EdgeInsets.only(bottom: 8)),
        EnumDropdown<AuthTheme>(
          null,
          AuthTheme.values,
          (item) => authTheme = item,
          "theme",
        ),
        const Padding(padding: EdgeInsets.only(bottom: 8)),
        DefaultDropdown(
          null,
          const ["true", "false"],
          (item) => useOAuthProviderIfPossible = item != "false",
          "useOAuthProviderIfPossible",
        ),
        const Padding(padding: EdgeInsets.only(bottom: 8)),
        EnumDropdown<OAuth>(
          null,
          OAuth.values,
          (item) => oAuth = item,
          "oAuth",
        ),
        const Padding(padding: EdgeInsets.only(bottom: 8)),
        DefaultTextField(
          "Scopes (space-seprated)",
          (value) => scopes = value,
        ),
        const Padding(padding: EdgeInsets.only(bottom: 8)),
        DefaultTextField(
          "State (optional)",
          (value) => state = value,
        ),
        const Padding(padding: EdgeInsets.only(bottom: 8)),
        DefaultTextField(
          "Code challenge (optional)",
          (value) => codeChallenge = value,
        ),
        const Padding(padding: EdgeInsets.only(bottom: 8)),
        DefaultTextField(
          "Code verifier (optional)",
          (value) => codeVerifier = value,
        ),
        const Padding(padding: EdgeInsets.only(bottom: 8)),
        ElevatedButton(
            onPressed: () async {
              _authorize();
            },
            child: const Text("authorize")),
        if (authData != null)
          AuthDataWidget(oAuth: oAuth ?? OAuth.vk, authData: authData!),
      ],
    );
  }

  _authorize() async {
    final vkid = await VKID.getInstance();
    AuthFlowData flow;
    if (codeChallenge == null) {
      flow = PublicFlowData(state);
    } else {
      flow = ConfidentialFlowData(state, codeChallenge!);
    }
    vkid.authorize(
      onAuth: (data) {
        setState(() {
          authData = data;
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
              (data) => setState(() {
                    authData = data;
                  }));
        });
      },
      onError: (error) {
        String text;
        switch (error) {
          case AuthCancelledError():
            text = "Cancelled";
            break;
          case AuthOtherError(description: var description):
            text = "Other error: $description";
            break;
        }
        showSnackbar(widget.messengerKey, text);
      },
      params: AuthParamsBuilder()
          .withLocale(authLocale)
          .withTheme(authTheme)
          .withUseOAuthProviderIfPossible(useOAuthProviderIfPossible)
          .withOAuth(oAuth)
          .withAuthFlow(flow)
          .withScopes(scopes?.split(" ").toSet() ?? const {})
          .build(),
    );
  }
}
