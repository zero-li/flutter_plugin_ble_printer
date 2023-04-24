///
/// @Desc:
/// @Author: zhhli
/// @Date: 2021-01-08
///
import 'package:pigeon/pigeon.dart';

// 输出配置
// 控制台执行：flutter pub run pigeon --input pigeons/message.dart
@ConfigurePigeon(PigeonOptions(
  dartOut: './lib/pigeon_ble_printer.dart',
  kotlinOut:
      'android/src/main/kotlin/com/zgo/flutter_plugin_ble_printer/Pigeon.kt',
  kotlinOptions: KotlinOptions(
    // copyrightHeader: ['zero'],
    package: 'com.zgo.flutter_plugin_ble_printer',
  ),
  objcHeaderOut: 'ios/Classes/Pigeon.h',
  objcSourceOut: 'ios/Classes/Pigeon.m',
  objcOptions: ObjcOptions(
    prefix: 'FLT',
  ),
))
@HostApi()
abstract class FlutterPrintApi {
  /// 打印文本数据
  void printText(String text);

  /// 打印图片
  /// https://flutter.cn/docs/development/ui/assets-and-images#loading-flutter-assets-in-ios
  /// flutter:
  ///   assets:
  ///     - icons/heart.png
  /// filePath = assets/icons/heart.png
  ///
  void printImage(int x, int y, String filePath);

  /// 控制打印机走纸到标签缝隙（标缝）
  void form();

  /// 打印输出
  void print();

  /// 获取状态
  int getEndStatus(int secondTimeout);
}
