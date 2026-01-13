package com.zgo.flutter_plugin_ble_printer

import com.zgo.flutter_plugin_ble_printer.printer.HMPrinter
import com.zgo.flutter_plugin_ble_printer.printer.XPrinter
import io.flutter.embedding.engine.plugins.FlutterPlugin

object PrinterManager {

    private var currentPrinter: IPrinter? = null

    fun createPrinterForDevice(binding: FlutterPlugin.FlutterPluginBinding,device: ZgoBTDevice): IPrinter {
        currentPrinter = when {
            device.name.startsWith("XP", ignoreCase = true) -> {
                XPrinter()
            }
            else -> {
                // 默认返回一个打印机实现
                HMPrinter()
            }
        }
        currentPrinter?.initBinding(binding)
        return currentPrinter!!
    }

    fun getCurrentPrinter(): IPrinter? {
        return currentPrinter
    }

    fun releasePrinter() {
        currentPrinter = null
    }



}