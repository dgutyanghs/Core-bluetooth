//
//  HLDeviceModel.h
//  SmartCoach
//
//  Created by AlexYang on 15/8/11.
//  Copyright (c) 2015年 SmartCoach. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HLDeviceModel : NSObject
@property (nonatomic, copy) NSString *deviceName;
@property (nonatomic, copy) NSString *UUIDStr;
@property (nonatomic, assign, getter=isConnected) BOOL connected;
@property (nonatomic, copy) NSString *deviceMAC;
@property (nonatomic, assign, getter=isAutoReConnect) BOOL autoReConnect;


+(instancetype)deviceWithName:(NSString *)name UUID:(NSString *)uuid status:(BOOL)status;
+(instancetype)deviceWithName:(NSString *)name UUID:(NSString *)uuid MAC:(NSString *)mac status:(BOOL)status;
@end
