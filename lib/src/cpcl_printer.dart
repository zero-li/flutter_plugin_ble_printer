part of flutter_plugin_ble_printer;


class CPCLPrinter {
  CPCLPrinter._();


  static final FlutterPrintApi _api = FlutterPrintApi();

  // static Future<bool> portOpen(ZgoBTDevice device) async {
  //   var connecting = 1;
  //   // 重试3次
  //   while (connecting < 3) {
  //     int portOpen = await _api.portOpen(device.address);
  //     if (portOpen == 0) {
  //       isConnected = true;
  //       CPCLPrinter.device = device;
  //       // 跳出while
  //       connecting = 5;
  //     } else {
  //       connecting = connecting + 1;
  //       isConnected = false;
  //
  //       await Future.delayed(Duration(seconds: 3));
  //     }
  //     debugPrint("正在连接 isConnected: $isConnected");
  //   }
  //
  //   debugPrint("连接状态 isConnected: $isConnected");
  //
  //   return isConnected;
  // }

  // 打印模板
  static Future<void> printTemple(String temple) async {
    await _api.printText(temple);
  }

  /// 打印图片
  /// https://flutter.cn/docs/development/ui/assets-and-images#loading-flutter-assets-in-ios
  ///
  /// flutter:
  ///   assets:
  ///     - icons/heart.png
  /// filePath = assets/icons/heart.png
  static Future<void> printImage(int x, int y, String filePath) async {
    await _api.printImage(x, y, filePath);
  }

  static Future<void> print() async {
    await _api.print();
  }

  static Future<void> form() async {
    await _api.form();
  }

  // static Future<void> portClose() async {
  //   await _api.portClose();
  //   isConnected = false;
  //   device = null;
  // }

  /// 'assets/files/print_mail_sto_cpcl.txt'
  /// 'assets/files/print_pick_code_w60_h40.txt'
  /// 'assets/files/print_pick_code_w40_h30.txt'
  static Future<String> loadAssetTemple({required String assetFilePath,
    required Map<String, dynamic> mapReplace}) async {
    var content = await rootBundle.loadString(assetFilePath);

    mapReplace.forEach((key, value) {
      content = content.replaceAll(key, value);
    });

    return content;
  }

  static Future<void> formPrint(AsyncPrintFunction block) async {
    await block();
    //await form();
    await print();
  }
}

typedef AsyncPrintFunction = Future<void> Function();
