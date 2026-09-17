import 'package:flutter/material.dart';
import 'package:vkid_flutter_sdk/library_vkid.dart';
import 'package:vkid_flutter_sdk_example/utils/show_snackbar.dart';

class LogoutWidget extends StatefulWidget {
  final GlobalKey<ScaffoldMessengerState> messengerKey;
  const LogoutWidget(this.messengerKey, {super.key});

  @override
  State<LogoutWidget> createState() => LogoutWidgetState();
}

class LogoutWidgetState extends State<LogoutWidget> {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        onPressed: () => _logout(), child: const Text("logout"));
  }

  _logout() async {
    final vkid = await VKID.getInstance();
    vkid.logout(
      onSuccess: () => showSnackbar(widget.messengerKey, "logged out"),
      onError: (error) {
        String text;
        switch (error) {
          case LogoutAccessTokenExpiredError():
            text = "Token expired";
            break;
          case LogoutOtherError(description: var description):
            text = "Other error: $description";
            break;
        }
        showSnackbar(widget.messengerKey, text);
      },
    );
  }
}
