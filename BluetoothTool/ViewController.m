//
//  ViewController.m
//  BluetoothTool
//
//  Created by AlexYang on 17/2/28.
//  Copyright © 2017年 AlexYang. All rights reserved.
//

#import "ViewController.h"
#import "AYBluetoothTool.h"
#import "AYDeviceModel.h"
#import "AYDevicesDetailCell.h"
#import "ISMessages+Alex.h"
#import "TestViewController.h"
#import "const.h"
#import "NSString+HexString.h"




@interface ViewController () <AYBluetoothDelegate, UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *scanBtn;
@property (weak, nonatomic) IBOutlet UIButton *stopScanBtn;
@property (nonatomic, strong) AYBluetoothTool *btClient;

@property (nonatomic, strong) NSMutableArray *advertisePeripherals;
@property (nonatomic, strong) NSMutableDictionary *peripheralDict;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.title = @"Bluetooth Demo";
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    AYBluetoothTool *btClient = [AYBluetoothTool sharedInstance];
    btClient.delegate = self;
    self.btClient = btClient;
    
    [self.scanBtn addTarget:self action:@selector(scanadvertisePeripherals:) forControlEvents:UIControlEventTouchUpInside];
    [self.stopScanBtn addTarget:self action:@selector(stopScanPeripherals:) forControlEvents:UIControlEventTouchUpInside];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(peripheralDidDisconnect:) name:DEVICE_DISCONNECT object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:DEVICE_DISCONNECT object:nil];
}


- (void)peripheralDidDisconnect:(NSNotification *)aNotification {
    NSDictionary *userInfo = aNotification.userInfo;
    NSString *name = userInfo[DEVICE_NAME];
    NSString *uuidStr = userInfo[DEVICE_UUID_STRING];
    [self.tableView reloadData];
    [ISMessages showWarningMsg:[NSString stringWithFormat:@"设备%@(UUID:%@)断开连接", name, uuidStr] title:@"设备断开"];
}

- (NSMutableArray *)advertisePeripherals {
    if (_advertisePeripherals == nil) {
        _advertisePeripherals = [NSMutableArray array];
    }
    
    return _advertisePeripherals;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)scanadvertisePeripherals:(UIButton *)sender {
    [self.btClient scanForPeripheralsWithServices:nil options:nil];
}

- (void)stopScanPeripherals:(UIButton *)sender {
    [self.btClient stopScan];
}


#pragma mark --  UITableViewDataSource

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
      return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
      return self.advertisePeripherals.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.advertisePeripherals.count <= 0) {
        return  nil;
    }
    
    static NSString *ID = @"deviceDetailCellPopView";
    
    //从数组中取出外设
    CBPeripheral * peripheral = self.advertisePeripherals[indexPath.row];
    NSString * name = peripheral.name;
    
    BOOL isConnected = NO;
    if (peripheral.state == CBPeripheralStateConnected) {
        isConnected = YES;
    }else {
        isConnected = NO;
    }
    
    NSString *uuidStr = peripheral.identifier.UUIDString;
    AYDeviceModel * deviceModel = [AYDeviceModel deviceWithName:name UUID:peripheral.identifier.UUIDString MAC:self.peripheralDict[uuidStr] status:isConnected];
    
    AYDevicesDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    
    if (cell == nil) {
        cell = [[AYDevicesDetailCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ID];
        cell.backgroundColor = [UIColor clearColor];
        cell.textLabel.textColor = [UIColor blackColor];
        cell.detailTextLabel.textColor = [UIColor blackColor];
    }
    
    cell.deviceModel = deviceModel;
    return cell;
}



-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
     CBPeripheral * peripheral = self.advertisePeripherals[indexPath.row];
    
    NSDictionary *dict = @{CBConnectPeripheralOptionNotifyOnDisconnectionKey:@(YES), CBConnectPeripheralOptionNotifyOnNotificationKey:@(YES)};
    
    [self.btClient connectPeripheral:peripheral options:dict ];
}

#pragma mark AYBluetoothDelegate

- (void)AYBluetoothCentralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI {
    
    
    if (![self.advertisePeripherals containsObject:peripheral]) {
        [self.advertisePeripherals addObject:peripheral];
        //mac地址
        NSData *MACData = advertisementData[@"kCBAdvDataManufacturerData"];
        NSString *deviceMAC = [NSString stringInHexFormatByData:MACData];
        [self.peripheralDict setObject:deviceMAC.uppercaseString forKey:peripheral.identifier.UUIDString];
        
        NSIndexPath * indexPath = [NSIndexPath indexPathForRow:self.advertisePeripherals.count - 1 inSection:0];
        [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}


- (void)AYBluetoothCentralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    
    NSString *msg = [NSString stringWithFormat:@"设备:%@" ,peripheral.name];
    [ISMessages showSuccessMsg:msg title:@"蓝牙连接成功"];
    [self.tableView reloadData];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1* NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        TestViewController *testVc = [[TestViewController alloc] init];
        testVc.currentPeripheral = peripheral;
        [self.navigationController pushViewController:testVc animated:YES];
    });
}






-(NSMutableDictionary *)peripheralDict {
    if (_peripheralDict == nil) {
        _peripheralDict = [NSMutableDictionary dictionary];
    }
    
    return _peripheralDict;
}


- (NSDictionary *)AYBluetoothProtocolDebugInfo {
    
    NSDictionary  *protocolDict = @{
        @"0x01":@"发送命令:打开心率功能成功",
        @"0x81":@"发送命令:打开心率功能失败",
        @"0x02":@"发送命令:关闭心率功能成功",
        @"0x82":@"发送命令:关闭心率功能失败",
        @"0x03":@"发送命令:获取电量成功",
        @"0x83":@"发送命令:获取电量失败",
        @"0x04":@"发送命令:获取步数成功",
        @"0x84":@"发送命令:获取步数失败",
        @"0x05":@"发送命令:查询心率测量状态成功",
        @"0x85":@"发送命令:查询心率测量状态失败",
        @"0x06":@"发送命令:查询计步状态成功",
        @"0x86":@"发送命令:查询计步状态失败",
        @"0x07":@"发送命令:获取设备时间成功",
        @"0x87":@"发送命令:获取设备时间失败",
        @"0x08":@"发送命令:设置设备时间成功",
        @"0x88":@"发送命令:设置设备时间失败",
        @"0x09":@"发送命令:恢复出厂设置成功",
        @"0x89":@"发送命令:恢复出厂设置失败",
        @"0x11":@"接收Notify:心率值",
        
    };
    
    return protocolDict;
}


/**
 检测到peripheral的services后,的回调

 @param peripheral device
 @param error   error, default is nil
 */
- (void)AYBluetoothPeripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
    
    NSArray * services = peripheral.services;
    for (CBService * service in services) {
        if ([[[UIDevice currentDevice] systemVersion] floatValue] > 7.0) {
            NSLog(@"serviceID : 0x%@",service.UUID.UUIDString);
        }
        // 对每个service进行检测, 得到它的Characteristics,
        //函数回调 - (void)AYBluetoothPeripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error;
        [peripheral discoverCharacteristics:nil forService:service];
    }
}


/**
 上面函数中, 执行[peripheral discoverCharacteristics:nil forService:service];得到的回调
 */
- (void)AYBluetoothPeripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {
    NSArray * characteristics = service.characteristics;
    for (CBCharacteristic * characteristic in characteristics) {
        if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:FEATURE_RX]]) {
            [peripheral setNotifyValue:YES forCharacteristic:characteristic];
        }
        else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:FEATURE_TX]]) {
            
        } else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:DEVICE_SW_VERSION]]) {
            [peripheral readValueForCharacteristic:characteristic];
        }
    }
}

@end
