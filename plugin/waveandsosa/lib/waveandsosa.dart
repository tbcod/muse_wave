import 'package:flutter/services.dart';


// ['com.example.muse_wave', 'com.musewave.player.music',  #包名
// 'va/us/ass/Jii',  // jni路径
// '"dmsMia"', '"sdVV"',  #jni 函数
// 'va/us/ass/Hid',  # hander
// 'va/us/ass/Wocc',  # wvcClass
// '/wac']

class Waveandsosa {
  static const _methodChannel = MethodChannel('com.wave.and.sosa');

  static Future<String?> getPlatformVersion() async {
    try {
      final version = await _methodChannel.invokeMethod<String>('getPlatformVersion');
      print('getting platform version: $version');
      return version;
    } catch (e) {
      print('Error getting platform version: $e');
      return null;
    }
  }

  static Future bbGo() async {
    final res = await _methodChannel.invokeMethod('bbGo');
    print('bbGo: $res');
    return res;
  }

  static Future bbStop() async {
    final res = await _methodChannel.invokeMethod('bbStop');
    print('bbStop: $res');
    return res;
  }
}
