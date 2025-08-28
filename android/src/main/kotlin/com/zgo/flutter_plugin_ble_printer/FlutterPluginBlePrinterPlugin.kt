package com.zgo.flutter_plugin_ble_printer


import android.content.Context
import android.content.res.AssetManager
import android.graphics.BitmapFactory
import android.util.Log
import cpcl.PrinterHelper
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding


/** FlutterPluginBlePrinterPlugin */
class FlutterPluginBlePrinterPlugin : FlutterPlugin, ActivityAware, FlutterPrintApi {

    lateinit var context: Context
    lateinit var binding: FlutterPlugin.FlutterPluginBinding

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        context = binding.applicationContext
        this.binding = binding


    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        FlutterPrintApi.setUp(binding.binaryMessenger, null)
    }


    override fun printText(text: String) {
        PrinterHelper.printText(text)
    }

    override fun printImage(x: Long, y: Long, filePath: String) {
        val assetManager: AssetManager = context.assets

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

    override fun getEndStatus(secondTimeout: Long): Long {
        val status = PrinterHelper.getEndStatus(secondTimeout.toInt())
        return status.toLong()
    }

    override fun onAttachedToActivity(bindingAct: ActivityPluginBinding) {

        HostBluetoothApi.setUp(binding.binaryMessenger, ZgoBluetoothApi(binding, bindingAct))
        // setup
        FlutterPrintApi.setUp(binding.binaryMessenger, this)


        PrinterHelper(context, PrinterHelper.PRINT_NAME_A300)
        PrinterHelper.isWriteLog = true
        PrinterHelper.isLog = true

        Log.d("zgo", "onAttachedToActivity")
    }

    override fun onDetachedFromActivityForConfigChanges() {

    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {

    }

    override fun onDetachedFromActivity() {

    }


}


//  PrinterHelper.printBitmap(x,  y,  type,  bitmap,  compressType, boolean from, int light);