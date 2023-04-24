///
/// @Desc:
/// @Author: zhhli
/// @Date: 2021-01-08
///
import 'package:pigeon/pigeon.dart';

// 输出配置
// 控制台执行：flutter pub run pigeon --input pigeons/message_bluetooth.dart
@ConfigurePigeon(PigeonOptions(
  dartOut: './lib/src/pigeon_bluetooth.dart',
  kotlinOut:
      'android/src/main/kotlin/com/zgo/flutter_plugin_ble_printer/PigeonBluetooth.kt',
  kotlinOptions: KotlinOptions(
    // copyrightHeader: ['zero'],
    package: 'com.zgo.flutter_plugin_ble_printer',
  ),
  objcHeaderOut: 'ios/Classes/PigeonBluetooth.h',
  objcSourceOut: 'ios/Classes/PigeonBluetooth.m',
  objcOptions: ObjcOptions(
    prefix: 'FLT',
  ),
))
//
// class BleDevice{
//
//
// }
//
//
// enum ZgoBTState{
//   /// 未授权，请前往系统设置授权
//   unauthorized,
//   /// 蓝牙未开
//   off,
//   /// 正常
//   on,
//
// }
//
// // : Enums aren't yet supported for primitive arguments in FlutterApis

enum ZgoBTConnectError {
  bleTimeout, //                  = 0, ///< \~chinese 蓝牙连接超时 \~english Bluetooth connection timed out
  bleDiscoverServiceTimeout, //   = 1, ///< \~chinese 获取服务超时 \~english Get service timed out
  bleValidateTimeout, //          = 2, ///< \~chinese 验证超时 \~english Print Verification timed out
  bleUnknownDevice, //           = 3, ///< \~chinese 未知设备 \~english Unknown device
  bleSystem, //                  = 4, ///< \~chinese 系统错误 \~english System error
  bleValidateFail, //          = 5, ///< \~chinese 验证失败 \~english Verification failed
  streamTimeout, //             = 6, ///< \~chinese 流打开超时 \~english Stream open timeout
  streamEmpty, //             = 7, ///< \~chinese 打开的是空流 \~english Empty stream
  streamOccurred, //            = 8  ///< \~chinese 流发生错误 \~english An error has occurred on the stream
}

class ZgoBTDevice {
  String name;
  String address;
  String uuid;
  int state;

  ZgoBTDevice(this.name, this.address, this.uuid, this.state);
}

/// flutter call native
@HostApi()
abstract class HostBluetoothApi {
  bool isOn();

  int btState();

  /// 搜索蓝牙设备
  void scanBluetooth();

  /// 停止搜索蓝牙设备
  void stopScanBluetooth();

  /// 连接打印机
  void connectPrinter(ZgoBTDevice device);

  /// 断开打印机
  void disconnectPrinter();
}

/// native call flutter
@FlutterApi()
abstract class FlutterBluetoothApi {
  /// 获取已发现的所有打印机
  void whenFindAllDevice(List<ZgoBTDevice> list);

  void onChangeAllDeviceState(List<ZgoBTDevice> list);

  void whenConnectSuccess(ZgoBTDevice device);

  void whenConnectFailureWithErrorBlock(ZgoBTDevice device, int error);

  ///  断开连接的回调，调用disconnect断开打印机后，会调用该方法
  ///  YES表示主动断开，NO表示被动断开
  void whenDisconnect(ZgoBTDevice device, int isActive);
}
