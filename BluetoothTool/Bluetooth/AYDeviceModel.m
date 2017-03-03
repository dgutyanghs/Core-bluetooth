//
//  AYDeviceModel.m
//  SmartCoach
//
//  Created by AlexYang on 15/8/11.
//  Copyright (c) 2015年 SmartCoach. All rights reserved.
//

#import "AYDeviceModel.h"

@implementation AYDeviceModel


+(instancetype)deviceWithName:(NSString *)name UUID:(NSString *)uuid status:(BOOL)status;
{
    AYDeviceModel *deviceModel = [[AYDeviceModel alloc] init];
    
    deviceModel.deviceName = name;
    deviceModel.UUIDStr = uuid;
    deviceModel.connected = status;
    
    return deviceModel;
}


+(instancetype)deviceWithName:(NSString *)name UUID:(NSString *)uuid MAC:(NSString *)mac status:(BOOL)status;
{
    AYDeviceModel *deviceModel = [[AYDeviceModel alloc] init];
    
    deviceModel.deviceName = name;
    deviceModel.UUIDStr = uuid;
    deviceModel.connected = status;
    deviceModel.deviceMAC = mac;
    
    return deviceModel;
}
@end
