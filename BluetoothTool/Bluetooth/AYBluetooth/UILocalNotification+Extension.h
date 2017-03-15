//
//  UILocalNotification+Extension.h
//  BluetoothTool
//
//  Created by AlexYang on 17/3/15.
//  Copyright © 2017年 AlexYang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UILocalNotification (Extension)

+ (void)registerLocalNotification:(NSInteger)alertTime string:(NSString *)string key:(NSString *)key;

+ (void)cancelLocalNotificationWithKey:(NSString *)key;
@end
