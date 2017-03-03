//
//  const.h
//  BluetoothTool
//
//  Created by AlexYang on 17/3/3.
//  Copyright © 2017年 AlexYang. All rights reserved.
//

#ifndef const_h
#define const_h


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
};

#endif /* const_h */
