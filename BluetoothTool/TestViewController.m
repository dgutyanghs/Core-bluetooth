//
//  TestViewController.m
//  BluetoothTool
//
//  Created by AlexYang on 17/2/28.
//  Copyright © 2017年 AlexYang. All rights reserved.
//

#import "TestViewController.h"
#import "AYCallbackModel.h"
#import "HLBluetoothTool.h"

@interface TestViewController ()
@property (weak, nonatomic) IBOutlet UILabel *eventLabel;
- (IBAction)addCallbackEvent:(id)sender;
- (IBAction)deleteCallbackEvent:(id)sender;

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
    model.command = 0x11;
    model.block = ^(CBCharacteristic *characteristic,NSError *error) {
        NSData *data = nil;
        const unsigned char *ptr = NULL;
        data = characteristic.value;
        ptr = [data bytes];
        
        NSLog(@"event callback!! heart rate %d",ptr[1]);

    };
    
    HLBluetoothTool *btClient = [HLBluetoothTool sharedInstance];
    [btClient.callbackTasks addObject:model];
}

- (IBAction)deleteCallbackEvent:(id)sender {
}
@end
