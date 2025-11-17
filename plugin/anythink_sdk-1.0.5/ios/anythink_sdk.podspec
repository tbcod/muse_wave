#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint anythink_sdk.podspec` to validate before publishing.
#

Pod::Spec.new do |s|
  s.name             = 'anythink_sdk'
  s.version          = '1.0.5'
  s.summary          = 'A new Flutter project.'
  s.description      = <<-DESC
A new Flutter project.
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*.{h,m}'
  s.public_header_files = 'Classes/**/*.h'
  s.dependency 'Flutter'
  s.static_framework = true
  s.platform = :ios, '12.0'
  
  #************************* Manual import ******************************#
# s.frameworks = 'SystemConfiguration', 'CoreGraphics','Foundation','UIKit','AVFoundation','AdSupport','AudioToolbox','CoreMedia','StoreKit','SystemConfiguration','WebKit','AppTrackingTransparency','CoreMotion','CoreTelephony','MessageUI','SafariServices','WebKit','CoreMotion','JavaScriptCore','CoreLocation','MediaPlayer'

#  s.pod_target_xcconfig =   {'OTHER_LDFLAGS' => ['-lObjC']}

#  s.libraries = 'c++', 'z', 'sqlite3', 'xml2', 'resolv', 'bz2.1.0','bz2','xml2','resolv.9','iconv','c++abi'

# s.vendored_frameworks = 'ThirdPartySDK/*.{framework,xcframework}'

#  s.resource = 'ThirdPartySDK/**/*.bundle'

#  s.vendored_library = 'ThirdPartySDK/**/*.a'


  #*************************************************************#

  #************************ CocoaPod **********************************#

   #podfile建议使用github源，文件顶部增加 source 'https://github.com/CocoaPods/Specs.git'

s.dependency 'AnyThinkiOS','6.4.41'
s.dependency 'TraminiSDK','6.4.41'
s.dependency 'AnyThinkDebugUISDK','1.0.3'
# s.dependency 'AnyThinkVungleSDKAdapter','6.4.27'
# s.dependency 'AnyThinkUnityAdsSDKAdapter','6.4.27'
# s.dependency 'AnyThinkPangleSDKAdapter','6.4.27'
# s.dependency 'AnyThinkFacebookSDKAdapter','6.4.27'
# s.dependency 'AnyThinkAdmobSDKAdapter','6.4.27'
# s.dependency 'AnyThinkApplovinSDKAdapter','6.4.27'
# s.dependency 'AnyThinkMintegralSDKAdapter','6.4.27'


# s.dependency 'TPNGromoreSDKAdapter','6.4.27'
# s.dependency 'TPNTTSDKAdapter_Mix','6.4.27'
# s.dependency 'TPNBaiduSDKAdapter','6.4.27'
# s.dependency 'TPNKuaiShouSDKAdapter','6.4.27'
# s.dependency 'TPNGDTSDKAdapter','6.4.27'
#
# s.dependency 'TPNAdmobSDKAdapter','6.4.27.1'
# s.dependency 'TPNMintegralSDKAdapter','6.4.27'
#
# s.dependency 'TPNDebugUISDK','1.0.3'

#*************************************************************#

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'VALID_ARCHS' => 'x86_64 armv7 arm64' }   

 # s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'VALID_ARCHS[sdk=iphonesimulator*]' => 'arm64', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => '$(inherited)' }
  
end
