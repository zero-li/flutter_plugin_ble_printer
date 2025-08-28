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


/*!
 *  \~chinese
 *
 *  打印二维码
 *  command PrinterHelper.BARCODE：平向
 *          PrinterHelper.VBARCODE：垂直向
 *
 *  x     二维码的起始横坐标。（单位：dot）
 *  y     二维码的起始纵坐标。（单位：dot）
 *  M     QR的类型：
 *        1：普通类型
 *        2：在类型1的基础上增加了个别的符号
 *  U     单位宽度/模块的单元度,范围是1到32默认为6
 *  data  二维码的数据
 *
 *  \~english
 *
 *  Print QR Code
 *  command PrinterHelper.BARCODE：Horizontal
 *          PrinterHelper.VBARCODE：Vertical
 *
 *  x     QR code start x coordinate. (unit: dot)
 *  y     QR code start y coordinate. (unit: dot)
 *  M     QR code type:
 *        1：Standard type
 *        2：Enhanced type with additional symbols
 *  U     Unit width/module size, range is 1 to 32, default is 6
 *  data  QR code data
 *
 */
- (BOOL)printQrCodeCommand:(NSString *)command
                         x:(NSInteger)arg_x
                         y:(NSInteger)arg_y
                         M:(NSInteger)arg_M
                         U:(NSInteger)arg_U
                      data:(NSString *)arg_data
                     error:(NSError **)error {

    // 验证参数
    if (!command || !arg_data) {
        if (error) {
            *error = [NSError errorWithDomain:@"PTCommandCPCLDomain"
                                         code:1001
                                     userInfo:@{
                                             NSLocalizedDescriptionKey: @"Command and data cannot be nil"}];
        }
        return NO;
    }

    // 确定是横向还是纵向二维码
    BOOL isVertical = [command isEqualToString:@"VBARCODE"];

    // 验证M参数（QR码模型）
    PTCPCLQRCodeModel model;
    if (arg_M == 1) {
        model = PTCPCLQRCodeModel1;
    } else if (arg_M == 2) {
        model = PTCPCLQRCodeModel2;
    } else {
        model = PTCPCLQRCodeModel2; // 默认值
    }

    // 验证U参数（单元宽度）
    PTCPCLQRCodeUnitWidth unitWidth;
    if (arg_U >= 1 && arg_U <= 32) {
        unitWidth = (PTCPCLQRCodeUnitWidth) arg_U;
    } else {
        unitWidth = PTCPCLQRCodeUnitWidth_6; // 默认值
    }

    // 根据方向调用相应的QR码开始方法
    if (isVertical) {
        [self cpclBarcodeVerticalQRcodeWithXPos:arg_x
                                           yPos:arg_y
                                          model:model
                                      unitWidth:unitWidth];
    } else {
        [self cpclBarcodeQRcodeWithXPos:arg_x
                                   yPos:arg_y
                                  model:model
                              unitWidth:unitWidth];
    }

    // 添加QR码数据（使用默认纠错级别和字符模式）
    [self cpclBarcodeQRCodeCorrectionLecel:PTCPCLQRCodeCorrectionLevelM
                             characterMode:PTCPCLQRCodeDataInputModeA
                                   context:arg_data];

    // 结束QR码
    [self cpclBarcodeQRcodeEnd];

    return YES;
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
