//
//  ViewController.m
//  BluetoothTool
//
//  Created by AlexYang on 17/2/28.
//  Copyright © 2017年 AlexYang. All rights reserved.
//

#import "ViewController.h"
#import "HLBluetoothTool.h"
#import "HLDeviceModel.h"
#import "HLDevicesDetailCell.h"
#import "ISMessages+Alex.h"
#import "TestViewController.h"



#define SERVICE                 @"fff0" //服务
#define FEATURE_RX              @"FFF7"
#define SETTING_TX              @"FFF6"
    
#define DEVICE_INFO             @"180a" //device info 服务
#define DEVICE_SW_VERSION       @"2a26" //software 特征
#define BATTERY_LEVEL_FEATURE   @"2A19" //battery feature

typedef NS_ENUM(uint8_t, PROTOCOL_ENUM) {
    PROTOCOL_ENUM_HEART_RATE_DATA_MODE  = 0x11,
    PROTOCOL_ENUM_TIME_RECEIVE          = 0x07,
    PROTOCOL_ENUM_HRV_RR_DATA_RECEIVE   = 0x10,
    PROTOCOL_ENUM_HRV_RR_DATA_RECEIVE_HISTORY = 0x21,
    PROTOCOL_ENUM_HRV_RR_ERROR          = 0x90,
    PROTOCOL_ENUM_FACTORY_RESET         = 0x09,
    PROTOCOL_ENUM_BATTERY_INFO          = 0x03,
    PROTOCOL_ENUM_STEPS_AUTO            = 0x13,
    PROTOCOL_ENUM_STEPS_MANAUL          = 0x04,
    
    //STATUS , 1: CONNECT, 0: DISCONNECT
    PROTOCOL_ENUM_DEVICE_MEASURE_STATUS = 0x12,
    PROTOCOL_ENUM_STEPS_STATUS          = 0x06,
    PROTOCOL_ENUM_HEART_RATE_STATUS     = 0x05,
    PROTOCOL_ENUM_HEART_RATE_LINK_STATUS= 0x26,
    
    PROTOCOL_ENUM_WARNING_HR_VALUE_GET      = 0x22,
    PROTOCOL_ENUM_WARNING_HR_VALUE_SET      = 0x23,
    PROTOCOL_ENUM_DEVICE_ID_GET             = 0x24,
    PROTOCOL_ENUM_DEVICE_ID_SET             = 0x25,
    PROTOCOL_ENUM_BATTERY_LOW_WARNNING  = 0x14,
    PROTOCOL_ENUM_PERSON_INFO_SET       = 0x27,
    PROTOCOL_ENUM_PERSON_INFO_GET       = 0x28,
    PROTOCOL_ENUM_CALORIA               = 0x2C,
    PROTOCOL_ENUM_DISTANCE              = 0x2d,
    
    PROTOCOL_ENUM_HRV_RR_MANUAL_START   = 0x2f,
    PROTOCOL_ENUM_HRV_RR_MANUAL_END     = 0x2e,
    PROTOCOL_ENUM_HRV_RR_STATUS         = 0x30,
    PROTOCOL_ENUM_HRV_RR_REALTIME_NOTIFY    = 0x16,
    PROTOCOL_ENUM_HEART_RATE_REALTIME   = 0x34,
    PROTOCOL_ENUM_RR_DATA_LIST          = 0x35,
    PROTOCOL_ENUM_RR_DATA_BY_TIME       = 0x36,
    PROTOCOL_ENUM_Soft_Reset_Device     = 0x37,
    
    PROTOCOL_ENUM_DangerousWarning      = 0x17,
    PROTOCOL_ENUM_ClearRRData           = 0x39,
    
    PROTOCOL_ENUM_ModifyDeviceName      = 0x3A,
    PROTOCOL_ENUM_QueryDeviceName       = 0x3B,
    
    
    PROTOCOL_ENUM_SET_DEVICE_TIME      = 0x08,
    PROTOCOL_ENUM_GET_DEVICE_TIME      = 0x07,
    PROTOCOL_ENUM_SET_DEVICE_TIME_ERROR = 0x88,
    
};


@interface ViewController () <HLBluetoothDelegate, UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *scanBtn;
@property (weak, nonatomic) IBOutlet UIButton *stopScanBtn;
@property (nonatomic, strong) HLBluetoothTool *btClient;

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
    
    HLBluetoothTool *btClient = [HLBluetoothTool sharedInstance];
    btClient.delegate = self;
    self.btClient = btClient;
    
    [self.scanBtn addTarget:self action:@selector(scanadvertisePeripherals:) forControlEvents:UIControlEventTouchUpInside];
    [self.stopScanBtn addTarget:self action:@selector(stopScanPeripherals:) forControlEvents:UIControlEventTouchUpInside];
    
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
    HLDeviceModel * deviceModel = [HLDeviceModel deviceWithName:name UUID:peripheral.identifier.UUIDString MAC:self.peripheralDict[uuidStr] status:isConnected];
    
    HLDevicesDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    
    if (cell == nil) {
        cell = [[HLDevicesDetailCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ID];
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
    
    [self.btClient connectPeripheral:peripheral options:nil ];
}

#pragma mark HLBluetoothDelegate

- (void)HLBluetoothCentralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI {
    
//    NSString *name = peripheral.name;
    
    if (![self.advertisePeripherals containsObject:peripheral]) {
        [self.advertisePeripherals addObject:peripheral];
        //mac地址
        NSData *MACData = advertisementData[@"kCBAdvDataManufacturerData"];
        NSString *deviceMAC = [self convertDataToHexStr:MACData];
        [self.peripheralDict setObject:deviceMAC.uppercaseString forKey:peripheral.identifier.UUIDString];
        
        NSIndexPath * indexPath = [NSIndexPath indexPathForRow:self.advertisePeripherals.count - 1 inSection:0];
        [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}


- (void)HLBluetoothCentralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    
   // save the uuid string , for automatic connect
//    [[NSUserDefaults standardUserDefaults] setObject:peripheral.identifier.UUIDString forKey:BT_AUTO_DEVICE];
    
    NSString *msg = [NSString stringWithFormat:@"设备:%@" ,peripheral.name];
    [ISMessages showSuccessMsg:msg title:@"蓝牙连接成功"];
    [self.tableView reloadData];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1* NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        TestViewController *testVc = [[TestViewController alloc] init];
        [self.navigationController pushViewController:testVc animated:YES];
    });
}





/**
 *  NSData 二进制 转 NSString
 *
 *  @param data NSData
 *
 *  @return NSString
 */
- (NSString *)convertDataToHexStr:(NSData *)data {
    if (!data || [data length] == 0) {
        return @"";
    }
    NSMutableString *string = [[NSMutableString alloc] initWithCapacity:[data length]];
    
    [data enumerateByteRangesUsingBlock:^(const void *bytes, NSRange byteRange, BOOL *stop) {
        unsigned char *dataBytes = (unsigned char*)bytes;
        for (NSInteger i = 0; i < byteRange.length; i++) {
            NSString *hexStr = [NSString stringWithFormat:@"%x", (dataBytes[i]) & 0xff];
            if ([hexStr length] == 2) {
                [string appendString:hexStr];
            } else {
                [string appendFormat:@"0%@", hexStr];
            }
        }
    }];
    
    return string;
}


-(NSMutableDictionary *)peripheralDict {
    if (_peripheralDict == nil) {
        _peripheralDict = [NSMutableDictionary dictionary];
    }
    
    return _peripheralDict;
}


- (NSDictionary *)HLBluetoothProtocolDebugInfo {
    
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
        @"0x10":@"发送命令:同步当前RR数据成功",
        @"0x90":@"发送命令:同步当前RR数据失败",
        @"0x21":@"发送命令:同步历史RR数据成功",
        @"0xA1":@"发送命令:同步历史RR数据失败",
        @"0x22":@"发送命令:获取警告心率值成功",
        @"0xA2":@"发送命令:获取警告心率值失败",
        @"0x23":@"发送命令:设置警告心率值成功",
        @"0xA3":@"发送命令:设置警告心率值失败",
        @"0x24":@"发送命令:读取设备ID成功",
        @"0xA4":@"发送命令:读取设备ID失败",
        @"0x25":@"发送命令:设置设备ID成功",
        @"0xA5":@"发送命令:设置设备ID失败",
        @"0x26":@"发送命令:读取心率带连接状态成功",
        @"0xA6":@"发送命令:读取心率带连接状态失败",
        @"0x27":@"发送命令:设置私人信息成功",
        @"0xA7":@"发送命令:设置私人信息失败",
        @"0x28":@"发送命令:读取私人信息成功",
        @"0xA8":@"发送命令:读取私人信息失败",
        @"0x29":@"发送命令:设置闹钟成功",
        @"0xA9":@"发送命令:设置闹钟失败",
        @"0x2A":@"发送命令:读取闹钟成功",
        @"0xAA":@"发送命令:读取闹钟失败",
        @"0x2C":@"发送命令:获取卡路里成功",
        @"0xAC":@"发送命令:获取卡路里失败",
        @"0x2D":@"发送命令:获取距离成功",
        @"0xAD":@"发送命令:获取距离失败",
        @"0x2F":@"发送命令:手动测量RR开始成功",
        @"0xAF":@"发送命令:手动测量RR开始失败",
        @"0x2E":@"发送命令:手动测量RR结束成功",
        @"0xAE":@"发送命令:手动测量RR结束失败",
        @"0x30":@"发送命令:手动测量RR结束成功",
        @"0xBE":@"发送命令:手动测量RR结束失败",
        @"0x35":@"发送命令:获取当天RR数据分布成功",
        @"0xB5":@"发送命令:获取当天RR数据分布失败",
        
        @"0x11":@"接收Notify:心率值",
        
    };
    
    return protocolDict;
}

- (void)HLBluetoothPeripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
    
}

- (void)HLBluetoothPeripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {
    
    
    NSArray * characteristics = service.characteristics;
    for (CBCharacteristic * characteristic in characteristics) {
        if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:FEATURE_RX]]) {
            [peripheral setNotifyValue:YES forCharacteristic:characteristic];
        }
        else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:SETTING_TX]]) {
            
        } else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:DEVICE_SW_VERSION]]) {
            [peripheral readValueForCharacteristic:characteristic];
        }
    }
}

@end
