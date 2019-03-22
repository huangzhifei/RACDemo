//
//  BInstance.m
//  RACDemo
//
//  Created by huangzhifei on 2019/3/21.
//  Copyright © 2019 eric. All rights reserved.
//

#import "BInstance.h"

@implementation BInstance

+ (instancetype)shareInstance {
    static BInstance *_instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[BInstance alloc] init];
    });
    return _instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.count = 5;
    }
    return self;
}

@end
