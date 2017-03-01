//
//  ISMessages+Alex.h
//  SmartBra
//
//  Created by AlexYang on 16/11/2.
//
//

#import "ISMessages.h"

@interface ISMessages (Alex)

+(void)showNetworkResultMsg:(NSString *)msg Status:(ISAlertType)status ;
+(void)showNetworkResultMsg:(NSString *)msg Status:(ISAlertType)status displayLastSeconds:(double)seconds;
+(void)showResultMsg:(NSString *)msg title:(NSString *)title Status:(ISAlertType)status ;

+(void)showErrorMsg:(NSString *)msg title:(NSString *)title ;
+(void)showSuccessMsg:(NSString *)msg title:(NSString *)title;
+(void)showWarningMsg:(NSString *)msg title:(NSString *)title;
@end
