import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waveandsosa/waveandsosa.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // const MethodChannel channel = MethodChannel('com.wave.and.sosa');
  //
  // setUp(() {
  //   TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
  //     channel,
  //     (MethodCall methodCall) async {
  //       return '42';
  //     },
  //   );
  // });
  //
  // tearDown(() {
  //   TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, null);
  // });

  test('getPlatformVersion', () async {
    expect(await Waveandsosa.getPlatformVersion(), '42');
  });
}
