import 'package:flutter/material.dart';
import 'package:vkid_flutter_sdk/library_vkid.dart';
import 'package:dio/dio.dart';
import 'package:vkid_flutter_sdk_example/utils/show_snackbar.dart';

class RevokeWidget extends StatefulWidget {
  final GlobalKey<ScaffoldMessengerState> messengerKey;
  final String clientID;
  const RevokeWidget(this.messengerKey, this.clientID, {super.key});

  @override
  State<RevokeWidget> createState() => RevokeWidgetState();
}

class RevokeWidgetState extends State<RevokeWidget> {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        onPressed: () => _revoke(), child: const Text("revoke"));
  }

  _revoke() async {
    try {
      final vkid = await VKID.getInstance();
      final token = (await vkid.currentAuthData)?.token;
      final response = await Dio().post("https://id.vk.ru/oauth2/revoke",
          data: FormData.fromMap({
            "access_token": token,
            "client_id": widget.clientID,
          }));
      final body = response.data;
      if (body["response"] == 1) {
        showSnackbar(widget.messengerKey, "success");
      } else {
        showSnackbar(widget.messengerKey, "error");
      }
    } catch (e) {
      showSnackbar(widget.messengerKey, "error during revoking");
    }
  }
}
