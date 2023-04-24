import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_plugin_ble_printer/src/pigeon_bluetooth.dart';
import 'package:flutter_plugin_ble_printer/src/zgo_bluetooth_api.dart';
import 'package:get/get.dart';

///
/// @Desc:
///
/// @Author: zhhli
///
/// @Date: 22/12/23
///
class BleHelper {}

class BleStateWidget extends StatelessWidget {
  const BleStateWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<int>(
          stream: ZgoBTApi.instance.state,
          initialData: 1,
          builder: (context, snapshot) {
            final state = snapshot.data;
            // bool isOn = state == BluetoothState.on;
            bool isOn = state == 1;
            if (!isOn && Platform.isAndroid) {
              ZgoBTApi.instance.turnOn();
            }

            return BleListWidget();
          }),
      floatingActionButton: Obx(() {
        if (ZgoBTApi.instance.isScanning.value) {
          return FloatingActionButton(
            onPressed: () => ZgoBTApi.instance.stopScan(),
            backgroundColor: Colors.red,
            child: const Icon(Icons.stop),
          );
        } else {
          return FloatingActionButton(
              child: const Icon(Icons.search),
              onPressed: () => ZgoBTApi.instance
                  .startScan(timeout: const Duration(seconds: 4)));
        }
      }),
    );
  }
}

class BleListWidget extends StatefulWidget {
  const BleListWidget({Key? key}) : super(key: key);

  @override
  State<BleListWidget> createState() => _BleListWidgetState();
}

class _BleListWidgetState extends State<BleListWidget> {
  @override
  Widget build(BuildContext context) {
    ZgoBTApi api = ZgoBTApi.instance;

    return RefreshIndicator(
      onRefresh: () => api.startScan(timeout: const Duration(seconds: 4)),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text("已连接"),
            Obx(() => api.deviceConnected.value == null
                ? SizedBox()
                : BleDeviceWidget(
                    device: api.deviceConnected.value!,
                    trailing: ElevatedButton(
                        onPressed: () async {
                          await ZgoBTApi.instance.disconnect();
                          // 刷新
                          setState(() {});
                        },
                        child: Text(
                          "点击断开",
                        )),
                  )),
            const Text("未连接"),
            Obx(
              () => Column(
                  children: ZgoBTApi.instance.scanResults.value
                      .where((device) {
                        print("widget scanResults: ${device.name}");

                        return device.name != api.deviceConnected.value?.name;
                      })
                      .map((device) => BleDeviceWidget(
                            device: device,
                            trailing: ElevatedButton(
                                onPressed: () async {
                                  ///await CPCLPrinter.portOpen(device);
                                  await ZgoBTApi.instance
                                      .connectPrinter(device);
                                  // 刷新
                                  setState(() {});
                                },
                                child: Text(
                                  "点击连接",
                                )),
                          ))
                      .toList()),
            ),
          ],
        ),
      ),
    );
  }
}

class BleDeviceWidget extends StatelessWidget {
  const BleDeviceWidget(
      {Key? key, required this.device, required this.trailing})
      : super(key: key);

  final ZgoBTDevice device;
  final Widget trailing;

  @override
  Widget build(BuildContext context) {
    // return StreamBuilder<ZgoBTDeviceState>(
    //   stream: ZgoBTApi.instance.deviceState(device),
    //   initialData: ZgoBTDeviceState.connecting,
    //   builder: (c, snapshot) => ListTile(
    //     leading: Column(
    //       mainAxisAlignment: MainAxisAlignment.center,
    //       children: [
    //         snapshot.data == ZgoBTDeviceState.connected
    //             ? const Icon(Icons.bluetooth_connected)
    //             : const Icon(Icons.bluetooth_disabled),
    //       ],
    //     ),
    //     title: Text(device.name),
    //     subtitle: Text(device.address),
    //     trailing: trailing,
    //   ),
    // );

    return ListTile(
      leading: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          device.state == 2
              ? const Icon(Icons.bluetooth_connected)
              : const Icon(Icons.bluetooth_disabled),
        ],
      ),
      title: Text(device.name),
      subtitle: Text(device.address),
      trailing: trailing,
    );
  }
}
