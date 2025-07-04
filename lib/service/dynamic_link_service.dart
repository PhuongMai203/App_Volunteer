import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:share_plus/share_plus.dart';

class DynamicLinkService {
  static const String uriPrefix = 'https://helpconnecte9c17.page.link';
  static const String androidPackageName = 'com.company.help_connect';
  static const String iosBundleId = 'com.example.helpConnect';

  // CHIA SẺ CHIẾN DỊCH
  static Future<String> createCampaignDynamicLink(String campaignId) async {
    final DynamicLinkParameters parameters = DynamicLinkParameters(
      uriPrefix: uriPrefix,
      link: Uri.parse('https://help-connect-e9c17.web.app/campaigns/$campaignId'),
      androidParameters: AndroidParameters(
        packageName: androidPackageName,
        minimumVersion: 0,
      ),
      iosParameters: IOSParameters(
        bundleId: iosBundleId,
        minimumVersion: '1.0.0',
      ),
    );

    final ShortDynamicLink shortLink =
    await FirebaseDynamicLinks.instance.buildShortLink(parameters);
    return shortLink.shortUrl.toString();
  }


  static Future<void> shareCampaign(String campaignId) async {
    final url = await createCampaignDynamicLink(campaignId);
    await Share.share('share_campaign_message'.tr(namedArgs: {'url': url}));

  }
// CHIA SẺ ỨNG DỤNG

  static Future<String> createAppShareLink() async {
    final DynamicLinkParameters parameters = DynamicLinkParameters(
      uriPrefix: uriPrefix,
      link: Uri.parse('https://help-connect-e9c17.web.app'), // Link gốc khi mở app
      androidParameters: AndroidParameters(
        packageName: androidPackageName,
        minimumVersion: 0,
      ),
      iosParameters: IOSParameters(
        bundleId: iosBundleId,
        appStoreId: '1234567890', // <-- Thay bằng App Store ID thật nếu có
        minimumVersion: '1.0.0',
      ),
    );

    final ShortDynamicLink shortLink = await FirebaseDynamicLinks.instance.buildShortLink(parameters);
    return shortLink.shortUrl.toString();
  }

  static Future<void> shareApp() async {
    final url = await createAppShareLink();
    await Share.share('share_app_message'.tr(namedArgs: {'url': url}));
  }

}
