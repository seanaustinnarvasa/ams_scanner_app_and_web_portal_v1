import 'package:nustar_turnstile_scanner/components/toast.dart';
import 'package:url_launcher/url_launcher.dart';

class URLLauncher {
  
  static void send(String URL) async {
    final uri = Uri.parse(URL);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      Toast.show("Could not launch $URL");
      // throw 'Could not launch $URL';
    }
  }

  static void sendEmail(Uri params) async {
    var url = params.toString();
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
  
}