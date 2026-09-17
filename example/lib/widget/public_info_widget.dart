import 'package:flutter/material.dart';
import 'package:vkid_flutter_sdk/library_vkid.dart';
import 'package:vkid_flutter_sdk_example/uikit/expandable_card.dart';
import 'package:dio/dio.dart';
import 'package:vkid_flutter_sdk_example/utils/show_snackbar.dart';

class PublicInfoWidget extends StatefulWidget {
  final GlobalKey<ScaffoldMessengerState> messengerKey;
  final String clientID;
  const PublicInfoWidget(this.messengerKey, this.clientID, {super.key});

  @override
  State<PublicInfoWidget> createState() => PublicInfoWidgetState();
}

class PublicInfoWidgetState extends State<PublicInfoWidget> {
  User? user;

  @override
  Widget build(BuildContext context) {
    return ExpandableCard("Public info", [
      ElevatedButton(
          onPressed: () async {
            _getPublicInfo();
          },
          child: const Text("get")),
      if (user != null) Text(_userText()),
    ]);
  }

  _getPublicInfo() async {
    try {
      final vkid = await VKID.getInstance();
      final idToken = (await vkid.currentAuthData)?.idToken;
      final response = await Dio().post("https://id.vk.ru/oauth2/public_info",
          data: FormData.fromMap({
            "id_token": idToken,
            "client_id": widget.clientID,
          }));
      final body = response.data;
      final userData = body["user"];
      setState(() {
        user = User(
          userData["first_name"],
          userData["last_name"],
          userData["phone"] ?? "",
          userData["avatar"] ?? "",
          userData["email"] ?? "",
        );
      });
    } catch (e) {
      showSnackbar(widget.messengerKey, "error during code exchange");
    }
  }

  String _userText() {
    return """
First name: ${user!.firstName}
Last name: ${user!.lastName}
Phone: ${user!.phone}
Avatar: ${user!.avatarUrl?.substring(0, 16)}...
Email: ${user!.email}
    """;
  }
}
