//
//  BluetoothApi.m
//  flutter_plugin_ble_printer
//
//  Created by ZHH on 23/4/19.
//

#import "BluetoothApi.h"


@interface BluetoothApi()

@property (nonatomic, strong) NSObject<FlutterPluginRegistrar> * registrar;

// 扫描到的设备
@property(nonatomic) NSMutableDictionary *scannedPTPrintersDict;
@property(nonatomic) NSArray<PTPrinter *> *devices;

@property(nonatomic) FLTZgoBTDevice *fltDeviceConnected;

// flutter 端API，回调状态
@property (nonatomic, strong) FLTFlutterBluetoothApi *flutterApi;

@property(nonatomic, retain) BluetoothPrintStreamHandler *stateStreamHandler;




@end

@implementation BluetoothApi


/// 重写一个构造方法 来接收 Flutter 相关蚕食
/// @param registrar Flutter类 包含回调方法等信息
- (instancetype)initWithMessenger:(NSObject<FlutterPluginRegistrar>*)registrar{
    self = [super init];
    if (self) {
        self.registrar = registrar;
        
        [self initApi];
        
        
    }
    return self;
    
    
}


- (void) initApi
{
//    FLTFlutterBluetoothApi * api = [[FLTFlutterBluetoothApi alloc] init];
    
    
    self.flutterApi = [[FLTFlutterBluetoothApi alloc] initWithBinaryMessenger:self.registrar.messenger];
    
    
    
    
    
    FlutterEventChannel* stateChannel = [FlutterEventChannel eventChannelWithName: @"flutter_plugin_ble_printer/state"
                                                                  binaryMessenger:[self.registrar messenger]];
    BluetoothPrintStreamHandler* stateStreamHandler = [[BluetoothPrintStreamHandler alloc] init];
    [stateChannel setStreamHandler:stateStreamHandler];
    self.stateStreamHandler = stateStreamHandler;
    

    self.scannedPTPrintersDict = [NSMutableDictionary new];

    
    
    [[PTDispatcher share] whenFindAllBluetooth:^(NSMutableArray<PTPrinter *> *printerArray) {
        /// 按照距离排序
        self.devices = [printerArray sortedArrayUsingComparator:^NSComparisonResult(PTPrinter*  _Nonnull obj1, PTPrinter*  _Nonnull obj2) {
            return obj1.distance.floatValue > obj2.distance.floatValue;
        }];
        
        

        NSMutableArray<FLTZgoBTDevice *> *arrayTwo = [NSMutableArray array];


        NSUInteger count = self.devices.count;
        
        for( int i =0 ; i< count; i++){
            PTPrinter *ptPrinter = [self.devices objectAtIndex:i];
            
            NSString *name = ptPrinter.name;
            NSLog(@"搜索到设备: %@ mac: %@", name, ptPrinter.mac);
            
            [self.scannedPTPrintersDict setObject:ptPrinter forKey:ptPrinter.mac];
            
            NSNumber *state = [NSNumber numberWithInt:(int)ptPrinter.peripheral.state];
            
            FLTZgoBTDevice *device = [FLTZgoBTDevice makeWithName:name address:ptPrinter.mac uuid:ptPrinter.uuid state:state];
            
        
            [arrayTwo addObject:device];
        
            
        }
        
        
        
        [self.flutterApi whenFindAllDeviceList:arrayTwo completion:^(FlutterError *_Nullable error){
            
            NSLog(@"ios whenFindAllDeviceList: %@", error.message);
            
        }];
        
        
        
        
        
        
    }];
    
//    [[PTDispatcher share] whenConnectSuccess];
    
    
    [[PTDispatcher share] whenConnectSuccess:^(){
        PTPrinter *ptPrinter = [PTDispatcher share].printerConnected ;
        
        NSNumber *state = [NSNumber numberWithInt:(int)ptPrinter.peripheral.state];
        
        FLTZgoBTDevice *device = [FLTZgoBTDevice makeWithName:ptPrinter.name address:ptPrinter.mac uuid:ptPrinter.uuid state:state];
        
        self.fltDeviceConnected = device;
        [self.flutterApi whenConnectSuccessDevice: device  completion:^(FlutterError * _Nullable error){}];
        
        
        NSLog(@"连接成功: %@", device.name);
        
        // notify flutter
        [self changeAllDeviceStateList];
        
    }];
    
    
    [[PTDispatcher share] whenConnectFailureWithErrorBlock:^(PTConnectError error) {
        NSNumber *number = [NSNumber numberWithInt:(int)error];
        NSLog(@"连接失败: %d", (int)error);
        
        FLTZgoBTDevice *device =self.fltDeviceConnected;
        
        [self.flutterApi whenConnectFailureWithErrorBlockDevice:device error:number completion:^(FlutterError * _Nullable error) {
            
        }];
        
        self.fltDeviceConnected = NULL;
        
        // notify flutter
        [self changeAllDeviceStateList];
        
        
        
        
        
    }];
    
        
    [[PTDispatcher share] whenUnconnect:^(BOOL isActive) {
        // 参数YES表示主动断开，NO表示被动断开
        NSNumber *number = isActive ? @1:@0;
        NSLog(@"断开连接: %@", isActive ? @"主动断开":@"被动断开");
        FLTZgoBTDevice *device =self.fltDeviceConnected;
        [self.flutterApi whenDisconnectDevice: device isActive:number completion:^(FlutterError *_Nullable error){}];
        
        // notify flutter
        //[self changeAllDeviceStateList];
        
        [self startScanBluetooth];
        
        
        
    }];
}



- (nullable NSNumber *)btStateWithError:(FlutterError * _Nullable __autoreleasing * _Nonnull)error {
    
    return @1;
}


// 蓝牙是否开启
- (nullable NSNumber *)isOnWithError:(FlutterError * _Nullable __autoreleasing * _Nonnull)error {
    PTBluetoothState state = [[PTDispatcher share] getBluetoothStatus];
    
    int number = state == PTBluetoothStatePoweredOn ? 1: 0;
    
    NSLog(@"蓝牙：%@", state == PTBluetoothStatePoweredOn ? @"已打开": @"未打开");
    
    return [NSNumber numberWithInt:number];
}

- (void) startScanBluetooth{
    // 清空
    [self.scannedPTPrintersDict removeAllObjects];
    
    
    
    // 过滤
    [[PTDispatcher share] setupPeripheralFilter:^BOOL(CBPeripheral *peripheral, NSDictionary<NSString *,id> *advertisementData, NSNumber *RSSI) {
        // 过滤无名字(null) & 不含有'HM' 的外设
//        if (!peripheral.name || ![peripheral.name containsString:@"HM"]) {
//            return NO;
//        }

        id connectable = advertisementData[@"kCBAdvDataIsConnectable"];
        // 过滤无法连接的外设(connectable == 0)
        if ([connectable isKindOfClass:[NSNumber class]] && [connectable boolValue] == 1) {
            return YES;
        }
        
        return YES;
    }];

    [[PTDispatcher share] scanBluetooth];
}


/// 搜索蓝牙设备
- (void)scanBluetoothWithError:(FlutterError * _Nullable __autoreleasing * _Nonnull)error {

    [self startScanBluetooth];
    
    NSLog(@"scanBluetooth ...");
    
    
    
}

/// 停止搜索蓝牙设备
- (void)stopScanBluetoothWithError:(FlutterError * _Nullable __autoreleasing * _Nonnull)error {
    
    [[PTDispatcher share] stopScanBluetooth];
    
    NSLog(@"stopScanBluetooth ...");
}


/// 连接打印机
- (void)connectPrinterDevice:(nonnull FLTZgoBTDevice *)device error:(FlutterError * _Nullable __autoreleasing * _Nonnull)error {
    
    NSLog(@"connectPrinterDevice  FLTZgoBTDevice: %@  mac: %@", device.name, device.address);
    
    PTPrinter *ptPrinter = [self.scannedPTPrintersDict objectForKey:[device address]];
    
    NSLog(@"connectPrinterDevice  PTPrinter: %@  mac: %@", ptPrinter.name, ptPrinter.mac);

    
    [[PTDispatcher share] connectPrinter:ptPrinter];
    
}

/// 断开打印机
- (void)disconnectPrinterWithError:(FlutterError * _Nullable __autoreleasing * _Nonnull)error {
    [[PTDispatcher share] disconnect];
}


- (NSArray<FLTZgoBTDevice *> *) changeAllDeviceStateList{
    
    
    NSMutableArray<FLTZgoBTDevice *> *arrayTwo = [NSMutableArray array];


    NSUInteger count = self.devices.count;
    
    for( int i =0 ; i< count; i++){
        PTPrinter *ptPrinter = [self.devices objectAtIndex:i];
        
        NSString *name = ptPrinter.name;
        
        NSNumber *state = [NSNumber numberWithInt:(int)ptPrinter.peripheral.state];
        
        NSString *str = @"";
        if(ptPrinter.peripheral.state == CBPeripheralStateDisconnected){
            str = @"已断开";
        }
        if(ptPrinter.peripheral.state == CBPeripheralStateConnecting){
            str = @"连接中...";
        }
        if(ptPrinter.peripheral.state == CBPeripheralStateConnected){
            str = @"已连接";
        }
        if(ptPrinter.peripheral.state == CBPeripheralStateDisconnecting){
            str = @"正在断开中...";
        }
        
        NSLog(@"设备状态: %@ state: %@ %@ mac: %@ ", name, state , str, ptPrinter.mac);

        
        FLTZgoBTDevice *device = [FLTZgoBTDevice makeWithName:name address:ptPrinter.mac uuid:ptPrinter.uuid state:state];
        
    
        [arrayTwo addObject:device];
    
        
    }
    
    
    
    [self.flutterApi onChangeAllDeviceStateList:arrayTwo completion:^(FlutterError *_Nullable error){
        
        NSLog(@"ios whenFindAllDeviceList: %@", error.message);
        
    }];
    
    return arrayTwo;
    
}

@end






@implementation BluetoothPrintStreamHandler

- (FlutterError*)onListenWithArguments:(id)arguments eventSink:(FlutterEventSink)eventSink {
  self.sink = eventSink;
  return nil;
}

- (FlutterError*)onCancelWithArguments:(id)arguments {
  self.sink = nil;
  return nil;
}

@end
