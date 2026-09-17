import 'package:vkid_flutter_sdk/library_vkid.dart';

extension OAuthMapping on OneTapOAuth {
  OAuth toOAuth() {
    switch (this) {
      case OneTapOAuth.mail:
        return OAuth.mail;
      case OneTapOAuth.ok:
        return OAuth.ok;
    }
  }
}
