//
//  UIColor+Help.m
//  Tuotuo
//
//  Created by yangyong on 14-4-28.
//  Copyright (c) 2014年 gainline. All rights reserved.
//

#import "UIColor+Help.h"

@implementation UIColor (Help)

+ (UIColor*) colorWithHex:(NSInteger)hexValue alpha:(CGFloat)alphaValue
{
    return [UIColor colorWithRed:((float)((hexValue & 0xFF0000) >> 16))/255.0
                           green:((float)((hexValue & 0xFF00) >> 8))/255.0
                            blue:((float)(hexValue & 0xFF))/255.0 alpha:alphaValue];
}

+ (UIColor*) colorWithHex:(NSInteger)hexValue
{
    return [UIColor colorWithHex:hexValue alpha:1.0];
}

+ (NSString *) hexFromUIColor: (UIColor*) color {
    if (CGColorGetNumberOfComponents(color.CGColor) < 4) {
        const CGFloat *components = CGColorGetComponents(color.CGColor);
        color = [UIColor colorWithRed:components[0]
                                green:components[0]
                                 blue:components[0]
                                alpha:components[1]];
    }
    
    if (CGColorSpaceGetModel(CGColorGetColorSpace(color.CGColor)) != kCGColorSpaceModelRGB) {
        return [NSString stringWithFormat:@"#FFFFFF"];
    }
    
    return [NSString stringWithFormat:@"#%x%x%x", (int)((CGColorGetComponents(color.CGColor))[0]*255.0),
            (int)((CGColorGetComponents(color.CGColor))[1]*255.0),
            (int)((CGColorGetComponents(color.CGColor))[2]*255.0)];
}


+ (CGFloat) colorComponentFrom: (NSString *) string start: (NSUInteger) start length: (NSUInteger) length

{
    
    NSString *substring = [string substringWithRange: NSMakeRange(start, length)];
    
    NSString *fullHex = length == 2 ? substring : [NSString stringWithFormat: @"%@%@", substring, substring];
    
    unsigned hexComponent;
    
    [[NSScanner scannerWithString: fullHex] scanHexInt: &hexComponent];
    
    return hexComponent / 255.0;
    
}



+ (UIColor *) colorWithHexString: (NSString *) hexString

{
    
    NSString *colorString = [[hexString stringByReplacingOccurrencesOfString: @"#"withString: @""] uppercaseString];
    
    CGFloat alpha, red, blue, green;
    
    switch ([colorString length]) {
            
        case 3: // #RGB
            
            alpha = 1.0f;
            
            red   = [self colorComponentFrom: colorString start: 0 length: 1];
            
            green = [self colorComponentFrom: colorString start: 1 length: 1];
            
            blue  = [self colorComponentFrom: colorString start: 2 length: 1];
            
            break;
            
        case 4: // #ARGB
            
            alpha = [self colorComponentFrom: colorString start: 0 length: 1];
            
            red   = [self colorComponentFrom: colorString start: 1 length: 1];
            
            green = [self colorComponentFrom: colorString start: 2 length: 1];
            
            blue  = [self colorComponentFrom: colorString start: 3 length: 1];
            
            break;
            
        case 6: // #RRGGBB
            
            alpha = 1.0f;
            
            red   = [self colorComponentFrom: colorString start: 0 length: 2];
            
            green = [self colorComponentFrom: colorString start: 2 length: 2];
            
            blue  = [self colorComponentFrom: colorString start: 4 length: 2];
            
            break;
            
        case 8: // #AARRGGBB
            
            alpha = [self colorComponentFrom: colorString start: 0 length: 2];
            
            red   = [self colorComponentFrom: colorString start: 2 length: 2];
            
            green = [self colorComponentFrom: colorString start: 4 length: 2];
            
            blue  = [self colorComponentFrom: colorString start: 6 length: 2];
            
            break;
            
        default:
            
            [NSException raise:@"Invalid color value" format: @"Color value %@ is invalid.  It should be a hex value of the form #RBG, #ARGB, #RRGGBB, or #AARRGGBB", hexString];
            
            break;
            
    }
    
    return [UIColor colorWithRed: red green: green blue: blue alpha: alpha];
    
}


+(instancetype)blackColorHL1 {
    UIColor *color = [UIColor colorWithRed:28/255.0 green:27/255.0 blue:37/255.0 alpha:1.0];
    return color;
}

+(instancetype)blackColorHL2{
    UIColor *color = [UIColor colorWithRed:24/255.0 green:23/255.0 blue:33/255.0 alpha:1.0];
    return color;
}

+(instancetype)blackColorBG {
    UIColor *color = [UIColor colorWithHex:0x2f3239];
    return color;
}

+(instancetype)grayColorHL1 {
    UIColor *color = [UIColor colorWithRed:86/255.0 green:84/255.0 blue:104/255.0 alpha:1.0];
    return color;
}

+(instancetype)cyanColorHL1{
    UIColor *color = [UIColor colorWithRed:19/255.0 green:150/255.0 blue:206/255.0 alpha:1.0];
    return color;
}


+(instancetype)seperateLineColor{
    UIColor *color = [UIColor colorWithHex:0xececec];
    return color;
}


+(instancetype)grayLabelColor{
    UIColor *color = [UIColor colorWithHex:0x5e626c];
    return color;
}


+(instancetype)blackColorHL_New {
    UIColor *color = [UIColor colorWithRed:46/255.0 green:51/255.0 blue:58/255.0 alpha:1.0];
    return color;
}


+(instancetype)cyanColorHL_New {
    UIColor *color = [UIColor colorWithHex:0x07ccae];
    return color;
}


+(instancetype)grayColorHL_New {
    UIColor *color = [UIColor colorWithRed:81/255.0 green:87/255.0 blue:101/255.0 alpha:1.0];
    return color;
}
@end
