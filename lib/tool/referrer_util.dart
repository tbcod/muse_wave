import 'package:android_play_install_referrer/android_play_install_referrer.dart';
import 'package:muse_wave/tool/bus.dart';
import 'package:muse_wave/tool/log.dart';
import 'package:muse_wave/tool/remote_utils.dart';

const String localInstallReferrerKey = "localInstallReferrerKey";
const String isABuyUserKey = "localIsABuyUserKey";

class ReferrerUtil {
  static final sh = ReferrerUtil._();

  ReferrerUtil._();

  String? get installReferrer => _installReferrer;

  String? _installReferrer;

  Future init() async {
    _installReferrer = museSp.getString(localInstallReferrerKey);
    if (_installReferrer != null && _installReferrer!.isNotEmpty) {
      AppLog.i('存在installReferrer: $_installReferrer');
      return;
    }
    ReferrerDetails details = await AndroidPlayInstallReferrer.installReferrer;
    _installReferrer = details.installReferrer;
    AppLog.i('获取installReferrer成功： $_installReferrer');
    museSp.setString(localInstallReferrerKey, _installReferrer ?? '');
  }

  bool get isBuyReferrer {
    final isBuy = museSp.getBool(isABuyUserKey);
    if (isBuy) return true;

    if (_installReferrer == null || _installReferrer!.isEmpty) return false;

    final urlList = _installReferrer!.split('&');
    final Map<String, dynamic> referrerMap = {};
    for (final params in urlList) {
      final entries = params.split('=');
      referrerMap[entries.first] = entries.last;
    }

    if (referrerMap.isEmpty) return false;


    // 检查 gclid (Google Ads)
    if (referrerMap.containsKey('gclid')) {
      museSp.setBool(isABuyUserKey, true);
      return true;
    }


    String medium = referrerMap['utm_medium'] as String? ?? '';
    if (medium == 'organic') return false;    //排出自然量

    // 检查 referrerUrl 是否包含付费渠道关键词
    final lowerReferrer = _installReferrer!.toLowerCase();
    for (final keyword in RemoteUtil.shareInstance.referParams) {
      if (lowerReferrer.contains(keyword.toLowerCase())) {
        museSp.setBool(isABuyUserKey, true);
        return true;
      }
    }

    // 有 utm_source 和 utm_campaign 的其他付费渠道
    String source = referrerMap['utm_source'] as String? ?? '';
    String campaign = referrerMap['utm_campaign'] as String? ?? '';
    if (source.isNotEmpty && campaign.isNotEmpty) {
      museSp.setBool(isABuyUserKey, true);
      return true;
    }

    return false;
  }


}
