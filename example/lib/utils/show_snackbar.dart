import 'package:flutter/material.dart';

showSnackbar(GlobalKey<ScaffoldMessengerState> messengerKey, String text) {
  final snackBar = SnackBar(
    content: Text(text),
  );
  messengerKey.currentState!.showSnackBar(snackBar);
}
