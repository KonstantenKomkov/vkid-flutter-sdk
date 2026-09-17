import 'package:vkid_flutter_sdk/library_vkid.dart';

String? cornersStyleName(OneTapCornersStyle? style) {
  switch (style) {
    case null:
      return null;
    case OneTapCornersDefault():
      return "default";
    case OneTapCornersNone():
      return "none";
    case OneTapCornersRounded():
      return "rounded";
    case OneTapCornersRound():
      return "round";
    // ignore: unused_local_variable
    case OneTapCornersCustom(radius: final radiusNew):
      return "custom";
  }
}
