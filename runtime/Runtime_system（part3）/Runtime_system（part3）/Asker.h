//
//  Asker.h
//  Runtime_system（part3）
//
//  Created by 刘杨 on 15/10/1.
//  Copyright © 2015年 刘杨. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Asker : NSObject
+ (Asker *)object;

- (void)sendUnkownMessage;
@end
