import 'package:muse_wave/tool/log.dart';
import 'package:shared_preferences/shared_preferences.dart';

Bus bus = Bus.sh;

class Bus {
  static Bus sh = Bus._();

  Bus._();

  DateTime? startTime;

  bool get isBMode {
    bool isOpenUser = museSp.getBool("isOpenUser");
    // AppLog.i("isBMode:$isOpenUser");
    return isOpenUser;
  }

  bool isLaunchLoadingAdShowing = false;

  bool get isFirstAppLaunch {
    return getAppLaunchCount <= 1;
  }

  int get getAppLaunchCount {
    final count = museSp.getInt('KeyAppLaunchCount');
    return count;
  }

  void setAppLaunchCount() {
    museSp.setInt('KeyAppLaunchCount', getAppLaunchCount + 1);
  }

  bool get isFirstShowAd {
    bool isFirst = museSp.getBool('KeyIsFirstShowAd', def: true);
    return isFirst;
  }

  void setFirstShowAd() {
    museSp.setBool('KeyIsFirstShowAd', false);
  }



}

MuseSP get museSp => MuseSP.instance;

class MuseSP {
  static final MuseSP instance = MuseSP._();

  MuseSP._();

  late SharedPreferences _museSp;

  Future init() async {
    _museSp = await SharedPreferences.getInstance();
  }

  Future setInt(String key, int value) async {
    await _museSp.setInt(key, value);
  }

  int getInt(String key) {
    int? value = _museSp.getInt(key);
    return value ?? 0;
  }


  Future setDouble(String key, double value) async {
    await _museSp.setDouble(key, value);
  }

  double getDouble(String key) {
    double? value = _museSp.getDouble(key);
    return value ?? 0;
  }



  Future setBool(String key, bool value) async {
    await _museSp.setBool(key, value);
  }

  bool getBool(String key,{bool def = false}) {
    return _museSp.getBool(key) ?? def;
  }

  Future setString(String key, String value) async {
    await _museSp.setString(key, value);
  }

  String? getString(String key) {
    String? value = _museSp.getString(key);
    return value;
  }
}
