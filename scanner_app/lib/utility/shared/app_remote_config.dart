import 'dart:convert';
import 'package:firebase_remote_config/firebase_remote_config.dart';

class AppRemoteConfig {
  static Future<dynamic> get({
    required String rcName,
    bool? isParamStringType,
    bool? isParamIntNumType,
    bool? isParamDoubleNumType,
    bool? isParamBoolType,
    bool? isParamJsonType,
    bool? isParamValueType
  }) async {
    try {
      final remoteConfig = FirebaseRemoteConfig.instance;
      await remoteConfig.setConfigSettings(
        RemoteConfigSettings(
          fetchTimeout: const Duration(seconds: 60),
          minimumFetchInterval: const Duration(seconds: 60)
        )
      );
      await remoteConfig.fetchAndActivate();
      if (isParamStringType ?? false) {
        final val = remoteConfig.getString(rcName);
        return val.isNotEmpty ? val : '';
      }
      if (isParamIntNumType ?? false) {
        return remoteConfig.getInt(rcName);
      }
      if (isParamDoubleNumType ?? false) {
        return remoteConfig.getDouble(rcName);
      }
      if (isParamBoolType ?? false) {
        return remoteConfig.getBool(rcName);
      }
      if (isParamValueType ?? false) {
        RemoteConfigValue jsonData = remoteConfig.getValue(rcName);
        dynamic encoded = jsonDecode(jsonData.asString());
        return encoded;
      }
      if (isParamJsonType ?? false) {
        return List<String>.from(jsonDecode(remoteConfig.getString(rcName)));
      }
    } catch (e) {
      return '';
    }
  }
}