//
//  CBPeripheral+AutoConnect.m
//  BluetoothTool
//
//  Created by AlexYang on 17/3/2.
//  Copyright © 2017年 AlexYang. All rights reserved.
//

#import "CBPeripheral+AutoConnect.h"
#import <objc/runtime.h>


@implementation CBPeripheral (AutoConnect)

@dynamic autoConnect;

- (void)setAutoConnect:(BOOL)autoConnect {
    objc_setAssociatedObject(self, @selector(autoConnect), @(autoConnect), OBJC_ASSOCIATION_ASSIGN);
}

- (BOOL)autoConnect {
    NSNumber *ret = objc_getAssociatedObject(self, @selector(autoConnect));
    return ret.boolValue;
}
@end
