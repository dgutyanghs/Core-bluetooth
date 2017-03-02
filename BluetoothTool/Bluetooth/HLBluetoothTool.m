//
//  HLBluetoothTool.m
//
//  Created by AlexYang on 16/7/8.
//
//

#import "HLBluetoothTool.h"
#import "ISMessages+Alex.h"
#import "AYCallbackModel.h"
#import "CBPeripheral+AutoConnect.h"


/**
 *  蓝牙中心管理者
 */
static CBCentralManager * _CBmgr;

static HLBluetoothTool *_instance = nil;

@interface HLBluetoothTool ()<CBCentralManagerDelegate, CBPeripheralDelegate>

@property (nonatomic , strong, nonnull) NSArray<NSString*> *resultErrors;
@property (nonatomic , strong) CBCharacteristic *featureRX;
@property (nonatomic , strong) CBCharacteristic *featureTX;
@property (nonatomic , strong) CBCharacteristic *featureFWVersion;


/**
 callbackTasks的任务, 在下面函数被调用. 
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(nullable NSError *)error ;
 */
@property (nonatomic, strong, nullable) NSMutableArray <AYCallbackModel *> *callbackTasks;

/**
 自动重连的CBPeripheral 的identify.uuidstring list
 */
@property (nonatomic, strong) NSMutableArray <NSString *> *autoConnectIdentifies;

@property (nonatomic, strong) NSMutableArray <CBPeripheral *> *connectedPeripherals;

/**
 *  用户的自定蓝牙 protocol, 每次执行,可打印相关结果. 
 */
@property (nonatomic, strong) NSDictionary *msgDict;

@end

@implementation HLBluetoothTool

+(id)allocWithZone:(struct _NSZone *)zone{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [super allocWithZone:zone];
    });
    return _instance;
}

+(instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[HLBluetoothTool alloc] init];
        _instance.callbackTasks  = [NSMutableArray array];
        if (_CBmgr == nil) {
            _CBmgr = [[CBCentralManager alloc] initWithDelegate:_instance queue:nil options:@{CBCentralManagerOptionRestoreIdentifierKey:BT_RestoreID}];
        }
    });
    return _instance;
}

-(id)copyWithZone:(NSZone *)zone{
    return _instance;
}


+ (BOOL)addCallbackBlockForDidUpdateValueForCharacteristic:(AYCallbackModel *) model {
    if (_instance == nil) {
        return NO;
    }
    
    if ([_instance.callbackTasks containsObject:model]) {
        return YES;
    }else {
        [_instance.callbackTasks addObject:model];
    }
    
    return YES;
}

+ (void)removeCallbackBlockByCommandType:(NSUInteger)commandType{
    if (_instance == nil) {
        return;
    }
    
    for (AYCallbackModel *model in _instance.callbackTasks) {
        if (model.command == commandType) {
            [_instance.callbackTasks removeObject:model];
        }
    }
}

#pragma mark - bluetooth scan 
-(void)centralManagerDidUpdateState:(CBCentralManager *)central {
    switch (central.state) {
        case CBCentralManagerStatePoweredOn:
            NSLog(@"蓝牙开启，准备扫描连接");
            [self autoConnectPeripheralExecute];
            break;
        case CBCentralManagerStatePoweredOff:
            NSLog(@"蓝牙未打开");
            break;
        case CBCentralManagerStateUnsupported:
            NSLog(@"设备不支持蓝牙4.0!");
            break;
        case CBCentralManagerStateUnauthorized:
            NSLog(@"设备未授权!");
            break;
        default:
            NSLog(@"未知状态！");
            break;
    }
}


- (void)centralManager:(CBCentralManager *)central willRestoreState:(NSDictionary<NSString *, id> *)dict {
    NSLog(@"blue test restoreState:%@", dict.debugDescription);
    NSArray *peripherals = dict[CBCentralManagerRestoredStatePeripheralsKey];
    
    for (CBPeripheral *peripheral in peripherals) {
        peripheral.delegate = self;
    }
    
}



#pragma mark - CBCentralManagerDelegate
/**
 *  发现外设后调用
 *
 *  @param central           中心设备
 *  @param peripheral        外设
 *  @param advertisementData 广播信息
 *  @param RSSI              信号强度
 */

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    NSLog(@"\n发现外设 %@ ", advertisementData.debugDescription);
    
    if ([self.delegate respondsToSelector:@selector(HLBluetoothCentralManager:didDiscoverPeripheral:advertisementData:RSSI:)]) {
        [self.delegate HLBluetoothCentralManager:central didDiscoverPeripheral:peripheral advertisementData:advertisementData RSSI:RSSI];
    }
    
}

#pragma mark - RSSI 回调

-(void)peripheral:(CBPeripheral *)peripheral didReadRSSI:(NSNumber *)RSSI error:(NSError *)error {
    if (error) {
        NSLog(@"%@", error.description);
    }else {
//        NSLog(@"device:%@ RSSI:%d", peripheral.name, RSSI.intValue);
        if ([self.delegate respondsToSelector:@selector(HLBluetoothPeripheral:didReadRSSI:error:)]) {
            [self.delegate HLBluetoothPeripheral:peripheral didReadRSSI:RSSI error:error];
        }
    }
}
/**
 *  连接外设成功后调用
 *
 *  @param central    中心设备
 *  @param peripheral 外设
 */
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    peripheral.delegate = self;
//    _selectedPeripheral = peripheral;
    peripheral.autoConnect = YES;
    [self.autoConnectIdentifies addObject:peripheral.identifier.UUIDString];
    [self.connectedPeripherals addObject:peripheral];
    
    [peripheral discoverServices:nil];
    [peripheral readRSSI];
    
    if ([self.delegate respondsToSelector:@selector(HLBluetoothCentralManager:didConnectPeripheral:)]) {
        [self.delegate HLBluetoothCentralManager:central didConnectPeripheral:peripheral ];
    }
    
    
}


- (NSMutableArray *)autoConnectIdentifies {
    if (_autoConnectIdentifies == nil) {
        _autoConnectIdentifies = [NSMutableArray array];
    }
    
    return _autoConnectIdentifies;
}

- (NSMutableArray<CBPeripheral *> *)connectedPeripherals {
    if (_connectedPeripherals == nil) {
        _connectedPeripherals = [NSMutableArray array];
    }
    return _connectedPeripherals;
}

/*
*  连接外设失败后调用
*
*  @param central    中心设备
*  @param peripheral 外设
*  @param error      错误信息
*/
- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    NSLog(@"主动连接设备失败");
}

/**
 *  外设断开连接后调用
 *
 *  @param central    中心设备，一般是手机
 *  @param peripheral 外设
 *  @param error      错误信息
 */
- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    
    if ([self.delegate respondsToSelector:@selector(HLBluetoothCentralManager:didDisconnectPeripheral:error:)]) {
        [self.delegate HLBluetoothCentralManager:central didDisconnectPeripheral:peripheral error:error];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:BLUETOOTH_DISCONNECT object:nil];
    _selectedPeripheral = nil;
    
    NSLog(@"disconnect error :%@",error.debugDescription);
    if (error == nil) {
        //用户主动断开连接
    }else {
        [self autoConnectPeripheralExecute];
    }
}


#pragma mark - CBPeripheralDelegate

/**
 *  发现外设的服务后调用
 *
 *  @param peripheral 外设
 *  @param error      错误信息
 */
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
    
    NSArray * services = peripheral.services;
    if ([self.delegate respondsToSelector:@selector(HLBluetoothPeripheral:didDiscoverServices:)]) {
        [self.delegate HLBluetoothPeripheral:peripheral didDiscoverServices:error];
    }
    
    
    for (CBService * service in services) {
        if ([[[UIDevice currentDevice] systemVersion] floatValue] > 7.0) {
            NSLog(@"serviceID : 0x%@",service.UUID.UUIDString);
        }
        [peripheral discoverCharacteristics:nil forService:service];
        
    }
}

/**
 *  发现某个外设特定服务中的特征会调用
 *
 *  @param peripheral 特征所属的外设
 *  @param service    特征所属的服务
 *  @param error      错误信息
 */
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {
    
    if ([self.delegate respondsToSelector:@selector(HLBluetoothPeripheral:didDiscoverCharacteristicsForService:error:)]) {
        [self.delegate HLBluetoothPeripheral:peripheral didDiscoverCharacteristicsForService:service error:error];
    }
}



- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(nullable NSError *)error {
    
    NSData *data = nil;
    const unsigned char *ptr = NULL;

    data = characteristic.value;
    ptr = [data bytes];
    
//    [self logPeripheralData:data];
    
    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:BATTERY_LEVEL_FEATURE]]) {
        NSLog(@"get battery update :%@", characteristic.debugDescription);
        if ([self.delegate respondsToSelector:@selector(HLBluetoothPeripheral:didUpdateBatteryLevel:)]) {
            [self.delegate HLBluetoothPeripheral:peripheral didUpdateBatteryLevel:data];
            return;
        }
    }
    
    if (characteristic == self.featureFWVersion) {
        NSString *sw = [NSString stringWithFormat:@"%s", ptr];
        NSLog(@"sw:%@", sw);
        return;
    }
    
    
    NSUInteger dataType = ptr[0];
    //callback
    for (AYCallbackModel *model in self.callbackTasks) {
        if (model.command != dataType) {
            continue;
        }else {
            if (model.block) {
                model.block(characteristic, error);
            }
        }
    }
    
    
    
    if ([self.delegate respondsToSelector:@selector(HLBluetoothPeripheral:didUpdateValueForCharacteristic:error:)]) {
        [self.delegate HLBluetoothPeripheral:peripheral didUpdateValueForCharacteristic:characteristic error:error];
    }
}




-(void)logPeripheralData:(NSData *)data {
    NSString *logStr = [NSString string];
    const unsigned char *temp = [data bytes];
    unsigned long len = [data length];
    
    for (int i = 0; i < len ; i++) {
        logStr = [logStr stringByAppendingFormat:@"0x%.2x ", *temp];
        temp++;
    }
    NSLog(@"recieve HL data:%@", logStr);
}


-(BOOL)calibrateReceivedData:(const unsigned char *)ptr {
    uint8_t sum = 0;
    uint8_t checksumReceived = ptr[PROTOCOL_LEN -1];
    for (int i = 0; i < PROTOCOL_LEN - 1; i++) {
        sum += ptr[i];
    }
    
    return (sum == checksumReceived) ? true:false;
}

-(void)HLBluetoothReadRSSI {
    
    if (self.selectedPeripheral.state == CBPeripheralStateConnected) {
        [self.selectedPeripheral readRSSI];
    }
}

#pragma mark -- bluetooth  start scan
- (void)connectPeripheral:(CBPeripheral *)peripheral options:(nullable NSDictionary<NSString *,id> *)options {
    [_CBmgr connectPeripheral:peripheral options:options];
}

- (void)stopScan {
    [_CBmgr stopScan];
}

- (void)cannelPeripheralConnection:(CBPeripheral *)peripheral {
    [_CBmgr cancelPeripheralConnection:peripheral];
}

- (void)cannelPeripheralCurrentConnection {
    if (self.selectedPeripheral.state == CBPeripheralStateConnected) {
        [_CBmgr cancelPeripheralConnection:self.selectedPeripheral];
    }
}

- (void)scanForPeripheralsWithServices:(nullable NSArray<CBUUID *> *)services options:(nullable NSDictionary<NSString *, id> *)options {
    [_CBmgr scanForPeripheralsWithServices:services options:options];
}


/**
  自动连接到, 已开启AutoConnect属性的CBPeripheral
 */
- (void)autoConnectPeripheralExecute {
    
    NSMutableArray *identifiers = [NSMutableArray arrayWithCapacity:self.autoConnectIdentifies.count];
    for (NSString *uuidString in self.autoConnectIdentifies) {
        NSUUID *identify = [[NSUUID alloc] initWithUUIDString:uuidString];
        [identifiers addObject:identify];
    }
    
    NSArray *peripherals = [_CBmgr retrievePeripheralsWithIdentifiers:identifiers];
    [peripherals enumerateObjectsUsingBlock:^(CBPeripheral *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSLog(@"retrievePeripheral:idx:%ld, name:%@, uuid:%@",idx, obj.name, obj.identifier.UUIDString);
    }];
    
    for (CBPeripheral *peripheral in peripherals) {
        [self connectPeripheral:peripheral options:nil];
    }
}





- (BOOL)accessPeripheral:(CBPeripheral *)peripheral ByCommand:(NSData *)command  {
    if (peripheral.state != CBPeripheralStateConnected) {
        NSLog(@"设备没连接");
        return false;
    }
    
    NSAssert(self.featureTX, @"featureTx is nil");
    
    [peripheral writeValue:command forCharacteristic:self.featureTX type:CBCharacteristicWriteWithResponse];
    
    return true;
}


- (CBPeripheralState)state {
    return self.selectedPeripheral.state;
}


- (NSString *)queryBluetoothCommunicateMsgByValue:(const uint8_t)value {
    if (self.msgDict == nil) {
        if ([self.delegate respondsToSelector:@selector(HLBluetoothProtocolDebugInfo)]) {
            _msgDict = [self.delegate HLBluetoothProtocolDebugInfo];
        }
        
        if (_msgDict == nil) {
            return nil;
        }
    }
    
    NSString *msgKey    = [NSString stringWithFormat:@"0x%.2x",value];
    NSString *temp      = [msgKey uppercaseString];
    NSString *msgInfo   = [self.msgDict valueForKey:temp];
    
    return msgInfo;
};



- (void)configurePeripheral:(CBPeripheral *)peripheral ForAutoReconnect:(BOOL)autoConnect {
    if (peripheral == nil) {
        return;
    }
    
    peripheral.autoConnect = autoConnect;
    
    NSString *identfyStr = peripheral.identifier.UUIDString;
    if (autoConnect) {
        if ([self.autoConnectIdentifies containsObject:identfyStr]) {
            return;
        }else {
            [self.autoConnectIdentifies addObject:identfyStr];
        }
    }else {
        [self.autoConnectIdentifies removeObject:identfyStr];
    }
    
}
@end
