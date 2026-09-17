import 'package:flutter/material.dart';
import 'package:vkid_flutter_sdk/library_vkid.dart';
import 'dart:math';

class AuthDataWidget extends StatefulWidget {
  final AuthData authData;
  final OAuth oAuth;
  const AuthDataWidget(
      {required this.oAuth, required this.authData, super.key});

  @override
  State<AuthDataWidget> createState() => _AuthDataWidgetState();
}

class _AuthDataWidgetState extends State<AuthDataWidget> {
  @override
  Widget build(BuildContext context) {
    return Text(_authDataText());
  }

  String _authDataText() {
    final authData = widget.authData;
    return """
OAuth: ${widget.oAuth.name}
Token: ${authData.token.substring(0, 16)}...
ID token: ${authData.idToken.substring(0, 16)}...
User ID: ${authData.userID}
Expire time: ${authData.expireTime}
First name: ${authData.userData.firstName}
Last name: ${authData.userData.lastName}
Phone: ${authData.userData.phone}
Avatar: ${authData.userData.avatarUrl?.substring(0, min(16, authData.userData.avatarUrl.length))}...
Email: ${authData.userData.email}
Scopes: ${authData.scopes.join(", ")}
            """;
  }
}
