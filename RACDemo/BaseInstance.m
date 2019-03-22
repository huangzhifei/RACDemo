//
//  BaseInstance.m
//  RACDemo
//
//  Created by huangzhifei on 2019/3/21.
//  Copyright © 2019 eric. All rights reserved.
//

#import "BaseInstance.h"

@implementation BaseInstance

+ (instancetype)shareInstance {
    static BaseInstance *_instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[BaseInstance alloc] init];
    });
    return _instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _count = 4;
        NSLog(@"%@", self);
    }
    return self;
}

@end
