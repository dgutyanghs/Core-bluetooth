//
//  AYCallbackModel.h
//  BluetoothTool
//
//  Created by AlexYang on 17/2/28.
//  Copyright © 2017年 AlexYang. All rights reserved.
//

#import <Foundation/Foundation.h>


@class CBCharacteristic;
typedef void (^ay_didUpdateValueForCharacteristicBlock)(CBCharacteristic *characteristic,NSError *error);

@interface AYCallbackModel : NSObject
@property (nonatomic, copy) NSString *uuidString;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, assign) NSUInteger command;
@property (nonatomic, copy) ay_didUpdateValueForCharacteristicBlock block;
@end
