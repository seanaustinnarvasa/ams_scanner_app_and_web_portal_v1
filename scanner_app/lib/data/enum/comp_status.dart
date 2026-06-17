enum CompStatus {
  none('none'),
  issued('Issued'),
  redeemed('Redeemed'),
  expired('Expired'),
  voided('Voided');

  const CompStatus(this.rawValue);

  final String rawValue;
}

extension CompStatusX on CompStatus {
  static CompStatus fromString(String type) {
    switch (type) {
      case "issued":
        return CompStatus.issued;
      case "redeemed":
        return CompStatus.redeemed;
      case "expired":
        return CompStatus.expired;
      case "voided":
        return CompStatus.voided;
      default:
        return CompStatus.none;
    }
  }
}
