//
//  NSObject+InvokeOriginalMethod.m
//  RACDemo
//
//  Created by huangzhifei on 2019/4/1.
//  Copyright © 2019 eric. All rights reserved.
//

#import "NSObject+InvokeOriginalMethod.h"
#include <objc/runtime.h>

@implementation NSObject (InvokeOriginalMethod)

+ (void *)invokeOriginalMethod:(id)target selector:(SEL)selector {
    void *result = NULL;

    // Get the class method list
    uint count;
    Method *methodList = class_copyMethodList([target class], &count);

    // check the number of same name
    int number = 0;
    for (int i = 0; i < count; i++) {
        Method method = methodList[i];
        SEL name = method_getName(method);
        if (name == selector) {
            number++;
        }
    }

    // if only one (just itself), then call super, forbid recursively call.
    if (number == 1) {
        IMP implementation = [self getSuperClassImplementation:target selector:selector];
        // id (*IMP)(id, SEL, ...)
        result = ((void *(*) (id, SEL)) implementation)(target, selector);
    } else {
        // Call original method . Note here take the last same name method as the original method
        for (int i = count - 1; i >= 0; i--) {
            Method method = methodList[i];
            SEL name = method_getName(method);
            IMP implementation = method_getImplementation(method);
            if (selector == name) {
                // id (*IMP)(id, SEL, ...)
                result = ((void *(*) (id, SEL)) implementation)(target, selector);
                break;
            }
        }
    }

    free(methodList);
    return result;
}

+ (IMP)getSuperClassImplementation:(id)target selector:(SEL)selector {
    IMP implementation = NULL;
    Class superClazz = [target superclass];
    while (superClazz) {
        uint count;
        Method *methodList = class_copyMethodList(superClazz, &count);
        for (int i = 0; i < count; i++) {
            Method method = methodList[i];
            SEL name = method_getName(method);
            if (name == selector) {
                implementation = method_getImplementation(method);
                break;
            }
        }
        if (implementation) {
            break;
        } else {
            superClazz = [superClazz superclass];
        }
    }
    return implementation;
}

@end
