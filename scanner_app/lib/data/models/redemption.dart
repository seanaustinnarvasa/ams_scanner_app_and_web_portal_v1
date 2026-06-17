import 'package:nustar_turnstile_scanner/utility/shared/app.data.dart';

class Redemption {
  int? playerId;
  List<dynamic>? vouchers;
  bool? errorStatus;
  String? errorMessage;
  dynamic status;
  int? voucherId;
  String? username;
  String? deviceimei;

  Redemption({
    this.playerId,
    this.vouchers,
    this.errorStatus,
    this.errorMessage,
    this.status,
    this.voucherId,
    this.username,
    this.deviceimei
  });

  factory Redemption.fromJson(Map<String, dynamic> data) {
    return Redemption(
      playerId: data[App.playerIdKey],
      vouchers: data[App.vouchersKey],
      errorStatus: data[App.errorKey],
      errorMessage: data[App.errorMessageKey],
      status: data[App.statusKey],
      voucherId: data[App.voucherIdKey],
      username: data[App.usernameKey],
      deviceimei: data[App.deviceImeiKey],
    );
  }

}