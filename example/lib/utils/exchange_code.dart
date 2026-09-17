import 'package:flutter/material.dart';
import 'package:vkid_flutter_sdk/library_vkid.dart';
import 'package:dio/dio.dart';
import 'package:vkid_flutter_sdk_example/utils/show_snackbar.dart';

exchangeCode(
  AuthCodeData authCodeData,
  String? codeVerifier,
  String clientID,
  GlobalKey<ScaffoldMessengerState> messengerKey,
  Function(AuthData) onAuthData,
) async {
  try {
    final response = await Dio().post("https://id.vk.ru/oauth2/auth",
        data: FormData.fromMap({
          "grant_type": "authorization_code",
          "code": authCodeData.code,
          "code_verifier": codeVerifier,
          "client_id": clientID,
          "device_id": authCodeData.deviceID,
          "redirect_uri": authCodeData.redirectUri,
          "state": "state",
        }));
    final body = response.data;
    onAuthData(AuthData(
      body["access_token"],
      body["id_token"],
      body["user_id"],
      body["expires_in"],
      User("User should be fetched by token", "", "", "", ""),
      (body["scope"] as String).split(" ").toSet(),
    ));
  } catch (e) {
    showSnackbar(messengerKey, "error during code exchange");
  }
}
