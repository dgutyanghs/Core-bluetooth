//
//  TestViewController.h
//  BluetoothTool
//
//  Created by AlexYang on 17/2/28.
//  Copyright © 2017年 AlexYang. All rights reserved.
//

#import <UIKit/UIKit.h>


@class CBPeripheral;
@interface TestViewController : UIViewController
@property (nonatomic, strong) CBPeripheral *currentPeripheral;
@end
