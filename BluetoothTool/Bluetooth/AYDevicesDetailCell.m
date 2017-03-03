//
//  AYDevicesCell.m
//  SmartCoach
//
//  Created by AlexYang on 15/8/11.
//  Copyright (c) 2015年 SmartCoach. All rights reserved.
//

#import "AYDevicesDetailCell.h"

@implementation AYDevicesDetailCell


-(void)layoutSubviews
{
    [super layoutSubviews];
}



-(void)setDeviceModel:(AYDeviceModel *)deviceModel
{
    _deviceModel = deviceModel;
    
    self.textLabel.text = deviceModel.deviceName;
    self.detailTextLabel.text = [NSString stringWithFormat:@" MAC: %@", deviceModel.deviceMAC];
    if (deviceModel.isConnected) {
        [self.imageView setImage:[UIImage imageNamed:@"selected"]];
    } else {
        [self.imageView setImage:[UIImage imageNamed:@"Unchecked"]];
    }
    
}
@end
