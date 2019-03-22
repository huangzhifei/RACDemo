//
//  BaseInstance.h
//  RACDemo
//
//  Created by huangzhifei on 2019/3/21.
//  Copyright © 2019 eric. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface BaseInstance : NSObject

@property (nonatomic, assign) NSInteger count;

+ (instancetype)shareInstance;

@end

NS_ASSUME_NONNULL_END
