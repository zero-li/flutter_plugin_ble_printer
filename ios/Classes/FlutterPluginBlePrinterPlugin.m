#import "FlutterPluginBlePrinterPlugin.h"
#import "NSString+HLanguage.h"
#import "BluetoothApi.h"
#import "PrintApi.h"


@interface FlutterPluginBlePrinterPlugin ()




@end

@implementation FlutterPluginBlePrinterPlugin

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    // FlutterMethodChannel* channel = [FlutterMethodChannel
    //     methodChannelWithName:@"flutter_plugin_ble_printer"
    //           binaryMessenger:[registrar messenger]];
    // FlutterPluginBlePrinterPlugin* instance = [[FlutterPluginBlePrinterPlugin alloc] init];
    // [registrar addMethodCallDelegate:instance channel:channel];
    
    
    
    
    PrintApi * printApi = [[PrintApi alloc] init];
    FLTFlutterPrintApiSetup([registrar messenger], [printApi initWithMessenger:registrar]);
    
    BluetoothApi * bluetoothApi = [[BluetoothApi alloc] init];
    FLTHostBluetoothApiSetup([registrar messenger], [bluetoothApi initWithMessenger:registrar]);
    
    
    
    
    
    
}


@end

