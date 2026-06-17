import 'dart:convert';
import 'dart:developer';
import 'package:nustar_turnstile_scanner/utility/shared/app.data.dart';

List<Points> pointsFromJson(String str) =>
    List<Points>.from(json.decode(str).map((x) => Points.fromJson(x)));

String pointsToJson(List<Points> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));
    
class Points {
  String? membershipId;
  String? tenantId;
  String? transactionId;
  double? amount;
  String? userId;
  int? points;
  int? updatedPoints;
  String? transaction;
  int? rewardsBalance;
  bool? pinCorrect;
  bool? errorStatus;
  String? errorMessage;
  // String? playerId;
  dynamic playerId;
  String? cardTier;
  String? firstName;
  String? lastName;

  Points({
    this.membershipId,
    this.tenantId,
    this.transactionId,
    this.amount,
    this.userId,
    this.points,
    this.updatedPoints,
    this.transaction,
    this.rewardsBalance,
    this.pinCorrect,
    this.errorStatus,
    this.errorMessage,
    this.playerId,
    this.cardTier,
    this.firstName,
    this.lastName
  });

  factory Points.fromJson(Map<String, dynamic> data) {
    return Points(
      membershipId: data[App.membershipIdPrm],
      transaction: data[App.transactionKey],
      points: data[App.points.toLowerCase()],
      updatedPoints: data[App.updatedPointsKey],
      rewardsBalance: data[App.rewardsBalanceKey],
      pinCorrect: data[App.pinCorrect],
      errorStatus: data[App.errorKey],
      errorMessage: data[App.errorMessageKey],
      playerId: data[App.playerIdKey],
      cardTier: data[App.cardIdKey],
      firstName: data[App.firstNameKey],
      lastName: data[App.lastNameKey],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data[App.membershipIdPrm] = membershipId;
    data[App.transactionKey] = transaction;
    data[App.points.toLowerCase()] = points;
    data[App.updatedPointsKey] = updatedPoints;
    data[App.rewardsBalanceKey] = rewardsBalance;
    data[App.pinCorrect] = pinCorrect;
    data[App.errorKey] = errorStatus;
    data[App.errorMessageKey] = errorMessage;
    data[App.playerIdKey] = playerId;
    data[App.cardIdKey] = cardTier;
    data[App.firstNameKey] = firstName;
    data[App.lastNameKey] = lastName;
    return data;
  }

  static Points? parse(dynamic json) {
    if ( json is Map ) {
      var membershipId = json[App.membershipIdPrm.capitalize()];
      if (membershipId != null) {
        try {
          String transaction = json[App.transactionKey].toString();
          String errorMessage = json[App.errorMessageKey].toString();
          String playerID = json[App.playerIdKey].toString();
          String cardTier = json[App.cardIdKey].toString();
          String firstName = json[App.firstNameKey].toString();
          String lastName = json[App.lastNameKey].toString();
          int points = json[App.points.toLowerCase()];
          int updatedPoints = json[App.updatedPointsKey];
          int rewardsBalance = json[App.rewardsBalanceKey];
          bool pinCorrect = json[App.pinCorrect];
          bool errorStatus = json[App.errorKey];
          return Points(
            membershipId: membershipId,
            transaction: transaction,
            points: points,
            updatedPoints: updatedPoints,
            rewardsBalance: rewardsBalance,
            pinCorrect: pinCorrect,
            errorStatus: errorStatus,
            errorMessage: errorMessage,
            playerId: playerID,
            cardTier: cardTier,
            firstName: firstName,
            lastName: lastName
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