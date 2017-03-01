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
#import "ISMessages+Alex.h"

@interface TestViewController ()
@property (weak, nonatomic) IBOutlet UILabel *eventLabel;
- (IBAction)addCallbackEvent:(id)sender;
- (IBAction)deleteCallbackEvent:(id)sender;

@property (nonatomic, strong) AYCallbackModel *model;
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
        dispatch_async(dispatch_get_main_queue(), ^{
            self.eventLabel.text = [NSString stringWithFormat:@"%d", ptr[1]];
        });

    };
    
    [HLBluetoothTool addCallbackBlockForDidUpdateValueForCharacteristic:model];
    self.model = model;
    
}

- (IBAction)deleteCallbackEvent:(id)sender {
    [HLBluetoothTool removeCallbackBlockByCommandType:self.model.command];
    [ISMessages showSuccessMsg:[NSString stringWithFormat:@"command:0x%lx 移除完成", (unsigned long)self.model.command] title:@"remove callback"];
}
@end
