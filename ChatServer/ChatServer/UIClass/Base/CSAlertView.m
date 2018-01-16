//
//  CSAlertView.m
//  ChatServer
//
//  Created by 刘杨 on 2017/11/4.
//  Copyright © 2017年 Married. All rights reserved.
//

#import "CSAlertView.h"

@implementation CSAlertView

+ (void)showAlert:(NSString *)message delay:(NSTimeInterval)delay{
    dispatch_async(dispatch_get_main_queue(), ^{
        CSAlertView *v = [[CSAlertView alloc] initWithTitle:nil message:message delegate:nil cancelButtonTitle:nil otherButtonTitles:nil, nil];
        [v show];
        [NSObject cancelPreviousPerformRequestsWithTarget:v selector:@selector(delayDismiss) object:nil];
        [v performSelector:@selector(delayDismiss) withObject:nil afterDelay:delay];
    });
}

- (void)delayDismiss{
    [self dismissWithClickedButtonIndex:0 animated:YES];
}
@end
