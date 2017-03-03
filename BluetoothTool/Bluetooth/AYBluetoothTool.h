//
//  AYBluetoothTool.h
//  CNOOC
//
//  Created by AlexYang on 16/7/8.
//
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

#define PROTOCOL_LEN            20
#define BT_RESTORE_ID           @"mybluetoothrestoreid"
#define BT_AUTO_CONNECT_SWITCH  @"bluetoothautoconnectswitch"
#define BT_AUTO_DEVICE          @"bluetoothautodevice"
#define BLUETOOTH_DISCONNECT    @"bluetoothdisconnected"


#define DEVICE_SW_VERSION               @"2a26" 
#define BATTERY_LEVEL_FEATURE           @"2A19" //battery feature

@protocol AYBluetoothDelegate <NSObject>

@optional
#pragma mark - New Feb28
- ( NSDictionary *)AYBluetoothProtocolDebugInfo;


- (void)AYBluetoothCentralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI;

- (void)AYBluetoothPeripheral:(CBPeripheral *)peripheral didReadRSSI:(NSNumber *)RSSI error:(NSError *)error;

- (void)AYBluetoothCentralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral;

- (void)AYBluetoothCentralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error;

- (void)AYBluetoothCentralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error ;

- (void)AYBluetoothPeripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error;

- (void)AYBluetoothPeripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error ;

- (void)AYBluetoothPeripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(nullable NSError *)error;

//- (void)AYBluetoothPeripheral:(CBPeripheral *)peripheral didUpdateValue:(NSData *)data error:(nullable NSError *)error;

- (void)AYBluetoothPeripheral:(nonnull CBPeripheral *)peripheral didUpdateBatteryLevel:(nullable NSData *)value;
    
@end


@class AYCallbackModel;

@interface AYBluetoothTool : NSObject
@property (nonatomic , assign, nullable) id <AYBluetoothDelegate> delegate;
@property (strong, nonatomic, nullable, readonly) CBPeripheral * selectedPeripheral;


+(nullable instancetype)sharedInstance;

+ (BOOL)addCallbackBlockForDidUpdateValueForCharacteristic:(nullable AYCallbackModel *) model ;
+ (void)removeCallbackBlockByCommandType:(NSUInteger)commandType;
- (void)readRSSI;

NS_ASSUME_NONNULL_BEGIN
//connect device
- (void)connectPeripheral:(CBPeripheral *)peripheral options:(nullable NSDictionary<NSString *,id> *)options ;

//stop scan
- (void)stopScan;

//cannel connect
- (void)cannelPeripheralConnection:(CBPeripheral *)peripheral ;


//scan services
- (void)scanForPeripheralsWithServices:(nullable NSArray<CBUUID *> *)services options:(nullable NSDictionary<NSString *, id> *)options;

//auto reconnect peripheral
-(void)autoConnectPeripheralExecute;

//send command
-(BOOL)accessPeripheralByCommand:(NSData *)command;

/**
 *  query comuunicate result by receive Value
 *
 *  @param value receive from bluetooth device's communicate data
 *
 *  @return detail Info according value
 */
- (NSString *)queryBluetoothCommunicateMsgByValue:(const uint8_t)value;

// set peripheral autoConnect flag
- (void)configurePeripheral:(CBPeripheral *)peripheral ForAutoReconnect:(BOOL)autoConnect;

NS_ASSUME_NONNULL_END

@end
