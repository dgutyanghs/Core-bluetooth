//
//  CBPeripheral+AutoConnect.h
//  BluetoothTool
//
//  Created by AlexYang on 17/3/2.
//  Copyright © 2017年 AlexYang. All rights reserved.
//

#import <CoreBluetooth/CoreBluetooth.h>

@interface CBPeripheral (AutoConnect)
@property (nonatomic, assign) BOOL autoConnect;
@end
