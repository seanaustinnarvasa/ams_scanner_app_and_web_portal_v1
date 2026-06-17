import 'dart:developer';
    
class Token {
  String? userId;
  String? password;
  String? clientKey;
  String? key;
  String? expiration;
  bool? hasError;
  String? errorMessage;

  Token({
    this.userId,
    this.password,
    this.clientKey,
    this.key,
    this.expiration,
    this.hasError,
    this.errorMessage
  });

  factory Token.fromJson(Map<String, dynamic> data) {
    return Token(
      userId: data["userId"],
      password: data["password"],
      clientKey: data["clientKey"],
      key: data["key"],
      expiration: data["expiration"],
      hasError: data["hasError"],
      errorMessage: data["errorMessage"],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['userId'] = userId;
    data['password'] = password;
    data['clientKey'] = clientKey;
    data['key'] = key;
    data['expiration'] = expiration;
    data['hasError'] = hasError;
    data['ErrorMessage'] = errorMessage;
    return data;
  }

  static Token? parse(dynamic json) {
    if ( json is Map ) {
      var userId = json['userId'];
      if (userId != null) {
        try {
          String password = json['password'].toString();
          String clientKey = json['clientKey'].toString();
          String key = json['key'].toString();
          String expiration = json['expiration'].toString();
          String errorMessage = json['ErrorMessage'].toString();
          bool hasError = json['hasError'];
          return Token(
            userId: userId,
            password: password,
            clientKey: clientKey,
            key: key,
            expiration: expiration,
            errorMessage: errorMessage,
            hasError: hasError
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