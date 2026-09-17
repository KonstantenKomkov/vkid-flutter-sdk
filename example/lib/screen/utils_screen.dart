import 'package:flutter/material.dart';
import 'package:vkid_flutter_sdk/library_vkid.dart';
import 'package:vkid_flutter_sdk_example/widget/auth_widget.dart';
import 'package:vkid_flutter_sdk_example/widget/logout_widget.dart';
import 'package:vkid_flutter_sdk_example/widget/public_info_widget.dart';
import 'package:vkid_flutter_sdk_example/widget/refresh_token_widget.dart';
import 'package:vkid_flutter_sdk_example/widget/refresh_user_widget.dart';
import 'package:vkid_flutter_sdk_example/widget/revoke_widget.dart';

class UtilsScreen extends StatefulWidget {
  final GlobalKey<ScaffoldMessengerState> messengerKey;
  final String clientID;
  const UtilsScreen(this.messengerKey, this.clientID, {super.key});

  @override
  State<UtilsScreen> createState() => UtilsScreenState();
}

class UtilsScreenState extends State<UtilsScreen> {
  bool? logsEnabled = false;

  @override
  Widget build(BuildContext context) {
    () async {
      var startLoggingState = await (await VKID.getInstance()).logsEnabled;
      setState(() {
        logsEnabled = startLoggingState;
      });
    }();
    return SingleChildScrollView(
        child: Column(
      children: [
        AuthWidget(widget.messengerKey, widget.clientID),
        RefreshTokenWidget(widget.messengerKey),
        RefreshUserWidget(widget.messengerKey),
        PublicInfoWidget(widget.messengerKey, widget.clientID),
        LogoutWidget(widget.messengerKey),
        RevokeWidget(widget.messengerKey, widget.clientID),
        CheckboxListTile(
            title: const Text("Logs enabled"),
            subtitle: const Text("Restart app to apply change for iOS"),
            value: logsEnabled,
            onChanged: (newValue) async {
              (await VKID.getInstance()).setLogsEnabled(newValue ?? false);
              setState(() {
                logsEnabled = newValue;
              });
            }),
      ],
    ));
  }
}
