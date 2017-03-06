//
//  TestViewController.m
//  BluetoothTool
//
//  Created by AlexYang on 17/2/28.
//  Copyright © 2017年 AlexYang. All rights reserved.
//

#import "TestViewController.h"
#import "AYCallbackModel.h"
#import "AYBluetoothTool.h"
#import "ISMessages+Alex.h"
#import "const.h"

@interface TestViewController ()
@property (weak, nonatomic) IBOutlet UILabel *eventLabel;
- (IBAction)addCallbackEvent:(id)sender;
- (IBAction)deleteCallbackEvent:(id)sender;
- (IBAction)addTempCallbackEvent:(id)sender;
- (IBAction)autoConnectSwitch:(UISwitch *)sender;

@end

@implementation TestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"Test callBack";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)addCallbackEvent:(id)sender {
    AYCallbackModel *model = [[AYCallbackModel alloc] init];
    model.name = @"heart rate listen";
    model.command = PROTOCOL_ENUM_HEART_RATE_DATA_MODE;
    model.block = ^(CBCharacteristic *characteristic,NSError *error) {
        NSData *data = nil;
        const unsigned char *ptr = NULL;
        data = characteristic.value;
        ptr = [data bytes];
        
        NSLog(@"event callback!! heart rate %d",ptr[1]);
        dispatch_async(dispatch_get_main_queue(), ^{
            self.eventLabel.text = [NSString stringWithFormat:@"%d", ptr[1]];
        });

    };
    
    [AYBluetoothTool addCallbackBlockForDidUpdateValueForCharacteristic:model];
}

- (IBAction)deleteCallbackEvent:(id)sender {
    [AYBluetoothTool removeCallbackBlockByPeripheralUUID:self.currentPeripheral.identifier.UUIDString CommandType:PROTOCOL_ENUM_HEART_RATE_DATA_MODE];
    [ISMessages showSuccessMsg:[NSString stringWithFormat:@"command:PROTOCOL_ENUM_HEART_RATE_DATA_MODE 移除完成"] title:@"remove callback"];
}

- (IBAction)addTempCallbackEvent:(id)sender {
    AYCallbackModel *model = [[AYCallbackModel alloc] init];
    model.uuidString = self.currentPeripheral.identifier.UUIDString;
    model.name = @"temp callback";
    model.command = PROTOCOL_ENUM_DEVICE_MEASURE_STATUS;
    model.block = ^(CBCharacteristic *characteristic,NSError *error) {
        NSData *data = nil;
        const unsigned char *ptr = NULL;
        data = characteristic.value;
        ptr = [data bytes];
        
        NSLog(@"event callback!! 0x12");

    };
    
    [AYBluetoothTool addCallbackBlockForDidUpdateValueForCharacteristic:model];
    
    double delayInSeconds = 10.0;
    
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        //执行事件
        [AYBluetoothTool removeCallbackBlockByPeripheralUUID:self.currentPeripheral.identifier.UUIDString CommandType: PROTOCOL_ENUM_DEVICE_MEASURE_STATUS];
        [ISMessages showSuccessMsg:@"command 0x12 移除" title:@"dispatch_after"];
        NSLog(@"command 0x12 移除");
    });
}


- (IBAction)autoConnectSwitch:(UISwitch *)sender {
    if (sender.isOn) {
         
    }else {
        
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    AYBluetoothTool *btClient = [AYBluetoothTool sharedInstance];
    [btClient cannelPeripheralConnection:self.currentPeripheral];
    [ISMessages showWarningMsg:@"断开连接" title:self.currentPeripheral.name];
}

@end
