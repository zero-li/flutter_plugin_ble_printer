import 'package:flutter/material.dart';
import 'package:flutter_plugin_ble_printer/ble_helper.dart';
import 'package:flutter_plugin_ble_printer/flutter_plugin_ble_printer.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
          appBar: AppBar(
            title: Text("蓝牙"),
            actions: [
              Builder(builder: (context) {
                return ElevatedButton(
                  onPressed: null,
                  child: const Text('OPEN'),
                  // onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                  //     builder: (context) => FindDevicesScreen())),
                );
              })
            ],
          ),
          body: Column(
            children: [
              Expanded(flex: 1, child: BleStateWidget()),
              ElevatedButton(
                  onPressed: () async {
                    await CPCLPrinter.formPrint(() async {
                      var temple = await CPCLPrinter.loadAssetTemple(
                          assetFilePath:
                              'assets/files/print_pick_code_w60_h40.txt',
                          mapReplace: {
                            '[dayTime]': "4-11",
                            '[pickCodeTop]': "AA123",
                            '[pickCodeBig]': "2024",
                            '[barcode]': "1363604310467",
                          });

                      await CPCLPrinter.printTemple(temple);

                      await CPCLPrinter.printImage(
                          20, 20, "assets/images/ic_baishi_mini.png");
                    });
                  },
                  child: Text("打印"))
            ],
          )),
    );
  }
}

class PrintPage extends StatelessWidget {
  const PrintPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
