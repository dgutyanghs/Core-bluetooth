//
//  AYBluetoothTool.m
//
//  Created by AlexYang on 16/7/8.
//
//

#import "AYBluetoothTool.h"
#import "ISMessages+Alex.h"
#import "AYCallbackModel.h"
#import "CBPeripheral+AutoConnect.h"


#define AY_PATH(fileName) [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:fileName]

//归档和解档宏
#define AY_ARCHIVE(object, fileName) [NSKeyedArchiver archiveRootObject:object toFile:AY_PATH(fileName)]
#define AY_UNARCHIVE(fileName) [NSKeyedUnarchiver unarchiveObjectWithFile:AY_PATH(fileName)]


#define DEVICES_AUTOCONNECT @"devices_autoconnect.out"
/**
 *  蓝牙中心管理者
 */
static CBCentralManager * _CBmgr;

static AYBluetoothTool *_instance = nil;

@interface AYBluetoothTool ()<CBCentralManagerDelegate, CBPeripheralDelegate>

@property (nonatomic , strong, nonnull) NSArray<NSString*> *resultErrors;
@property (nonatomic , strong) CBCharacteristic *featureTX;
@property (nonatomic , strong) CBCharacteristic *featureFWVersion;


/**
  属性callbackTasks的任务, 在下面函数被调用.
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(nullable NSError *)error ;
 */
@property (nonatomic, strong, nullable) NSMutableArray <AYCallbackModel *> *callbackTasks;

/**
 自动重连的CBPeripheral 的identify.uuidstring list
 */
@property (nonatomic, strong) NSMutableArray <NSString *> *autoConnectIdentifies;

@property (nonatomic, strong) NSMutableArray <CBPeripheral *> *connectedPeripherals;
@property (nonatomic, strong) NSMutableArray <CBPeripheral *> *allPeripherals;

/**
 *  用户的自定蓝牙通讯 protocol, 用户每次发出蓝牙command时,可打印执行后相关结果.
   说明: AYBluetoothTool初始化时, 会检测用户是否实现delegate了方法 .
    - ( NSDictionary *)AYBluetoothProtocolDebugInfo;
 */
@property (nonatomic, strong) NSDictionary *msgDict;

@end

@implementation AYBluetoothTool

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
        _instance = [[AYBluetoothTool alloc] init];
        _instance.callbackTasks  = [NSMutableArray array];
        if (_CBmgr == nil) {
            _CBmgr = [[CBCentralManager alloc] initWithDelegate:_instance queue:nil options:@{CBCentralManagerOptionRestoreIdentifierKey:BT_RESTORE_ID}];
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


/**
  remove the tasks in the callbacktasks array
 
 @param uuidString peripheral uuidstring 
 @param commandType       if commandType is 0xFFFFFFFF, then call all tasks for this peripheral 
 */
+ (void)removeCallbackBlockByPeripheralUUID:(NSString *)uuidString CommandType:(NSUInteger)commandType{
    if (_instance == nil || _instance.callbackTasks.count == 0) {
        return;
    }
    
    if (uuidString == nil) {
        NSLog(@"error, uuidString is nil");
        return;
    }
    
    for (int i = 0; i < _instance.callbackTasks.count; i++) {
        AYCallbackModel *model = _instance.callbackTasks[i];
        if (commandType == ANY_COMMAND_TYPE) {
            if ([model.uuidString isEqualToString:uuidString]) {
                [_instance.callbackTasks removeObject:model];
                NSLog(@"remove peripheral:%@ all callbacktask", uuidString);
            }
        }else if ((model.command == commandType) && [model.uuidString isEqualToString:uuidString]) {
            [_instance.callbackTasks removeObject:model];
        }
    }
    
//    for (AYCallbackModel *model in _instance.callbackTasks) {
//        if (commandType == ANY_COMMAND_TYPE) {
//            if ([model.uuidString isEqualToString:uuidString]) {
//                [_instance.callbackTasks removeObject:model];
//            }
//        }else if ((model.command == commandType) && [model.uuidString isEqualToString:uuidString]) {
//            [_instance.callbackTasks removeObject:model];
//        }
//    }
}

#pragma mark - bluetooth scan 
-(void)centralManagerDidUpdateState:(CBCentralManager *)central {
    
    if (central.state == CBCentralManagerStatePoweredOn) {
        NSLog(@"蓝牙开启，准备扫描连接");
        [self scanForPeripheralsWithServices:nil options:nil];
        
        for (CBPeripheral *peripheral in self.connectedPeripherals) {
            if (peripheral.state != CBPeripheralStateConnected) {
                [self connectPeripheral:peripheral options:nil];
            }
        }
    }else {
        NSLog(@"蓝牙未打开,或其他");
        [self.connectedPeripherals removeAllObjects];
    }
}


- (void)centralManager:(CBCentralManager *)central willRestoreState:(NSDictionary<NSString *, id> *)dict {
    NSLog(@"blue test restoreState:%@", dict.debugDescription);
    NSArray *peripherals = dict[CBCentralManagerRestoredStatePeripheralsKey];
    for (CBPeripheral *peripheral in peripherals) {
        [self.connectedPeripherals addObject:peripheral];
        peripheral.delegate = self;
    }
    
    [self scanForPeripheralsWithServices:nil options:nil];
    
    
//    [self autoConnectPeripheralExecute];
    
}


- (NSMutableArray<CBPeripheral *> *)allPeripherals {
    if (_allPeripherals == nil) {
        _allPeripherals = [NSMutableArray array];
    }
    
    return _allPeripherals;
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
    
    if ([self.delegate respondsToSelector:@selector(AYBluetoothCentralManager:didDiscoverPeripheral:advertisementData:RSSI:)]) {
        [self.delegate AYBluetoothCentralManager:central didDiscoverPeripheral:peripheral advertisementData:advertisementData RSSI:RSSI];
    }
    
}

#pragma mark - RSSI 回调

-(void)peripheral:(CBPeripheral *)peripheral didReadRSSI:(NSNumber *)RSSI error:(NSError *)error {
    if (error) {
        NSLog(@"%@", error.description);
    }else {
//        NSLog(@"device:%@ RSSI:%d", peripheral.name, RSSI.intValue);
        if ([self.delegate respondsToSelector:@selector(AYBluetoothPeripheral:didReadRSSI:error:)]) {
            [self.delegate AYBluetoothPeripheral:peripheral didReadRSSI:RSSI error:error];
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
    peripheral.autoConnect = YES; //自动连接开启
    
    NSString *uuidStr = peripheral.identifier.UUIDString;
    if (![self.autoConnectIdentifies containsObject:uuidStr]) {
        [self.autoConnectIdentifies addObject:uuidStr];
        AY_ARCHIVE(self.autoConnectIdentifies, DEVICES_AUTOCONNECT);
    }
    
    [self.connectedPeripherals addObject:peripheral];
    
    [peripheral discoverServices:nil];
    [peripheral readRSSI];
    
    if ([self.delegate respondsToSelector:@selector(AYBluetoothCentralManager:didConnectPeripheral:)]) {
        [self.delegate AYBluetoothCentralManager:central didConnectPeripheral:peripheral ];
    }
    
    
}


- (NSMutableArray *)autoConnectIdentifies {
    
    if (_autoConnectIdentifies == nil) {
        _autoConnectIdentifies = AY_UNARCHIVE(DEVICES_AUTOCONNECT);
        if (_autoConnectIdentifies == nil) {
            _autoConnectIdentifies = [NSMutableArray array];
        }
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
    [self.connectedPeripherals removeObject:peripheral];
    
    if ([self.delegate respondsToSelector:@selector(AYBluetoothCentralManager:didDisconnectPeripheral:error:)]) {
        [self.delegate AYBluetoothCentralManager:central didDisconnectPeripheral:peripheral error:error];
    }
    
    [AYBluetoothTool removeCallbackBlockByPeripheralUUID:peripheral.identifier.UUIDString CommandType:ANY_COMMAND_TYPE];
    
    NSDictionary *dict = @{DEVICE_NAME:peripheral.name, DEVICE_UUID_STRING:peripheral.identifier.UUIDString};
    [[NSNotificationCenter defaultCenter] postNotificationName:DEVICE_DISCONNECT object:nil userInfo:dict];
    _selectedPeripheral = nil;
    
    NSLog(@"disconnect error :%@",error.debugDescription);
    if (error == nil) {
        //用户主动断开连接, 不执行auto connect
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
    
    if ([self.delegate respondsToSelector:@selector(AYBluetoothPeripheral:didDiscoverServices:)]) {
        [self.delegate AYBluetoothPeripheral:peripheral didDiscoverServices:error];
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
    
    NSArray * characteristics = service.characteristics;
    for (CBCharacteristic * characteristic in characteristics) {
        if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:FEATURE_RX]]) {
            [peripheral setNotifyValue:YES forCharacteristic:characteristic];
        }
        else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:FEATURE_TX]]) {
            self.featureTX = characteristic;
        } else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:DEVICE_SW_VERSION]]) {
            [peripheral readValueForCharacteristic:characteristic];
        }
    }
    
    
    if ([self.delegate respondsToSelector:@selector(AYBluetoothPeripheral:didDiscoverCharacteristicsForService:error:)]) {
        [self.delegate AYBluetoothPeripheral:peripheral didDiscoverCharacteristicsForService:service error:error];
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
        if ([self.delegate respondsToSelector:@selector(AYBluetoothPeripheral:didUpdateBatteryLevel:)]) {
            [self.delegate AYBluetoothPeripheral:peripheral didUpdateBatteryLevel:data];
            return;
        }
    }
    
    if (characteristic == self.featureFWVersion) {
        NSString *sw = [NSString stringWithFormat:@"%s", ptr];
        NSLog(@"sw:%@", sw);
        return;
    }
    
    
    NSUInteger dataType = ptr[0];
    
//    if (self.msgDict != nil) {
        NSString *retStr = [self queryBluetoothCommunicateMsgByValue:ptr[0]];
        NSLog(@"%@", retStr);
//    }
    
    //callback
    for (AYCallbackModel *model in self.callbackTasks) {
        if ((model.command != dataType) || (![model.uuidString isEqualToString: peripheral.identifier.UUIDString])) {
            continue;
        }else {
            if (model.block) {
                model.block(characteristic, error);
            }
        }
    }
    
    
    
    if ([self.delegate respondsToSelector:@selector(AYBluetoothPeripheral:didUpdateValueForCharacteristic:error:)]) {
        [self.delegate AYBluetoothPeripheral:peripheral didUpdateValueForCharacteristic:characteristic error:error];
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
    NSLog(@"recieve AY data:%@", logStr);
}


-(void)AYBluetoothReadRSSI {
    
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
    
    if (peripherals.count) {
        for (CBPeripheral *peripheral in peripherals) {
            if (peripheral.state != CBPeripheralStateConnected) {
                [self connectPeripheral:peripheral options:nil];
            }
        }
    }else {
        [self scanForPeripheralsWithServices:nil options:nil];
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



- (NSString *)queryBluetoothCommunicateMsgByValue:(const uint8_t)value {
    if (self.msgDict == nil) {
        if ([self.delegate respondsToSelector:@selector(AYBluetoothProtocolDebugInfo)]) {
            _msgDict = [self.delegate AYBluetoothProtocolDebugInfo];
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
