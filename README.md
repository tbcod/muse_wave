# muse_wave

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

包名
测试包名：com.example.muse_wave
正式包名：com.musewave.player.music


keytool -genkey -v -keystore android/release.jks -storetype JKS -keyalg RSA -keysize 2048 -validity 10000 -alias mw

flutter build apk --obfuscate --split-debug-info=build/app/outputs/symbols
flutter build appbundle --obfuscate --split-debug-info=build/app/outputs/symbols

keytool -list -v -keystore android/release.jks -storepass mw1332
keytool -list -v -keystore android/tb.jks -storepass tb123456

//获取hash值

keytool -exportcert -alias androiddebugkey -keystore %HOMEPATH%\.android\debug.keystore | openssl sha1 -binary | openssl
base64

