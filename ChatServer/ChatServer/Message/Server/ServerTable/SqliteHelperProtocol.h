//
//  SqliteHelperProtocol.h
//  ChatServer
//
//  Created by 刘杨 on 2018/2/6.
//  Copyright © 2018年 Married. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SqliteHelperProtocol <NSObject>
- (NSString *)tableName;
- (BOOL)createTable;
- (BOOL)updateTable:(NSInteger)version;
@end
