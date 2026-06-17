import 'dart:convert';
import 'dart:developer';
import 'package:nustar_turnstile_scanner/utility/shared/app.data.dart';
import 'package:openpgp/openpgp.dart';

class Gpg {

  static Codec<String, String> stringToBase64 = utf8.fuse(base64);

  static Future<KeyPair?> generateKeyPair(String name, String email, String uuid) async {
    var ret;
    try {
      String? passk = await encodeData(uuid);
      dynamic keyOptions = KeyOptions()..rsaBits = 1024;
      KeyPair? kp = await OpenPGP.generate(
        options: Options()
          ..name = name
          ..email = email
          ..passphrase = passk
          ..keyOptions = keyOptions);
      ret = kp;
    } catch (error) {
      log(error.toString());
    }
    return ret;
  }

  static Future encryptData(String strData, String pubKey) async {
    String b64enc = App.e;
    try {
      b64enc = await OpenPGP.encrypt(strData, pubKey);
      b64enc = (await encodeData(b64enc))!;
      //stringToBase64.encode(b64enc);
    } catch (error) {
      log(error.toString());
      return null;
    }
    return b64enc;
  }

  static Future decryptData(String strData, String pKey, String secret) async {
    String b64dec = App.e;
    try {
      b64dec = (await decodeData(strData))!;
      b64dec = await OpenPGP.decrypt(b64dec, pKey, secret);
    } catch (error) {
      log(error.toString());
      return null;
    }
    return b64dec;
  }

  static Future<String?> encodeData(String str) async {
    String ret = App.e;
    try {
      ret = stringToBase64.encode(str);
    } catch (e) {
      return null;
    }
    return ret;
  }

  static Future<String?> decodeData(String str) async {
    String ret = App.e;
    try {
      ret = stringToBase64.decode(str);
    } catch (e) {
      return null;
    }
    return ret;
  }

}