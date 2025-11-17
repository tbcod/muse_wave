import 'dart:ui';

import 'package:get/get.dart';
import 'package:muse_wave/lang/pt_pt.dart';
import 'package:muse_wave/lang/zh_cn.dart';

import 'de_de.dart';
import 'en_us.dart';
import 'es_es.dart';
import 'fr_fr.dart';

class MyTranslations extends Translations {
  static Locale locale = Get.deviceLocale ?? const Locale("en", "US");

  static const fallbackLocale = Locale("en", "US");

  @override
  Map<String, Map<String, String>> get keys => {
    'en_US': enUS,
    'zh_CN': zhCN,
    'de_DE': deDE,
    "fr_FR": frFR,
    "es_ES": esES,
    "pt_PT": ptPT,
  };
}
