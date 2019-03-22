//
//  AInstance.m
//  RACDemo
//
//  Created by huangzhifei on 2019/3/21.
//  Copyright © 2019 eric. All rights reserved.
//

#import "AInstance.h"

@implementation AInstance

+ (instancetype)shareInstance {
    static AInstance *_instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[AInstance alloc] init];
    });
    return _instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        
    }
    return self;
}

@end
