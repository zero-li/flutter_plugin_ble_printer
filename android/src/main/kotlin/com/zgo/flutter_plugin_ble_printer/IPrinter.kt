package com.zgo.flutter_plugin_ble_printer

import android.content.Context
import io.flutter.embedding.engine.plugins.FlutterPlugin

interface IPrinter : FlutterPrintApi{

    /** 连接打印机 */
    fun connectPrinter(device: ZgoBTDevice):Long

    /** 断开打印机 */
    fun disconnectPrinter()

    fun initBinding(binding: FlutterPlugin.FlutterPluginBinding)

}