//
//  PrintApi.h
//  flutter_plugin_ble_printer
//
//  Created by ZHH on 23/4/19.
//

#import <Foundation/Foundation.h>
#import <Flutter/Flutter.h>
#import "Pigeon.h"
#import <PrinterSDK/PrinterSDK.h>

NS_ASSUME_NONNULL_BEGIN

@interface PrintApi : NSObject<FLTFlutterPrintApi>



/// 重写一个构造方法 来接收 Flutter 相关蚕食
/// @param registrar Flutter类 包含回调方法等信息
- (instancetype)initWithMessenger:(NSObject<FlutterPluginRegistrar>*)registrar;


@end

NS_ASSUME_NONNULL_END
