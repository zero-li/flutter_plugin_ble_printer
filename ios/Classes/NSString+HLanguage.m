//
//  NSString+HLanguage.m
//  flutter_plugin_ble_printer
//
//  Created by ZHH on 23/4/12.
//

#import "NSString+HLanguage.h"

@implementation NSString(HLanguage)


- (NSString *)localized
{
    return [[NSBundle mainBundle] localizedStringForKey:self value:nil table:nil];
}

@end
