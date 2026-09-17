import 'package:flutter/material.dart';
import 'package:vkid_flutter_sdk/library_vkid.dart';
import 'package:vkid_flutter_sdk_example/uikit/default_text_field.dart';
import 'package:vkid_flutter_sdk_example/uikit/expandable_card.dart';
import 'package:vkid_flutter_sdk_example/utils/show_snackbar.dart';

class RefreshTokenWidget extends StatefulWidget {
  final GlobalKey<ScaffoldMessengerState> messengerKey;
  const RefreshTokenWidget(this.messengerKey, {super.key});

  @override
  State<RefreshTokenWidget> createState() => RefreshTokenWidgetState();
}

class RefreshTokenWidgetState extends State<RefreshTokenWidget> {
  RefreshTokenData? refreshTokenData;

  @override
  Widget build(BuildContext context) {
    return ExpandableCard("Refresh token", [
      ElevatedButton(
          onPressed: () async {
            _refreshToken();
          },
          child: const Text("refresh")),
      if (refreshTokenData != null) Text(_refreshTokenText())
    ]);
  }

  _refreshToken() async {
    final vkid = await VKID.getInstance();
    vkid.refreshToken(
      onSuccess: (data) {
        setState(() {
          refreshTokenData = data;
        });
      },
      onError: (error) {
        String text;
        switch (error) {
          case RefreshTokenExpiredError():
            text = "Refresh token expired";
            break;
          case RefreshTokenOtherError(description: var description):
            text = "Other error: $description";
            break;
        }
        showSnackbar(widget.messengerKey, text);
      },
    );
  }

  String _refreshTokenText() {
    return """
Access token: ${refreshTokenData?.accessToken.substring(0, 16)}
      """;
  }
}
