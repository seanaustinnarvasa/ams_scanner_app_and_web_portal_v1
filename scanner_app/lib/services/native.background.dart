class NativeBackground {
  static final NativeBackground _instance = NativeBackground._internal();
  NativeBackground._internal();

  factory NativeBackground() => _instance;
  // factory NativeBackground() => _instance != null ? NativeBackground._() :

  NativeBackground._() {
    handlePlatformChannelMethods();
  }

  Future <void> handlePlatformChannelMethods() async {}
}