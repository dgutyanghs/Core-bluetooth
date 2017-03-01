//
//  ISMessages+Alex.m
//  SmartBra
//
//  Created by AlexYang on 16/11/2.
//
//

#import "ISMessages+Alex.h"

@implementation ISMessages (Alex)

+(void)showNetworkResultMsg:(NSString *)msg Status:(ISAlertType)status {
    [ISMessages showCardAlertWithTitle:@"网络传输"
                               message:msg
                              duration:3.0f
                           hideOnSwipe:YES
                             hideOnTap:YES
                             alertType:status
                         alertPosition:ISAlertPositionTop
                               didHide:nil];
}

+(void)showNetworkResultMsg:(NSString *)msg Status:(ISAlertType)status displayLastSeconds:(double)seconds {
    [ISMessages showCardAlertWithTitle:@"网络传输"
                               message:msg
                              duration:seconds
                           hideOnSwipe:YES
                             hideOnTap:YES
                             alertType:status
                         alertPosition:ISAlertPositionTop
                               didHide:nil];
}

+(void)showResultMsg:(NSString *)msg title:(NSString *)title Status:(ISAlertType)status {
    [ISMessages showCardAlertWithTitle:title
                               message:msg
                              duration:3.0f
                           hideOnSwipe:YES
                             hideOnTap:YES
                             alertType:status
                         alertPosition:ISAlertPositionTop
                               didHide:nil];
}


+(void)showErrorMsg:(NSString *)msg title:(NSString *)title {
    [ISMessages showCardAlertWithTitle:title
                               message:msg
                              duration:3.0f
                           hideOnSwipe:YES
                             hideOnTap:YES
                             alertType:ISAlertTypeError
                         alertPosition:ISAlertPositionTop
                               didHide:nil];
}

+(void)showSuccessMsg:(NSString *)msg title:(NSString *)title {
    
    [ISMessages showCardAlertWithTitle:title
                               message:msg
                              duration:3.0f
                           hideOnSwipe:YES
                             hideOnTap:YES
                             alertType:ISAlertTypeSuccess
                         alertPosition:ISAlertPositionTop
                               didHide:nil];
}


+(void)showWarningMsg:(NSString *)msg title:(NSString *)title {
    
    [ISMessages showCardAlertWithTitle:title
                               message:msg
                              duration:8.0f
                           hideOnSwipe:YES
                             hideOnTap:YES
                             alertType:ISAlertTypeWarning
                         alertPosition:ISAlertPositionTop
                               didHide:nil];
}
@end
