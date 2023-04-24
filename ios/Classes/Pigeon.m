// Autogenerated from Pigeon (v9.2.4), do not edit directly.
// See also: https://pub.dev/packages/pigeon

#import "Pigeon.h"
#import <Flutter/Flutter.h>

#if !__has_feature(objc_arc)
#error File requires ARC to be enabled.
#endif

static NSArray *wrapResult(id result, FlutterError *error) {
  if (error) {
    return @[
      error.code ?: [NSNull null], error.message ?: [NSNull null], error.details ?: [NSNull null]
    ];
  }
  return @[ result ?: [NSNull null] ];
}
static id GetNullableObjectAtIndex(NSArray *array, NSInteger key) {
  id result = array[key];
  return (result == [NSNull null]) ? nil : result;
}

NSObject<FlutterMessageCodec> *FLTFlutterPrintApiGetCodec(void) {
  static FlutterStandardMessageCodec *sSharedObject = nil;
  sSharedObject = [FlutterStandardMessageCodec sharedInstance];
  return sSharedObject;
}

void FLTFlutterPrintApiSetup(id<FlutterBinaryMessenger> binaryMessenger, NSObject<FLTFlutterPrintApi> *api) {
  /// 打印文本数据
  {
    FlutterBasicMessageChannel *channel =
      [[FlutterBasicMessageChannel alloc]
        initWithName:@"dev.flutter.pigeon.FlutterPrintApi.printText"
        binaryMessenger:binaryMessenger
        codec:FLTFlutterPrintApiGetCodec()];
    if (api) {
      NSCAssert([api respondsToSelector:@selector(printTextText:error:)], @"FLTFlutterPrintApi api (%@) doesn't respond to @selector(printTextText:error:)", api);
      [channel setMessageHandler:^(id _Nullable message, FlutterReply callback) {
        NSArray *args = message;
        NSString *arg_text = GetNullableObjectAtIndex(args, 0);
        FlutterError *error;
        [api printTextText:arg_text error:&error];
        callback(wrapResult(nil, error));
      }];
    } else {
      [channel setMessageHandler:nil];
    }
  }
  /// 打印图片
  /// https://flutter.cn/docs/development/ui/assets-and-images#loading-flutter-assets-in-ios
  /// flutter:
  ///   assets:
  ///     - icons/heart.png
  /// filePath = assets/icons/heart.png
  ///
  {
    FlutterBasicMessageChannel *channel =
      [[FlutterBasicMessageChannel alloc]
        initWithName:@"dev.flutter.pigeon.FlutterPrintApi.printImage"
        binaryMessenger:binaryMessenger
        codec:FLTFlutterPrintApiGetCodec()];
    if (api) {
      NSCAssert([api respondsToSelector:@selector(printImageX:y:filePath:error:)], @"FLTFlutterPrintApi api (%@) doesn't respond to @selector(printImageX:y:filePath:error:)", api);
      [channel setMessageHandler:^(id _Nullable message, FlutterReply callback) {
        NSArray *args = message;
        NSNumber *arg_x = GetNullableObjectAtIndex(args, 0);
        NSNumber *arg_y = GetNullableObjectAtIndex(args, 1);
        NSString *arg_filePath = GetNullableObjectAtIndex(args, 2);
        FlutterError *error;
        [api printImageX:arg_x y:arg_y filePath:arg_filePath error:&error];
        callback(wrapResult(nil, error));
      }];
    } else {
      [channel setMessageHandler:nil];
    }
  }
  /// 控制打印机走纸到标签缝隙（标缝）
  {
    FlutterBasicMessageChannel *channel =
      [[FlutterBasicMessageChannel alloc]
        initWithName:@"dev.flutter.pigeon.FlutterPrintApi.form"
        binaryMessenger:binaryMessenger
        codec:FLTFlutterPrintApiGetCodec()];
    if (api) {
      NSCAssert([api respondsToSelector:@selector(formWithError:)], @"FLTFlutterPrintApi api (%@) doesn't respond to @selector(formWithError:)", api);
      [channel setMessageHandler:^(id _Nullable message, FlutterReply callback) {
        FlutterError *error;
        [api formWithError:&error];
        callback(wrapResult(nil, error));
      }];
    } else {
      [channel setMessageHandler:nil];
    }
  }
  /// 打印输出
  {
    FlutterBasicMessageChannel *channel =
      [[FlutterBasicMessageChannel alloc]
        initWithName:@"dev.flutter.pigeon.FlutterPrintApi.print"
        binaryMessenger:binaryMessenger
        codec:FLTFlutterPrintApiGetCodec()];
    if (api) {
      NSCAssert([api respondsToSelector:@selector(printWithError:)], @"FLTFlutterPrintApi api (%@) doesn't respond to @selector(printWithError:)", api);
      [channel setMessageHandler:^(id _Nullable message, FlutterReply callback) {
        FlutterError *error;
        [api printWithError:&error];
        callback(wrapResult(nil, error));
      }];
    } else {
      [channel setMessageHandler:nil];
    }
  }
  /// 获取状态
  {
    FlutterBasicMessageChannel *channel =
      [[FlutterBasicMessageChannel alloc]
        initWithName:@"dev.flutter.pigeon.FlutterPrintApi.getEndStatus"
        binaryMessenger:binaryMessenger
        codec:FLTFlutterPrintApiGetCodec()];
    if (api) {
      NSCAssert([api respondsToSelector:@selector(getEndStatusSecondTimeout:error:)], @"FLTFlutterPrintApi api (%@) doesn't respond to @selector(getEndStatusSecondTimeout:error:)", api);
      [channel setMessageHandler:^(id _Nullable message, FlutterReply callback) {
        NSArray *args = message;
        NSNumber *arg_secondTimeout = GetNullableObjectAtIndex(args, 0);
        FlutterError *error;
        NSNumber *output = [api getEndStatusSecondTimeout:arg_secondTimeout error:&error];
        callback(wrapResult(output, error));
      }];
    } else {
      [channel setMessageHandler:nil];
    }
  }
}
