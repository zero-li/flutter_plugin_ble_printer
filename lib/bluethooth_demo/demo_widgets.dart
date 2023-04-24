///
/// @Desc:
///
/// @Author: zhhli
///
/// @Date: 22/12/21
///
import 'package:flutter/material.dart';
import 'package:flutter_plugin_ble_printer/src/pigeon_bluetooth.dart';

class ScanResultTile extends StatelessWidget {
  const ScanResultTile({Key? key, required this.device, this.onTap})
      : super(key: key);

  final ZgoBTDevice device;
  final VoidCallback? onTap;

  Widget _buildTitle(BuildContext context) {
    if (device.name.isNotEmpty) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            device.name,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            device.address,
            style: Theme.of(context).textTheme.caption,
          )
        ],
      );
    } else {
      return Text(device.address);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: _buildTitle(context),
      // leading: Text(result.rssi.toString()),
      trailing: ElevatedButton(
        style: ElevatedButton.styleFrom(
          primary: Colors.black,
          onPrimary: Colors.white,
        ),
        onPressed: onTap,
        child: const Text('点击连接'),
      ),
      children: <Widget>[],
    );
  }
}
