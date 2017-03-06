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

@interface TestViewController () <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UILabel *valueLabel;
- (IBAction)addCallbackEvent:(id)sender;
- (IBAction)deleteCallbackEvent:(id)sender;
- (IBAction)addTempCallbackEvent:(id)sender;
- (IBAction)autoConnectSwitch:(UISwitch *)sender;
@property (weak, nonatomic) IBOutlet UITableView *tableView;


@property (nonatomic, strong) NSMutableArray <AYCallbackModel *> *events;
@end

@implementation TestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"Test callBack";
    self.events = [NSMutableArray arrayWithCapacity:2];
    
    self.tableView.dataSource = self;
    self.tableView.delegate   = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)addCallbackEvent:(id)sender {
    AYCallbackModel *model = [[AYCallbackModel alloc] init];
    model.name = @"heart rate listen";
    model.command = PROTOCOL_ENUM_HEART_RATE_DATA_MODE;
    model.uuidString = self.currentPeripheral.identifier.UUIDString;
    model.block = ^(CBCharacteristic *characteristic,NSError *error) {
        NSData *data = nil;
        const unsigned char *ptr = NULL;
        data = characteristic.value;
        ptr = [data bytes];
        
        NSLog(@"event callback!! heart rate %d",ptr[1]);
        dispatch_async(dispatch_get_main_queue(), ^{
            self.valueLabel.text = [NSString stringWithFormat:@"%d", ptr[1]];
        });

    };
    
    BOOL ret = [AYBluetoothTool addCallbackBlockForDidUpdateValueForCharacteristic:model];
    if (ret) {
        [self.events addObject:model];
        [self.tableView reloadData];
    }
}

- (IBAction)deleteCallbackEvent:(id)sender {
    
    NSString *uuidString = self.currentPeripheral.identifier.UUIDString;
    for (int i = 0; i < self.events.count; i++) {
        AYCallbackModel *eventModel = self.events[i];
        if ([eventModel.uuidString isEqualToString:uuidString] && eventModel.command == PROTOCOL_ENUM_HEART_RATE_DATA_MODE ) {
            [self.events removeObject:eventModel];
        }
    }
    [self.tableView reloadData];
    
    
    [AYBluetoothTool removeCallbackBlockByPeripheralUUID:uuidString CommandType:PROTOCOL_ENUM_HEART_RATE_DATA_MODE];
    [ISMessages showSuccessMsg:[NSString stringWithFormat:@"command:PROTOCOL_ENUM_HEART_RATE_DATA_MODE 移除完成"] title:@"remove callback"];
}

- (IBAction)addTempCallbackEvent:(id)sender {
    __block AYCallbackModel *model = [[AYCallbackModel alloc] init];
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
    
    BOOL ret = [AYBluetoothTool addCallbackBlockForDidUpdateValueForCharacteristic:model];
    
    if (ret) {
        [self.events addObject:model];
        [self.tableView reloadData];
    }
    
    double delayInSeconds = 10.0;
    
    __weak __typeof(self) weakSelf = self;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        //执行事件
        [AYBluetoothTool removeCallbackBlockByPeripheralUUID:self.currentPeripheral.identifier.UUIDString CommandType: PROTOCOL_ENUM_DEVICE_MEASURE_STATUS];
        [ISMessages showSuccessMsg:@"command 0x12 移除" title:@"dispatch_after"];
        NSLog(@"command 0x12 移除");
        [weakSelf.events removeObject:model];
        [weakSelf.tableView reloadData];
        
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


#pragma mark  tableView DataSource Delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return  self.events.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellID = @"cellID";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellID];
    }
    
    AYCallbackModel *eventModel = self.events[indexPath.row];
    cell.textLabel.text = eventModel.name;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"command:%ld", eventModel.command];
    
    return cell;
}

@end
