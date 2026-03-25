
import 'dart:async';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:muse_wave/muse_config.dart';
import 'package:muse_wave/tool/bus.dart';
import 'package:muse_wave/tool/log.dart';

class UmpUtil {
  static final UmpUtil sh = UmpUtil._();

  UmpUtil._();

  static const keyObtainedIsMuseUmpShowed = "kMuseShowedObtainedKey";
  static const keIsyMusRequested = "kMuseIsRequestedKey";

  Completer<bool>? completer;

  Future<void> showUMP() async {
    ConsentRequestParameters params = ConsentRequestParameters();
    completer = Completer();
    if (!MuseConfig.isUser) {
      // DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      // String testIdentifier = (await deviceInfo.androidInfo).identifierForVendor ?? "";
      // ConsentDebugSettings debugSettings = ConsentDebugSettings(debugGeography: DebugGeography.debugGeographyEea, testIdentifiers: [testIdentifier]);
      // params = ConsentRequestParameters(consentDebugSettings: debugSettings);
    }

    Future.delayed(const Duration(seconds: 22)).then((value) {
      if (!completer!.isCompleted) completer!.complete(true);
    });
    ConsentInformation.instance.requestConsentInfoUpdate(
      params,
          () async {
        if (await ConsentInformation.instance.isConsentFormAvailable()) {
          ConsentForm.loadConsentForm(
                (ConsentForm consentForm) async {
              var status = await ConsentInformation.instance.getConsentStatus();
              museSp.setBool(keIsyMusRequested, true);
              if (status == ConsentStatus.required) {
                consentForm.show(
                      (FormError? formError) async {
                    var status = await ConsentInformation.instance.getConsentStatus();
                    AppLog.i("【UMP】show status:${status.name}, error:${formError?.message}");
                    museSp.setBool(keyObtainedIsMuseUmpShowed, status == ConsentStatus.obtained);
                    if (!completer!.isCompleted) completer!.complete(true);
                  },
                );
              } else {
                if (!completer!.isCompleted) completer!.complete(true);
              }
            },
                (formError) {
              if (!completer!.isCompleted) completer!.complete(true);
              AppLog.e("【UMP】formError: ${formError.message}");
            },
          );
        } else {
          AppLog.e("【UMP】无效");
          museSp.setBool(keIsyMusRequested, true);
          if (!completer!.isCompleted) completer!.complete(true);
        }
      },
          (FormError error) {
            AppLog.e("【UMP】message error:${error.message}");
        if (!completer!.isCompleted) completer!.complete(true);
      },
    );
  }

  // void reset() {
  //   ConsentInformation.instance.reset();
  // }
  //
  // bool get isObtained {
  //   return museSp.getBool(keyUmpObtainedIsShowed);
  // }
}