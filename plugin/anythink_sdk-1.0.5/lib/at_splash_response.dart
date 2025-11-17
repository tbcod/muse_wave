
import 'package:anythink_sdk/at_base_response.dart';

/*Splash status */
enum SplashStatus {
  splashDidFinishLoading,
  splashDidFailToLoad,
  splashDidTimeout,
  splashDidShowSuccess,
  splashDidShowFailed,
  splashDidClick,
  splashDidClose,
  splashWillClose,
  splashDidDeepLink,

  splashUnknown
}

/*Splash callback */
class ATSplashResponse extends BaseResponse {
  final SplashStatus splashStatus;
  final Map extraMap;
  final bool? isTimeout;

  ATSplashResponse(this.splashStatus,this.extraMap,String errStr,String placementID,bool isDeeplinkSuccess, this.isTimeout):
        super(errStr,placementID,isDeeplinkSuccess);


  factory ATSplashResponse.withMap(Map map) {
    var tempSplashStatus;

    // 为可能为空的字符串参数添加默认值
    var requestMessage = map['requestMessage'] as String? ?? '';
    var placementID = map['placementID'] as String? ?? '';
    var adStatus = map['callbackName'] as String? ?? '';

    // 初始化 Map 类型的额外数据
    var tempExtraMap = map.containsKey('extraDic') && map['extraDic'] != null
        ? map['extraDic']
        : {'message': 'No additional information'};

    // 处理布尔值，确保有默认值
    var isDeeplinkSuccess = map['isDeeplinkSuccess'] as bool? ?? false;
    var isTimeout = map['isTimeout'] as bool? ?? false;

    // 状态判断
    switch (adStatus) {
      case 'splashDidFailToLoad':
        tempSplashStatus = SplashStatus.splashDidFailToLoad;
        break;
      case 'splashDidFinishLoading':
        tempSplashStatus = SplashStatus.splashDidFinishLoading;
        break;
      case 'splashDidTimeout':
        tempSplashStatus = SplashStatus.splashDidTimeout;
        break;
      case 'splashDidShowSuccess':
        tempSplashStatus = SplashStatus.splashDidShowSuccess;
        break;
      case 'splashDidShowFailed':
        tempSplashStatus = SplashStatus.splashDidShowFailed;
        break;
      case 'splashDidClick':
        tempSplashStatus = SplashStatus.splashDidClick;
        break;
      case 'splashDidClose':
        tempSplashStatus = SplashStatus.splashDidClose;
        break;
      case 'splashWillClose':
        tempSplashStatus = SplashStatus.splashWillClose;
        break;
      case 'splashDidDeepLink':
        tempSplashStatus = SplashStatus.splashDidDeepLink;
        break;
      default:
        tempSplashStatus = SplashStatus.splashUnknown;
    }

    return ATSplashResponse(
        tempSplashStatus,
        tempExtraMap,
        requestMessage,
        placementID,
        isDeeplinkSuccess,
        isTimeout
    );
  }
}







