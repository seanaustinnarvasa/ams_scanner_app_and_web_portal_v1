import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nustar_turnstile_scanner/utility/shared/app.data.dart';
import 'package:overlay_loading_progress/overlay_loading_progress.dart';

class Loader {
  static void close(BuildContext context) => Navigator.pop(context);

  static Widget indicator(double size, Color color) {
    return SliverFillRemaining(
      child: Container(
        margin: EdgeInsets.zero,
        child: Center(
          child: 
          SizedBox(
            height: size,
            width: size,
            child: CupertinoActivityIndicator(color: color),
          ),
        ),
      ),
    );
  }

  static Widget indicatorWithImage() {
    return Dialog(
      child: Container(
        width: 200,
        height: 200,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: ExactAssetImage(App.nustarLogo),
            fit: BoxFit.cover
          )
        ),
      )
    );
  }

  static void show(BuildContext context, int? delaySec) async {
    loadingInProgress(context);
    delaySec != 0 || delaySec != null ? 
      await Future.delayed(Duration(seconds: delaySec ?? 0)) :
      const SizedBox(width: 0);
  }

  static void stop() async {
    OverlayLoadingProgress.stop();
  }

  static void showWithGIF(BuildContext context) async {
    OverlayLoadingProgress.start(
      context,
      gifOrImagePath: '{ASSETS_GIF}',
      loadingWidth: 50,
      barrierDismissible: true
    );
  }

  static void showCustomWithGIF(BuildContext context) async {
    OverlayLoadingProgress.start(context,
      gifOrImagePath: '{ASSETS_GIF}',
      barrierDismissible: true,
      widget: Container(
        height: 100,
        width: 100,
        color: Colors.black38,
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      ));
  }

  static loadingInProgress(BuildContext context) {
    OverlayLoadingProgress.start(context, barrierDismissible: false, color: Colors.white);
  }

}