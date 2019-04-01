//
//  ViewController+AViewControllerCategory.m
//  RACDemo
//
//  Created by huangzhifei on 2019/4/1.
//  Copyright © 2019 eric. All rights reserved.
//

#import "ViewController+AViewControllerCategory.h"
#import "NSObject+InvokeOriginalMethod.h"

@implementation ViewController (AViewControllerCategory)

- (void)viewDidLoad {
    
    NSLog(@"AViewControllerCategory %@", NSStringFromSelector(_cmd));
    self.view.tag = 1;
    [NSObject invokeOriginalMethod:self selector:_cmd];
}

@end
