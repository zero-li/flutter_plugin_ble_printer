package com.zgo.flutter_plugin_ble_printer.printer

import android.content.res.AssetManager
import android.graphics.BitmapFactory
import android.util.Log
import com.zgo.flutter_plugin_ble_printer.IPrinter
import com.zgo.flutter_plugin_ble_printer.ZgoBTDevice
import cpcl.PrinterHelper
import io.flutter.embedding.engine.plugins.FlutterPlugin
import net.posprinter.CPCLConst
import net.posprinter.CPCLPrinter
import net.posprinter.IDeviceConnection
import net.posprinter.POSConnect
import java.nio.charset.Charset

class  XPrinter : IPrinter {

    lateinit var binding: FlutterPlugin.FlutterPluginBinding

    private    var connect : IDeviceConnection? = null

    private var printer: CPCLPrinter? = null


    override fun initBinding(binding: FlutterPlugin.FlutterPluginBinding) {
        this.binding = binding
        POSConnect.init(binding.applicationContext)
        POSConnect.openLog( true)
    }
    override fun connectPrinter(device: ZgoBTDevice) : Long {
        var connecting = 0
        var result = false


        connect?.close()
        connect = POSConnect.createDevice(POSConnect.DEVICE_TYPE_BLUETOOTH)


        while (connecting < 3) {
            //result = PrinterHelper.PortOpen("Bluetooth,${device.address}")

            result = connect!!.connectSync(device.address){ code,connInfo, msg ->
                when (code) {
                    POSConnect.CONNECT_SUCCESS -> {
                        Log.d("zgo_print_plugin", "connectCallback: CONNECT_SUCCESS $msg")
//                        UIUtils.toast(R.string.con_success)
//                        connectCallback?.let { it(true) }
                    }
                    POSConnect.CONNECT_FAIL -> {
                        Log.e("zgo_print_plugin", "connectCallback: CONNECT_FAIL $msg")
//                        UIUtils.toast(R.string.con_failed)
//                        connectCallback?.let { it(false) }
                    }
                    POSConnect.CONNECT_INTERRUPT -> {
                        Log.e("zgo_print_plugin", "connectCallback: CONNECT_INTERRUPT $msg")
//                        UIUtils.toast(R.string.con_has_disconnect)
//                        connectCallback?.let { it(false) }
                    }
                    POSConnect.SEND_FAIL -> {
                        Log.e("zgo_print_plugin", "connectCallback: SEND_FAIL $msg")
//                        UIUtils.toast(R.string.send_failed)
                    }
                    POSConnect.USB_DETACHED -> {
                        Log.e("zgo_print_plugin", "connectCallback: USB_DETACHED $msg")
//                        UIUtils.toast(R.string.usb_detached)
                    }
                    POSConnect.USB_ATTACHED -> {
                        Log.e("zgo_print_plugin", "connectCallback: USB_ATTACHED $msg")
//                        UIUtils.toast(R.string.usb_attached)
                    }
                }


            }




            PrinterHelper.logcat("portOpen:$result")
            Log.d("zgo_print_plugin", "connectPrinter: $result")

            if (!result) {
                Thread.sleep(500)
                connecting++
            } else {
                break
            }

        }

        if (result ) {
            PrinterHelper.logcat("连接成功")
            printer = CPCLPrinter(connect!!)
            return 0
        } else {
            PrinterHelper.logcat("连接失败")
            return -1
        }


    }

    override fun disconnectPrinter() {
        printer = null
        connect?.close()
    }

    // 打印模版
    override fun printText(text: String) {
        //PrinterHelper.printText(text)
//        printer?.initializePrinter(320)
//        printer?.sendData("/r/n".toByteArray())
        val data = text.toByteArray(charset = Charset.forName("GBK"))
        printer?.sendData(data)
        //printer?.addText(20,20,"text1234")
        Log.d("zgo_print_plugin", "printText: $text")
        Log.d("zgo_print_plugin", "printText: ${data.toHex()}")
    }

    override fun printImage(x: Long, y: Long, filePath: String) {
        val assetManager: AssetManager = binding.applicationContext.assets

        val filePathAndroid = binding.flutterAssets.getAssetFilePathBySubpath(filePath)
        // filePath: images/ic_zhongtong_mini.png
        //filePathAndroid: flutter_assets/images/ic_zhongtong_mini.png

        Log.d("zgo_print_plugin", "filePath: $filePath $x $y")
        Log.d("zgo_print_plugin", "filePathAndroid: $filePathAndroid")

//        printer?.initializePrinter(320)

        val expressLogo = assetManager.open(filePathAndroid)
        val bitmap = BitmapFactory.decodeStream(expressLogo)

        val width: Int = bitmap.width

        Log.d("zgo_print_plugin", "bitmap.width: ${bitmap.width} width: $width")

        //PrinterHelper.Expanded(x.toString(), y.toString(), bitmap, 0, 0)

        printer?.addCGraphics(x.toInt(),y.toInt(),width,bitmap)



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
        //PrinterHelper.PrintQR(command, x, y, M, U, data)
        printer?.addQRCode(x.toInt(),y.toInt(),CPCLConst.QRCODE_MODE_ENHANCE,U.toInt(),data)


    }

    override fun printBarcode(
        command: String, type: String, width: String, ratio: String, height: String,
        x: String, y: String, undertext: Boolean, number: String, size: String,
        offset: String, data: String
    ) {


        // 绘制一维条码
        //CPCLPrinter addBarcode(int x, int y, String type, int height, String data)
        //CPCLPrinter addBarcode(int x, int y, String type, int width, int ratio, int height, String data)
        //横向一维条码
        //CPCLPrinter addBarcodeV(int x, int y, String type, int height, String data)
        //CPCLPrinter addBarcodeV(int x, int y, String type, int width, int ratio, int height, String data)

        if(command == "VBARCODE"){
            printer?.addBarcodeV(
                x.toInt(),
                y.toInt(),
                CPCLConst.BCS_128,
                width.toInt(),
                ratio.toInt(),
                height.toInt(),
                data
            )
        }else{
            printer?.addBarcode(
                x.toInt(),
                y.toInt(),
                CPCLConst.BCS_128,
                width.toInt(),
                ratio.toInt(),
                height.toInt(),
                data
            )
        }


    }


    override fun print() {
        printer?.addPrint()
        Log.d("zgo_print_plugin", "print()")
    }

    override fun form() {
        printer?.addForm()
        Log.d("zgo_print_plugin", "form()")
    }

    override fun getEndStatus(secondTimeout: Long): Long {
        val status = printer?.printerStatus(secondTimeout.toInt()){

        }
//        return status.toLong()
        return  0
    }

    fun ByteArray.toHex(): String = joinToString("") { "%02X".format(it) }

}