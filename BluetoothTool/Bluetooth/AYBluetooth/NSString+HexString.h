//
//  NSString+HexString.h
//  BluetoothTool
//
//  Created by AlexYang on 17/3/3.
//  Copyright © 2017年 AlexYang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (HexString)

/**
 *  NSData 二进制 转 NSString
 *
 *  @param data NSData
 *
 *  @return NSString
 */
+ (instancetype)stringInHexFormatByData:(NSData *)data;
@end
