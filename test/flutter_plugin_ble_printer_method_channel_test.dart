import 'package:flutter/services.dart';
import 'package:flutter_plugin_ble_printer/src/pigeon_ble_printer.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  FlutterPrintApi platform = FlutterPrintApi();
  const MethodChannel channel = MethodChannel('flutter_plugin_ble_printer');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getEndStatus', () async {
    expect(await platform.getEndStatus(3), 1);
  });
}
