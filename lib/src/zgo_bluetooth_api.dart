import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_plugin_ble_printer/src/pigeon_bluetooth.dart';
import 'package:get/get.dart';

///
/// @Desc:
///
/// @Author: zhhli
///
/// @Date: 23/4/17
///
///
// part of flutter_plugin_ble_printer;

enum ZgoBTDeviceState {
  disconnect,
  connecting,
  connected,
  disconnecting,
  ;
}

extension BTDeviceState on ZgoBTDevice {
  ZgoBTDeviceState get state {
    return ZgoBTDeviceState.values[this.state];
  }
}

class ZgoBTApi extends FlutterBluetoothApi {
  static const String namespace = 'flutter_plugin_ble_printer';

  ZgoBTApi._() {
    FlutterBluetoothApi.setup(this);

    _stateEventChannel.receiveBroadcastStream().listen((event) {
      if (event is Map && event.containsKey("state")) {
        // var state = ZgoBTConnectState.values[event["state"]];
        // _connectStateStreamController.add(state);
      }
    });
  }

  static final ZgoBTApi _instance = ZgoBTApi._();

  static ZgoBTApi get instance => _instance;

  final EventChannel _stateEventChannel =
      const EventChannel('$namespace/state');

  final Rx<ZgoBTDevice?> _deviceConnected = Rx(null);
  final Rx<List<ZgoBTDevice>> _scanResults = Rx([]);
  final Rx<bool> _isScanning = Rx(false);

  Rx<ZgoBTDevice?> get deviceConnected => _deviceConnected;

  Rx<List<ZgoBTDevice>> get scanResults => _scanResults;

  Rx<bool> get isScanning => _isScanning;

  final HostBluetoothApi _api = HostBluetoothApi();

  Future<bool> isOn() async {
    return await _api.isOn();
  }

  /// Gets the current state of the Bluetooth module
  Stream<int> get state async* {
    yield* _stateEventChannel.receiveBroadcastStream().map((s) => s);
  }

  Future<void> turnOn() async {}

  Future<List<ZgoBTDevice>> startScan({
    Duration? timeout,
  }) async {
    await scan(timeout: timeout);
    return scanResults.value;
  }

  Future<void> scan({
    Duration? timeout,
  }) async {
    if (isScanning.value == true) {
      throw Exception('Another scan is already in progress.');
    }

    // Emit to isScanning
    _isScanning.value = true;

    // Clear scan results list
    _scanResults.value = [];

    await _api.scanBluetooth();

    timeout ??= Duration(seconds: 4);

    await Future.delayed(timeout);

    await stopScan();
  }

  Future<void> stopScan() async {
    _isScanning.value = false;
    await _api.stopScanBluetooth();
  }

  Future<void> connectPrinter(ZgoBTDevice device) async {
    await _api.connectPrinter(device);
  }

  Future<void> disconnect() async {
    await _api.disconnectPrinter();
  }

  @override
  void onChangeBluetoothState(int state) {
    // switch(state){
    //   case 0:
    //     _state = ZgoBTState.unauthorized;
    //     break;
    //   case 1:
    //     _state = ZgoBTState.off;
    //     break;
    //   case 2:
    //     _state = ZgoBTState.off;
    //     break;
    // }
  }

  @override
  void whenFindAllDevice(List<ZgoBTDevice?> list) {
    List<ZgoBTDevice> listNew = [];

    for (var device in list) {
      debugPrint(
          "whenFindAllDevice ${device?.name}  address: ${device?.address}");
      if (device != null) {
        listNew.add(device);
      }
    }

    debugPrint("whenFindAllDevice :${listNew.length}");
    _scanResults.value = listNew;
  }

  @override
  void onChangeAllDeviceState(List<ZgoBTDevice?> list) {
    List<ZgoBTDevice> listNew = [];

    for (var device in list) {
      debugPrint(
          "onChangeAllDeviceState ${device?.name}  state: ${device?.state}");
      if (device != null) {
        listNew.add(device);
      }
    }

    debugPrint("changeAllDevice :${listNew.length}");
    _scanResults.value = listNew;
  }

  @override
  void whenConnectFailureWithErrorBlock(ZgoBTDevice device, int error) {
    if (_deviceConnected.value?.address == device.address) {
      _deviceConnected.value = null;
    }

    debugPrint("connectFailure :${device.name}");
  }

  @override
  void whenConnectSuccess(ZgoBTDevice device) {
    if (_deviceConnected.value?.address != device.address) {
      debugPrint("whenConnectSuccess: ${device.name} ${device.state}");

      _deviceConnected.value = device;
    }
    debugPrint("connectSuccess :${device.name}");
  }

  @override
  void whenDisconnect(ZgoBTDevice device, int isActive) {
    if (_deviceConnected.value?.address == device.address) {
      _deviceConnected.value = null;
    }

    debugPrint("disconnect :${device.name}");
  }
}
