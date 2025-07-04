import 'package:easy_localization/easy_localization.dart';
import 'package:url_launcher/url_launcher.dart';

class FacebookShareHelper {
  static Future<void> shareToFacebook({
    required String urlToShare,
    String quote = '',
  }) async {
    final encodedUrl = Uri.encodeComponent(urlToShare);
    final encodedQuote = Uri.encodeComponent(quote);

    final fbShareUrl =
        'https://www.facebook.com/sharer/sharer.php?u=$encodedUrl&quote=$encodedQuote';

    if (await canLaunchUrl(Uri.parse(fbShareUrl))) {
      await launchUrl(Uri.parse(fbShareUrl), mode: LaunchMode.externalApplication);
    } else {
      throw "cannot_open_browser_to_share_Facebook".tr();
    }
  }
}
