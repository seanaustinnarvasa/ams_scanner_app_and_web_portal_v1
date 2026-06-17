import 'dart:convert';
import 'dart:developer';
import 'package:nustar_turnstile_scanner/utility/shared/app.data.dart';

List<Users> usersFromJson(String str) =>
    List<Users>.from(json.decode(str).map((x) => Users.fromJson(x)));

String usersToJson(List<Users> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));
    
class Users {
  String? username;
  String? name;
  String? tenantName;
  int? tenantId;
  bool? errorStatus;
  bool? enableEarn;
  bool? enableInquiry;
  bool? enableRedeem;
  bool? enableRedeemComp;
  String? errorMessage;
  
  Users({
    this.username,
    this.name,
    this.tenantName,
    this.tenantId,
    this.errorStatus,
    this.enableEarn,
    this.enableInquiry,
    this.enableRedeem,
    this.enableRedeemComp,
    this.errorMessage
  });

  factory Users.fromJson(Map<String, dynamic> data) {
    return Users(
      username: data[App.usernameKey],
      name: data[App.nameKey],
      tenantName: data[App.tenantNameKey],
      tenantId: data[App.tenantIdKey],
      errorStatus: data[App.errorKey],
      enableEarn: data[App.enableEarnKey],
      enableInquiry: data[App.enableInquiryKey],
      enableRedeem: data[App.enableRedeemKey],
      enableRedeemComp: data[App.enableRedeemCompKey],
      errorMessage: data[App.errorMessageKey]
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data[App.usernameKey] = username;
    data[App.nameKey] = name;
    data[App.tenantNameKey] = tenantName;
    data[App.tenantIdKey] = tenantId;
    data[App.errorKey] = errorStatus;
    data[App.enableEarnKey] = enableEarn;
    data[App.enableInquiryKey] = enableInquiry;
    data[App.enableRedeemKey] = enableRedeem;
    data[App.enableRedeemCompKey] = enableRedeemComp;
    data[App.errorMessageKey] = errorMessage;
    return data;
  }

  static Users? parse(dynamic json) {
    if (json is Map) {
      var username = json[App.usernameKey];
      if (username != null) {
        try {
          String name = json[App.nameKey].toString();
          String tenantName = json[App.tenantNameKey].toString();
          String errorMessage = json[App.errorMessageKey].toString();
          bool errorStatus = json[App.errorKey];
          bool enableEarn = json[App.enableEarnKey];
          bool enableInquiry = json[App.enableInquiryKey];
          bool enableRedeem = json[App.enableRedeemKey];
          bool enableRedeemComp = json[App.enableRedeemCompKey];
          int tenantId = json[App.tenantIdKey];
          return Users(
            username: username,
            name: name,
            tenantName: tenantName,
            tenantId: tenantId,
            errorStatus: errorStatus,
            enableEarn: enableEarn,
            enableInquiry: enableInquiry,
            enableRedeem: enableRedeem,
            enableRedeemComp: enableRedeemComp,
            errorMessage: errorMessage
          );
        }
        catch (e) {
          log(e.toString());
        }
      }
    }
    return null;
  }

}