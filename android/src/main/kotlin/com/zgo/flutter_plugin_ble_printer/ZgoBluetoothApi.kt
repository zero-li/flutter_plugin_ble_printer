package com.zgo.flutter_plugin_ble_printer

import android.Manifest
import android.annotation.SuppressLint
import android.bluetooth.BluetoothAdapter
import android.bluetooth.BluetoothClass
import android.bluetooth.BluetoothDevice
import android.bluetooth.BluetoothManager
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.content.pm.PackageManager
import android.os.Build
import android.util.Log
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import cpcl.PrinterHelper
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.PluginRegistry


/*
 * 
 * 
 * @author: zhhli
 * @date: 23/4/20
 */


class ZgoBluetoothApi(
    private val binding: FlutterPlugin.FlutterPluginBinding,
    private val activityPluginBinding: ActivityPluginBinding
) : HostBluetoothApi,
    PluginRegistry.RequestPermissionsResultListener {

    private val context: Context = binding.applicationContext

    private val flutterApi = FlutterBluetoothApi(binding.binaryMessenger)

    private lateinit var eventChannel: EventChannel
    private var eventSink: EventChannel.EventSink? = null


    private val mBluetoothManager: BluetoothManager =
        (context.getSystemService(Context.BLUETOOTH_SERVICE) as BluetoothManager)
    private val mBtAdapter: BluetoothAdapter = mBluetoothManager.adapter


    private val deviceMap = mutableMapOf<String, ZgoBTDevice>()
    private var deviceConnected: ZgoBTDevice? = null

    private val REQUEST_FINE_LOCATION_PERMISSIONS = 1452

    private var isInited = false


    init {
        eventChannel = EventChannel(binding.binaryMessenger, "flutter_plugin_ble_printer/state")
        eventChannel.setStreamHandler(object : EventChannel.StreamHandler {
            override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                // eventChannel 建立连接
                eventSink = events

                // 推送消息给Event数据流，flutter层负责监听数据流
                //Handler(Looper.getMainLooper()).post {
                //  eventSink?.success(data)
                // }

            }

            override fun onCancel(arguments: Any?) {
                eventSink = null
            }

        })

    }


    /******************************************* 初始化蓝牙  */


    @SuppressLint("NewApi")
    private fun initBroadcastReceiverForBluetooth() {


        //监听蓝牙连接状态的广播
        val intent = IntentFilter()
        intent.addAction(BluetoothDevice.ACTION_ACL_DISCONNECTED)
        intent.addAction(BluetoothDevice.ACTION_ACL_CONNECTED)
        context.registerReceiver(mReceiver, intent)

        val scanIntent = IntentFilter()
        scanIntent.addAction(BluetoothDevice.ACTION_FOUND) // 用BroadcastReceiver来取得搜索结果
        scanIntent.addAction(BluetoothDevice.ACTION_BOND_STATE_CHANGED)
        scanIntent.addAction(BluetoothAdapter.ACTION_DISCOVERY_FINISHED)
        context.registerReceiver(mScanReceiver, scanIntent)

        Log.d("zgo", "initBroadcastReceiverForBluetooth")

        activityPluginBinding.addRequestPermissionsResultListener(this)

    }


    //扫描结束
    private val mScanReceiver: BroadcastReceiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context, intent: Intent) {
            val action = intent.action
            //搜索设备时，取得设备的MAC地址
            if (BluetoothDevice.ACTION_FOUND == action) {
                val device: BluetoothDevice =
                    intent.getParcelableExtra(BluetoothDevice.EXTRA_DEVICE)!!

                Log.d("zgo", "name : ${device.name}")
                // 过滤 printer
                if (device.bluetoothClass.majorDeviceClass == BluetoothClass.Device.Major.IMAGING) {

                    if (!deviceMap.contains(device.address)) {
                        //搜索的蓝牙设备
                        val d = ZgoBTDevice(
                            name = device.name + "",
                            address = device.address,
                            uuid = device.address,
                            1
                        )

                        deviceMap[device.address] = d

                        flutterApi.whenFindAllDevice(deviceMap.values.toList()) {

                        }

                        Log.d("zzz", device.name)

                    }

                }
            } else if (BluetoothDevice.ACTION_BOND_STATE_CHANGED == action) {
                val device: BluetoothDevice =
                    intent.getParcelableExtra(BluetoothDevice.EXTRA_DEVICE)!!
                when (device.bondState) {
                    BluetoothDevice.BOND_BONDING -> Log.d("zgo", "${device.name} 正在配对......")
                    BluetoothDevice.BOND_BONDED -> Log.d("zgo", "${device.name} 完成配对")
                    BluetoothDevice.BOND_NONE -> Log.d("zgo", "${device.name} 取消配对")
                    else -> {
                    }
                }
            } else if (BluetoothAdapter.ACTION_DISCOVERY_FINISHED == action) {

                flutterApi.whenFindAllDevice(deviceMap.values.toList()) {

                }

            }
        }
    }


    private val mReceiver: BroadcastReceiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context, intent: Intent) {
            val action = intent.action
            if (BluetoothDevice.ACTION_ACL_DISCONNECTED == action) {
                try {
                    Log.d("zgo", "已断开 disconnect .... ${deviceConnected?.name}")
                    //  PrinterHelper.portClose()
                    deviceConnected?.let {
                        val isActive = if (it.state == 0L) {
                            // 主动断开
                            1L
                        } else {
                            0L
                        }
                        flutterApi.whenDisconnect(it, isActive) {}
                    }

                } catch (e: Exception) {
                    e.printStackTrace()
                }
            } else if (BluetoothDevice.ACTION_ACL_CONNECTED == action) {
                try {
                    Log.d("zgo", "已连接 connected .... ${deviceConnected?.name}")
                    deviceConnected?.let {
                        val device2 = ZgoBTDevice(it.name, it.address, it.address, 2)
                        deviceConnected = device2
                        flutterApi.whenConnectSuccess(device2) {}
                    }

                } catch (e: Exception) {
                    e.printStackTrace()
                }
            }
        }
    }


    @SuppressLint("MissingPermission")
    private fun startScanBluetooth() {
        deviceMap.clear()


        if (mBtAdapter.isDiscovering) {
            mBtAdapter.cancelDiscovery()
        }

        if (!mBtAdapter.isEnabled) {
            mBtAdapter.enable()
            return
        }

        if (!mBtAdapter.startDiscovery()) {
            Log.e("BlueTooth", "扫描尝试失败,请重试")
        }
        try {
            Thread.sleep(100)
        } catch (e: InterruptedException) {
            e.printStackTrace()
        }
    }


    override fun isOn(): Boolean {
        return mBtAdapter.isEnabled
    }

    override fun btState(): Long {
        return 1L
    }

    override fun scanBluetooth() {
        if (!isInited) {
            initBroadcastReceiverForBluetooth()
            isInited = true
        }

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {

            val grantedScan = hasPermission(Manifest.permission.BLUETOOTH_SCAN)
                    && hasPermission(Manifest.permission.BLUETOOTH_CONNECT)
            if (!grantedScan) {
                ActivityCompat.requestPermissions(
                    activityPluginBinding.activity,
                    arrayOf(
                        Manifest.permission.BLUETOOTH_SCAN,
                        Manifest.permission.BLUETOOTH_CONNECT
                    ),
                    REQUEST_FINE_LOCATION_PERMISSIONS
                )
                return
            }


        } else {
            val grantedScan = hasPermission(Manifest.permission.ACCESS_FINE_LOCATION)
            if (!grantedScan) {
                ActivityCompat.requestPermissions(
                    activityPluginBinding.activity,
                    arrayOf(Manifest.permission.ACCESS_FINE_LOCATION),
                    REQUEST_FINE_LOCATION_PERMISSIONS
                )
                return
            }


        }



        startScanBluetooth()
    }

    @SuppressLint("MissingPermission")
    override fun stopScanBluetooth() {
        mBtAdapter.cancelDiscovery()
    }

    override fun connectPrinter(device: ZgoBTDevice) {
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

        if (connecting < 3) {
            deviceConnected = device

            // flutterApi.whenConnectSuccess(device) {}

        } else {
            activityPluginBinding.activity.runOnUiThread {
                flutterApi.whenConnectFailureWithErrorBlock(device, result.toLong()) {}
            }

        }

    }

    override fun disconnectPrinter() {
        PrinterHelper.portClose()
        deviceConnected?.let {
            //主动断开
            val state = 0L
            val device2 = ZgoBTDevice(it.name, it.address, it.address, state)
            deviceConnected = device2
        }
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray
    ): Boolean {
        if (requestCode == REQUEST_FINE_LOCATION_PERMISSIONS) {
            if (grantResults[0] == PackageManager.PERMISSION_GRANTED) {
                startScanBluetooth()
            } else {
                Log.e("zgo", "无权限")
                flutterApi.whenFindAllDevice(listOf()) {}
            }
            return true
        }
        return false

    }


    private fun hasPermission(permission: String) =
        ContextCompat.checkSelfPermission(context, permission) == PackageManager.PERMISSION_GRANTED


}
