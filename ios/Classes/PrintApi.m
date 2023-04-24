//
//  PrintApi.m
//  flutter_plugin_ble_printer
//
//  Created by ZHH on 23/4/19.
//

#import "PrintApi.h"



@interface PrintApi()


//@property(nonatomic)NSObject<FlutterPluginRegistrar>* messenger;

@property (nonatomic, strong) NSObject<FlutterPluginRegistrar> * registrar;


@property (nonatomic, strong) PTCommandCPCL *cmd;


@end


#pragma mark -- 实现 FLTFlutterPrintApi 的代理方法
@implementation PrintApi


/// 重写一个构造方法 来接收 Flutter 相关蚕食
/// @param registrar Flutter类 包含回调方法等信息
- (instancetype)initWithMessenger:(NSObject<FlutterPluginRegistrar>*)registrar{
    self = [super init];
    if (self) {
        self.registrar = registrar;
    }
    
    self.cmd = [[PTCommandCPCL alloc] init];
    
    
    return self;
    
    
}





- (void)printTextText:(NSString *)text error:(FlutterError *_Nullable *_Nonnull)error{
    
    //NSStringEncoding gbkEncoding = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
    //NSData *data =[text dataUsingEncoding:gbkEncoding];
    
    [self.cmd appendCommand:text];
    
}


- (void)printImageX:(NSNumber *)x y:(NSNumber *)y filePath:(NSString *)filePath error:(FlutterError *_Nullable *_Nonnull)error{
    
    
    // https://flutter.cn/docs/development/ui/assets-and-images#loading-flutter-assets-in-ios
    NSString* key = [self.registrar lookupKeyForAsset:filePath];
    NSString* path = [[NSBundle mainBundle] pathForResource:key ofType:nil];
    
    
    UIImage *image = [UIImage imageWithContentsOfFile:path];
    if (image == nil) {
        return;
    }
    
    
    
    
    [self.cmd cpclPrintBitmapWithXPos:[x intValue] yPos:[y intValue] image:image.CGImage bitmapMode:PTBitmapModeDithering compress:PTBitmapCompressModeNone isPackage:NO];
}





- (nullable NSNumber *)getEndStatusSecondTimeout:(NSNumber *)secondTimeout error:(FlutterError *_Nullable *_Nonnull)error{
    
    PTCommandCPCL *cmd = [[PTCommandCPCL alloc] init];
    
    [cmd cpclGetPaperStatus];
    [[PTDispatcher share] sendData:cmd.cmdData];
    [[PTDispatcher share] whenReceiveData:^(NSData *data) {
        if ([data length] == 1) {
            uint8_t *buffer = (uint8_t *)[data bytes];
            //            CPCLBluetoothPrinterStatus status = CPCLBluetoothPrinterStatusOK;
            NSMutableArray <NSString *> *stateArrs = [[NSMutableArray alloc] init];
            
            if ((buffer[0] & 0x01) != 0) {
                [stateArrs addObject:@"打印机忙碌"];
                //                status |= CPCLBluetoothPrinterStatusPrinting;
            }
            if((buffer[0] & 0x02) != 0) {
                [stateArrs addObject:@"缺纸"];
                //                status |= CPCLBluetoothPrinterStatusNoPaper;
            }
            if((buffer[0] & 0x04) != 0) {
                [stateArrs addObject:@"开盖"];
                //                status |= CPCLBluetoothPrinterStatusCoverOpened;
            }
            if((buffer[0] & 0x08) != 0) {
                [stateArrs addObject:@"电量低"];
                //                status |= CPCLBluetoothPrinterStatusBatteryLow;
            }
            if (stateArrs.count > 0) {
                // [SVProgressHUD showErrorWithStatus:[stateArrs componentsJoinedByString:@"-"]];
            }else {
                //[SVProgressHUD showSuccessWithStatus:@"Ready".localized];
            }
        }
    }];
    
    /// 实现不处理
    [[PTDispatcher share] whenSendSuccess:^(int64_t dataCount, double time) {
        
    }];
    
    /// 实现不处理
    [[PTDispatcher share] whenSendProgressUpdate:^(NSNumber *number) {
        
    }];
    
    return  @1;
}

- (void)formWithError:(FlutterError *_Nullable *_Nonnull)error; {
    [self.cmd cpclForm];
    
}


- (void)printWithError:(FlutterError * _Nullable *_Nonnull)error {
    [self.cmd cpclPrint];
    [[PTDispatcher share] sendData:self.cmd.cmdData];
    
    
    [[PTDispatcher share] whenSendSuccess:^(int64_t dataCount, double time) {
        
        NSLog(@"数据发送成功");
    }];
    
    [[PTDispatcher share] whenSendProgressUpdate:^(NSNumber *number) {
        
        NSLog(@"数据发送中 ... %@", number);
    }];
    
    /// 实现不处理
    [[PTDispatcher share] whenReceiveData:^(NSData *data) {
        
    }];
    
    [[PTDispatcher share] whenSendFailure:^{
        NSLog(@"数据发送失败！！！");
    }];
    
    self.cmd = [[PTCommandCPCL alloc] init];
}






@end
