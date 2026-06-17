import 'dart:convert';
import 'package:nustar_turnstile_scanner/utility/shared/app.data.dart';

List<Comps> pointsFromJson(String str) => List<Comps>.from(json.decode(str).map((x) => Comps.fromJson(x)));

String pointsToJson(List<Comps> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));
    
class Comps {
  String? compId;
  String? compStatus;
  bool? success;
  String? errorMessage;

  Comps({
    this.compId,
    this.compStatus,
    this.success,
    this.errorMessage
  });

  factory Comps.fromJson(Map<String, dynamic> data) {
    return Comps(
      compId: data[App.compIdKey],
      compStatus: data[App.compStatusKey],
      success: data[App.successKey],
      errorMessage: data[App.errorMessageKey]
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data[App.compIdKey] = compId;
    data[App.compStatusKey] = compStatus;
    data[App.successKey] = success;
    data[App.errorMessageKey] = errorMessage;
    return data;
  }

}