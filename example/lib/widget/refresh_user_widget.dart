import 'package:flutter/material.dart';
import 'package:vkid_flutter_sdk/library_vkid.dart';
import 'package:vkid_flutter_sdk_example/uikit/expandable_card.dart';
import 'package:vkid_flutter_sdk_example/utils/show_snackbar.dart';

class RefreshUserWidget extends StatefulWidget {
  final GlobalKey<ScaffoldMessengerState> messengerKey;
  const RefreshUserWidget(this.messengerKey, {super.key});

  @override
  State<RefreshUserWidget> createState() => RefreshUserWidgetState();
}

class RefreshUserWidgetState extends State<RefreshUserWidget> {
  User? user;

  @override
  Widget build(BuildContext context) {
    return ExpandableCard("Refresh user", [
      ElevatedButton(
          onPressed: () async {
            _refreshUser();
          },
          child: const Text("refresh")),
      if (user != null) Text(_userText()),
    ]);
  }

  _refreshUser() async {
    final vkid = await VKID.getInstance();
    vkid.fetchUser(
      onSuccess: (data) {
        setState(() {
          user = data;
        });
      },
      onError: (error) {
        String text;
        switch (error) {
          case FetchUserTokenExpiredError():
            text = "Token expired";
            break;
          case FetchUserOtherError(description: var description):
            text = "Other error: $description";
            break;
        }
        showSnackbar(widget.messengerKey, text);
      },
    );
  }

  String _userText() {
    return """
First name: ${user!.firstName}
Last name: ${user!.lastName}
Phone: ${user!.phone}
Avatar: ${user!.avatarUrl.substring(0, 16)}...
Email: ${user!.email}
    """;
  }
}
