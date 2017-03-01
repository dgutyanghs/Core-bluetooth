//
//  HLBluetoothTool.h
//  CNOOC
//
//  Created by AlexYang on 16/7/8.
//
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

#define PROTOCOL_LEN 20
#define BT_RestoreID  @"mybluetoothrestoreid"
#define BT_AUTO_CONNECT_SWITCH  @"bluetoothautoconnectswitch"
#define BT_AUTO_DEVICE         @"bluetoothautodevice"
#define BLUETOOTH_DISCONNECT    @"bluetoothdisconnected"


#define DEVICE_SW_VERSION               @"2a26" 
#define BATTERY_LEVEL_FEATURE           @"2A19" //battery feature



@protocol HLBluetoothDelegate <NSObject>

@optional
#pragma mark - New Feb28
- (NSDictionary *)HLBluetoothProtocolDebugInfo;


- (void)HLBluetoothNotifyWhenSensorFarfromSkin;
- (void)HLBluetoothCentralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI;
- (void)HLBluetoothPeripheral:(CBPeripheral *)peripheral didReadRSSI:(NSNumber *)RSSI error:(NSError *)error;
- (void)HLBluetoothCentralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral;
- (void)HLBluetoothCentralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error;
- (void)HLBluetoothCentralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error ;
- (void)HLBluetoothPeripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error;
- (void)HLBluetoothPeripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error ;
- (void)HLBluetoothPeripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(nullable NSError *)error;
//- (void)HLBluetoothPeripheral:(CBPeripheral *)peripheral didUpdateValue:(NSData *)data error:(nullable NSError *)error;
- (void)HLBluetoothPeripheral:(nonnull CBPeripheral *)peripheral didUpdateBatteryLevel:(nullable NSData *)value;
    
@end


@class AYCallbackModel;

@interface HLBluetoothTool : NSObject
@property (nonatomic , assign, nullable) id <HLBluetoothDelegate> delegate;
@property (strong, nonatomic, nullable, readonly) CBPeripheral * selectedPeripheral;
@property (nonatomic, assign, readonly) CBPeripheralState state;
//@property (nonatomic, strong, nullable) NSMutableArray <ay_didUpdateValueForCharacteristicBlock> *callBackTasks;
@property (nonatomic, strong, nullable) NSMutableArray <AYCallbackModel *> *callbackTasks;


+(nullable instancetype)sharedInstance;
-(void)readRSSI;

NS_ASSUME_NONNULL_BEGIN
//connect device
-(void)connectPeripheral:(CBPeripheral *)peripheral options:(nullable NSDictionary<NSString *,id> *)options ;
//stop scan
-(void)stopScan;
//cannel connect
-(void)cannelPeripheralConnection:(CBPeripheral *)peripheral ;
-(void)cannelPeripheralCurrentConnection;
//scan services
-(void)scanForPeripheralsWithServices:(nullable NSArray<CBUUID *> *)services options:(nullable NSDictionary<NSString *, id> *)options;


-(void)autoConnectPeripheralExecute;

//send command
-(BOOL)accessPeripheralByCommand:(NSData *)command;

/**
 *  query comuunicate result by receive Value
 *
 *  @param value receive from bluetooth device
 *
 *  @return detail Info according value
 */
- (NSString *)queryBluetoothCommunicateMsgByValue:(const uint8_t)value;
NS_ASSUME_NONNULL_END

//calibrate time according your phone's time
- (void)executeTimeCalibrateCommand;
@end
