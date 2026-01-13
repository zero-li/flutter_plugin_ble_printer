package com.zgo.flutter_plugin_ble_printer.printer

import android.content.res.AssetManager
import android.graphics.BitmapFactory
import android.util.Log
import com.zgo.flutter_plugin_ble_printer.IPrinter
import com.zgo.flutter_plugin_ble_printer.ZgoBTDevice
import cpcl.PrinterHelper
import io.flutter.embedding.engine.plugins.FlutterPlugin

class  HMPrinter : IPrinter {

    lateinit var binding: FlutterPlugin.FlutterPluginBinding

    override fun initBinding(binding: FlutterPlugin.FlutterPluginBinding) {
        this.binding = binding
    }
    override fun connectPrinter(device: ZgoBTDevice) : Long {
        var connecting = 0
        var result = 0
        while (connecting < 3) {
            result = PrinterHelper.PortOpen("Bluetooth,${device.address}")
            PrinterHelper.logcat("portOpen:$result")

            if (result != 0) {
                Thread.sleep(500)
                connecting++
            } else {
                break

            }

        }

        if (result == 0) {
            PrinterHelper.logcat("连接成功")
        } else {
            PrinterHelper.logcat("连接失败")
        }

        return  result.toLong()
    }

    override fun disconnectPrinter() {
        PrinterHelper.portClose()
    }


    override fun printText(text: String) {
        PrinterHelper.printText(text)
    }

    override fun printImage(x: Long, y: Long, filePath: String) {
        val assetManager: AssetManager = binding.applicationContext.assets

        val filePathAndroid = binding.flutterAssets.getAssetFilePathBySubpath(filePath)
        // filePath: images/ic_zhongtong_mini.png
        //filePathAndroid: flutter_assets/images/ic_zhongtong_mini.png

        Log.d("zgo_print_plugin", "filePath: $filePath $x $y")
        Log.d("zgo_print_plugin", "filePathAndroid: $filePathAndroid")

        val expressLogo = assetManager.open(filePathAndroid)
        val bitmap = BitmapFactory.decodeStream(expressLogo)


        PrinterHelper.Expanded(x.toString(), y.toString(), bitmap, 0, 0)


    }


    /**
     * 打印二维码
     * ommand PrinterHelper.BARCODE：⽔平⽅向
     *        PrinterHelper.VBARCODE：垂直⽅向
     *
     * x     ⼆维码的起始横坐标。（单位：dot）
     *
     * y     ⼆维码的起始纵坐标。（单位：dot）
     *
     * M     QR的类型：
     *       1：普通类型
     *       2：在类型1的基础上增加了个别的符号
     *
     * U     单位宽度/模块的单元⾼度,范围是1到32默认为6
     *
     * data  ⼆维码的数据
     */
    override fun printQrCode(
        command: String,
        x: String,
        y: String,
        M: String,
        U: String,
        data: String
    ) {
        PrinterHelper.PrintQR(command, x, y, M, U, data)

    }

    override fun printBarcode(
        command: String, type: String, width: String, ratio: String, height: String,
        x: String, y: String, undertext: Boolean, number: String, size: String,
        offset: String, data: String
    ) {
        PrinterHelper.Barcode(
            command,
            type,
            width,
            ratio,
            height,
            x,
            y,
            undertext,
            number,
            size,
            offset,
            data
        )

    }


    override fun print() {
        PrinterHelper.Print()
    }

    override fun form() {
        PrinterHelper.Form()
    }


    /// 0 发送成功
    //1 发送失败
    //2 打印失败（开盖）
    //-1 超时（在设置的时间内打印机没有回馈）
    override fun getEndStatus(secondTimeout: Long): Long {
        val status = PrinterHelper.getEndStatus(secondTimeout.toInt())
        return status.toLong()
    }


}