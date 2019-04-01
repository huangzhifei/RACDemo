//
//  NSObject+InvokeOriginalMethod.h
//  RACDemo
//
//  Created by huangzhifei on 2019/4/1.
//  Copyright © 2019 eric. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (InvokeOriginalMethod)

+ (void *)invokeOriginalMethod:(id)target selector:(SEL)selector;

@end

NS_ASSUME_NONNULL_END
